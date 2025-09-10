from django.contrib.auth import get_user_model
from rest_framework.authentication import BaseAuthentication
from rest_framework import exceptions

try:
    import firebase_admin
    from firebase_admin import auth as fb_auth
    if not firebase_admin._apps:
        firebase_admin.initialize_app()
    _FIREBASE_AVAILABLE = True
except Exception:
    _FIREBASE_AVAILABLE = False

User = get_user_model()


class FirebaseAuthentication(BaseAuthentication):
    """Authenticate requests bearing a Firebase ID token.

    Expects header: Authorization: Bearer <firebase_id_token>
    If firebase_admin is not configured, silently returns None so other auth backends can run.
    """

    www_authenticate_realm = 'api'

    def authenticate(self, request):
        if not _FIREBASE_AVAILABLE:
            return None
        auth_header = request.META.get('HTTP_AUTHORIZATION') or ''
        if not auth_header.startswith('Bearer '):
            return None
        token = auth_header[7:].strip()
        if not token:
            return None
        try:
            decoded = fb_auth.verify_id_token(token)
        except Exception as e:
            raise exceptions.AuthenticationFailed(f'Invalid Firebase token: {e}')

        uid = decoded.get('uid') or decoded.get('user_id')
        if not uid:
            raise exceptions.AuthenticationFailed('Token missing uid')
        email = decoded.get('email') or f'{uid}@firebase.local'

        user, created = User.objects.get_or_create(username=uid, defaults={'email': email})
        if created:
            user.set_unusable_password()
            user.save(update_fields=['password'])

        # Ensure profile stores firebase uid
        from .models import UserProfile
        profile, _ = UserProfile.objects.get_or_create(user=user)
        if not profile.firebase_uid:
            profile.firebase_uid = uid
            profile.save(update_fields=['firebase_uid', 'updated_at'])
        return (user, None)

    def authenticate_header(self, request):  # pragma: no cover
        return 'Bearer realm="api"'
