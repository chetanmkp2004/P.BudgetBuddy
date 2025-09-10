/// Central listing of backend REST endpoints (path segment only).
class Endpoints {
  // These align with Budget/urls.py -> path('api/', include('finance.urls'))
  static const accounts = '/api/accounts/';
  static const transactions = '/api/transactions/';
  static const categories = '/api/categories/';
  static const budgets = '/api/budgets/';
  static const summary = '/api/summary/';
  static const profile = '/api/profile/';
  static const token = '/api/auth/token/';
  static const tokenRefresh = '/api/auth/token/refresh/';
}
