import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/sample_entries.dart';
import '../models/bullet_entry.dart';
import '../models/key_definition.dart';
import '../models/diary.dart';
import '../models/diary_page.dart';
import '../models/diary_section.dart';

part 'bullet_journal_bloc.freezed.dart';

Map<String, String> _defaultStatusKeyMapping() => {
      TaskStatus.planned.id: 'key-incomplete',
      TaskStatus.inProgress.id: 'key-progress',
      TaskStatus.completed.id: 'key-completed',
    };

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
}

@freezed
class BulletJournalState with _$BulletJournalState {
  const factory BulletJournalState({
    @Default(<BulletEntry>[]) List<BulletEntry> entries,
    @Default(true) bool isLoading,
    @Default(<KeyDefinition>[]) List<KeyDefinition> customKeys,
    @Default(TaskStatus.defaultStatuses) List<TaskStatus> taskStatuses,
    @Default({}) Map<String, String> statusKeyMapping,
    @Default(<Diary>[]) List<Diary> diaries,
  }) = _BulletJournalState;
}

class BulletJournalBloc extends Bloc<BulletJournalEvent, BulletJournalState> {
  BulletJournalBloc({List<BulletEntry>? initialEntries})
      : _initialEntries = initialEntries ?? sampleEntries,
        super(BulletJournalState(
          statusKeyMapping: _defaultStatusKeyMapping(),
        )) {
    on<_LoadEntries>(_onLoadEntries);
    on<_ToggleTask>(_onToggleTask);
    on<_SnoozeTask>(_onSnoozeTask);
    on<_AddCustomKey>(_onAddCustomKey);
    on<_UpdateStatusKey>(_onUpdateStatusKey);
    on<_DeleteCustomKey>(_onDeleteCustomKey);
    on<_AddTaskStatus>(_onAddTaskStatus);
    on<_DeleteTaskStatus>(_onDeleteTaskStatus);
    on<_UpdateTaskStatusOrder>(_onUpdateTaskStatusOrder);
    on<_AddDiary>(_onAddDiary);
    on<_DeleteDiary>(_onDeleteDiary);
    on<_AddEntryToDiary>(_onAddEntryToDiary);
    on<_ToggleTaskInDiary>(_onToggleTaskInDiary);
    on<_SnoozeTaskInDiary>(_onSnoozeTaskInDiary);
    on<_UpdateEntry>(_onUpdateEntry);
    on<_UpdateEntryInDiary>(_onUpdateEntryInDiary);
    on<_UpdateDiary>(_onUpdateDiary);
    on<_ReorderEntriesInDiary>(_onReorderEntriesInDiary);
    on<_AddPageToDiary>(_onAddPageToDiary);
    on<_DeletePageFromDiary>(_onDeletePageFromDiary);
    on<_UpdatePageInDiary>(_onUpdatePageInDiary);
    on<_SetCurrentPageInDiary>(_onSetCurrentPageInDiary);
    on<_TogglePageFavoriteInDiary>(_onTogglePageFavoriteInDiary);
    on<_ReorderPagesInDiary>(_onReorderPagesInDiary);
    on<_AddEntryToPage>(_onAddEntryToPage);
    on<_UpdateEntryInPage>(_onUpdateEntryInPage);
    on<_ReorderEntriesInPage>(_onReorderEntriesInPage);
    on<_ToggleTaskInPage>(_onToggleTaskInPage);
    on<_SnoozeTaskInPage>(_onSnoozeTaskInPage);
    on<_AddSectionToPage>(_onAddSectionToPage);
    on<_DeleteSectionFromPage>(_onDeleteSectionFromPage);
    on<_UpdateSectionInPage>(_onUpdateSectionInPage);
    on<_ReorderSectionsInPage>(_onReorderSectionsInPage);
    on<_AssignEntryToSection>(_onAssignEntryToSection);
    add(const BulletJournalEvent.loadEntries());
  }

  final List<BulletEntry> _initialEntries;

  void _onLoadEntries(
    _LoadEntries event,
    Emitter<BulletJournalState> emit,
  ) {
    emit(state.copyWith(
      entries: _initialEntries,
      isLoading: false,
    ));
  }

  void _onToggleTask(
    _ToggleTask event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedEntries = state.entries.map((entry) {
      if (entry.id != event.entryId) return entry;

      final updatedTasks = entry.tasks.map((task) {
        if (task.id != event.taskId) return task;
        return task.copyWith(
          status: task.status.next(state.taskStatuses),
        );
      }).toList();

      return entry.copyWith(tasks: updatedTasks);
    }).toList();

    emit(state.copyWith(entries: updatedEntries));
  }

  void _onSnoozeTask(
    _SnoozeTask event,
    Emitter<BulletJournalState> emit,
  ) {
    final now = DateTime.now();
    final updatedEntries = state.entries.map((entry) {
      if (entry.id != event.entryId) return entry;

      final updatedTasks = entry.tasks.map((task) {
        if (task.id != event.taskId) return task;
        final postponedTo = now.add(event.postpone);
        final updatedSnoozes = [
          ...task.snoozes,
          SnoozeInfo(requestedAt: now, postponedTo: postponedTo),
        ];
        return task.copyWith(
          status: TaskStatus.planned,
          dueDate: postponedTo,
          snoozes: updatedSnoozes,
        );
      }).toList();

      return entry.copyWith(tasks: updatedTasks);
    }).toList();

    emit(state.copyWith(entries: updatedEntries));
  }

  void _onAddCustomKey(
    _AddCustomKey event,
    Emitter<BulletJournalState> emit,
  ) {
    emit(state.copyWith(customKeys: [...state.customKeys, event.definition]));
  }

  void _onUpdateStatusKey(
    _UpdateStatusKey event,
    Emitter<BulletJournalState> emit,
  ) {
    emit(state.copyWith(
      statusKeyMapping: {
        ...state.statusKeyMapping,
        event.status.id: event.keyId,
      },
    ));
  }

  void _onDeleteCustomKey(
    _DeleteCustomKey event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedCustomKeys = state.customKeys
        .where((key) => key.id != event.keyId)
        .toList();
    emit(state.copyWith(customKeys: updatedCustomKeys));
  }

  void _onAddTaskStatus(
    _AddTaskStatus event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedStatuses = [...state.taskStatuses, event.status]
      ..sort((a, b) => a.order.compareTo(b.order));
    emit(state.copyWith(taskStatuses: updatedStatuses));
  }

  void _onDeleteTaskStatus(
    _DeleteTaskStatus event,
    Emitter<BulletJournalState> emit,
  ) {
    // 기본 상태는 삭제 불가
    final isDefault = TaskStatus.defaultStatuses
        .any((status) => status.id == event.statusId);
    if (isDefault) return;

    // "기타" 상태 찾기
    final etcStatus = TaskStatus.etc;

    // 기본 엔트리에서 해당 상태를 사용하는 작업들을 "기타"로 마이그레이션
    final updatedEntries = state.entries.map((entry) {
      final hasTargetStatus = entry.tasks.any(
        (task) => task.status.id == event.statusId,
      );
      if (!hasTargetStatus) return entry;

      final updatedTasks = entry.tasks.map((task) {
        if (task.status.id == event.statusId) {
          return task.copyWith(status: etcStatus);
        }
        return task;
      }).toList();

      return entry.copyWith(tasks: updatedTasks);
    }).toList();

    // 다이어리 엔트리에서 해당 상태를 사용하는 작업들을 "기타"로 마이그레이션
    final updatedDiaries = state.diaries.map((diary) {
      final updatedDiaryEntries = diary.entries.map((entry) {
        final hasTargetStatus = entry.tasks.any(
          (task) => task.status.id == event.statusId,
        );
        if (!hasTargetStatus) return entry;

        final updatedTasks = entry.tasks.map((task) {
          if (task.status.id == event.statusId) {
            return task.copyWith(status: etcStatus);
          }
          return task;
        }).toList();

        return entry.copyWith(tasks: updatedTasks);
      }).toList();

      return diary.copyWith(entries: updatedDiaryEntries);
    }).toList();

    // 상태 목록에서 삭제
    final updatedStatuses = state.taskStatuses
        .where((status) => status.id != event.statusId)
        .toList();
    final updatedMapping = Map<String, String>.from(state.statusKeyMapping)
      ..remove(event.statusId);

    emit(state.copyWith(
      entries: updatedEntries,
      diaries: updatedDiaries,
      taskStatuses: updatedStatuses,
      statusKeyMapping: updatedMapping,
    ));
  }

  void _onUpdateTaskStatusOrder(
    _UpdateTaskStatusOrder event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedStatuses = state.taskStatuses.map((status) {
      if (status.id == event.statusId) {
        return status.copyWith(order: event.newOrder);
      }
      return status;
    }).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    emit(state.copyWith(taskStatuses: updatedStatuses));
  }

  void _onAddDiary(
    _AddDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    emit(state.copyWith(diaries: [...state.diaries, event.diary]));
  }

  void _onDeleteDiary(
    _DeleteDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries
        .where((diary) => diary.id != event.diaryId)
        .toList();
    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAddEntryToDiary(
    _AddEntryToDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      return diary.copyWith(entries: [...diary.entries, event.entry]);
    }).toList();
    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onToggleTaskInDiary(
    _ToggleTaskInDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;

      final updatedEntries = diary.entries.map((entry) {
        if (entry.id != event.entryId) return entry;

        final updatedTasks = entry.tasks.map((task) {
          if (task.id != event.taskId) return task;
          return task.copyWith(
            status: task.status.next(state.taskStatuses),
          );
        }).toList();

        return entry.copyWith(tasks: updatedTasks);
      }).toList();

      return diary.copyWith(entries: updatedEntries);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onSnoozeTaskInDiary(
    _SnoozeTaskInDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    final now = DateTime.now();
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;

      final updatedEntries = diary.entries.map((entry) {
        if (entry.id != event.entryId) return entry;

        final updatedTasks = entry.tasks.map((task) {
          if (task.id != event.taskId) return task;
          final postponedTo = now.add(event.postpone);
          final updatedSnoozes = [
            ...task.snoozes,
            SnoozeInfo(requestedAt: now, postponedTo: postponedTo),
          ];
          return task.copyWith(
            status: TaskStatus.planned,
            dueDate: postponedTo,
            snoozes: updatedSnoozes,
          );
        }).toList();

        return entry.copyWith(tasks: updatedTasks);
      }).toList();

      return diary.copyWith(entries: updatedEntries);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdateEntry(
    _UpdateEntry event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedEntries = state.entries.map((entry) {
      if (entry.id != event.entryId) return entry;
      return event.updatedEntry;
    }).toList();
    emit(state.copyWith(entries: updatedEntries));
  }

  void _onUpdateEntryInDiary(
    _UpdateEntryInDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;

      final updatedEntries = diary.entries.map((entry) {
        if (entry.id != event.entryId) return entry;
        return event.updatedEntry;
      }).toList();

      return diary.copyWith(entries: updatedEntries);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdateDiary(
    _UpdateDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      return event.updatedDiary;
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onReorderEntriesInDiary(
    _ReorderEntriesInDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      return diary.copyWith(entries: event.reorderedEntries);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAddPageToDiary(
    _AddPageToDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final newPages = [...diary.pages, event.page];
      final newCurrentPageId = diary.currentPageId ?? event.page.id;
      return diary.copyWith(
        pages: newPages,
        currentPageId: newCurrentPageId,
      );
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onDeletePageFromDiary(
    _DeletePageFromDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final newPages = diary.pages.where((p) => p.id != event.pageId).toList();
      String? newCurrentPageId = diary.currentPageId;
      if (diary.currentPageId == event.pageId) {
        newCurrentPageId = newPages.isNotEmpty ? newPages.first.id : null;
      }
      return diary.copyWith(
        pages: newPages,
        currentPageId: newCurrentPageId,
      );
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdatePageInDiary(
    _UpdatePageInDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != event.pageId) return page;
        return event.updatedPage;
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onSetCurrentPageInDiary(
    _SetCurrentPageInDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      return diary.copyWith(currentPageId: event.pageId);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onTogglePageFavoriteInDiary(
    _TogglePageFavoriteInDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != event.pageId) return page;
        return page.copyWith(isFavorite: !page.isFavorite);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onReorderPagesInDiary(
    _ReorderPagesInDiary event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      return diary.copyWith(pages: event.reorderedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAddEntryToPage(
    _AddEntryToPage event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != event.pageId) return page;
        return page.copyWith(entries: [...page.entries, event.entry]);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdateEntryInPage(
    _UpdateEntryInPage event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != event.pageId) return page;
        final updatedEntries = page.entries.map((entry) {
          if (entry.id != event.entryId) return entry;
          return event.updatedEntry;
        }).toList();
        return page.copyWith(entries: updatedEntries);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onReorderEntriesInPage(
    _ReorderEntriesInPage event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != event.pageId) return page;
        return page.copyWith(entries: event.reorderedEntries);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onToggleTaskInPage(
    _ToggleTaskInPage event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != event.pageId) return page;
        final updatedEntries = page.entries.map((entry) {
          if (entry.id != event.entryId) return entry;
          final updatedTasks = entry.tasks.map((task) {
            if (task.id != event.taskId) return task;
            return task.copyWith(
              status: task.status.next(state.taskStatuses),
            );
          }).toList();
          return entry.copyWith(tasks: updatedTasks);
        }).toList();
        return page.copyWith(entries: updatedEntries);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onSnoozeTaskInPage(
    _SnoozeTaskInPage event,
    Emitter<BulletJournalState> emit,
  ) {
    final now = DateTime.now();
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != event.pageId) return page;
        final updatedEntries = page.entries.map((entry) {
          if (entry.id != event.entryId) return entry;
          final updatedTasks = entry.tasks.map((task) {
            if (task.id != event.taskId) return task;
            final postponedTo = now.add(event.postpone);
            final updatedSnoozes = [
              ...task.snoozes,
              SnoozeInfo(requestedAt: now, postponedTo: postponedTo),
            ];
            return task.copyWith(
              status: TaskStatus.planned,
              dueDate: postponedTo,
              snoozes: updatedSnoozes,
            );
          }).toList();
          return entry.copyWith(tasks: updatedTasks);
        }).toList();
        return page.copyWith(entries: updatedEntries);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAddSectionToPage(
    _AddSectionToPage event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != event.pageId) return page;
        // 섹션의 order 설정 (현재 섹션 개수)
        final newSection = event.section.copyWith(
          order: page.sections.length,
        );
        return page.copyWith(
          sections: [...page.sections, newSection],
        );
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onDeleteSectionFromPage(
    _DeleteSectionFromPage event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != event.pageId) return page;
        // 섹션 삭제 및 해당 섹션의 엔트리들 sectionId를 null로 설정
        final updatedEntries = page.entries.map((entry) {
          if (entry.sectionId == event.sectionId) {
            return entry.copyWith(sectionId: null);
          }
          return entry;
        }).toList();
        final updatedSections = page.sections
            .where((section) => section.id != event.sectionId)
            .toList();
        return page.copyWith(
          sections: updatedSections,
          entries: updatedEntries,
        );
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdateSectionInPage(
    _UpdateSectionInPage event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != event.pageId) return page;
        final updatedSections = page.sections.map((section) {
          if (section.id != event.sectionId) return section;
          return event.updatedSection;
        }).toList();
        return page.copyWith(sections: updatedSections);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onReorderSectionsInPage(
    _ReorderSectionsInPage event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != event.pageId) return page;
        // order 업데이트
        final updatedSections = event.reorderedSections.asMap().entries.map((entry) {
          return entry.value.copyWith(order: entry.key);
        }).toList();
        return page.copyWith(sections: updatedSections);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAssignEntryToSection(
    _AssignEntryToSection event,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != event.diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != event.pageId) return page;
        final updatedEntries = page.entries.map((entry) {
          if (entry.id != event.entryId) return entry;
          return entry.copyWith(sectionId: event.sectionId);
        }).toList();
        return page.copyWith(entries: updatedEntries);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }
}

