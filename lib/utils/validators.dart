String? nameValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your name';
  }
  if (value.length < 3) {
    return 'Name must be at least 3 characters long';
  }
  return null;
}

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  // Basic email regex pattern
  final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegExp.hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}

String? phoneValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your phone number';
  }
  // Basic phone regex pattern
  final phoneRegExp = RegExp(r'^\d{10}$');
  if (!phoneRegExp.hasMatch(value)) {
    return 'Please enter a valid 10-digit phone number';
  }
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null;
}

String? confirmPasswordValidator(String? value, String? password) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }
  if (value != password) {
    return 'Passwords do not match';
  }
  return null;
}
