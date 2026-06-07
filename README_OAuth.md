Configurar OAuth (Google & Apple) para o app com Supabase

Resumo rápido
- Esquema de callback configurado no app: `signwriterfacil://login-callback`
- URL de callback a adicionar no Supabase (Auth > Providers): `signwriterfacil://login-callback`
- Também mantenha o padrão web callback em Supabase: `https://<YOUR_SUPABASE_PROJECT>.supabase.co/auth/v1/callback`

Passos detalhados

1) Supabase: habilitar provedores
- Acesse o Dashboard Supabase > Authentication > Providers.
- Ative Google: forneça Client ID e Client Secret do Google Cloud.
- Ative Apple: forneça Client ID (Service ID) e o Key (JWT) criado no Apple Developer.
- Em Redirect URLs adicione:
  - `https://<YOUR_SUPABASE_PROJECT>.supabase.co/auth/v1/callback`
  - `signwriterfacil://login-callback`

2) Google (Android/iOS)
- No Google Cloud Console, crie credenciais OAuth 2.0:
  - Para Android: crie um OAuth Client ID do tipo Android e adicione o pacote `applicationId` (ex.: `com.example.signwriter_facil`) e a impressão digital SHA-1/256 do certificado (para builds de release use a chave correta).
  - Para iOS: crie um OAuth Client ID do tipo iOS e adicione o Bundle ID (`$(PRODUCT_BUNDLE_IDENTIFIER)` ou seu bundle real).
- Use os Client ID/Secret gerados no painel do Supabase.

3) Apple (iOS)
- No Apple Developer:
  - Crie um Service ID e habilite "Sign In with Apple".
  - Crie uma Key para autenticação (private key) e copie o Key ID, Team ID e o conteúdo da chave.
- Use esses valores no Supabase (cada campo no painel do Supabase para Apple).
- Habilite capability "Sign in with Apple" no Xcode (Target > Signing & Capabilities).

4) Android (manifest já atualizado)
- O arquivo `android/app/src/main/AndroidManifest.xml` foi atualizado para aceitar deep links `signwriterfacil://login-callback`.
- Verifique `android/app/build.gradle.kts` e ajuste `applicationId` se desejar um ID personalizado.

5) iOS (Info.plist já atualizado)
- `ios/Runner/Info.plist` já tem `CFBundleURLTypes` com o esquema `signwriterfacil`.
- No Xcode habilite "Sign in with Apple" capability para o target e verifique o Bundle ID.

6) Testando localmente
- Rode:
```bash
flutter pub get
flutter run -d <seu_dispositivo>
```
- Na tela de login, pressione "Continuar com Google" ou "Continuar com Apple".
- O fluxo deverá abrir o navegador e, ao concluir, redirecionar para `signwriterfacil://login-callback` que reabrirá o app.

Observações e alternativas
- Se preferir evitar deep links, é possível usar `google_sign_in` e `sign_in_with_apple` localmente, trocando o token recebido pelo Supabase via endpoint `signInWithIdToken`. Posso implementar esse fluxo se preferir.
- Habilitar capacidades no Xcode (Sign in with Apple) não foi automatizado — é necessário abrir o projeto no Xcode e adicionar a capability.

Se quiser, eu:
- implemento a troca de tokens (`google_sign_in` + Supabase) em vez de deep links, ou
- faço commits com as mudanças de plataforma que já apliquei e crio um `PR` com instruções detalhadas.

Diga qual opção prefere (deep links continua ok, ou implementar token-exchange).