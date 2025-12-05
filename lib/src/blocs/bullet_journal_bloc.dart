import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../constants/layout_order.dart';
import '../data/sample_entries.dart';
import '../models/bullet_entry.dart';
import '../models/diary.dart';
import '../models/diary_page.dart';
import '../models/diary_section.dart';
import '../models/key_definition.dart';
import '../models/page_component.dart';
import '../utils/page_sort_utils.dart';
import 'bullet_journal_event.dart';
import 'bullet_journal_state.dart';

// Re-export Event and State for convenience
export 'bullet_journal_event.dart';
export 'bullet_journal_state.dart';

class BulletJournalBloc extends Bloc<BulletJournalEvent, BulletJournalState> {
  BulletJournalBloc({List<BulletEntry>? initialEntries})
      : _initialEntries = initialEntries ?? sampleEntries,
        super(BulletJournalState(
          statusKeyMapping:
              BulletJournalStateExtension.defaultStatusKeyMapping(),
        )) {
    on<BulletJournalEvent>((event, emit) {
      event.when(
        loadEntries: () => _onLoadEntries(emit),
        toggleTask: (entryId, taskId) => _onToggleTask(entryId, taskId, emit),
        snoozeTask: (entryId, taskId, postpone) =>
            _onSnoozeTask(entryId, taskId, postpone, emit),
        addCustomKey: (definition) => _onAddCustomKey(definition, emit),
        updateStatusKey: (status, keyId) =>
            _onUpdateStatusKey(status, keyId, emit),
        deleteCustomKey: (keyId) => _onDeleteCustomKey(keyId, emit),
        addTaskStatus: (status) => _onAddTaskStatus(status, emit),
        deleteTaskStatus: (statusId) => _onDeleteTaskStatus(statusId, emit),
        updateTaskStatusOrder: (statusId, newOrder) =>
            _onUpdateTaskStatusOrder(statusId, newOrder, emit),
        addDiary: (diary) => _onAddDiary(diary, emit),
        deleteDiary: (diaryId) => _onDeleteDiary(diaryId, emit),
        addEntryToDiary: (diaryId, entry) =>
            _onAddEntryToDiary(diaryId, entry, emit),
        toggleTaskInDiary: (diaryId, entryId, taskId) =>
            _onToggleTaskInDiary(diaryId, entryId, taskId, emit),
        snoozeTaskInDiary: (diaryId, entryId, taskId, postpone) =>
            _onSnoozeTaskInDiary(diaryId, entryId, taskId, postpone, emit),
        updateEntry: (entryId, updatedEntry) =>
            _onUpdateEntry(entryId, updatedEntry, emit),
        updateEntryInDiary: (diaryId, entryId, updatedEntry) =>
            _onUpdateEntryInDiary(diaryId, entryId, updatedEntry, emit),
        updateDiary: (diaryId, updatedDiary) =>
            _onUpdateDiary(diaryId, updatedDiary, emit),
        reorderEntriesInDiary: (diaryId, reorderedEntries) =>
            _onReorderEntriesInDiary(diaryId, reorderedEntries, emit),
        addPageToDiary: (diaryId, page) =>
            _onAddPageToDiary(diaryId, page, emit),
        deletePageFromDiary: (diaryId, pageId) =>
            _onDeletePageFromDiary(diaryId, pageId, emit),
        updatePageInDiary: (diaryId, pageId, updatedPage) =>
            _onUpdatePageInDiary(diaryId, pageId, updatedPage, emit),
        setCurrentPageInDiary: (diaryId, pageId) =>
            _onSetCurrentPageInDiary(diaryId, pageId, emit),
        togglePageFavoriteInDiary: (diaryId, pageId) =>
            _onTogglePageFavoriteInDiary(diaryId, pageId, emit),
        reorderPagesInDiary: (diaryId, reorderedPages) =>
            _onReorderPagesInDiary(diaryId, reorderedPages, emit),
        addEntryToPage: (diaryId, pageId, entry) =>
            _onAddEntryToPage(diaryId, pageId, entry, emit),
        updateEntryInPage: (diaryId, pageId, entryId, updatedEntry) =>
            _onUpdateEntryInPage(diaryId, pageId, entryId, updatedEntry, emit),
        reorderEntriesInPage: (diaryId, pageId, reorderedEntries) =>
            _onReorderEntriesInPage(diaryId, pageId, reorderedEntries, emit),
        toggleTaskInPage: (diaryId, pageId, entryId, taskId) =>
            _onToggleTaskInPage(diaryId, pageId, entryId, taskId, emit),
        snoozeTaskInPage: (diaryId, pageId, entryId, taskId, postpone) =>
            _onSnoozeTaskInPage(
                diaryId, pageId, entryId, taskId, postpone, emit),
        addSectionToPage: (diaryId, pageId, section) =>
            _onAddSectionToPage(diaryId, pageId, section, emit),
        deleteSectionFromPage: (diaryId, pageId, sectionId) =>
            _onDeleteSectionFromPage(diaryId, pageId, sectionId, emit),
        updateSectionInPage: (diaryId, pageId, sectionId, updatedSection) =>
            _onUpdateSectionInPage(
                diaryId, pageId, sectionId, updatedSection, emit),
        reorderSectionsInPage: (diaryId, pageId, reorderedSections) =>
            _onReorderSectionsInPage(diaryId, pageId, reorderedSections, emit),
        assignEntryToSection: (diaryId, pageId, entryId, sectionId) =>
            _onAssignEntryToSection(diaryId, pageId, entryId, sectionId, emit),
        assignComponentToSection: (diaryId, pageId, componentId, sectionId) =>
            _onAssignComponentToSection(
                diaryId, pageId, componentId, sectionId, emit),
        addComponentToPage: (diaryId, pageId, component) =>
            _onAddComponentToPage(diaryId, pageId, component, emit),
        deleteComponentFromPage: (diaryId, pageId, componentId) =>
            _onDeleteComponentFromPage(diaryId, pageId, componentId, emit),
        updateComponentInPage:
            (diaryId, pageId, componentId, updatedComponent) =>
                _onUpdateComponentInPage(
                    diaryId, pageId, componentId, updatedComponent, emit),
        reorderComponentsInPage: (diaryId, pageId, reorderedComponents) =>
            _onReorderComponentsInPage(
                diaryId, pageId, reorderedComponents, emit),
        updateLayoutOrderInPage: (diaryId, pageId, layoutOrder) =>
            _onUpdateLayoutOrderInPage(diaryId, pageId, layoutOrder, emit),
        updateTimeTableCell: (diaryId, pageId, componentId, row, column,
                content, backgroundColorHex) =>
            _onUpdateTimeTableCell(diaryId, pageId, componentId, row, column,
                content, backgroundColorHex, emit),
        addEntryToTimeTableCell:
            (diaryId, pageId, componentId, row, column, entryId) =>
                _onAddEntryToTimeTableCell(
                    diaryId, pageId, componentId, row, column, entryId, emit),
        removeEntryFromTimeTableCell:
            (diaryId, pageId, componentId, row, column, entryId) =>
                _onRemoveEntryFromTimeTableCell(
                    diaryId, pageId, componentId, row, column, entryId, emit),
        updateTimeTableColumnWidths: (diaryId, pageId, componentId,
                columnWidths) =>
            _onUpdateTimeTableColumnWidths(
                diaryId, pageId, componentId, columnWidths, emit),
        updateTimeTableRowHeights: (diaryId, pageId, componentId, rowHeights) =>
            _onUpdateTimeTableRowHeights(
                diaryId, pageId, componentId, rowHeights, emit),
      );
    });
    add(const BulletJournalEvent.loadEntries());
  }

  final List<BulletEntry> _initialEntries;

  List<String> _safeLayoutOrder(DiaryPage page) {
    try {
      return List<String>.from(page.layoutOrder);
    } catch (_) {
      return <String>[];
    }
  }

  String _componentIdFrom(PageComponent component) {
    return component.map(
      section: (section) => section.id,
      timeTable: (timeTable) => timeTable.id,
    );
  }

  List<String> _pruneLayoutOrder(
    List<String> layoutOrder, {
    Set<String>? validEntryIds,
    Set<String>? validComponentIds,
  }) {
    final pruned = <String>[];
    for (final token in layoutOrder) {
      if (token.startsWith(layoutEntryPrefix)) {
        final entryId = token.substring(layoutEntryPrefix.length);
        if (validEntryIds == null || validEntryIds.contains(entryId)) {
          if (!pruned.contains(token)) {
            pruned.add(token);
          }
        }
      } else if (token.startsWith(layoutComponentPrefix)) {
        final componentId = token.substring(layoutComponentPrefix.length);
        if (validComponentIds == null ||
            validComponentIds.contains(componentId)) {
          if (!pruned.contains(token)) {
            pruned.add(token);
          }
        }
      }
    }
    return pruned;
  }

  List<String> _mergeEntryOrderIntoLayoutOrder(
    List<String> layoutOrder,
    List<BulletEntry> orderedEntries,
  ) {
    final newLayout = <String>[];
    final entryTokens =
        orderedEntries.map((e) => layoutEntryToken(e.id)).iterator;

    for (final token in layoutOrder) {
      if (token.startsWith(layoutEntryPrefix)) {
        if (entryTokens.moveNext()) {
          newLayout.add(entryTokens.current);
        }
      } else if (token.startsWith(layoutComponentPrefix)) {
        newLayout.add(token);
      }
    }

    while (entryTokens.moveNext()) {
      newLayout.add(entryTokens.current);
    }

    if (newLayout.isEmpty) {
      newLayout.addAll(orderedEntries.map((e) => layoutEntryToken(e.id)));
    }

    return newLayout;
  }

  List<DiaryPage> _applySequentialPageOrder(List<DiaryPage> pages) {
    var orderCounter = 0;
    return pages.map((page) {
      if (page.isIndexPage) {
        return page.order == -1 ? page : page.copyWith(order: -1);
      }
      final updatedPage = page.copyWith(order: orderCounter);
      orderCounter++;
      return updatedPage;
    }).toList();
  }

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

  void _onSnoozeTask(
    String entryId,
    String taskId,
    Duration postpone,
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

  void _onAddCustomKey(
    KeyDefinition definition,
    Emitter<BulletJournalState> emit,
  ) {
    emit(state.copyWith(customKeys: [...state.customKeys, definition]));
  }

  void _onUpdateStatusKey(
    TaskStatus status,
    String keyId,
    Emitter<BulletJournalState> emit,
  ) {
    // 기존 키 리스트 가져오기 (없으면 빈 리스트)
    final existingKeys = state.statusKeyMapping[status.id] ?? [];

    // 이미 해당 키가 할당되어 있지 않으면 추가
    if (!existingKeys.contains(keyId)) {
      emit(state.copyWith(
        statusKeyMapping: {
          ...state.statusKeyMapping,
          status.id: [...existingKeys, keyId],
        },
      ));
    }
  }

  void _onDeleteCustomKey(
    String keyId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedCustomKeys =
        state.customKeys.where((key) => key.id != keyId).toList();

    // statusKeyMapping에서 해당 키를 모든 상태의 리스트에서 제거
    final updatedMapping = <String, List<String>>{};
    for (final entry in state.statusKeyMapping.entries) {
      final keysWithoutDeleted = entry.value.where((k) => k != keyId).toList();
      if (keysWithoutDeleted.isNotEmpty) {
        updatedMapping[entry.key] = keysWithoutDeleted;
      }
    }

    emit(state.copyWith(
      customKeys: updatedCustomKeys,
      statusKeyMapping: updatedMapping,
    ));
  }

  void _onAddTaskStatus(
    TaskStatus status,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedStatuses = [...state.taskStatuses, status]
      ..sort((a, b) => a.order.compareTo(b.order));
    emit(state.copyWith(taskStatuses: updatedStatuses));
  }

  void _onDeleteTaskStatus(
    String statusId,
    Emitter<BulletJournalState> emit,
  ) {
    // 기본 상태는 삭제 불가
    final isDefault =
        TaskStatus.defaultStatuses.any((status) => status.id == statusId);
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
    final updatedStatuses =
        state.taskStatuses.where((status) => status.id != statusId).toList();
    final updatedMapping =
        Map<String, List<String>>.from(state.statusKeyMapping)
          ..remove(statusId);

    emit(state.copyWith(
      entries: updatedEntries,
      diaries: updatedDiaries,
      taskStatuses: updatedStatuses,
      statusKeyMapping: updatedMapping,
    ));
  }

  void _onUpdateTaskStatusOrder(
    String statusId,
    int newOrder,
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

  void _onAddDiary(
    Diary diary,
    Emitter<BulletJournalState> emit,
  ) {
    emit(state.copyWith(diaries: [...state.diaries, diary]));
  }

  void _onDeleteDiary(
    String diaryId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries =
        state.diaries.where((diary) => diary.id != diaryId).toList();
    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAddEntryToDiary(
    String diaryId,
    BulletEntry entry,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      return diary.copyWith(entries: [...diary.entries, entry]);
    }).toList();
    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onToggleTaskInDiary(
    String diaryId,
    String entryId,
    String taskId,
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

  void _onSnoozeTaskInDiary(
    String diaryId,
    String entryId,
    String taskId,
    Duration postpone,
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

  void _onUpdateEntry(
    String entryId,
    BulletEntry updatedEntry,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedEntries = state.entries.map((entry) {
      if (entry.id != entryId) return entry;
      return updatedEntry;
    }).toList();
    emit(state.copyWith(entries: updatedEntries));
  }

  void _onUpdateEntryInDiary(
    String diaryId,
    String entryId,
    BulletEntry updatedEntry,
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

  void _onUpdateDiary(
    String diaryId,
    Diary updatedDiary,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      return updatedDiary;
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onReorderEntriesInDiary(
    String diaryId,
    List<BulletEntry> reorderedEntries,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      return diary.copyWith(entries: reorderedEntries);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAddPageToDiary(
    String diaryId,
    DiaryPage page,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;

      final existingPages = PageSortUtils.sortPages(diary.pages);
      final hasIndexPage = existingPages.any((p) => p.isIndexPage);

      List<DiaryPage> newPages = [...existingPages, page];

      // 인덱스 페이지가 없고 새로운 페이지가 인덱스 페이지가 아닐 때 자동 생성
      if (!hasIndexPage && !page.isIndexPage) {
        final indexPage = DiaryPage(
          id: 'index-page-${DateTime.now().millisecondsSinceEpoch}',
          name: null, // 인덱스 페이지는 이름 없음
          entries: [],
          sections: [],
          createdAt: DateTime.now(),
          isIndexPage: true,
        );
        newPages = [indexPage, ...newPages];
      }

      final sortedPages = PageSortUtils.sortPages(newPages);
      final normalizedPages = _applySequentialPageOrder(sortedPages);

      final newCurrentPageId = diary.currentPageId ?? page.id;
      return diary.copyWith(
        pages: normalizedPages,
        currentPageId: newCurrentPageId,
      );
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onDeletePageFromDiary(
    String diaryId,
    String pageId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;

      // 삭제하려는 페이지가 인덱스 페이지인지 확인
      final pageToDelete = diary.pages.firstWhere(
        (p) => p.id == pageId,
        orElse: () => diary.pages.first,
      );

      if (pageToDelete.isIndexPage) {
        // 인덱스 페이지는 삭제 불가
        return diary;
      }

      final newPages = diary.pages.where((p) => p.id != pageId).toList();

      // 페이지가 1개 이하가 되면 인덱스 페이지 제거
      final nonIndexPagesCount = newPages.where((p) => !p.isIndexPage).length;
      final finalPages = nonIndexPagesCount <= 1
          ? newPages.where((p) => !p.isIndexPage).toList()
          : PageSortUtils.sortPages(newPages);

      String? newCurrentPageId = diary.currentPageId;
      if (diary.currentPageId == pageId) {
        newCurrentPageId = finalPages.isNotEmpty ? finalPages.first.id : null;
      }

      final normalizedPages = _applySequentialPageOrder(finalPages);

      return diary.copyWith(
        pages: normalizedPages,
        currentPageId: newCurrentPageId,
      );
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdatePageInDiary(
    String diaryId,
    String pageId,
    DiaryPage updatedPage,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        return updatedPage;
      }).toList();
      // 페이지 정렬 (인덱스 페이지가 맨 앞)
      final sortedPages = PageSortUtils.sortPages(updatedPages);
      return diary.copyWith(pages: sortedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onSetCurrentPageInDiary(
    String diaryId,
    String? pageId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      return diary.copyWith(currentPageId: pageId);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onTogglePageFavoriteInDiary(
    String diaryId,
    String pageId,
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

  void _onReorderPagesInDiary(
    String diaryId,
    List<DiaryPage> reorderedPages,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final sequentialPages = _applySequentialPageOrder(reorderedPages);
      final sortedPages = PageSortUtils.sortPages(sequentialPages);
      return diary.copyWith(pages: sortedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAddEntryToPage(
    String diaryId,
    String pageId,
    BulletEntry entry,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedEntries = [...page.entries, entry];
        final layoutOrder = _safeLayoutOrder(page);
        final validEntryIds = updatedEntries.map((e) => e.id).toSet();
        final validComponentIds = page.components.map(_componentIdFrom).toSet();
        final updatedLayoutOrder = [
          ..._pruneLayoutOrder(
            layoutOrder,
            validEntryIds: validEntryIds,
            validComponentIds: validComponentIds,
          ),
          layoutEntryToken(entry.id),
        ];
        return page.copyWith(
          entries: updatedEntries,
          layoutOrder: updatedLayoutOrder,
        );
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdateEntryInPage(
    String diaryId,
    String pageId,
    String entryId,
    BulletEntry updatedEntry,
    Emitter<BulletJournalState> emit,
  ) {
    debugPrint(
        '[BulletJournalBloc] _onUpdateEntryInPage 시작 - Diary: $diaryId, Page: $pageId, Entry: $entryId');
    debugPrint(
        '[BulletJournalBloc] 업데이트된 엔트리 상태 - Status ID: ${updatedEntry.keyStatus.id}, Status Label: ${updatedEntry.keyStatus.label}');

    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedEntries = page.entries.map((entry) {
          if (entry.id != entryId) return entry;
          debugPrint(
              '[BulletJournalBloc] 엔트리 교체 - 기존 Status: ${entry.keyStatus.id}, 새 Status: ${updatedEntry.keyStatus.id}');
          return updatedEntry;
        }).toList();
        debugPrint(
            '[BulletJournalBloc] 페이지 업데이트 완료 - Page: $pageId, 엔트리 수: ${updatedEntries.length}');
        return page.copyWith(entries: updatedEntries);
      }).toList();
      debugPrint(
          '[BulletJournalBloc] 다이어리 업데이트 완료 - Diary: $diaryId, 페이지 수: ${updatedPages.length}');
      return diary.copyWith(pages: updatedPages);
    }).toList();

    debugPrint(
        '[BulletJournalBloc] 상태 emit 시작 - 다이어리 수: ${updatedDiaries.length}');
    emit(state.copyWith(diaries: updatedDiaries));
    debugPrint('[BulletJournalBloc] 상태 emit 완료');
  }

  void _onReorderEntriesInPage(
    String diaryId,
    String pageId,
    List<BulletEntry> reorderedEntries,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedLayoutOrder = _mergeEntryOrderIntoLayoutOrder(
            _safeLayoutOrder(page), reorderedEntries);
        return page.copyWith(
          entries: reorderedEntries,
          layoutOrder: updatedLayoutOrder,
        );
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onToggleTaskInPage(
    String diaryId,
    String pageId,
    String entryId,
    String taskId,
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

  void _onSnoozeTaskInPage(
    String diaryId,
    String pageId,
    String entryId,
    String taskId,
    Duration postpone,
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

  void _onAddSectionToPage(
    String diaryId,
    String pageId,
    DiarySection section,
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

  void _onDeleteSectionFromPage(
    String diaryId,
    String pageId,
    String sectionId,
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
        final updatedSections =
            page.sections.where((section) => section.id != sectionId).toList();
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
    String diaryId,
    String pageId,
    String sectionId,
    DiarySection updatedSection,
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

  void _onReorderSectionsInPage(
    String diaryId,
    String pageId,
    List<DiarySection> reorderedSections,
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

  void _onAssignEntryToSection(
    String diaryId,
    String pageId,
    String entryId,
    String? sectionId,
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

  void _onAssignComponentToSection(
    String diaryId,
    String pageId,
    String componentId,
    String? sectionId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedComponents = page.components.map((component) {
          return component.map(
            section: (s) => component,
            timeTable: (t) {
              if (t.id != componentId) return t;
              return t.copyWith(sectionId: sectionId);
            },
          );
        }).toList();
        return page.copyWith(components: updatedComponents);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdateLayoutOrderInPage(
    String diaryId,
    String pageId,
    List<String> layoutOrder,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        return page.copyWith(layoutOrder: layoutOrder);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAddComponentToPage(
    String diaryId,
    String pageId,
    PageComponent component,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        // 컴포넌트의 order 설정 (현재 컴포넌트 개수)
        final newComponent = component.map(
          section: (section) => section.copyWith(order: page.components.length),
          timeTable: (timeTable) =>
              timeTable.copyWith(order: page.components.length),
        );
        final updatedComponents = [...page.components, newComponent];
        final layoutOrder = _safeLayoutOrder(page);
        final validEntryIds = page.entries.map((e) => e.id).toSet();
        final validComponentIds =
            updatedComponents.map(_componentIdFrom).toSet();
        final updatedLayoutOrder = [
          ..._pruneLayoutOrder(
            layoutOrder,
            validEntryIds: validEntryIds,
            validComponentIds: validComponentIds,
          ),
          layoutComponentToken(_componentIdFrom(newComponent)),
        ];
        return page.copyWith(
          components: updatedComponents,
          layoutOrder: updatedLayoutOrder,
        );
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onDeleteComponentFromPage(
    String diaryId,
    String pageId,
    String componentId,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedComponents = page.components
            .where((component) => component.map(
                  section: (s) => s.id != componentId,
                  timeTable: (t) => t.id != componentId,
                ))
            .toList();
        final validEntryIds = page.entries.map((e) => e.id).toSet();
        final validComponentIds =
            updatedComponents.map(_componentIdFrom).toSet();
        final updatedLayoutOrder = _pruneLayoutOrder(
          _safeLayoutOrder(page),
          validEntryIds: validEntryIds,
          validComponentIds: validComponentIds,
        );
        return page.copyWith(
          components: updatedComponents,
          layoutOrder: updatedLayoutOrder,
        );
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdateComponentInPage(
    String diaryId,
    String pageId,
    String componentId,
    PageComponent updatedComponent,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedComponents = page.components.map((component) {
          final matches = component.map(
            section: (s) => s.id == componentId,
            timeTable: (t) => t.id == componentId,
          );
          if (!matches) return component;
          return updatedComponent;
        }).toList();
        return page.copyWith(components: updatedComponents);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onReorderComponentsInPage(
    String diaryId,
    String pageId,
    List<PageComponent> reorderedComponents,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        // order 업데이트
        final updatedComponents =
            reorderedComponents.asMap().entries.map((entry) {
          return entry.value.map(
            section: (s) => s.copyWith(order: entry.key),
            timeTable: (t) => t.copyWith(order: entry.key),
          );
        }).toList();
        return page.copyWith(components: updatedComponents);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdateTimeTableCell(
    String diaryId,
    String pageId,
    String componentId,
    int row,
    int column,
    String content,
    String? backgroundColorHex,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedComponents = page.components.map((component) {
          return component.map(
            section: (s) => s,
            timeTable: (t) {
              if (t.id != componentId) return t;
              // 기존 셀 찾기 또는 새 셀 추가
              final cells = List<TimeTableCell>.from(t.cells);
              final cellIndex = cells.indexWhere(
                (cell) => cell.row == row && cell.column == column,
              );

              if (cellIndex >= 0) {
                final existing = cells[cellIndex];
                cells[cellIndex] = existing.copyWith(
                  content: content,
                  backgroundColorHex:
                      backgroundColorHex ?? existing.backgroundColorHex,
                );
              } else {
                cells.add(
                  TimeTableCell(
                    row: row,
                    column: column,
                    content: content,
                    backgroundColorHex: backgroundColorHex,
                  ),
                );
              }

              return t.copyWith(cells: cells);
            },
          );
        }).toList();
        return page.copyWith(components: updatedComponents);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onAddEntryToTimeTableCell(
    String diaryId,
    String pageId,
    String componentId,
    int row,
    int column,
    String entryId,
    Emitter<BulletJournalState> emit,
  ) {
    // TODO: Implement entry addition to time table cell
    // This requires updating the TimeTableCell model to support entry IDs
    emit(state);
  }

  void _onRemoveEntryFromTimeTableCell(
    String diaryId,
    String pageId,
    String componentId,
    int row,
    int column,
    String entryId,
    Emitter<BulletJournalState> emit,
  ) {
    // TODO: Implement entry removal from time table cell
    // This requires updating the TimeTableCell model to support entry IDs
    emit(state);
  }

  void _onUpdateTimeTableColumnWidths(
    String diaryId,
    String pageId,
    String componentId,
    List<double> columnWidths,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedComponents = page.components.map((component) {
          return component.map(
            section: (s) => s,
            timeTable: (t) {
              if (t.id != componentId) return t;
              return t.copyWith(columnWidths: columnWidths);
            },
          );
        }).toList();
        return page.copyWith(components: updatedComponents);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }

  void _onUpdateTimeTableRowHeights(
    String diaryId,
    String pageId,
    String componentId,
    List<double> rowHeights,
    Emitter<BulletJournalState> emit,
  ) {
    final updatedDiaries = state.diaries.map((diary) {
      if (diary.id != diaryId) return diary;
      final updatedPages = diary.pages.map((page) {
        if (page.id != pageId) return page;
        final updatedComponents = page.components.map((component) {
          return component.map(
            section: (s) => s,
            timeTable: (t) {
              if (t.id != componentId) return t;
              return t.copyWith(rowHeights: rowHeights);
            },
          );
        }).toList();
        return page.copyWith(components: updatedComponents);
      }).toList();
      return diary.copyWith(pages: updatedPages);
    }).toList();

    emit(state.copyWith(diaries: updatedDiaries));
  }
}
