import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/bullet_entry.dart';
import '../models/key_definition.dart';
import '../models/diary.dart';
import '../models/diary_page.dart';
import '../models/diary_section.dart';
import '../models/page_component.dart';

part 'bullet_journal_event.freezed.dart';

@freezed
class BulletJournalEvent with _$BulletJournalEvent {
  const factory BulletJournalEvent.loadEntries() = _LoadEntries;
  const factory BulletJournalEvent.toggleTask({
    required String entryId,
    required String taskId,
  }) = _ToggleTask;
  const factory BulletJournalEvent.snoozeTask({
    required String entryId,
    required String taskId,
    required Duration postpone,
  }) = _SnoozeTask;
  const factory BulletJournalEvent.addCustomKey(KeyDefinition definition) =
      _AddCustomKey;
  const factory BulletJournalEvent.updateStatusKey({
    required TaskStatus status,
    required String keyId,
  }) = _UpdateStatusKey;
  const factory BulletJournalEvent.deleteCustomKey(String keyId) =
      _DeleteCustomKey;
  const factory BulletJournalEvent.addTaskStatus(TaskStatus status) =
      _AddTaskStatus;
  const factory BulletJournalEvent.deleteTaskStatus(String statusId) =
      _DeleteTaskStatus;
  const factory BulletJournalEvent.updateTaskStatusOrder({
    required String statusId,
    required int newOrder,
  }) = _UpdateTaskStatusOrder;
  const factory BulletJournalEvent.addDiary(Diary diary) = _AddDiary;
  const factory BulletJournalEvent.deleteDiary(String diaryId) = _DeleteDiary;
  const factory BulletJournalEvent.addEntryToDiary({
    required String diaryId,
    required BulletEntry entry,
  }) = _AddEntryToDiary;
  const factory BulletJournalEvent.toggleTaskInDiary({
    required String diaryId,
    required String entryId,
    required String taskId,
  }) = _ToggleTaskInDiary;
  const factory BulletJournalEvent.snoozeTaskInDiary({
    required String diaryId,
    required String entryId,
    required String taskId,
    required Duration postpone,
  }) = _SnoozeTaskInDiary;
  const factory BulletJournalEvent.updateEntry({
    required String entryId,
    required BulletEntry updatedEntry,
  }) = _UpdateEntry;
  const factory BulletJournalEvent.updateEntryInDiary({
    required String diaryId,
    required String entryId,
    required BulletEntry updatedEntry,
  }) = _UpdateEntryInDiary;
  const factory BulletJournalEvent.updateDiary({
    required String diaryId,
    required Diary updatedDiary,
  }) = _UpdateDiary;
  const factory BulletJournalEvent.reorderEntriesInDiary({
    required String diaryId,
    required List<BulletEntry> reorderedEntries,
  }) = _ReorderEntriesInDiary;
  const factory BulletJournalEvent.addPageToDiary({
    required String diaryId,
    required DiaryPage page,
  }) = _AddPageToDiary;
  const factory BulletJournalEvent.deletePageFromDiary({
    required String diaryId,
    required String pageId,
  }) = _DeletePageFromDiary;
  const factory BulletJournalEvent.updatePageInDiary({
    required String diaryId,
    required String pageId,
    required DiaryPage updatedPage,
  }) = _UpdatePageInDiary;
  const factory BulletJournalEvent.setCurrentPageInDiary({
    required String diaryId,
    required String? pageId,
  }) = _SetCurrentPageInDiary;
  const factory BulletJournalEvent.togglePageFavoriteInDiary({
    required String diaryId,
    required String pageId,
  }) = _TogglePageFavoriteInDiary;
  const factory BulletJournalEvent.reorderPagesInDiary({
    required String diaryId,
    required List<DiaryPage> reorderedPages,
  }) = _ReorderPagesInDiary;
  const factory BulletJournalEvent.addEntryToPage({
    required String diaryId,
    required String pageId,
    required BulletEntry entry,
  }) = _AddEntryToPage;
  const factory BulletJournalEvent.updateEntryInPage({
    required String diaryId,
    required String pageId,
    required String entryId,
    required BulletEntry updatedEntry,
  }) = _UpdateEntryInPage;
  const factory BulletJournalEvent.reorderEntriesInPage({
    required String diaryId,
    required String pageId,
    required List<BulletEntry> reorderedEntries,
  }) = _ReorderEntriesInPage;
  const factory BulletJournalEvent.toggleTaskInPage({
    required String diaryId,
    required String pageId,
    required String entryId,
    required String taskId,
  }) = _ToggleTaskInPage;
  const factory BulletJournalEvent.snoozeTaskInPage({
    required String diaryId,
    required String pageId,
    required String entryId,
    required String taskId,
    required Duration postpone,
  }) = _SnoozeTaskInPage;
  const factory BulletJournalEvent.addSectionToPage({
    required String diaryId,
    required String pageId,
    required DiarySection section,
  }) = _AddSectionToPage;
  const factory BulletJournalEvent.deleteSectionFromPage({
    required String diaryId,
    required String pageId,
    required String sectionId,
  }) = _DeleteSectionFromPage;
  const factory BulletJournalEvent.updateSectionInPage({
    required String diaryId,
    required String pageId,
    required String sectionId,
    required DiarySection updatedSection,
  }) = _UpdateSectionInPage;
  const factory BulletJournalEvent.reorderSectionsInPage({
    required String diaryId,
    required String pageId,
    required List<DiarySection> reorderedSections,
  }) = _ReorderSectionsInPage;
  const factory BulletJournalEvent.assignEntryToSection({
    required String diaryId,
    required String pageId,
    required String entryId,
    required String? sectionId,
  }) = _AssignEntryToSection;

  // 컴포넌트 관련 이벤트
  const factory BulletJournalEvent.addComponentToPage({
    required String diaryId,
    required String pageId,
    required PageComponent component,
  }) = _AddComponentToPage;
  const factory BulletJournalEvent.deleteComponentFromPage({
    required String diaryId,
    required String pageId,
    required String componentId,
  }) = _DeleteComponentFromPage;
  const factory BulletJournalEvent.updateComponentInPage({
    required String diaryId,
    required String pageId,
    required String componentId,
    required PageComponent updatedComponent,
  }) = _UpdateComponentInPage;
  const factory BulletJournalEvent.reorderComponentsInPage({
    required String diaryId,
    required String pageId,
    required List<PageComponent> reorderedComponents,
  }) = _ReorderComponentsInPage;
  const factory BulletJournalEvent.updateLayoutOrderInPage({
    required String diaryId,
    required String pageId,
    required List<String> layoutOrder,
  }) = _UpdateLayoutOrderInPage;

  // 타임테이블 셀 업데이트
  const factory BulletJournalEvent.updateTimeTableCell({
    required String diaryId,
    required String pageId,
    required String componentId,
    required int row,
    required int column,
    required String content,
  }) = _UpdateTimeTableCell;
}
