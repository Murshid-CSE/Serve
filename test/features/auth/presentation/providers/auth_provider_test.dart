import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/features/auth/domain/repositories/auth_repository.dart';
import 'package:community_care_hub/features/auth/domain/entities/user_entity.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  final tUser = UserEntity(
    uid: 'test-uid',
    name: 'Test User',
    email: 'test@example.com',
    phone: '1234567890',
    role: 'donor',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('authActionsProvider', () {
    test('signInWithEmail calls repository and returns user', () async {
      // arrange
      final container = makeProviderContainer();
      when(() => mockRepository.signInWithEmail(any(), any()))
          .thenAnswer((_) async => tUser);

      // act
      final authActions = container.read(authActionsProvider);
      final result = await authActions.signInWithEmail('test@example.com', 'password');

      // assert
      expect(result, equals(tUser));
      verify(() => mockRepository.signInWithEmail('test@example.com', 'password')).called(1);
    });

    test('registerWithEmail calls repository and returns user', () async {
      // arrange
      final container = makeProviderContainer();
      when(() => mockRepository.registerWithEmail(any(), any(), any(), any()))
          .thenAnswer((_) async => tUser);

      // act
      final authActions = container.read(authActionsProvider);
      final result = await authActions.registerWithEmail('Test User', 'test@example.com', '1234567890', 'password');

      // assert
      expect(result, equals(tUser));
      verify(() => mockRepository.registerWithEmail('Test User', 'test@example.com', '1234567890', 'password')).called(1);
    });
  });
}
