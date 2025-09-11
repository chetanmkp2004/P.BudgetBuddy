enum BiometricError {
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  authFailed,
  unknown,
}

class BiometricResult {
  final bool success;
  final BiometricError? error;
  final String message;

  BiometricResult({required this.success, this.error, required this.message});
}

// For web, we don't have BiometricType, so use a placeholder
class BiometricType {
  const BiometricType._(this.name);
  final String name;

  static const BiometricType fingerprint = BiometricType._('fingerprint');
  static const BiometricType face = BiometricType._('face');
  static const BiometricType iris = BiometricType._('iris');
}
