import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jstack_assignment/core/network/api_exceptions.dart';
import 'package:jstack_assignment/domain/entities/user.dart';
import 'package:jstack_assignment/domain/repositories/auth_repository.dart';
import 'package:jstack_assignment/presentation/viewmodels/auth_viewmodel.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late AuthViewModel authViewModel;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.isAuthenticated()).thenReturn(false);
    when(() => mockAuthRepo.currentUser).thenReturn(null);
    authViewModel = AuthViewModel(authRepository: mockAuthRepo);
  });

  group('AuthViewModel Tests', () {
    test('Initial state is unauthenticated when no session exists', () {
      expect(authViewModel.status, AuthStatus.unauthenticated);
      expect(authViewModel.isAuthenticated, isFalse);
      expect(authViewModel.user, isNull);
    });

    test('Successful login updates state to authenticated and sets user', () async {
      const mockUser = User(
        id: 'USR10001',
        name: 'Demo User',
        email: 'demo@jstack.co',
      );

      when(() => mockAuthRepo.login(
            email: 'demo@jstack.co',
            password: 'Demo@123',
          )).thenAnswer((_) async => (token: 'mock_access_token_123', user: mockUser));

      final success = await authViewModel.login(
        email: 'demo@jstack.co',
        password: 'Demo@123',
      );

      expect(success, isTrue);
      expect(authViewModel.status, AuthStatus.authenticated);
      expect(authViewModel.user?.name, 'Demo User');
      expect(authViewModel.errorMessage, isNull);
    });

    test('Invalid credentials sets error status and message', () async {
      when(() => mockAuthRepo.login(
            email: 'wrong@jstack.co',
            password: 'wrongpassword',
          )).thenThrow(
        const UnauthorizedException(
          message: 'Invalid email or password',
          errorCode: 'AUTH_INVALID_CREDENTIALS',
        ),
      );

      final success = await authViewModel.login(
        email: 'wrong@jstack.co',
        password: 'wrongpassword',
      );

      expect(success, isFalse);
      expect(authViewModel.status, AuthStatus.error);
      expect(authViewModel.errorMessage, 'Invalid email or password');
    });

    test('Logout clears user and transitions to unauthenticated', () async {
      when(() => mockAuthRepo.logout()).thenAnswer((_) async {});

      await authViewModel.logout();

      expect(authViewModel.status, AuthStatus.unauthenticated);
      expect(authViewModel.user, isNull);
    });
  });
}
