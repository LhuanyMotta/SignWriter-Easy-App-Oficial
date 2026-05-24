class TranslationModel {
  final String id;
  final String sourceText;
  final List<String> signIds;
  final List<String> notFoundWords;
  final DateTime createdAt;

  TranslationModel({
    required this.id,
    required this.sourceText,
    required this.signIds,
    required this.notFoundWords,
    required this.createdAt,
  });
}
