from django.contrib import admin
from . import models


@admin.register(models.UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
	list_display = ("user", "currency", "monthly_income", "created_at")


@admin.register(models.Account)
class AccountAdmin(admin.ModelAdmin):
	list_display = ("user", "name", "type", "balance", "currency", "is_active")
	list_filter = ("type", "is_active")
	search_fields = ("name", "institution")


@admin.register(models.Category)
class CategoryAdmin(admin.ModelAdmin):
	list_display = ("user", "name", "type", "default_budget_limit")
	list_filter = ("type",)
	search_fields = ("name",)


@admin.register(models.Budget)
class BudgetAdmin(admin.ModelAdmin):
	list_display = ("user", "category", "period", "start_date", "end_date", "limit_amount")
	list_filter = ("period",)


@admin.register(models.Transaction)
class TransactionAdmin(admin.ModelAdmin):
	list_display = ("user", "account", "direction", "amount", "currency", "txn_time", "is_pending")
	list_filter = ("direction", "is_pending")
	search_fields = ("description", "merchant", "external_id")
	date_hierarchy = "txn_time"


@admin.register(models.Goal)
class GoalAdmin(admin.ModelAdmin):
	list_display = ("user", "name", "target_amount", "deadline", "status")
	list_filter = ("status",)


@admin.register(models.GoalContribution)
class GoalContributionAdmin(admin.ModelAdmin):
	list_display = ("goal", "amount", "contributed_at", "source_account")
	date_hierarchy = "contributed_at"


@admin.register(models.Insight)
class InsightAdmin(admin.ModelAdmin):
	list_display = ("user", "title", "severity", "acknowledged", "generated_at")
	list_filter = ("severity", "acknowledged")
	search_fields = ("title",)


@admin.register(models.AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
	list_display = ("timestamp", "user", "action", "model_name", "object_id")
	list_filter = ("action", "model_name")
	search_fields = ("model_name", "object_id")


@admin.register(models.UserActivity)
class UserActivityAdmin(admin.ModelAdmin):
	list_display = ("timestamp", "user", "method", "path", "ip")
	list_filter = ("method",)

