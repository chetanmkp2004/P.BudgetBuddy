from django.apps import AppConfig


class FinanceConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'finance'

    def ready(self):
        # Import signals to connect them
        try:
            from . import signals  # noqa: F401
        except Exception:
            # Avoid crashing on migrations where app registry not fully ready
            pass
