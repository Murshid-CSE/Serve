import 'package:flutter/widgets.dart';

class Validators {
  Validators._();

  // Convenience getters for use as FormFieldValidator<String>
  static FormFieldValidator<String> get required =>
      (value) => validateRequired(value, 'This field');

  static FormFieldValidator<String> get email => validateEmail;

  static FormFieldValidator<String> get phone => validatePhone;

  static FormFieldValidator<String> get name => validateName;

  static FormFieldValidator<String> get password => validatePassword;

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Name is too long';
    }
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final phoneRegex = RegExp(r'^[+]?[0-9]{10,13}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  static String? validateBloodGroup(String? value) {
    if (value == null || value.isEmpty) {
      return 'Blood group is required';
    }
    const validGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    if (!validGroups.contains(value)) {
      return 'Please select a valid blood group';
    }
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    if (value.trim().length > 100) {
      return 'Quantity description is too long';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 10) {
      return 'Please provide a more detailed description';
    }
    if (value.trim().length > 500) {
      return 'Description is too long (max 500 characters)';
    }
    return null;
  }

  static String? validateHospitalName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Hospital name is required';
    }
    if (value.trim().length < 3) {
      return 'Please enter a valid hospital name';
    }
    return null;
  }

  static String? validateUnitsNeeded(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Units needed is required';
    }
    final units = int.tryParse(value.trim());
    if (units == null || units < 1) {
      return 'Please enter a valid number of units';
    }
    if (units > 20) {
      return 'Maximum 20 units can be requested';
    }
    return null;
  }

  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.trim().length > 100) {
      return 'Title is too long (max 100 characters)';
    }
    return null;
  }

  static bool isValidLatitude(double lat) {
    return lat >= -90 && lat <= 90;
  }

  static bool isValidLongitude(double lng) {
    return lng >= -180 && lng <= 180;
  }

  static String? validateLocation(double? lat, double? lng) {
    if (lat == null || lng == null) {
      return 'Location is required';
    }
    if (!isValidLatitude(lat) || !isValidLongitude(lng)) {
      return 'Invalid location coordinates';
    }
    return null;
  }
}
