import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jstack_assignment/core/network/api_exceptions.dart';
import 'package:jstack_assignment/domain/entities/transfer_result.dart';
import 'package:jstack_assignment/domain/entities/wallet.dart';
import 'package:jstack_assignment/domain/repositories/transaction_repository.dart';
import 'package:jstack_assignment/domain/repositories/wallet_repository.dart';
import 'package:jstack_assignment/presentation/viewmodels/transfer_viewmodel.dart';
import 'package:jstack_assignment/presentation/viewmodels/wallet_viewmodel.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}
class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late MockTransactionRepository mockTransactionRepo;
  late MockWalletRepository mockWalletRepo;
  late WalletViewModel walletViewModel;
  late TransferViewModel transferViewModel;

  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockWalletRepo = MockWalletRepository();

    when(() => mockWalletRepo.cachedWallet).thenReturn(
      const Wallet(
        walletId: 'WALLET10001',
        currency: 'INR',
        availableBalance: 25450.75,
        maskedAccountNumber: 'XXXX XXXX 4589',
      ),
    );

    walletViewModel = WalletViewModel(walletRepository: mockWalletRepo);
    transferViewModel = TransferViewModel(
      transactionRepository: mockTransactionRepo,
      walletViewModel: walletViewModel,
    );
  });

  group('TransferViewModel Tests', () {
    test('Successful transfer updates state and wallet balance', () async {
      const transferAmount = 1500.0;
      const newBalance = 23950.75;

      const mockResult = TransferResult(
        transactionId: 'TXN10015',
        status: 'SUCCESS',
        amount: transferAmount,
        currency: 'INR',
        availableBalance: newBalance,
        beneficiaryName: 'Rahul Sharma',
        createdAt: '2026-10-26T10:30:00Z',
      );

      when(() => mockTransactionRepo.transferMoney(
            beneficiaryName: any(named: 'beneficiaryName'),
            mobileNumber: any(named: 'mobileNumber'),
            amount: any(named: 'amount'),
            remarks: any(named: 'remarks'),
            idempotencyKey: any(named: 'idempotencyKey'),
          )).thenAnswer((_) async => mockResult);

      transferViewModel.setFormData(
        beneficiaryName: 'Rahul Sharma',
        mobileNumber: '9876543210',
        amount: transferAmount,
        remarks: 'Payment for services',
      );

      expect(transferViewModel.status, TransferStatus.confirming);
      expect(walletViewModel.availableBalance, 25450.75);

      final success = await transferViewModel.executeTransfer();

      expect(success, isTrue);
      expect(transferViewModel.status, TransferStatus.success);
      expect(transferViewModel.lastResult?.transactionId, 'TXN10015');
      expect(transferViewModel.errorMessage, isNull);

      // Verify wallet balance state updated to authoritative backend value
      expect(walletViewModel.availableBalance, newBalance);
    });

    test('Insufficient balance transfer sets failure state and error message', () async {
      when(() => mockTransactionRepo.transferMoney(
            beneficiaryName: any(named: 'beneficiaryName'),
            mobileNumber: any(named: 'mobileNumber'),
            amount: any(named: 'amount'),
            remarks: any(named: 'remarks'),
            idempotencyKey: any(named: 'idempotencyKey'),
          )).thenThrow(
        const InsufficientFundsException(
          message: 'Insufficient wallet balance',
          errorCode: 'INSUFFICIENT_FUNDS',
        ),
      );

      transferViewModel.setFormData(
        beneficiaryName: 'Rahul Sharma',
        mobileNumber: '9876543210',
        amount: 50000.0,
      );

      final success = await transferViewModel.executeTransfer();

      expect(success, isFalse);
      expect(transferViewModel.status, TransferStatus.failure);
      expect(transferViewModel.errorMessage, 'Insufficient wallet balance');
      expect(walletViewModel.availableBalance, 25450.75); // Balance remains untouched
    });

    test('Prevents duplicate transfer submission when already submitting', () async {
      when(() => mockTransactionRepo.transferMoney(
            beneficiaryName: any(named: 'beneficiaryName'),
            mobileNumber: any(named: 'mobileNumber'),
            amount: any(named: 'amount'),
            remarks: any(named: 'remarks'),
            idempotencyKey: any(named: 'idempotencyKey'),
          )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return const TransferResult(
          transactionId: 'TXN10016',
          status: 'SUCCESS',
          amount: 500.0,
          currency: 'INR',
          availableBalance: 24950.75,
          beneficiaryName: 'Amit Kumar',
        );
      });

      transferViewModel.setFormData(
        beneficiaryName: 'Amit Kumar',
        mobileNumber: '9811223344',
        amount: 500.0,
      );

      final future1 = transferViewModel.executeTransfer();
      final future2 = transferViewModel.executeTransfer(); // Immediate duplicate attempt

      final results = await Future.wait([future1, future2]);

      expect(results[0], isTrue);
      expect(results[1], isFalse); // Rejected as duplicate
      verify(() => mockTransactionRepo.transferMoney(
            beneficiaryName: any(named: 'beneficiaryName'),
            mobileNumber: any(named: 'mobileNumber'),
            amount: any(named: 'amount'),
            remarks: any(named: 'remarks'),
            idempotencyKey: any(named: 'idempotencyKey'),
          )).called(1);
    });
  });
}
