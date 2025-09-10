from rest_framework.permissions import BasePermission
from django.conf import settings


class IsAuthenticatedOrOptions(BasePermission):
    """Allow unauthenticated CORS preflight (OPTIONS) requests, require auth otherwise."""

    def has_permission(self, request, view):
        if request.method == 'OPTIONS':  # let browser preflight through
            return True
        return bool(request.user and request.user.is_authenticated)


class HasMobileApiKey(BasePermission):
    message = "Missing or invalid API key."

    def has_permission(self, request, view):
        if request.method == 'OPTIONS':  # allow preflight
            return True
        provided = request.headers.get('X-Mobile-API-Key')
        expected = getattr(settings, 'MOBILE_API_KEY', None)
        return bool(provided and expected and provided == expected)


class IsOwnerOnly(BasePermission):
    def has_object_permission(self, request, view, obj):
        user_id = getattr(obj, 'user_id', None) or getattr(getattr(obj, 'user', None), 'id', None)
        return request.user and request.user.is_authenticated and user_id == request.user.id
