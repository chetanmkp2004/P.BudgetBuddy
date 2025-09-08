from rest_framework import serializers
from .models import UserProfile, Account, Category, Transaction, Budget


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            'id', 'currency', 'monthly_income', 'preferences', 'financial_goals_note', 'firebase_uid',
        ]


class PreferencesSerializer(serializers.Serializer):
    preferences = serializers.JSONField()


class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ['id', 'name', 'type', 'institution', 'balance', 'currency', 'is_active', 'created_at', 'updated_at']
        read_only_fields = ['balance', 'created_at', 'updated_at']


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'type', 'icon', 'color', 'default_budget_limit', 'is_custom', 'created_at', 'updated_at']
        read_only_fields = ['created_at', 'updated_at']


class TransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = [
            'id','direction','amount','currency','description','txn_time','merchant','is_pending','external_id','account','category','created_at','updated_at'
        ]
        read_only_fields = ['created_at','updated_at']


class BudgetSerializer(serializers.ModelSerializer):
    class Meta:
        model = Budget
        fields = ['id','category','period','start_date','end_date','limit_amount','created_at','updated_at']
        read_only_fields = ['created_at','updated_at']

