class EmailValidator {
  bool isValid(String email)
  {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return false;
    }
    return trimmedEmail.contains('@') && trimmedEmail.contains('.');
  }
}