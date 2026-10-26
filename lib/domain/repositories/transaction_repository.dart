import '../entities/transaction_item.dart';
import '../entities/transfer_result.dart';

abstract class TransactionRepository {
  Future<List<TransactionItem>> getTransactions({
    String? type,
    String? search,
    bool forceRefresh = false,
  });

  Future<TransactionItem> getTransactionDetail(String id);

  Future<TransferResult> transferMoney({
    required String beneficiaryName,
    required String mobileNumber,
    required double amount,
    String? remarks,
    String? idempotencyKey,
  });

  List<TransactionItem> get cachedTransactions;
}
