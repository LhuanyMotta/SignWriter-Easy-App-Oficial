/// Implementação neutra para plataformas sem `dart:io` (como Flutter Web).
class LearningImageCache {
  factory LearningImageCache() => _instance;

  LearningImageCache._();

  static final LearningImageCache _instance = LearningImageCache._();

  Future<String?> resolve(String url) async => null;

  Future<void> prefetchAll(Iterable<String> urls) async {}
}
