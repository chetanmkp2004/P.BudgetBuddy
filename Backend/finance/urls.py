from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    HealthView, ProfileView, PreferencesView, ExportDataView, DeleteAccountView,
    TokenPairView, TokenRefresh, RegisterView,
    AccountViewSet, TransactionViewSet, CategoryViewSet, BudgetViewSet,
    SummaryView, CategorySpendingReportView, BudgetProgressView,
)

router = DefaultRouter()
router.register(r'accounts', AccountViewSet, basename='account')
router.register(r'transactions', TransactionViewSet, basename='transaction')
router.register(r'categories', CategoryViewSet, basename='category')
router.register(r'budgets', BudgetViewSet, basename='budget')


urlpatterns = [
    path("health/", HealthView.as_view(), name="finance-health"),
    path("auth/token/", TokenPairView.as_view(), name="token_obtain_pair"),
    path("auth/token/refresh/", TokenRefresh.as_view(), name="token_refresh"),
    path("auth/register/", RegisterView.as_view(), name="register"),

    path("profile/", ProfileView.as_view(), name="profile"),
    path("preferences/", PreferencesView.as_view(), name="preferences"),
    path("export/", ExportDataView.as_view(), name="export-data"),
    path("delete-account/", DeleteAccountView.as_view(), name="delete-account"),
    path('', include(router.urls)),
    path('summary/', SummaryView.as_view(), name='summary'),
    path('reports/category-spending/', CategorySpendingReportView.as_view(), name='category-spending'),
    path('reports/budget-progress/', BudgetProgressView.as_view(), name='budget-progress'),
]
