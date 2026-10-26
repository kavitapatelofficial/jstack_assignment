class TransferResult {
  final String transactionId;
  final String status;
  final double amount;
  final String currency;
  final double availableBalance;
  final String beneficiaryName;
  final String? createdAt;

  const TransferResult({
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.availableBalance,
    required this.beneficiaryName,
    this.createdAt,
  });

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    return TransferResult(
      transactionId: json['transactionId'] as String? ?? '',
      status: json['status'] as String? ?? 'SUCCESS',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      beneficiaryName: json['beneficiaryName'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
    );
  }
}
