import 'package:flutter/material.dart';

/// ViewModel para a tela de Conversar
class ChatViewModel extends ChangeNotifier {
  /// Lista de mensagens na conversa
  final List<Map<String, dynamic>> _messages = [];
  
  /// Indica se está processando uma mensagem
  bool _isProcessing = false;
  
  /// Getter para a lista de mensagens
  List<Map<String, dynamic>> get messages => _messages;
  
  /// Getter para o estado de processamento
  bool get isProcessing => _isProcessing;

  /// Construtor que inicializa com mensagem de boas-vindas
  ChatViewModel() {
    // Adiciona uma mensagem inicial do sistema
    _messages.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': 'Olá! Como posso ajudar você hoje? Você pode conversar em Libras comigo.',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  /// Envia uma mensagem do usuário
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    // Adiciona mensagem do usuário
    final userMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': text,
      'isUser': true,
      'timestamp': DateTime.now(),
    };
    
    _messages.add(userMessage);
    notifyListeners();
    
    // Simula processamento
    _simulateResponse(text);
  }
  
  /// Simula uma resposta do assistente
  void _simulateResponse(String userMessage) {
    _isProcessing = true;
    notifyListeners();
    
    // Simula um atraso na resposta para parecer mais natural
    Future.delayed(const Duration(seconds: 1), () {
      // Resposta simulada baseada em palavras-chave
      String response = 'Compreendi sua mensagem. Como posso ajudar mais?';
      
      if (userMessage.toLowerCase().contains('oi') || 
          userMessage.toLowerCase().contains('olá')) {
        response = 'Olá! Como está? Em que posso ajudar hoje?';
      } else if (userMessage.toLowerCase().contains('ajuda') || 
                userMessage.toLowerCase().contains('dúvida')) {
        response = 'Estou aqui para ajudar! Você pode perguntar sobre SignWriting ou conversar comigo em Libras.';
      } else if (userMessage.toLowerCase().contains('tchau') || 
                userMessage.toLowerCase().contains('adeus')) {
        response = 'Até mais! Foi bom conversar com você.';
      }
      
      // Adiciona resposta do assistente
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': response,
        'isUser': false,
        'timestamp': DateTime.now(),
      });
      
      _isProcessing = false;
      notifyListeners();
    });
  }
  
  /// Limpa o histórico de mensagens
  void clearChat() {
    _messages.clear();
    
    // Adiciona novamente a mensagem de boas-vindas
    _messages.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': 'Olá! Como posso ajudar você hoje? Você pode conversar em Libras comigo.',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
    
    notifyListeners();
  }
} 