import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

class WalletService {
  final ApiClient _client;

  WalletService(this._client);

  Future<Map<String, dynamic>> getWalletBalance() async {
    final response = await _client.get(ApiEndpoints.balance);
    return response.data as Map<String, dynamic>;
  }
}
