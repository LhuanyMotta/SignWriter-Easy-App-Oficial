/// Raios de borda padronizados — usar esses valores em vez de números soltos
/// (`BorderRadius.circular(14)`, `circular(18)`, `circular(20)`...) que
/// deixavam cada card do app com uma "personalidade" de cantos diferente.
class AppRadius {
  AppRadius._();

  /// Botões, chips, badges pequenos.
  static const double small = 10.0;

  /// Cards de lista/feature — o valor mais usado no app (dicionário,
  /// perfil...). Esse é o padrão pra qualquer "cartão" novo.
  static const double card = 16.0;

  /// Cards grandes/hero (banners, cabeçalhos destacados).
  static const double large = 20.0;

  /// Totalmente arredondado (avatares, indicadores de progresso, pills).
  static const double pill = 100.0;
}
