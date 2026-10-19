/// Validador de email com verificação de domínios reais e bloqueio de endereços aleatórios.
class EmailValidator {
  static const Set<String> validEmailDomains = {
    'gmail.com',
    'googlemail.com',
    'outlook.com',
    'hotmail.com',
    'live.com',
    'msn.com',
    'outlook.br',
    'hotmail.br',
    'live.br',
    'yahoo.com',
    'yahoo.com.br',
    'yahoomail.com',
    'icloud.com',
    'mail.com',
    'protonmail.com',
    'tutanota.com',
    'zoho.com',
    'yandex.com',
    'empresa.com',
    'company.com',
    'trabalho.com',
    'university.edu',
    'college.edu',
    'test.com',
    'example.com',
    'test.br',
  };

  static const Set<String> disposableDomains = {
    'mailinator.com',
    '10minutemail.com',
    'guerrillamail.com',
    'tempmail.com',
    'throwawaymail.com',
    'yopmail.com',
    'sharklasers.com',
    'trashmail.com',
    'dispostable.com',
    'fakeinbox.com',
  };

  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _lettersOnly = RegExp(r'^[a-z]+$');

  static bool isValid(String email) {
    email = email.trim().toLowerCase();

    if (email.isEmpty || !_emailPattern.hasMatch(email)) {
      return false;
    }

    final parts = email.split('@');
    if (parts.length != 2) {
      return false;
    }

    final localPart = parts[0];
    final domain = parts[1];

    if (!validEmailDomains.contains(domain) || disposableDomains.contains(domain)) {
      return false;
    }

    if (_looksLikeRandomGeneratedLocalPart(localPart)) {
      return false;
    }

    return true;
  }

  static bool _looksLikeRandomGeneratedLocalPart(String localPart) {
    if (localPart.isEmpty) {
      return true;
    }

    final hasSeparator = localPart.contains(RegExp(r'[._%+-]'));
    final isLettersOnly = _lettersOnly.hasMatch(localPart);

    if (isLettersOnly && !hasSeparator && localPart.length >= 20) {
      return true;
    }

    if (!hasSeparator && localPart.length >= 20 && localPart.contains(RegExp(r'\d')) == false) {
      return true;
    }

    return false;
  }

  static String getErrorMessage(String email) {
    email = email.trim().toLowerCase();

    if (email.isEmpty) {
      return 'Email não pode estar vazio';
    }

    if (!_emailPattern.hasMatch(email)) {
      return 'Formato de email inválido';
    }

    final parts = email.split('@');
    if (parts.length != 2) {
      return 'Email deve conter apenas um @';
    }

    final domain = parts[1];

    if (disposableDomains.contains(domain) || !validEmailDomains.contains(domain)) {
      return 'Domínio de email não suportado. Use Gmail, Outlook, Yahoo, etc.';
    }

    if (_looksLikeRandomGeneratedLocalPart(parts[0])) {
      return 'Este email parece ser aleatório ou inválido';
    }

    return 'Email inválido';
  }

  static List<String> getSupportedDomains() {
    return validEmailDomains.toList()..sort();
  }
}
