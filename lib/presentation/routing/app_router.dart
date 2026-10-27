import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/transaction_item.dart';
import '../../domain/entities/transfer_result.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../views/auth/login_screen.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/transactions/transaction_detail_screen.dart';
import '../views/transactions/transaction_history_screen.dart';
import '../views/transfer/send_money_screen.dart';
import '../views/transfer/transfer_result_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authViewModel,

      redirect: (context, state) {
        final isAuth = authViewModel.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';

        // User is not logged in
        if (!isAuth) {
          return isLoggingIn ? null : '/login';
        }

        // User is already logged in
        if (isAuth && isLoggingIn) {
          return '/dashboard';
        }

        return null;
      },

      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/transfer',
          builder: (context, state) => const SendMoneyScreen(),
        ),
        GoRoute(
          path: '/transfer-result',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};

            final isSuccess = extra['isSuccess'] as bool? ?? false;
            final result = extra['result'] as TransferResult?;
            final errorMessage = extra['errorMessage'] as String?;
            final amount = extra['amount'] as double?;
            final beneficiaryName = extra['beneficiaryName'] as String?;

            return TransferResultScreen(
              isSuccess: isSuccess,
              result: result,
              errorMessage: errorMessage,
              amount: amount,
              beneficiaryName: beneficiaryName,
            );
          },
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const TransactionHistoryScreen(),
        ),
        GoRoute(
          path: '/transaction/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            final extra = state.extra as TransactionItem?;

            return TransactionDetailScreen(
              transactionId: id,
              initialTransaction: extra,
            );
          },
        ),
      ],

      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.matchedLocation}')),
      ),
    );
  }
}
