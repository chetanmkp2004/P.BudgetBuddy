import 'dart:collection';

/// Lightweight in-memory cache with simple TTL logic.
class DataCache {
  static final DataCache I = DataCache._();
  DataCache._();

  final Map<String, _Entry> _store = HashMap();

  void put(
    String key,
    dynamic value, {
    Duration ttl = const Duration(minutes: 5),
  }) {
    _store[key] = _Entry(value, DateTime.now().add(ttl));
  }

  T? get<T>(String key) {
    final e = _store[key];
    if (e == null) return null;
    if (DateTime.now().isAfter(e.expires)) {
      _store.remove(key);
      return null;
    }
    return e.value as T?;
  }

  void invalidate(String key) => _store.remove(key);
  void clear() => _store.clear();
}

class _Entry {
  final dynamic value;
  final DateTime expires;
  _Entry(this.value, this.expires);
}
