import 'package:flutter_test/flutter_test.dart';
import 'package:signwriter_easy_app_oficial/services/email_service.dart';

void main() {
  group('EmailService', () {
    test('uses the app email as the default sender for verification emails', () {
      expect(EmailService.defaultSenderEmail, 'signwriter.easy.app@gmail.com');
      expect(EmailService().resolveSenderEmail(), 'signwriter.easy.app@gmail.com');
    });
  });
}
