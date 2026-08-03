enum LessonSaveOutcome {
  saved,
  draftPreserved,
  failed,
}

/// Resultado persistido de uma operação editorial de lição.
class LessonSaveResult {
  final LessonSaveOutcome outcome;
  final String? lessonId;
  final String savedStatus;

  const LessonSaveResult._({
    required this.outcome,
    required this.lessonId,
    required this.savedStatus,
  });

  const LessonSaveResult.saved({
    required String lessonId,
    required String status,
  }) : this._(
          outcome: LessonSaveOutcome.saved,
          lessonId: lessonId,
          savedStatus: status,
        );

  const LessonSaveResult.draftPreserved({required String lessonId})
      : this._(
          outcome: LessonSaveOutcome.draftPreserved,
          lessonId: lessonId,
          savedStatus: 'draft',
        );

  const LessonSaveResult.failed()
      : this._(
          outcome: LessonSaveOutcome.failed,
          lessonId: null,
          savedStatus: 'draft',
        );

  bool get isSaved => outcome == LessonSaveOutcome.saved;
  bool get isDraftPreserved => outcome == LessonSaveOutcome.draftPreserved;
  bool get canCloseEditor => outcome != LessonSaveOutcome.failed;
}
