import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_care_hub/features/auth/domain/usecases/register_with_email.dart';
import 'package:community_care_hub/features/auth/domain/repositories/auth_repository.dart';
import 'package:community_care_hub/features/auth/domain/entities/user_entity.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterWithEmail usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterWithEmail(mockRepository);
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

  group('RegisterWithEmail UseCase', () {
    test('should return UserEntity from repository when registration succeeds', () async {
      // arrange
      when(() => mockRepository.registerWithEmail(any(), any(), any(), any()))
          .thenAnswer((_) async => tUser);
      // act
      final result = await usecase('Test User', 'test@example.com', '1234567890', 'password');
      // assert
      expect(result, equals(tUser));
      verify(() => mockRepository.registerWithEmail('Test User', 'test@example.com', '1234567890', 'password')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository throws', () async {
      // arrange
      when(() => mockRepository.registerWithEmail(any(), any(), any(), any()))
          .thenThrow(Exception('Registration failed'));
      // act & assert
      expect(() async => await usecase('Test User', 'test@example.com', '1234567890', 'password'), throwsException);
    });
  });
}
