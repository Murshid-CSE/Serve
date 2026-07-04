import 'package:community_care_hub/features/auth/domain/entities/user_entity.dart';
import 'package:community_care_hub/features/auth/domain/repositories/auth_repository.dart';

class RegisterWithEmail {
  final AuthRepository _repository;

  const RegisterWithEmail(this._repository);

  Future<UserEntity> call(
    String name,
    String email,
    String phone,
    String password,
  ) {
    return _repository.registerWithEmail(name, email, phone, password);
  }
}
