from django.db import models
from django.contrib.auth import get_user_model
from django.core.validators import MinValueValidator

User = get_user_model()


class TimeStampedModel(models.Model):
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		abstract = True


class UserProfile(TimeStampedModel):
	user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
	firebase_uid = models.CharField(max_length=128, blank=True, db_index=True)
	currency = models.CharField(max_length=8, default="USD")
	monthly_income = models.DecimalField(max_digits=12, decimal_places=2, validators=[MinValueValidator(0)], default=0)
	preferences = models.JSONField(default=dict, blank=True)
	financial_goals_note = models.TextField(blank=True, default="")

	def __str__(self):
		return f"Profile<{self.user}>"


class Account(TimeStampedModel):
	ACCOUNT_TYPES = [
		("checking", "Checking"),
		("savings", "Savings"),
		("credit", "Credit Card"),
		("investment", "Investment"),
		("cash", "Cash"),
		("other", "Other"),
	]

	user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="accounts")
	name = models.CharField(max_length=100)
	type = models.CharField(max_length=20, choices=ACCOUNT_TYPES)
	institution = models.CharField(max_length=120, blank=True)
	balance = models.DecimalField(max_digits=14, decimal_places=2, validators=[MinValueValidator(0)], default=0)
	currency = models.CharField(max_length=8, default="USD")
	is_active = models.BooleanField(default=True)

	class Meta:
		unique_together = ("user", "name")
		ordering = ["name"]

	def __str__(self):
		return f"{self.name} ({self.get_type_display()})"

	def clean(self):
		# ensure non-negative balance stored
		if self.balance is not None and self.balance < 0:
			raise models.ValidationError({"balance": "Balance cannot be negative."})


class Category(TimeStampedModel):
	CATEGORY_TYPES = [
		("expense", "Expense"),
		("income", "Income"),
	]

	user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="categories")
	name = models.CharField(max_length=100)
	type = models.CharField(max_length=10, choices=CATEGORY_TYPES, default="expense")
	icon = models.CharField(max_length=50, blank=True)  # store icon key/name used by frontend
	color = models.CharField(max_length=9, blank=True)  # e.g., #RRGGBB or rgba()
	default_budget_limit = models.DecimalField(max_digits=12, decimal_places=2, validators=[MinValueValidator(0)], default=0)
	is_custom = models.BooleanField(default=True)

	class Meta:
		unique_together = ("user", "name", "type")
		ordering = ["type", "name"]

	def __str__(self):
		return f"{self.name} ({self.type})"

	def clean(self):
		if self.default_budget_limit is not None and self.default_budget_limit < 0:
			raise models.ValidationError({"default_budget_limit": "Budget limit cannot be negative."})


class Budget(TimeStampedModel):
	PERIOD_CHOICES = [
		("monthly", "Monthly"),
		("weekly", "Weekly"),
		("yearly", "Yearly"),
		("custom", "Custom"),
	]

	user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="budgets")
	category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name="budgets")
	period = models.CharField(max_length=10, choices=PERIOD_CHOICES, default="monthly")
	start_date = models.DateField()
	end_date = models.DateField()
	limit_amount = models.DecimalField(max_digits=12, decimal_places=2, validators=[MinValueValidator(0)])

	class Meta:
		constraints = [
			models.CheckConstraint(check=models.Q(end_date__gte=models.F("start_date")), name="budget_dates_valid"),
		]
		unique_together = ("user", "category", "period", "start_date", "end_date")

	def __str__(self):
		return f"Budget<{self.user}:{self.category} {self.period} {self.start_date} - {self.end_date}>"

	def clean(self):
		if self.category and self.category.user_id != self.user_id:
			raise models.ValidationError({"category": "Category must belong to the same user."})
		if self.category and self.category.type != "expense":
			raise models.ValidationError({"category": "Budgets can only be set for expense categories."})
		if self.limit_amount is not None and self.limit_amount < 0:
			raise models.ValidationError({"limit_amount": "Limit must be non-negative."})


class Transaction(TimeStampedModel):
	DIRECTION = [
		("out", "Expense"),
		("in", "Income"),
		("transfer", "Transfer"),
	]

	user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="transactions")
	account = models.ForeignKey(Account, on_delete=models.CASCADE, related_name="transactions")
	category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, related_name="transactions")
	direction = models.CharField(max_length=10, choices=DIRECTION, default="out")
	amount = models.DecimalField(max_digits=14, decimal_places=2, validators=[MinValueValidator(0.01)])
	currency = models.CharField(max_length=8, default="USD")
	description = models.CharField(max_length=255, blank=True)
	txn_time = models.DateTimeField()
	merchant = models.CharField(max_length=120, blank=True)
	is_pending = models.BooleanField(default=False)
	external_id = models.CharField(max_length=128, blank=True, db_index=True)

	class Meta:
		indexes = [
			models.Index(fields=["user", "txn_time"]),
			models.Index(fields=["account", "txn_time"]),
		]
		ordering = ["-txn_time"]

	def __str__(self):
		return f"{self.get_direction_display()} {self.amount} {self.currency} @ {self.txn_time:%Y-%m-%d}"

	def clean(self):
		errors = {}
		if self.amount is not None and self.amount <= 0:
			errors["amount"] = "Amount must be greater than 0."
		if self.account and self.account.user_id != self.user_id:
			errors["account"] = "Account must belong to the same user."
		if self.category:
			if self.category.user_id != self.user_id:
				errors["category"] = "Category must belong to the same user."
			if self.direction == "out" and self.category.type != "expense":
				errors["category"] = "Expense transactions require an expense category."
			if self.direction == "in" and self.category.type != "income":
				errors["category"] = "Income transactions require an income category."
		if self.currency and self.account and self.currency != self.account.currency:
			errors["currency"] = "Transaction currency must match account currency."
		if errors:
			raise models.ValidationError(errors)


class Goal(TimeStampedModel):
	STATUS = [
		("active", "Active"),
		("paused", "Paused"),
		("completed", "Completed"),
		("canceled", "Canceled"),
	]

	user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="goals")
	name = models.CharField(max_length=120)
	target_amount = models.DecimalField(max_digits=14, decimal_places=2, validators=[MinValueValidator(0.01)])
	deadline = models.DateField(null=True, blank=True)
	status = models.CharField(max_length=12, choices=STATUS, default="active")
	notes = models.TextField(blank=True, default="")

	def __str__(self):
		return f"Goal<{self.name}:{self.target_amount}>"

	def clean(self):
		if self.target_amount is not None and self.target_amount <= 0:
			raise models.ValidationError({"target_amount": "Target must be greater than 0."})


class GoalContribution(TimeStampedModel):
	goal = models.ForeignKey(Goal, on_delete=models.CASCADE, related_name="contributions")
	amount = models.DecimalField(max_digits=14, decimal_places=2, validators=[MinValueValidator(0.01)])
	contributed_at = models.DateTimeField()
	source_account = models.ForeignKey(Account, on_delete=models.SET_NULL, null=True, blank=True, related_name="goal_contributions")
	note = models.CharField(max_length=255, blank=True)

	class Meta:
		ordering = ["-contributed_at"]

	def clean(self):
		errors = {}
		if self.amount is not None and self.amount <= 0:
			errors["amount"] = "Amount must be greater than 0."
		if self.goal and self.source_account and self.goal.user_id != self.source_account.user_id:
			errors["source_account"] = "Source account must belong to the same user as the goal."
		if self.goal and self.goal.status in {"canceled", "completed"}:
			errors["goal"] = "Cannot contribute to a canceled or completed goal."
		if errors:
			raise models.ValidationError(errors)


class Insight(TimeStampedModel):
	user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="insights")
	title = models.CharField(max_length=200)
	body = models.TextField()
	severity = models.CharField(max_length=20, blank=True)  # e.g., info/warn/critical
	metadata = models.JSONField(default=dict, blank=True)
	generated_at = models.DateTimeField(auto_now_add=True)
	acknowledged = models.BooleanField(default=False)

	def __str__(self):
		return self.title


class AuditLog(models.Model):
	ACTIONS = [
		("create", "Create"),
		("update", "Update"),
		("delete", "Delete"),
	]

	user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name="audit_logs")
	action = models.CharField(max_length=10, choices=ACTIONS)
	model_name = models.CharField(max_length=100)
	object_id = models.CharField(max_length=64)
	timestamp = models.DateTimeField(auto_now_add=True)
	changes = models.JSONField(default=dict, blank=True)

	class Meta:
		indexes = [models.Index(fields=["model_name", "object_id"])]
		ordering = ["-timestamp"]

	def __str__(self):
		return f"Audit<{self.model_name}:{self.action} {self.object_id}>"


class UserActivity(models.Model):
	user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='activities')
	path = models.CharField(max_length=255)
	method = models.CharField(max_length=10)
	ip = models.GenericIPAddressField(null=True, blank=True)
	user_agent = models.TextField(blank=True)
	timestamp = models.DateTimeField(auto_now_add=True)

	class Meta:
		indexes = [models.Index(fields=["user", "timestamp"])]
		ordering = ['-timestamp']

