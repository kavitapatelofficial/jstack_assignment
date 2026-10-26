class Wallet {
  final String walletId;
  final String currency;
  final double availableBalance;
  final String maskedAccountNumber;

  const Wallet({
    required this.walletId,
    required this.currency,
    required this.availableBalance,
    required this.maskedAccountNumber,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      walletId: json['walletId'] as String? ?? '',
      currency: json['currency'] as String? ?? 'INR',
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      maskedAccountNumber: json['maskedAccountNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'currency': currency,
      'availableBalance': availableBalance,
      'maskedAccountNumber': maskedAccountNumber,
    };
  }

  Wallet copyWith({
    String? walletId,
    String? currency,
    double? availableBalance,
    String? maskedAccountNumber,
  }) {
    return Wallet(
      walletId: walletId ?? this.walletId,
      currency: currency ?? this.currency,
      availableBalance: availableBalance ?? this.availableBalance,
      maskedAccountNumber: maskedAccountNumber ?? this.maskedAccountNumber,
    );
  }
}
