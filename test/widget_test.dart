import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jstack_assignment/domain/entities/transaction_item.dart';
import 'package:jstack_assignment/presentation/widgets/balance_card.dart';
import 'package:jstack_assignment/presentation/widgets/status_badge.dart';
import 'package:jstack_assignment/presentation/widgets/transaction_tile.dart';

void main() {
  group('BalanceCard Widget Tests', () {
    testWidgets('Displays balance, currency, masked account number, and handles toggle', (tester) async {
      bool sendMoneyTapped = false;
      bool addMoneyTapped = false;
      bool historyTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalanceCard(
              balance: 25450.75,
              currency: 'INR',
              maskedAccountNumber: 'XXXX XXXX 4589',
              onSendMoneyTap: () => sendMoneyTapped = true,
              onAddMoneyTap: () => addMoneyTapped = true,
              onHistoryTap: () => historyTapped = true,
            ),
          ),
        ),
      );

      // Verify account and branding
      expect(find.text('XXXX XXXX 4589'), findsOneWidget);
      expect(find.text('jWallet Lite'), findsOneWidget);
      expect(find.text('Available Balance'), findsOneWidget);

      // Verify initial balance formatted
      expect(find.text('₹25,450.75'), findsOneWidget);

      // Tap balance visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Verify masked representation
      expect(find.text('₹ ••••••••'), findsOneWidget);

      // Tap Send Money quick action
      await tester.tap(find.text('Send Money'));
      expect(sendMoneyTapped, isTrue);

      // Tap Add Money quick action
      await tester.tap(find.text('Add Money'));
      expect(addMoneyTapped, isTrue);

      // Tap History quick action
      await tester.tap(find.text('History'));
      expect(historyTapped, isTrue);
    });
  });

  group('TransactionTile & StatusBadge Widget Tests', () {
    testWidgets('TransactionTile renders credit transaction with green badge', (tester) async {
      const creditTxn = TransactionItem(
        id: 'TXN10002',
        type: TransactionType.credit,
        amount: 5000.0,
        currency: 'INR',
        beneficiaryName: 'Amit Kumar',
        status: TransactionStatus.success,
        createdAt: '2026-10-19T14:15:00Z',
      );

      bool tileTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTile(
              transaction: creditTxn,
              onTap: () => tileTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Amit Kumar'), findsOneWidget);
      expect(find.text('TXN10002'), findsOneWidget);
      expect(find.text('+₹5,000.00'), findsOneWidget);
      expect(find.text('SUCCESS'), findsOneWidget);

      await tester.tap(find.byType(TransactionTile));
      expect(tileTapped, isTrue);
    });

    testWidgets('StatusBadge renders failed and pending states', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge(status: TransactionStatus.failed),
                StatusBadge(status: TransactionStatus.pending),
              ],
            ),
          ),
        ),
      );

      expect(find.text('FAILED'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
    });
  });
}
