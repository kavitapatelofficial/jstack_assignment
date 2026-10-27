import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiEndpoints {
  // Current host machine local Wi-Fi IP for physical real devices
  static const String hostMachineIp = '10.22.134.63';
  static const int port = 3000;

  static String getDefaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:$port';
    }
    try {
      if (Platform.isAndroid) {
        // Default to real device Wi-Fi connection with host machine
        return 'http://$hostMachineIp:$port';
      }
      if (Platform.isIOS) {
        return 'http://localhost:$port';
      }
    } catch (_) {}
    return 'http://localhost:$port';
  }

  // Endpoints
  static const String login = '/api/v1/auth/login';
  static const String profile = '/api/v1/users/profile';
  static const String balance = '/api/v1/wallet/balance';
  static const String transactions = '/api/v1/transactions';
  static const String transfer = '/api/v1/transactions/transfer';
  static String transactionDetail(String id) => '/api/v1/transactions/$id';
}
