import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart' as auth;
import 'package:local_auth/error_codes.dart' as auth_error;
import 'biometric_types.dart' as types;

class BiometricService {
  static final auth.LocalAuthentication _localAuth = auth.LocalAuthentication();
  static final BiometricService _instance = BiometricService._internal();

  factory BiometricService() => _instance;

  BiometricService._internal();

  Future<bool> isBiometricsAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint('Error checking biometric availability: ${e.message}');
      return false;
    }
  }

  Future<List<types.BiometricType>> getAvailableBiometrics() async {
    try {
      if (!await isBiometricsAvailable()) return [];
      final list = await _localAuth.getAvailableBiometrics();
      return list.map((e) {
        switch (e) {
          case auth.BiometricType.fingerprint:
            return types.BiometricType.fingerprint;
          case auth.BiometricType.face:
            return types.BiometricType.face;
          case auth.BiometricType.iris:
            return types.BiometricType.iris;
          default:
            return types.BiometricType.fingerprint;
        }
      }).toList();
    } on PlatformException catch (e) {
      debugPrint('Error getting biometrics: ${e.message}');
      return [];
    }
  }

  Future<types.BiometricResult> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      final bool available = await isBiometricsAvailable();
      if (!available) {
        return types.BiometricResult(
          success: false,
          error: types.BiometricError.notAvailable,
          message: 'Biometrics not available on this device',
        );
      }

      final bool success = await _localAuth.authenticate(
        localizedReason: reason,
        options: auth.AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return types.BiometricResult(
        success: success,
        error: success ? null : types.BiometricError.authFailed,
        message:
            success ? 'Authentication successful' : 'Authentication failed',
      );
    } on PlatformException catch (e) {
      debugPrint('Error authenticating: ${e.message}');

      types.BiometricError error = types.BiometricError.unknown;
      String message = e.message ?? 'Unknown error occurred';

      if (e.code == auth_error.notAvailable) {
        error = types.BiometricError.notAvailable;
        message = 'Biometrics not available';
      } else if (e.code == auth_error.notEnrolled) {
        error = types.BiometricError.notEnrolled;
        message = 'No biometrics enrolled';
      } else if (e.code == auth_error.lockedOut) {
        error = types.BiometricError.lockedOut;
        message = 'Biometrics locked out due to too many attempts';
      } else if (e.code == auth_error.permanentlyLockedOut) {
        error = types.BiometricError.permanentlyLockedOut;
        message = 'Biometrics permanently locked out';
      }

      return types.BiometricResult(
        success: false,
        error: error,
        message: message,
      );
    } catch (e) {
      return types.BiometricResult(
        success: false,
        error: types.BiometricError.unknown,
        message: e.toString(),
      );
    }
  }
}
