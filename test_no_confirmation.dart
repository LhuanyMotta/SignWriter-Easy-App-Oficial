import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔧 TESTE: Cadastro SEM confirmação de email');
  
  try {
    await Supabase.initialize(
      url: 'https://zznrlwswttfzccuvzbzw.supabase.co',
      anonKey: 'sb_secret_o3xDNKsqmm9fZeN9c_OKEw_FPVr1a6v',
    );
    
    print('✅ Supabase OK');
    
    // Tenta criar conta
    final email = 'teste${DateTime.now().millisecondsSinceEpoch}@teste.com';
    print('📧 Tentando criar: $email');
    
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: '123456',
    );
    
    if (response.user != null) {
      print('🎉 CONTA CRIADA!');
      print('📧 Email: ${response.user!.email}');
      print('✅ Confirmado: ${response.user!.emailConfirmedAt ?? "SIM (sem confirmação)"}');
      print('🔑 Session: ${response.session != null ? "SIM" : "NÃO"}');
      
      // Tenta login imediatamente
      print('\n🔐 Tentando login...');
      final login = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: '123456',
      );
      print('✅ Login OK: ${login.user?.email}');
      
    } else {
      print('❌ Falha: cadastro não retornou usuário nem sessão.');
      print('\n💡 SOLUÇÃO:');
      print('1. Acesse: https://app.supabase.com/project/zznrlwswttfzccuvzbzw');
      print('2. Authentication > Providers > Email');
      print('3. ✅ Enable Email Provider');
      print('4. ❌ DESMARQUE Confirm email');
      print('5. Clique Save');
    }
    
  } catch (e) {
    print('❌ Erro: $e');
  }
  
  runApp(const MaterialApp(
    home: Scaffold(
      body: Center(child: Text('Teste completo - Verifique console')),
    ),
  ));
}
