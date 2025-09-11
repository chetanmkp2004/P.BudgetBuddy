import 'package:flutter/foundation.dart';
import 'biometric_types.dart' as types;

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  Future<bool> isBiometricsAvailable() async => false;
  Future<List<types.BiometricType>> getAvailableBiometrics() async => const [];

  Future<types.BiometricResult> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    debugPrint('Biometrics not supported on web');
    return types.BiometricResult(
      success: false,
      error: types.BiometricError.notAvailable,
      message: 'Biometrics not available on web',
    );
  }
}
