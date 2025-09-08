from rest_framework.permissions import BasePermission


class HasMobileApiKey(BasePermission):
    message = "Missing or invalid API key."

    def has_permission(self, request, view):
        expected = request.headers.get('X-Mobile-API-Key')
        # In real deployments, compare against env/setting. Here we just require header present.
        return bool(expected)


class IsOwnerOnly(BasePermission):
    def has_object_permission(self, request, view, obj):
        user_id = getattr(obj, 'user_id', None) or getattr(getattr(obj, 'user', None), 'id', None)
        return request.user and request.user.is_authenticated and user_id == request.user.id
