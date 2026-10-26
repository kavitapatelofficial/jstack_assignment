enum TransactionType { credit, debit }
enum TransactionStatus { success, failed, pending }

class TransactionItem {
  final String id;
  final TransactionType type;
  final double amount;
  final String currency;
  final String beneficiaryName;
  final String? mobileNumber;
  final TransactionStatus status;
  final String createdAt;
  final String? remarks;

  const TransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.beneficiaryName,
    this.mobileNumber,
    required this.status,
    required this.createdAt,
    this.remarks,
  });

  bool get isCredit => type == TransactionType.credit;
  bool get isDebit => type == TransactionType.debit;

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String? ?? 'DEBIT').toUpperCase();
    final statusStr = (json['status'] as String? ?? 'SUCCESS').toUpperCase();

    return TransactionItem(
      id: json['id'] as String? ?? '',
      type: typeStr == 'CREDIT' ? TransactionType.credit : TransactionType.debit,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      beneficiaryName: json['beneficiaryName'] as String? ?? 'Unknown',
      mobileNumber: json['mobileNumber'] as String?,
      status: statusStr == 'SUCCESS'
          ? TransactionStatus.success
          : (statusStr == 'FAILED' ? TransactionStatus.failed : TransactionStatus.pending),
      createdAt: json['createdAt'] as String? ?? '',
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == TransactionType.credit ? 'CREDIT' : 'DEBIT',
      'amount': amount,
      'currency': currency,
      'beneficiaryName': beneficiaryName,
      'mobileNumber': mobileNumber,
      'status': status == TransactionStatus.success
          ? 'SUCCESS'
          : (status == TransactionStatus.failed ? 'FAILED' : 'PENDING'),
      'createdAt': createdAt,
      'remarks': remarks,
    };
  }
}
