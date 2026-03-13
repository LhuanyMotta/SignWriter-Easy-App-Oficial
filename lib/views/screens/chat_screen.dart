import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/chat_viewmodel.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';

/// Tela de conversa para comunicação em Libras
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatViewModel _viewModel;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Rola para o final da lista de mensagens
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // Envia a mensagem atual
  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      _viewModel.sendMessage(_messageController.text);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    final spacing = tokens?.spacingScale ?? 1.0;
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conversar'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Limpar conversa'),
                    content: const Text('Tem certeza que deseja limpar todo o histórico da conversa?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          _viewModel.clearChat();
                          Navigator.pop(context);
                        },
                        child: const Text('Limpar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Área de informações sobre o chat
              Container(
                padding: EdgeInsets.all(16 * spacing),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(
                        Icons.sign_language,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16 * spacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assistente SignWriter',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Disponível para ajudar em Libras e português',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lista de mensagens
              Expanded(
                child: Consumer<ChatViewModel>(
                  builder: (context, viewModel, child) {
                    final messages = viewModel.messages;
                    
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (messages.isNotEmpty) {
                        _scrollToBottom();
                      }
                    });
                    
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _buildMessageItem(message);
                      },
                    );
                  },
                ),
              ),
              
              // Indicador de digitação
              Consumer<ChatViewModel>(
                builder: (context, viewModel, child) {
                  return viewModel.isProcessing
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Assistente está digitando...',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens?.onSurfaceMuted ?? theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
              
              // Campo de entrada de mensagem
              Container(
                padding: EdgeInsets.all(8 * spacing),
                decoration: BoxDecoration(
                  color: tokens?.surface ?? theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.12),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic),
                      onPressed: () {
                        // Implementação futura para entrada de voz
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Recurso de entrada por voz será implementado em breve')),
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Digite sua mensagem...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: tokens?.surfaceMuted ?? theme.colorScheme.surfaceContainerHighest,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16 * spacing,
                            vertical: 10 * spacing,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final bool isUser = message['isUser'] as bool;
    final DateTime timestamp = message['timestamp'] as DateTime;
    final String timeString = DateFormat('HH:mm').format(timestamp);
    
    return Padding(
      padding: EdgeInsets.only(bottom: 16 * (Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0)),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 16,
              child: const Icon(Icons.sign_language, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * (Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0),
                vertical: 10 * (Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0),
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                  bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'] as String,
                    style: TextStyle(
                      color: isUser
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeString,
                    style: TextStyle(
                      fontSize: 10,
                      color: isUser
                          ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.8)
                          : Theme.of(context).extension<AppThemeTokens>()?.onSurfaceMuted ??
                              Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              radius: 16,
              child: Icon(
                Icons.person,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 