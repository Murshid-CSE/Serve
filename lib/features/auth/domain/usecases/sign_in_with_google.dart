import 'package:community_care_hub/features/auth/domain/entities/user_entity.dart';
import 'package:community_care_hub/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogle {

  const SignInWithGoogle(this._repository);
  final AuthRepository _repository;

  Future<UserEntity> call() {
    return _repository.signInWithGoogle();
  }
}
