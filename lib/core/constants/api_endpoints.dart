import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiEndpoints {
  static String getDefaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    try {
      if (Platform.isAndroid) {
        // Android Emulator loopback to host machine
        return 'http://10.0.2.2:3000';
      }
    } catch (_) {}
    return 'http://localhost:3000';
  }

  // Endpoints
  static const String login = '/api/v1/auth/login';
  static const String profile = '/api/v1/users/profile';
  static const String balance = '/api/v1/wallet/balance';
  static const String transactions = '/api/v1/transactions';
  static const String transfer = '/api/v1/transactions/transfer';
  static String transactionDetail(String id) => '/api/v1/transactions/$id';
}
