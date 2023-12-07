import 'package:local_auth/local_auth.dart';

class BiometricUtils {
  static Future<bool> authenticateWithBiometrics() async {
    final localAuth = LocalAuthentication();

    try {
      bool didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Please authenticate to log in',
        // stickyAuth: true,
      );
      return didAuthenticate;
    } catch (e) {
      print('Error authenticating: $e');
      return false;
    }
  }
}
