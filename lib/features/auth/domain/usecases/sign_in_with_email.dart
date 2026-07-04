import 'package:community_care_hub/features/auth/domain/entities/user_entity.dart';
import 'package:community_care_hub/features/auth/domain/repositories/auth_repository.dart';

class SignInWithEmail {
  final AuthRepository _repository;

  const SignInWithEmail(this._repository);

  Future<UserEntity> call(String email, String password) {
    return _repository.signInWithEmail(email, password);
  }
}
