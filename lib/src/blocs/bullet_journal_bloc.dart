import 'package:bloc/bloc.dart';

import '../data/sample_entries.dart';
import '../models/bullet_entry.dart';
import '../models/diary.dart';
import '../models/diary_page.dart';
import '../models/diary_section.dart';
import '../models/key_definition.dart';
import 'bullet_journal_event.dart';
import 'bullet_journal_state.dart';

// Re-export Event and State for convenience
export 'bullet_journal_event.dart';
export 'bullet_journal_state.dart';

class BulletJournalBloc extends Bloc<BulletJournalEvent, BulletJournalState> {
  BulletJournalBloc({List<BulletEntry>? initialEntries})
      : _initialEntries = initialEntries ?? sampleEntries,
        super(BulletJournalState(
          statusKeyMapping: BulletJournalStateExtension.defaultStatusKeyMapping(),
        )) {
    on<BulletJournalEvent>((event, emit) {
      event.when(
        loadEntries: () => _onLoadEntries(emit),
        toggleTask: (entryId, taskId) => _onToggleTask(entryId, taskId, emit),
        snoozeTask: (entryId, taskId, postpone) => _onSnoozeTask(entryId, taskId, postpone, emit),
        addCustomKey: (definition) => _onAddCustomKey(definition, emit),
        updateStatusKey: (status, keyId) => _onUpdateStatusKey(status, keyId, emit),
        deleteCustomKey: (keyId) => _onDeleteCustomKey(keyId, emit),
        addTaskStatus: (status) => _onAddTaskStatus(status, emit),
        deleteTaskStatus: (statusId) => _onDeleteTaskStatus(statusId, emit),
        updateTaskStatusOrder: (statusId, newOrder) => _onUpdateTaskStatusOrder(statusId, newOrder, emit),
        addDiary: (diary) => _onAddDiary(diary, emit),
        deleteDiary: (diaryId) => _onDeleteDiary(diaryId, emit),
        addEntryToDiary: (diaryId, entry) => _onAddEntryToDiary(diaryId, entry, emit),
        toggleTaskInDiary: (diaryId, entryId, taskId) => _onToggleTaskInDiary(diaryId, entryId, taskId, emit),
        snoozeTaskInDiary: (diaryId, entryId, taskId, postpone) => _onSnoozeTaskInDiary(diaryId, entryId, taskId, postpone, emit),
        updateEntry: (entryId, updatedEntry) => _onUpdateEntry(entryId, updatedEntry, emit),
        updateEntryInDiary: (diaryId, entryId, updatedEntry) => _onUpdateEntryInDiary(diaryId, entryId, updatedEntry, emit),
        updateDiary: (diaryId, updatedDiary) => _onUpdateDiary(diaryId, updatedDiary, emit),
        reorderEntriesInDiary: (diaryId, reorderedEntries) => _onReorderEntriesInDiary(diaryId, reorderedEntries, emit),
        addPageToDiary: (diaryId, page) => _onAddPageToDiary(diaryId, page, emit),
        deletePageFromDiary: (diaryId, pageId) => _onDeletePageFromDiary(diaryId, pageId, emit),
        updatePageInDiary: (diaryId, pageId, updatedPage) => _onUpdatePageInDiary(diaryId, pageId, updatedPage, emit),
        setCurrentPageInDiary: (diaryId, pageId) => _onSetCurrentPageInDiary(diaryId, pageId, emit),
        togglePageFavoriteInDiary: (diaryId, pageId) => _onTogglePageFavoriteInDiary(diaryId, pageId, emit),
        reorderPagesInDiary: (diaryId, reorderedPages) => _onReorderPagesInDiary(diaryId, reorderedPages, emit),
        addEntryToPage: (diaryId, pageId, entry) => _onAddEntryToPage(diaryId, pageId, entry, emit),
        updateEntryInPage: (diaryId, pageId, entryId, updatedEntry) => _onUpdateEntryInPage(diaryId, pageId, entryId, updatedEntry, emit),
        reorderEntriesInPage: (diaryId, pageId, reorderedEntries) => _onReorderEntriesInPage(diaryId, pageId, reorderedEntries, emit),
        toggleTaskInPage: (diaryId, pageId, entryId, taskId) => _onToggleTaskInPage(diaryId, pageId, entryId, taskId, emit),
        snoozeTaskInPage: (diaryId, pageId, entryId, taskId, postpone) => _onSnoozeTaskInPage(diaryId, pageId, entryId, taskId, postpone, emit),
        addSectionToPage: (diaryId, pageId, section) => _onAddSectionToPage(diaryId, pageId, section, emit),
        deleteSectionFromPage: (diaryId, pageId, sectionId) => _onDeleteSectionFromPage(diaryId, pageId, sectionId, emit),
        updateSectionInPage: (diaryId, pageId, sectionId, updatedSection) => _onUpdateSectionInPage(diaryId, pageId, sectionId, updatedSection, emit),
        reorderSectionsInPage: (diaryId, pageId, reorderedSections) => _onReorderSectionsInPage(diaryId, pageId, reorderedSections, emit),
        assignEntryToSection: (diaryId, pageId, entryId, sectionId) => _onAssignEntryToSection(diaryId, pageId, entryId, sectionId, emit),
      );
    });
    add(const BulletJournalEvent.loadEntries());
  }

  final List<BulletEntry> _initialEntries;

  void _onLoadEntries(
    Emitter<BulletJournalState> emit,
  ) {
    emit(state.copyWith(
      entries: _initialEntries,
      isLoading: false,
    ));
  }

  void _onToggleTask(
    String entryId,
    String taskId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedEntries = state.entries.map((entry) {
      if (entry.id != entryId) return entry;

      final updatedTasks = entry.tasks.map((task) {
        if (task.id != taskId) return task;
        return task.copyWith(
          status: task.status.next(state.taskStatuses),
        );
      }).toList();

      return entry.copyWith(tasks: updatedTasks);
    }).toList();

    emit(state.copyWith(entries: updatedEntries));
  }

  void _onSnoozeTask(String entryId, String taskId, Duration postpone,
    Emitter<BulletJournalState> emit,
  ) {
    final now = DateTime.now();
    final updatedEntries = state.entries.map((entry) {
      if (entry.id != entryId) return entry;

      final updatedTasks = entry.tasks.map((task) {
        if (task.id != taskId) return task;
        final postponedTo = now.add(postpone);
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

  void _onAddCustomKey(KeyDefinition definition,
    Emitter<BulletJournalState> emit,
  ) {
    emit(state.copyWith(customKeys: [...state.customKeys, definition]));
  }

  void _onUpdateStatusKey(TaskStatus status, String keyId,
    Emitter<BulletJournalState> emit,
  ) {
    emit(state.copyWith(
      statusKeyMapping: {
        ...state.statusKeyMapping,
        status.id: keyId,
      },
    ));
  }

  void _onDeleteCustomKey(String keyId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedCustomKeys = state.customKeys
        .where((key) => key.id != keyId)
        .toList();
    emit(state.copyWith(customKeys: updatedCustomKeys));
  }

  void _onAddTaskStatus(TaskStatus status,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedStatuses = [...state.taskStatuses, status]
      ..sort((a, b) => a.order.compareTo(b.order));
    emit(state.copyWith(taskStatuses: updatedStatuses));
  }

  void _onDeleteTaskStatus(String statusId,
    Emitter<BulletJournalState> emit,
  ) {
    // 기본 상태는 삭제 불가
    final isDefault = TaskStatus.defaultStatuses
        .any((status) => status.id == statusId);
    if (isDefault) return;

    // "기타" 상태 찾기
    final etcStatus = TaskStatus.etc;

    // 기본 엔트리에서 해당 상태를 사용하는 작업들을 "기타"로 마이그레이션
    final updatedEntries = state.entries.map((entry) {
      final hasTargetStatus = entry.tasks.any(
        (task) => task.status.id == statusId,
      );
      if (!hasTargetStatus) return entry;

      final updatedTasks = entry.tasks.map((task) {
        if (task.status.id == statusId) {
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
          (task) => task.status.id == statusId,
        );
        if (!hasTargetStatus) return entry;

        final updatedTasks = entry.tasks.map((task) {
          if (task.status.id == statusId) {
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
        .where((status) => status.id != statusId)
        .toList();
    final updatedMapping = Map<String, String>.from(state.statusKeyMapping)
      ..remove(statusId);

    emit(state.copyWith(
      entries: updatedEntries,
      diaries: updatedDiaries,
      taskStatuses: updatedStatuses,
      statusKeyMapping: updatedMapping,
    ));
  }

  void _onUpdateTaskStatusOrder(String statusId, int newOrder,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedStatuses = state.taskStatuses.map((status) {
      if (status.id == statusId) {
        return status.copyWith(order: newOrder);
      }
      return status;
    }).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    emit(state.copyWith(taskStatuses: updatedStatuses));
  }

  void _onAddDiary(Diary diary,
    Emitter<BulletJournalState> emit,
  ) {
    emit(state.copyWith(diaries: [...state.diaries, diary]));
  }

  void _onDeleteDiary(String diaryId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries
        .where((diary) => diary.id != diaryId)
        .toList();
    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAddEntryToDiary(String diaryId, BulletEntry entry,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      return diary.copyWith(entries: [...diary.entries, entry]);
    }).toList();
    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onToggleTaskInDiary(String diaryId, String entryId, String taskId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;

      final updatedEntries = diary.entries.map((entry) {
        if (entry.id != entryId) return entry;

        final updatedTasks = entry.tasks.map((task) {
          if (task.id != taskId) return task;
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

  void _onSnoozeTaskInDiary(String diaryId, String entryId, String taskId, Duration postpone,
    Emitter<BulletJournalState> emit,
  ) {
    final now = DateTime.now();
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;

      final updatedEntries = diary.entries.map((entry) {
        if (entry.id != entryId) return entry;

        final updatedTasks = entry.tasks.map((task) {
          if (task.id != taskId) return task;
          final postponedTo = now.add(postpone);
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

  void _onUpdateEntry(String entryId, BulletEntry updatedEntry,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedEntries = state.entries.map((entry) {
      if (entry.id != entryId) return entry;
      return updatedEntry;
    }).toList();
    emit(state.copyWith(entries: updatedEntries));
  }

  void _onUpdateEntryInDiary(String diaryId, String entryId, BulletEntry updatedEntry,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;

      final updatedEntries = diary.entries.map((entry) {
        if (entry.id != entryId) return entry;
        return updatedEntry;
      }).toList();

      return diary.copyWith(entries: updatedEntries);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdateDiary(String diaryId, Diary updatedDiary,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      return updatedDiary;
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onReorderEntriesInDiary(String diaryId, List<BulletEntry> reorderedEntries,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      return diary.copyWith(entries: reorderedEntries);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAddPageToDiary(String diaryId, DiaryPage page,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final newPages = [...diary.pages, page];
      final newCurrentPageId = diary.currentPageId ?? page.id;
      return diary.copyWith(
        pages: newPages,
        currentPageId: newCurrentPageId,
      );
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onDeletePageFromDiary(String diaryId, String pageId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final newPages = diary.pages.where((p) => p.id != pageId).toList();
      String? newCurrentPageId = diary.currentPageId;
      if (diary.currentPageId == pageId) {
        newCurrentPageId = newPages.isNotEmpty ? newPages.first.id : null;
      }
      return diary.copyWith(
        pages: newPages,
        currentPageId: newCurrentPageId,
      );
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdatePageInDiary(String diaryId, String pageId, DiaryPage updatedPage,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        return updatedPage;
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onSetCurrentPageInDiary(String diaryId, String? pageId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      return diary.copyWith(currentPageId: pageId);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onTogglePageFavoriteInDiary(String diaryId, String pageId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        return page.copyWith(isFavorite: !page.isFavorite);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onReorderPagesInDiary(String diaryId, List<DiaryPage> reorderedPages,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      return diary.copyWith(pages: reorderedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAddEntryToPage(String diaryId, String pageId, BulletEntry entry,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        return page.copyWith(entries: [...page.entries, entry]);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdateEntryInPage(String diaryId, String pageId, String entryId, BulletEntry updatedEntry,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedEntries = page.entries.map((entry) {
          if (entry.id != entryId) return entry;
          return updatedEntry;
        }).toList();
        return page.copyWith(entries: updatedEntries);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onReorderEntriesInPage(String diaryId, String pageId, List<BulletEntry> reorderedEntries,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        return page.copyWith(entries: reorderedEntries);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onToggleTaskInPage(String diaryId, String pageId, String entryId, String taskId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedEntries = page.entries.map((entry) {
          if (entry.id != entryId) return entry;
          final updatedTasks = entry.tasks.map((task) {
            if (task.id != taskId) return task;
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

  void _onSnoozeTaskInPage(String diaryId, String pageId, String entryId, String taskId, Duration postpone,
    Emitter<BulletJournalState> emit,
  ) {
    final now = DateTime.now();
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedEntries = page.entries.map((entry) {
          if (entry.id != entryId) return entry;
          final updatedTasks = entry.tasks.map((task) {
            if (task.id != taskId) return task;
            final postponedTo = now.add(postpone);
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

  void _onAddSectionToPage(String diaryId, String pageId, DiarySection section,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        // 섹션의 order 설정 (현재 섹션 개수)
        final newSection = section.copyWith(
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

  void _onDeleteSectionFromPage(String diaryId, String pageId, String sectionId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        // 섹션 삭제 및 해당 섹션의 엔트리들 sectionId를 null로 설정
        final updatedEntries = page.entries.map((entry) {
          if (entry.sectionId == sectionId) {
            return entry.copyWith(sectionId: null);
          }
          return entry;
        }).toList();
        final updatedSections = page.sections
            .where((section) => section.id != sectionId)
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

  void _onUpdateSectionInPage(String diaryId, String pageId, String sectionId, DiarySection updatedSection,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedSections = page.sections.map((section) {
          if (section.id != sectionId) return section;
          return updatedSection;
        }).toList();
        return page.copyWith(sections: updatedSections);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onReorderSectionsInPage(String diaryId, String pageId, List<DiarySection> reorderedSections,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        // order 업데이트
        final updatedSections = reorderedSections.asMap().entries.map((entry) {
          return entry.value.copyWith(order: entry.key);
        }).toList();
        return page.copyWith(sections: updatedSections);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAssignEntryToSection(String diaryId, String pageId, String entryId, String? sectionId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedEntries = page.entries.map((entry) {
          if (entry.id != entryId) return entry;
          return entry.copyWith(sectionId: sectionId);
        }).toList();
        return page.copyWith(entries: updatedEntries);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }
}
