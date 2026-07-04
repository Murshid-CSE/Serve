sealed class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'network-error',
    super.originalError,
  });
}

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AuthException.fromFirebase(dynamic error) {
    final code = error?.code ?? 'unknown';
    final message = switch (code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'email-already-in-use' => 'This email is already registered.',
      'invalid-email' => 'Please enter a valid email address.',
      'weak-password' => 'Password is too weak. Use at least 6 characters.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'operation-not-allowed' => 'This sign-in method is not enabled.',
      'account-exists-with-different-credential' =>
        'An account already exists with a different sign-in method.',
      _ => 'Authentication failed. Please try again.',
    };
    return AuthException(
      message: message,
      code: code,
      originalError: error,
    );
  }
}

class FirestoreException extends AppException {
  const FirestoreException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory FirestoreException.fromFirebase(dynamic error) {
    final code = error?.code ?? 'unknown';
    final message = switch (code) {
      'permission-denied' =>
        'You do not have permission to perform this action.',
      'not-found' => 'The requested data was not found.',
      'already-exists' => 'This record already exists.',
      'resource-exhausted' =>
        'Service temporarily unavailable. Please try again.',
      'unavailable' =>
        'Service temporarily unavailable. Please check your connection.',
      _ => 'Database operation failed. Please try again.',
    };
    return FirestoreException(
      message: message,
      code: code,
      originalError: error,
    );
  }
}

class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
  });
}

class LocationException extends AppException {
  const LocationException({
    super.message = 'Unable to get your location. Please enable GPS.',
    super.code = 'location-error',
    super.originalError,
  });
}

class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code = 'permission-denied',
    super.originalError,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = 'validation-error',
    super.originalError,
  });
}
