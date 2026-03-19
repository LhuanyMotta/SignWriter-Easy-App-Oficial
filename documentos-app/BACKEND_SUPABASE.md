# Estrutura do Backend e Integração com Supabase

Este documento explica como o aplicativo SignWriter Fácil se conecta e utiliza o Supabase como backend, detalhando a organização do código e o fluxo de dados.

## Organização do Projeto

O projeto está dividido em camadas para facilitar a manutenção e a escalabilidade:

- **Models (Modelos):** Representam os dados do aplicativo, como sinais, usuários, progresso, etc. Cada modelo possui métodos para converter de/para Map (JSON), facilitando a comunicação com o backend.
- **Services (Serviços):** São responsáveis por acessar o backend, realizando operações como buscar, inserir, atualizar e deletar dados. Cada serviço é focado em uma funcionalidade (exemplo: sinais, usuários).
- **ViewModels/Controllers:** Fazem a ponte entre a interface e os serviços, controlando o estado e a lógica de negócio.

## Implementação da Autenticação

### 1. Estrutura das Tabelas

No Supabase, será necessário criar/configurar:

```sql
-- Tabela de perfis de usuário (extensão da tabela auth.users do Supabase)
create table public.profiles (
  id uuid references auth.users on delete cascade,
  name text,
  email text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  
  primary key (id),
  unique(email)
);

-- Trigger para atualizar updated_at
create trigger handle_updated_at before update on profiles
  for each row execute procedure moddatetime (updated_at);

-- Políticas de segurança (RLS)
alter table public.profiles enable row level security;

-- Políticas de acesso
create policy "Usuários podem ver seus próprios perfis"
  on public.profiles for select
  using ( auth.uid() = id );

create policy "Usuários podem atualizar seus próprios perfis"
  on public.profiles for update
  using ( auth.uid() = id );
```

### 2. Serviço de Armazenamento (StorageService)

Para migrar do armazenamento local para o Supabase:

```dart
class SupabaseStorageService {
  final SupabaseClient _supabase;
  
  SupabaseStorageService(this._supabase);
  
  /// Salva dados do usuário
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _supabase
      .from('profiles')
      .upsert({
        'id': _supabase.auth.currentUser!.id,
        ...userData,
        'updated_at': DateTime.now().toIso8601String(),
      });
  }
  
  /// Recupera dados do usuário
  Future<Map<String, dynamic>?> getUserData() async {
    final response = await _supabase
      .from('profiles')
      .select()
      .eq('id', _supabase.auth.currentUser?.id)
      .single();
      
    return response as Map<String, dynamic>?;
  }
  
  /// Verifica se usuário está autenticado
  Future<bool> isAuthenticated() async {
    return _supabase.auth.currentUser != null;
  }
  
  /// Limpa dados locais (logout)
  Future<void> clearAll() async {
    await _supabase.auth.signOut();
  }
}
```

### 3. AuthViewModel com Supabase

Exemplo de como o AuthViewModel será atualizado:

```dart
class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase;
  final SupabaseStorageService _storage;
  
  /// Login com email e senha
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _currentUser = await _storage.getUserData();
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erro ao fazer login: $e');
      return false;
    }
  }
  
  /// Cadastro com email e senha
  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      
      if (response.user != null) {
        await _storage.saveUserData({
          'name': name,
          'email': email,
        });
        
        _currentUser = await _storage.getUserData();
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erro ao fazer cadastro: $e');
      return false;
    }
  }
}
```

### 4. Configuração Inicial

No `main.dart`:

```dart
void main() async {
  await Supabase.initialize(
    url: 'SUA_URL_DO_SUPABASE',
    anonKey: 'SUA_CHAVE_ANONIMA',
  );
  
  runApp(const MyApp());
}
```

### 5. Provedores de Autenticação Social

Para habilitar login com Google e Apple:

1. **Google:**
   - Configure no Console do Google Cloud
   - Adicione as credenciais no Supabase
   - Atualize o método `signInWithGoogle`:
   ```dart
   Future<bool> signInWithGoogle() async {
     try {
       final response = await _supabase.auth.signInWithOAuth(
         Provider.google,
         redirectTo: 'io.supabase.flutterquickstart://login-callback',
       );
       return response.session != null;
     } catch (e) {
       _setError('Erro ao fazer login com Google: $e');
       return false;
     }
   }
   ```

2. **Apple:**
   - Configure no Apple Developer Console
   - Adicione as credenciais no Supabase
   - Atualize o método `signInWithApple`:
   ```dart
   Future<bool> signInWithApple() async {
     try {
       final response = await _supabase.auth.signInWithOAuth(
         Provider.apple,
         redirectTo: 'io.supabase.flutterquickstart://login-callback',
       );
       return response.session != null;
     } catch (e) {
       _setError('Erro ao fazer login com Apple: $e');
       return false;
     }
   }
   ```

### 6. Recuperação de Senha

Implemente a recuperação de senha:

```dart
Future<bool> resetPassword(String email) async {
  try {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.flutterquickstart://reset-callback',
    );
    return true;
  } catch (e) {
    _setError('Erro ao enviar email de recuperação: $e');
    return false;
  }
}
```

### 7. Middleware de Autenticação

Crie um middleware para proteger rotas que requerem autenticação:

```dart
class AuthMiddleware extends StatelessWidget {
  final Widget child;
  
  const AuthMiddleware({required this.child});
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          if (session == null) {
            return const AuthScreen();
          }
          return child;
        }
        return const LoadingScreen();
      },
    );
  }
}
```

## O que é o Supabase?

O Supabase é uma plataforma open source que oferece banco de dados PostgreSQL, autenticação, storage e API pronta para uso. Ele funciona como um "Firebase open source", facilitando o desenvolvimento de aplicativos modernos sem precisar criar um backend do zero.

## Como funciona a integração

1. **Criação do Projeto no Supabase:**
   - O desenvolvedor cria um projeto no painel do Supabase e define as tabelas necessárias (exemplo: `signs` para os sinais).
   - Cada tabela pode ser gerenciada pelo painel web, onde é possível definir permissões, colunas e visualizar os dados.

2. **Configuração no Flutter:**
   - O app utiliza o pacote `supabase_flutter` para se conectar ao Supabase.
   - No arquivo `main.dart`, o Supabase é inicializado com a URL do projeto e a chave anônima fornecidas pelo painel.

3. **Serviços de Comunicação:**
   - Cada serviço (ex: `SignService`) utiliza o cliente do Supabase para buscar, inserir ou atualizar dados nas tabelas.
   - Os dados recebidos são convertidos para os modelos do app, facilitando o uso nas telas.

4. **Fluxo de Dados:**
   - As telas solicitam dados aos viewmodels/controllers.
   - Os viewmodels chamam os serviços, que acessam o Supabase.
   - Os dados retornam para o app, que exibe as informações ao usuário.

## Exemplo de Uso

Para buscar todos os sinais cadastrados:

```dart
final response = await Supabase.instance.client
    .from('signs')
    .select()
    .execute();

if (response.error == null) {
  final sinais = (response.data as List)
      .map((e) => SignModel.fromMap(e))
      .toList();
  // Agora é só usar a lista de sinais na interface
}
```

## Vantagens dessa abordagem

- **Escalabilidade:** Fácil adicionar novas funcionalidades e tabelas.
- **Organização:** Cada parte do código tem sua responsabilidade bem definida.
- **Segurança:** O Supabase oferece autenticação e permissões configuráveis.
- **Desenvolvimento rápido:** Não é necessário criar um backend do zero.

## Usando o Supabase MCP (Model Context Protocol)

O Supabase MCP permite que assistentes de IA interajam diretamente com o banco de dados, facilitando o desenvolvimento e debug.

### O que o Supabase MCP permite fazer

- **Consultas SQL:** Executar queries diretamente no banco
- **Gerenciar tabelas:** Criar, modificar, deletar tabelas
- **Inserir dados:** Adicionar registros nas tabelas
- **Atualizar dados:** Modificar registros existentes
- **Deletar dados:** Remover registros
- **Gerenciar funções:** Criar e executar funções SQL
- **Configurar RLS:** Gerenciar Row Level Security

### Como configurar o Supabase MCP

1. **Instalar o MCP:** Baixe e configure o Supabase MCP no seu ambiente
2. **Configurar credenciais:** Forneça a URL do projeto e chave de serviço do Supabase
3. **Conectar ao assistente:** O assistente de IA ganha acesso direto ao banco

### Exemplos de uso do MCP

- **Criar tabelas:** Estruturar o banco de dados inicial
- **Inserir dados de teste:** Popular o banco com sinais e conteúdo de exemplo
- **Debugging:** Verificar o estado atual das tabelas e dados
- **Otimização:** Analisar queries e performance
- **Desenvolvimento:** Testar estruturas antes de implementar no código

### Vantagens do MCP para desenvolvimento

- **Prototipagem rápida:** Criar e testar estruturas de banco rapidamente
- **Debugging eficiente:** Verificar dados diretamente via IA
- **Desenvolvimento colaborativo:** IA pode ajudar a estruturar o banco
- **Testes automatizados:** Criar dados de teste consistentes

---

Qualquer dúvida sobre a estrutura, integração ou uso do MCP, consulte este arquivo ou o painel do Supabase. 