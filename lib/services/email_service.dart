import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;

/// Serviço para envio de emails de confirmação e notificações
class EmailService {
  // Você pode usar qualquer provider: SendGrid, Mailtrap, Firebase, etc.
  // Para este exemplo, vamos usar uma abordagem com Supabase Edge Functions
  
  /// Envia um email de confirmação de cadastro
  /// 
  /// Parâmetros:
  /// - [email]: Email do usuário
  /// - [name]: Nome do usuário
  /// - [confirmationLink]: Link de confirmação do Supabase (enviado via deeplink)
  /// - [appName]: Nome da aplicação
  Future<bool> sendConfirmationEmail({
    required String email,
    required String name,
    required String confirmationLink,
    String appName = 'SignWriter Fácil',
  }) async {
    try {
      debugPrint('EmailService: Enviando email de confirmação para $email');
      
      // Opção 1: Se usar Supabase Edge Functions
      final result = await _sendViaSupabaseFunction(
        email: email,
        name: name,
        confirmationLink: confirmationLink,
        appName: appName,
        type: 'confirmation',
      );
      
      return result;
    } catch (e) {
      debugPrint('EmailService ERROR: Falha ao enviar email de confirmação: $e');
      return false;
    }
  }

  /// Envia um email de boas-vindas após confirmação
  Future<bool> sendWelcomeEmail({
    required String email,
    required String name,
    String appName = 'SignWriter Fácil',
  }) async {
    try {
      debugPrint('EmailService: Enviando email de boas-vindas para $email');
      
      final result = await _sendViaSupabaseFunction(
        email: email,
        name: name,
        appName: appName,
        type: 'welcome',
      );
      
      return result;
    } catch (e) {
      debugPrint('EmailService ERROR: Falha ao enviar email de boas-vindas: $e');
      return false;
    }
  }

  /// Envia email via Supabase Edge Functions
  /// 
  /// Para usar este serviço:
  /// 1. Crie uma Edge Function no Supabase Dashboard
  /// 2. Configure o provider de email (SendGrid, Resend, etc)
  /// 3. Configure as variáveis de ambiente
  Future<bool> _sendViaSupabaseFunction({
    required String email,
    required String name,
    required String type,
    String? confirmationLink,
    String appName = 'SignWriter Fácil',
  }) async {
    try {
      final apiUrl = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
      
      if (apiUrl == null || anonKey == null) {
        debugPrint('EmailService ERROR: Supabase credentials not found in .env');
        return false;
      }

      final url = Uri.parse('$apiUrl/functions/v1/send-email');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $anonKey',
        },
        body: jsonEncode({
          'email': email,
          'name': name,
          'type': type, // 'confirmation' ou 'welcome'
          'confirmationLink': confirmationLink,
          'appName': appName,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('EmailService: Email enviado com sucesso para $email');
        return true;
      } else {
        debugPrint('EmailService ERROR: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('EmailService ERROR: Exception ao enviar email: $e');
      return false;
    }
  }

  /// Alternativa: Enviar direto via API HTTP (ex: SendGrid, Resend, etc)
  /// Descomente e configure conforme necessário
  /*
  Future<bool> _sendViaHttpProvider({
    required String email,
    required String name,
    required String type,
    String? confirmationLink,
    String appName = 'SignWriter Fácil',
  }) async {
    try {
      final apiKey = dotenv.env['EMAIL_API_KEY'];
      final senderId = dotenv.env['EMAIL_SENDER_ID'];
      
      if (apiKey == null || senderId == null) {
        debugPrint('EmailService ERROR: Email API credentials not found');
        return false;
      }

      final emailContent = _getEmailTemplate(
        type: type,
        name: name,
        confirmationLink: confirmationLink,
        appName: appName,
      );

      final url = Uri.parse(_emailApiUrl);
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'from': senderId,
          'to': email,
          'subject': emailContent['subject'],
          'html': emailContent['html'],
          'text': emailContent['text'],
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('EmailService ERROR: $e');
      return false;
    }
  }

  /// Template de emails customizados
  Map<String, String> _getEmailTemplate({
    required String type,
    required String name,
    String? confirmationLink,
    String appName = 'SignWriter Fácil',
  }) {
    if (type == 'confirmation') {
      return {
        'subject': 'Confirme seu email em $appName',
        'text': 'Olá $name!\n\nClique no link abaixo para confirmar seu email:\n$confirmationLink',
        'html': '''
          <h2>Bem-vindo ao $appName!</h2>
          <p>Olá $name!</p>
          <p>Para confirmar seu cadastro, clique no link abaixo:</p>
          <a href="$confirmationLink" style="background-color: #2D78BB; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;">
            Confirmar Email
          </a>
          <p>Se você não criou esta conta, ignore este email.</p>
        ''',
      };
    } else if (type == 'welcome') {
      return {
        'subject': 'Bem-vindo ao $appName!',
        'text': 'Olá $name!\n\nObrigado por se cadastrar em $appName. Sua conta foi confirmada com sucesso!',
        'html': '''
          <h2>Bem-vindo ao $appName!</h2>
          <p>Olá $name!</p>
          <p>Obrigado por se cadastrar. Sua conta foi confirmada com sucesso!</p>
          <p>Agora você pode aproveitar todos os recursos do app.</p>
        ''',
      };
    }
    
    return {'subject': '', 'text': '', 'html': ''};
  }
  */
}
