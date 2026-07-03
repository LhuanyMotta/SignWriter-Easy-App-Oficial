// Compartilhamento de dados exportados (JSON) de forma multiplataforma.
//
// Em mobile/desktop: salva um arquivo temporário e compartilha o arquivo
// (assim o usuário pode escolher "salvar em Arquivos", enviar por e-mail etc).
//
// Na Web: não existe sistema de arquivos nem dart:io, então a exportação é
// feita via Share.share() (texto) ou download direto pelo navegador.
//
// A escolha de qual implementação usar é feita em tempo de COMPILAÇÃO pelo
// Dart, usando a diretiva abaixo: se `dart:io` existir na plataforma atual
// (Android/iOS/Windows/macOS/Linux), usa `export_data_io.dart`; senão
// (Web), usa `export_data_web.dart`.
export 'export_data_io.dart' if (dart.library.html) 'export_data_web.dart';
