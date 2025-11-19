import '../../../models/bullet_entry.dart';
import '../../../blocs/bullet_journal_bloc.dart';

/// Utility class for finding entries in diaries and pages
class EntryFinderUtils {
  /// Finds the current entry in the state by its ID
  static BulletEntry getCurrentEntry(
    String entryId,
    BulletJournalState state,
    BulletEntry fallbackEntry,
  ) {
    // 다이어리와 페이지에서 찾기
    for (final diary in state.diaries) {
      // 다이어리 레벨 엔트리 확인
      try {
        final entry = diary.entries.firstWhere(
          (e) => e.id == entryId,
        );
        return entry;
      } catch (e) {
        // 엔트리를 찾지 못함, 계속 진행
      }
      // 페이지 레벨 엔트리 확인
      for (final page in diary.pages) {
        try {
          final entry = page.entries.firstWhere(
            (e) => e.id == entryId,
          );
          return entry;
        } catch (e) {
          // 엔트리를 찾지 못함, 계속 진행
        }
      }
    }
    // 기본 엔트리에서 찾기
    try {
      final entry = state.entries.firstWhere(
        (e) => e.id == entryId,
      );
      return entry;
    } catch (e) {
      // 엔트리를 찾지 못함, 원본 반환
      return fallbackEntry;
    }
  }
}

