import 'package:flutter/foundation.dart';
import 'biometric_service_io.dart' as io;
import 'biometric_service_web.dart' as web;
import 'biometric_types.dart';

/// Unified BiometricService that delegates to platform-specific implementations
class BiometricService {
  static BiometricService? _instance;

  factory BiometricService() {
    _instance ??= BiometricService._internal();
    return _instance!;
  }

  BiometricService._internal();

  Future<bool> isBiometricsAvailable() async {
    if (kIsWeb) {
      return web.BiometricService().isBiometricsAvailable();
    } else {
      return io.BiometricService().isBiometricsAvailable();
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) {
      return web.BiometricService().getAvailableBiometrics();
    } else {
      return io.BiometricService().getAvailableBiometrics();
    }
  }

  Future<BiometricResult> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    if (kIsWeb) {
      return web.BiometricService().authenticate(
        reason: reason,
        biometricOnly: biometricOnly,
      );
    } else {
      return io.BiometricService().authenticate(
        reason: reason,
        biometricOnly: biometricOnly,
      );
    }
  }
}
