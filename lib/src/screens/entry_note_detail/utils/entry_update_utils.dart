import '../../../models/bullet_entry.dart';
import '../../../blocs/bullet_journal_bloc.dart';

/// Utility class for updating entries in diaries and pages
class EntryUpdateUtils {
  /// Finds the diary and page ID for an entry and updates it
  static void findDiaryIdAndPageIdAndUpdate(
    BulletJournalBloc bloc,
    BulletEntry entry,
    String focus,
    String note,
    TaskStatus? selectedStatus,
  ) {
    final state = bloc.state;

    // 엔트리가 어느 다이어리와 페이지에 속하는지 찾기
    String? diaryId;
    String? pageId;
    for (final diary in state.diaries) {
      // 다이어리 레벨 엔트리 확인
      if (diary.entries.any((e) => e.id == entry.id)) {
        diaryId = diary.id;
        break;
      }
      // 페이지 레벨 엔트리 확인
      for (final page in diary.pages) {
        if (page.entries.any((e) => e.id == entry.id)) {
          diaryId = diary.id;
          pageId = page.id;
          break;
        }
      }
      if (diaryId != null) break;
    }

    final updatedEntry = entry.copyWith(
      focus: focus,
      note: note,
      keyStatus: selectedStatus ?? entry.keyStatus,
    );

    if (diaryId != null && pageId != null) {
      // 페이지 레벨 엔트리 업데이트
      bloc.add(
        BulletJournalEvent.updateEntryInPage(
          diaryId: diaryId,
          pageId: pageId,
          entryId: entry.id,
          updatedEntry: updatedEntry,
        ),
      );
    } else if (diaryId != null) {
      // 다이어리 레벨 엔트리 업데이트
      bloc.add(
        BulletJournalEvent.updateEntryInDiary(
          diaryId: diaryId,
          entryId: entry.id,
          updatedEntry: updatedEntry,
        ),
      );
    } else {
      // 기본 엔트리
      bloc.add(
        BulletJournalEvent.updateEntry(
          entryId: entry.id,
          updatedEntry: updatedEntry,
        ),
      );
    }
  }
}

