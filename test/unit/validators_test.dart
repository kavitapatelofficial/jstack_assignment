import 'package:flutter_test/flutter_test.dart';
import 'package:jstack_assignment/core/utils/validators.dart';

void main() {
  group('Validators - Login Form Validation', () {
    test('validateEmail returns error for null or empty string', () {
      expect(Validators.validateEmail(null), 'Email address is required');
      expect(Validators.validateEmail(''), 'Email address is required');
      expect(Validators.validateEmail('   '), 'Email address is required');
    });

    test('validateEmail returns error for invalid email formats', () {
      expect(Validators.validateEmail('notanemail'), 'Enter a valid email address');
      expect(Validators.validateEmail('user@'), 'Enter a valid email address');
      expect(Validators.validateEmail('@domain.com'), 'Enter a valid email address');
      expect(Validators.validateEmail('user@domain'), 'Enter a valid email address');
    });

    test('validateEmail returns null for valid email address', () {
      expect(Validators.validateEmail('demo@jstack.co'), isNull);
      expect(Validators.validateEmail('test.user@company.com'), isNull);
    });

    test('validatePassword returns error for empty or short password', () {
      expect(Validators.validatePassword(null), 'Password is required');
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters');
    });

    test('validatePassword returns null for valid password', () {
      expect(Validators.validatePassword('Demo@123'), isNull);
      expect(Validators.validatePassword('supersecret'), isNull);
    });
  });

  group('Validators - Transfer Validation', () {
    test('validateAmount returns error for empty or non-numeric input', () {
      expect(Validators.validateAmount(null), 'Transfer amount is required');
      expect(Validators.validateAmount(''), 'Transfer amount is required');
      expect(Validators.validateAmount('abc'), 'Enter a valid numeric amount');
    });

    test('validateAmount returns error for zero or negative values', () {
      expect(Validators.validateAmount('0'), 'Amount must be greater than zero');
      expect(Validators.validateAmount('-50'), 'Amount must be greater than zero');
    });

    test('validateAmount returns error when amount exceeds maximum available balance', () {
      const availableBalance = 25450.75;
      final result = Validators.validateAmount('30000', maxBalance: availableBalance);
      expect(result, contains('Amount exceeds available balance'));
    });

    test('validateAmount returns null for valid transfer amount within balance', () {
      const availableBalance = 25450.75;
      expect(Validators.validateAmount('1500.00', maxBalance: availableBalance), isNull);
      expect(Validators.validateAmount('25450.75', maxBalance: availableBalance), isNull);
    });

    test('validateBeneficiaryName validates required name and min length', () {
      expect(Validators.validateBeneficiaryName(null), 'Beneficiary name is required');
      expect(Validators.validateBeneficiaryName(''), 'Beneficiary name is required');
      expect(Validators.validateBeneficiaryName('A'), 'Name must be at least 2 characters');
      expect(Validators.validateBeneficiaryName('Rahul Sharma'), isNull);
    });

    test('validateMobileNumber validates 10-digit Indian phone number format', () {
      expect(Validators.validateMobileNumber(null), 'Mobile number is required');
      expect(Validators.validateMobileNumber(''), 'Mobile number is required');
      expect(Validators.validateMobileNumber('12345'), 'Enter a valid 10-digit mobile number');
      expect(Validators.validateMobileNumber('1234567890'), 'Enter a valid 10-digit mobile number'); // doesn't start with 6-9
      expect(Validators.validateMobileNumber('9876543210'), isNull);
      expect(Validators.validateMobileNumber('8877665544'), isNull);
    });
  });
}
