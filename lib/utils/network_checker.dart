import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

class NetworkChecker {
  static Future<bool> hasConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    // Try pinging a reliable host (e.g. Google or your server)
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 3),
      );
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
