import 'package:flutter_test/flutter_test.dart';
import 'package:signwriter_easy_app_oficial/utils/email_validator.dart';

void main() {
  group('EmailValidator', () {
    test('rejects obviously random generated Gmail addresses', () {
      expect(
        EmailValidator.isValid('lhuanyioduejdcsfhdud@gmail.com'),
        isFalse,
      );
    });

    test('accepts normal Gmail addresses', () {
      expect(EmailValidator.isValid('joao.silva@gmail.com'), isTrue);
    });
  });
}
