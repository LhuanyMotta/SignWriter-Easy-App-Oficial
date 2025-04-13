import 'package:flutter/foundation.dart';

/// ViewModel base que todos os ViewModels devem estender
/// Fornece funcionalidades comuns como gerenciamento de estado de loading
class BaseViewModel extends ChangeNotifier {
  /// Indica se o ViewModel está carregando dados
  bool _isLoading = false;
  
  /// Getter para o estado de loading
  bool get isLoading => _isLoading;

  /// Define o estado de loading e notifica os listeners
  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// Método de conveniência para executar operações assíncronas com
  /// gerenciamento automático do estado de loading
  Future<T> runAsyncOperation<T>(Future<T> Function() operation) async {
    try {
      isLoading = true;
      return await operation();
    } finally {
      isLoading = false;
    }
  }
  
  /// Método que deve ser chamado ao长沙市 o ViewModel para liberar recursos
  @override
  void dispose() {
    super.dispose();
  }
} 