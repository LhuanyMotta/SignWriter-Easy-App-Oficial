import '../services/written_sign_preview_policy.dart';
import '../services/written_signs_service.dart';

/// Mensagem amigável para o usuário (sem detalhes técnicos).
String friendlyError(Object error) {
  if (error is WrittenSignsException) return error.message;
  if (error is WrittenSignPreviewException) return error.message;

  final text = error.toString().toLowerCase();

  if (text.contains('socket') ||
      text.contains('network') ||
      text.contains('failed host lookup') ||
      text.contains('connection') ||
      text.contains('offline')) {
    return 'Verifique sua conexão com a internet.';
  }

  if (text.contains('timeout') || text.contains('timed out')) {
    return 'A operação demorou mais que o esperado. Tente novamente.';
  }

  if (text.contains('rate limit') || text.contains('too many requests')) {
    return 'Muitas tentativas de envio. Aguarde alguns minutos e tente novamente.';
  }

  if (text.contains('smtp') ||
      text.contains('email service') ||
      text.contains('sending email')) {
    return 'O serviço de e-mail não está disponível. Verifique o SMTP do Supabase.';
  }

  if (text.contains('unauthorized') ||
      text.contains('jwt') ||
      text.contains('session') ||
      text.contains('not authenticated')) {
    return 'Sua sessão expirou. Entre novamente.';
  }

  return 'Não foi possível concluir a operação. Tente novamente.';
}
