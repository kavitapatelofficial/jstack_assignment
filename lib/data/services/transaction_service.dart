import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

class TransactionService {
  final ApiClient _client;

  TransactionService(this._client);

  Future<Map<String, dynamic>> getTransactions({
    String? type,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (type != null && type.isNotEmpty && type != 'ALL') {
      queryParams['type'] = type;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await _client.get(
      ApiEndpoints.transactions,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTransactionDetail(String id) async {
    final response = await _client.get(ApiEndpoints.transactionDetail(id));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> transferMoney({
    required String beneficiaryName,
    required String mobileNumber,
    required double amount,
    String? remarks,
    String? idempotencyKey,
  }) async {
    final headers = <String, dynamic>{};
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['Idempotency-Key'] = idempotencyKey;
    }

    final response = await _client.post(
      ApiEndpoints.transfer,
      data: {
        'beneficiaryName': beneficiaryName,
        'mobileNumber': mobileNumber,
        'amount': amount,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      },
      options: headers.isNotEmpty ? Options(headers: headers) : null,
    );
    return response.data as Map<String, dynamic>;
  }
}
