from decimal import Decimal
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.forms import model_to_dict
from .models import Transaction, Account, AuditLog


def _apply_transaction_to_account(account: Account, txn: Transaction, sign: int):
    if txn.direction == "in":
        delta = Decimal(sign) * txn.amount
    elif txn.direction == "out":
        delta = Decimal(-sign) * txn.amount
    else:  # transfer: don't adjust here (could be modeled as two txns)
        delta = Decimal(0)
    account.balance = (account.balance or Decimal(0)) + delta
    # Skip full_clean to allow negative balances; rely on explicit validation elsewhere.
    account.save(update_fields=["balance", "updated_at"])


@receiver(post_save, sender=Transaction)
def on_transaction_saved(sender, instance: Transaction, created, **kwargs):
    # adjust account balance for create only; updates are complex, recommend immutable amount/direction or custom logic
    if created and instance.account:
        _apply_transaction_to_account(instance.account, instance, sign=1)
    AuditLog.objects.create(
        user=instance.user,
        action="create" if created else "update",
        model_name="Transaction",
        object_id=str(instance.pk),
        changes={k: v for k, v in model_to_dict(instance).items() if k not in {"id"}},
    )


@receiver(post_delete, sender=Transaction)
def on_transaction_deleted(sender, instance: Transaction, **kwargs):
    if instance.account:
        _apply_transaction_to_account(instance.account, instance, sign=-1)
    AuditLog.objects.create(
        user=instance.user,
        action="delete",
        model_name="Transaction",
        object_id=str(instance.pk),
        changes={},
    )
