/// Validador de critérios de senha forte
class PasswordValidator {
  /// Critérios mínimos de uma senha forte
  static const int minLength = 8;
  static const int maxLength = 128;

  /// Verifica se a senha atende a todos os critérios
  static bool isValid(String password) {
    return hasMinimumLength(password) &&
        hasUppercase(password) &&
        hasLowercase(password) &&
        hasNumber(password) &&
        hasSpecialCharacter(password);
  }

  /// Verifica comprimento mínimo
  static bool hasMinimumLength(String password) {
    return password.length >= minLength;
  }

  /// Verifica se contém letra maiúscula
  static bool hasUppercase(String password) {
    return RegExp(r'[A-Z]').hasMatch(password);
  }

  /// Verifica se contém letra minúscula
  static bool hasLowercase(String password) {
    return RegExp(r'[a-z]').hasMatch(password);
  }

  /// Verifica se contém número
  static bool hasNumber(String password) {
    return RegExp(r'[0-9]').hasMatch(password);
  }

  /// Verifica se contém caractere especial
  static bool hasSpecialCharacter(String password) {
    // Caracteres especiais: !@#$%^&*()_+-=[]{}; :"',./<>?\|`~
    const specialChars = r'!@#$%^&*()_+-=[]{};"' "'" r',./<>?\|`~:;';
    return password.split('').any((char) => specialChars.contains(char));
  }

  /// Retorna uma lista dos critérios que NÃO foram atendidos
  static List<String> getUnmetCriteria(String password) {
    final criteria = <String>[];

    if (!hasMinimumLength(password)) {
      criteria.add('minLength');
    }
    if (!hasUppercase(password)) {
      criteria.add('uppercase');
    }
    if (!hasLowercase(password)) {
      criteria.add('lowercase');
    }
    if (!hasNumber(password)) {
      criteria.add('number');
    }
    if (!hasSpecialCharacter(password)) {
      criteria.add('specialChar');
    }

    return criteria;
  }
}
