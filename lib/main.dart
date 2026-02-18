import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:signwriter_easy_app_oficial/views/screens/auth_screen.dart';
import 'package:signwriter_easy_app_oficial/viewmodels/auth_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 ============ INICIANDO SIGNWRITER FÁCIL ============');
  
  try {
    // 1. PRIMEIRO: Carregar o arquivo .env
    print('📁 Carregando configurações do arquivo .env...');
    
    await dotenv.load(fileName: '.env');
    
    // 2. SEGUNDO: Pegar as variáveis do .env
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_KEY'];
    
    print('🔍 Variáveis carregadas:');
    print('   SUPABASE_URL: ${supabaseUrl != null ? '✅' : '❌'}');
    print('   SUPABASE_KEY: ${supabaseKey != null ? '✅' : '❌'}');
    
    // 3. VALIDAR: Verificar se as variáveis existem
    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      throw Exception('❌ SUPABASE_URL não encontrada ou vazia no arquivo .env');
    }
    
    if (supabaseKey == null || supabaseKey.isEmpty) {
      throw Exception('❌ SUPABASE_KEY não encontrada ou vazia no arquivo .env');
    }
    
    // Mostrar parte das informações (por segurança)
    print('🔗 Supabase URL: ${supabaseUrl.substring(0, 30)}...');
    print('🔑 Supabase Key: ${supabaseKey.substring(0, 10)}...');
    
    // 4. TERCEIRO: Inicializar o Supabase com as variáveis
    print('🔌 Inicializando conexão com Supabase...');
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    
    print('✅ Supabase inicializado com sucesso!');
    print('================================================\n');
    
    // 5. Iniciar o aplicativo
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthViewModel(Supabase.instance.client),
          ),
        ],
        child: const MyApp(),
      ),
    );
    
  } catch (e) {
    print('❌ ERRO CRÍTICO NA INICIALIZAÇÃO: $e');
    
    // Dicas para debugging
    print('\n🔧 DICAS PARA SOLUCIONAR:');
    print('   1. Verifique se o arquivo .env está na raiz do projeto');
    print('   2. Verifique se o conteúdo do .env está correto');
    print('   3. Execute: flutter clean && flutter pub get');
    print('   4. Reinicie o emulador se necessário');
    
    runApp(
      ErrorApp(
        errorMessage: '''
Erro ao inicializar o aplicativo:

$e

Verifique:
1. Arquivo .env na raiz do projeto
2. Conteúdo correto das variáveis
3. Dependências instaladas (flutter pub get)
''',
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignWriter Fácil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2D78BB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D78BB),
          primary: const Color(0xFF2D78BB),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String errorMessage;
  
  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 32),
                    const SizedBox(width: 12),
                    const Text(
                      'Erro de Configuração',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Card com informações do erro
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Não foi possível inicializar o aplicativo:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Mensagem de erro
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: SelectableText(
                              errorMessage,
                              style: TextStyle(  // REMOVIDO 'const'
                                fontFamily: 'monospace',
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Passos para resolver
                          const Text(
                            '📋 Passos para resolver:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          const _StepItem(
                            number: 1,
                            text: 'Verifique se o arquivo ".env" está na raiz do projeto',
                          ),
                          const _StepItem(
                            number: 2,
                            text: 'Abra o arquivo .env e confirme que tem:',
                            subText: 'SUPABASE_URL=sua_url\nSUPABASE_KEY=sua_key',
                          ),
                          const _StepItem(
                            number: 3,
                            text: 'Execute no terminal: flutter clean',
                          ),
                          const _StepItem(
                            number: 4,
                            text: 'Depois: flutter pub get',
                          ),
                          const _StepItem(
                            number: 5,
                            text: 'Reinicie o aplicativo',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Botão de ação
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D78BB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      main();
                    },
                    child: const Text(
                      'Tentar Novamente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar para os passos
class _StepItem extends StatelessWidget {
  final int number;
  final String text;
  final String? subText;
  
  const _StepItem({
    required this.number,
    required this.text,
    this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF2D78BB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                
                if (subText != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SelectableText(
                      subText!,
                      style: TextStyle(  // REMOVIDO 'const'
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}