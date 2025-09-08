from django.http import JsonResponse, HttpResponse
from django.contrib.auth import get_user_model
from django.db import transaction
from rest_framework import generics, permissions, status, viewsets, filters
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from django_filters.rest_framework import DjangoFilterBackend
from .models import UserProfile, UserActivity, Account, Category, Transaction, Budget, Goal, GoalContribution, Insight
from .serializers import UserProfileSerializer, PreferencesSerializer, AccountSerializer, CategorySerializer, TransactionSerializer, BudgetSerializer
from .permissions import HasMobileApiKey, IsOwnerOnly
import json


User = get_user_model()


class HealthView(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request):
        return Response({"status": "ok"})


class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated, HasMobileApiKey]

    def get_object(self):
        profile, _ = UserProfile.objects.get_or_create(user=self.request.user)
        return profile


class PreferencesView(APIView):
    permission_classes = [permissions.IsAuthenticated, HasMobileApiKey]

    def get(self, request):
        profile, _ = UserProfile.objects.get_or_create(user=request.user)
        return Response({"preferences": profile.preferences})

    def put(self, request):
        serializer = PreferencesSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        profile, _ = UserProfile.objects.get_or_create(user=request.user)
        profile.preferences = serializer.validated_data["preferences"]
        profile.save(update_fields=["preferences", "updated_at"])
        return Response({"preferences": profile.preferences})


class ExportDataView(APIView):
    permission_classes = [permissions.IsAuthenticated, HasMobileApiKey]

    def get(self, request):
        # Simple JSON export of the user's data
        user = request.user
        data = {
            "profile": UserProfileSerializer(UserProfile.objects.get_or_create(user=user)[0]).data,
            "accounts": list(Account.objects.filter(user=user).values()),
            "categories": list(Category.objects.filter(user=user).values()),
            "budgets": list(Budget.objects.filter(user=user).values()),
            "transactions": list(Transaction.objects.filter(user=user).values()),
            "goals": list(Goal.objects.filter(user=user).values()),
            "goal_contributions": list(GoalContribution.objects.filter(goal__user=user).values()),
            "insights": list(Insight.objects.filter(user=user).values()),
        }
        response = HttpResponse(json.dumps(data, default=str), content_type='application/json')
        response['Content-Disposition'] = 'attachment; filename="budgetbuddy_export.json"'
        return response


class DeleteAccountView(APIView):
    permission_classes = [permissions.IsAuthenticated, HasMobileApiKey]

    @transaction.atomic
    def delete(self, request):
        # Hard-delete all user data (app data); you may want to anonymize instead
        user = request.user
        UserProfile.objects.filter(user=user).delete()
        Account.objects.filter(user=user).delete()
        Category.objects.filter(user=user).delete()
        Budget.objects.filter(user=user).delete()
        Transaction.objects.filter(user=user).delete()
        Goal.objects.filter(user=user).delete()
        Insight.objects.filter(user=user).delete()
        # User record remains (Firebase auth) — adjust as needed
        return Response(status=status.HTTP_204_NO_CONTENT)


class TokenPairView(TokenObtainPairView):
    permission_classes = []  # Should be protected in production via Firebase verification endpoint


class TokenRefresh(TokenRefreshView):
    permission_classes = []


def log_activity(get_response):
    def middleware(request):
        response = get_response(request)
        try:
            UserActivity.objects.create(
                user=request.user if getattr(request, 'user', None) and request.user.is_authenticated else None,
                path=request.path[:255],
                method=request.method,
                ip=request.META.get('REMOTE_ADDR'),
                user_agent=request.META.get('HTTP_USER_AGENT', '')[:500],
            )
        except Exception:
            pass
        return response
    return middleware
class AccountViewSet(viewsets.ModelViewSet):
    serializer_class = AccountSerializer
    permission_classes = [permissions.IsAuthenticated, HasMobileApiKey]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['type', 'is_active', 'currency']
    search_fields = ['name', 'institution']
    ordering_fields = ['name', 'updated_at', 'balance']

    def get_queryset(self):
        return Account.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def perform_destroy(self, instance):
        # deleting an account cascades transactions; ensure integrity already handled by models
        instance.delete()


class TransactionViewSet(viewsets.ModelViewSet):
    serializer_class = TransactionSerializer
    permission_classes = [permissions.IsAuthenticated, HasMobileApiKey]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = {
        'direction': ['exact'],
        'txn_time': ['date', 'date__gte', 'date__lte'],
        'amount': ['gte', 'lte','exact'],
        'account': ['exact'],
        'category': ['exact'],
        'is_pending': ['exact'],
    }
    search_fields = ['description', 'merchant', 'external_id']
    ordering_fields = ['txn_time', 'amount', 'created_at']

    def get_queryset(self):
        return Transaction.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def perform_update(self, serializer):
        # Reconcile balances: remove old txn effect then apply new
        old = Transaction.objects.get(pk=self.get_object().pk)
        updated = serializer.save(user=self.request.user)
        from .signals import _apply_transaction_to_account
        if old.account_id:
            _apply_transaction_to_account(old.account, old, sign=-1)
        if updated.account_id:
            _apply_transaction_to_account(updated.account, updated, sign=1)


class CategoryViewSet(viewsets.ModelViewSet):
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated, HasMobileApiKey]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['type']
    search_fields = ['name']
    ordering_fields = ['name', 'updated_at']

    def get_queryset(self):
        return Category.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class BudgetViewSet(viewsets.ModelViewSet):
    serializer_class = BudgetSerializer
    permission_classes = [permissions.IsAuthenticated, HasMobileApiKey]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['period', 'category']
    search_fields = []
    ordering_fields = ['start_date', 'end_date', 'updated_at']

    def get_queryset(self):
        return Budget.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class SummaryView(APIView):
    permission_classes = [permissions.IsAuthenticated, HasMobileApiKey]

    def get(self, request):
        user = request.user
        accounts = Account.objects.filter(user=user)
        balances = accounts.values_list('balance', flat=True)
        total_balance = sum(balances) if balances else 0
        income = Transaction.objects.filter(user=user, direction='in').aggregate(total=models.Sum('amount'))['total'] or 0
        expense = Transaction.objects.filter(user=user, direction='out').aggregate(total=models.Sum('amount'))['total'] or 0
        net = (income - expense)
        return Response({
            'total_balance': total_balance,
            'income_total': income,
            'expense_total': expense,
            'net_cashflow': net,
        })


class CategorySpendingReportView(APIView):
    permission_classes = [permissions.IsAuthenticated, HasMobileApiKey]

    def get(self, request):
        user = request.user
        start = request.query_params.get('start')
        end = request.query_params.get('end')
        qs = Transaction.objects.filter(user=user, direction='out')
        if start:
            qs = qs.filter(txn_time__date__gte=start)
        if end:
            qs = qs.filter(txn_time__date__lte=end)
        data = qs.values('category__id','category__name').annotate(total=models.Sum('amount')).order_by('-total')
        return Response(list(data))


class BudgetProgressView(APIView):
    permission_classes = [permissions.IsAuthenticated, HasMobileApiKey]

    def get(self, request):
        user = request.user
        start = request.query_params.get('start')
        end = request.query_params.get('end')
        budgets = Budget.objects.filter(user=user)
        if start and end:
            budgets = budgets.filter(start_date__lte=end, end_date__gte=start)
        results = []
        for b in budgets.select_related('category'):
            spent = Transaction.objects.filter(user=user, direction='out', category=b.category, txn_time__date__gte=b.start_date, txn_time__date__lte=b.end_date).aggregate(total=models.Sum('amount'))['total'] or 0
            results.append({
                'budget_id': b.id,
                'category_id': b.category_id,
                'category': b.category.name,
                'period': b.period,
                'start_date': b.start_date,
                'end_date': b.end_date,
                'limit_amount': b.limit_amount,
                'spent': spent,
                'remaining': b.limit_amount - spent,
                'variance': b.limit_amount - spent,
            })
        return Response(results)
from django.shortcuts import render

# Create your views here.
