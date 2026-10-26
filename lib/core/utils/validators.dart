class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _mobileRegExp = RegExp(
    r'^[6-9]\d{9}$',
  );

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateBeneficiaryName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Beneficiary name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateMobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final clean = value.replaceAll(RegExp(r'\s+|-'), '');
    if (!_mobileRegExp.hasMatch(clean)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? validateAmount(String? value, {double? maxBalance}) {
    if (value == null || value.trim().isEmpty) {
      return 'Transfer amount is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid numeric amount';
    }
    if (parsed <= 0) {
      return 'Amount must be greater than zero';
    }
    if (maxBalance != null && parsed > maxBalance) {
      return 'Amount exceeds available balance (₹${maxBalance.toStringAsFixed(2)})';
    }
    return null;
  }
}
