import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/bullet_journal_bloc.dart';
import '../models/diary.dart';
import '../models/diary_page.dart';
import '../models/diary_section.dart';
import '../models/bullet_entry.dart';
import '../widgets/diary_background.dart';
import 'diary_detail/utils/entry_sort_type.dart';
import 'diary_detail/utils/entry_sort_utils.dart';
import 'diary_detail/utils/entry_finder_utils.dart';
import 'diary_detail/widgets/note_entry_line.dart';
import 'diary_detail/dialogs/add_entry_dialog.dart';
import 'diary_detail/dialogs/background_theme_dialog.dart';
import 'diary_detail/dialogs/sort_dialog.dart';
import 'diary_detail/dialogs/page_bottom_sheet.dart';
import 'diary_detail/dialogs/page_dialogs.dart';
import 'diary_detail/dialogs/section_dialogs.dart';

class DiaryDetailScreen extends StatefulWidget {
  const DiaryDetailScreen({super.key, required this.diaryId});

  final String diaryId;

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  EntrySortType _sortType = EntrySortType.dateDescending;
  List<BulletEntry> _manualOrder = [];
  bool _isKanbanView = false; // 칸반보드 보기 모드

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulletJournalBloc, BulletJournalState>(
      builder: (context, state) {
        final diary = state.diaries.firstWhere(
          (d) => d.id == widget.diaryId,
          orElse: () => Diary(
            id: '',
            name: '알 수 없음',
            description: '',
            createdAt: DateTime.now(),
          ),
        );

        // 페이지가 없으면 기본 페이지 생성
        if (diary.pages.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final defaultPage = DiaryPage(
              id: 'page-${DateTime.now().millisecondsSinceEpoch}',
              name: '페이지 1',
              entries: diary.entries,
              createdAt: DateTime.now(),
            );
            context.read<BulletJournalBloc>().add(
                  BulletJournalEvent.addPageToDiary(
                    diaryId: widget.diaryId,
                    page: defaultPage,
                  ),
                );
          });
        }

        // 현재 페이지 가져오기 (기존 데이터 호환성: sections 필드 마이그레이션)
        DiaryPage? currentPage;
        if (diary.currentPageId != null) {
          final foundPage = diary.pages.firstWhere(
            (p) => p.id == diary.currentPageId,
            orElse: () => diary.pages.isNotEmpty
                ? diary.pages.first
                : DiaryPage(
                    id: '',
                    name: '',
                    createdAt: DateTime.now(),
                  ),
          );
          // sections 필드가 없는 경우 마이그레이션
          try {
            foundPage.sections;
            currentPage = foundPage;
          } catch (e) {
            // sections 필드가 없는 경우 copyWith로 마이그레이션
            currentPage = foundPage.copyWith(sections: <DiarySection>[]);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<BulletJournalBloc>().add(
                    BulletJournalEvent.updatePageInDiary(
                      diaryId: widget.diaryId,
                      pageId: foundPage.id,
                      updatedPage: currentPage!,
                    ),
                  );
            });
          }
        } else if (diary.pages.isNotEmpty) {
          final firstPage = diary.pages.first;
          // sections 필드가 없는 경우 마이그레이션
          try {
            firstPage.sections;
            currentPage = firstPage;
          } catch (e) {
            // sections 필드가 없는 경우 copyWith로 마이그레이션
            currentPage = firstPage.copyWith(sections: <DiarySection>[]);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<BulletJournalBloc>().add(
                    BulletJournalEvent.updatePageInDiary(
                      diaryId: widget.diaryId,
                      pageId: firstPage.id,
                      updatedPage: currentPage!,
                    ),
                  );
            });
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<BulletJournalBloc>().add(
                  BulletJournalEvent.setCurrentPageInDiary(
                    diaryId: widget.diaryId,
                    pageId: currentPage!.id,
                  ),
                );
          });
        }

        final currentEntries = currentPage?.entries ?? [];

        // 수동 정렬 모드일 때 엔트리 목록이 변경되면 수동 정렬 순서 동기화
        if (_sortType == EntrySortType.manual) {
          final entryIds = currentEntries.map((e) => e.id).toSet();
          final manualOrderIds = _manualOrder.map((e) => e.id).toSet();

          // 현재 엔트리 목록을 Map으로 변환하여 ID로 빠르게 찾을 수 있게 함
          final entriesMap = {
            for (final entry in currentEntries) entry.id: entry
          };

          // _manualOrder의 엔트리를 최신 상태로 업데이트
          _manualOrder = _manualOrder
              .where((e) => entryIds.contains(e.id))
              .map((e) => entriesMap[e.id] ?? e)
              .toList();

          // 새로운 엔트리들 추가
          final newEntries = currentEntries
              .where((e) => !manualOrderIds.contains(e.id))
              .toList();
          _manualOrder = [..._manualOrder, ...newEntries];
        }

        final sortedEntries = EntrySortUtils.sortEntries(
          currentEntries,
          _sortType,
          _manualOrder,
        );

        // 섹션별로 엔트리 그룹화
        // sections가 null일 수 있는 경우를 처리 (기존 데이터 호환성)
        List<DiarySection> sections = <DiarySection>[];
        if (currentPage != null) {
          try {
            final sectionsValue = currentPage.sections;
            sections = List<DiarySection>.from(sectionsValue);
          } catch (e) {
            // 기존 데이터에 sections 필드가 없는 경우 빈 리스트 사용
            sections = <DiarySection>[];
          }
        }
        sections.sort((a, b) => a.order.compareTo(b.order));

        // 섹션이 있는 경우 섹션별로 그룹화
        final hasSections = sections.isNotEmpty;
        Map<String, List<BulletEntry>> entriesBySection = {};
        List<BulletEntry> unassignedEntries = [];

        if (hasSections) {
          // 섹션별로 엔트리 분류
          for (final section in sections) {
            entriesBySection[section.id] =
                sortedEntries.where((e) => e.sectionId == section.id).toList();
          }
          // 섹션이 할당되지 않은 엔트리 (sectionId가 null인 엔트리)
          unassignedEntries =
              sortedEntries.where((e) => e.sectionId == null).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  diary.name,
                  style: const TextStyle(fontSize: 18),
                ),
                if (currentPage != null)
                  Text(
                    currentPage.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              // 페이지 네비게이션 버튼 (뒤로가기 오른쪽)
              IconButton(
                icon: const Icon(Icons.pages),
                tooltip: '페이지',
                onPressed: () => showPageBottomSheet(
                  context,
                  state,
                  diary,
                  widget.diaryId,
                ),
              ),
              // 즐겨찾기 버튼 (더보기 왼쪽)
              if (currentPage != null)
                IconButton(
                  icon: Icon(
                    currentPage.isFavorite ? Icons.star : Icons.star_border,
                  ),
                  tooltip: '즐겨찾기',
                  onPressed: () {
                    context.read<BulletJournalBloc>().add(
                          BulletJournalEvent.togglePageFavoriteInDiary(
                            diaryId: widget.diaryId,
                            pageId: currentPage!.id,
                          ),
                        );
                  },
                ),
              // 더보기 버튼
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: '더보기',
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'sort',
                    child: Row(
                      children: [
                        Icon(Icons.sort, size: 20),
                        SizedBox(width: 12),
                        Text('정렬'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'background',
                    child: Row(
                      children: [
                        Icon(Icons.palette_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('배경 테마 선택'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'add_section',
                    child: Row(
                      children: [
                        Icon(Icons.category_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('섹션 추가'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'add_page',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, size: 20),
                        SizedBox(width: 12),
                        Text('페이지 추가'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'add',
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 12),
                        Text('엔트리 추가'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'kanban',
                    child: Row(
                      children: [
                        Icon(
                            _isKanbanView ? Icons.view_list : Icons.view_kanban,
                            size: 20),
                        const SizedBox(width: 12),
                        Text(_isKanbanView ? '리스트 보기' : '칸반보드 보기'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'sort':
                      showSortDialog(
                        context,
                        state,
                        _sortType,
                        widget.diaryId,
                        (sortType) {
                          setState(() {
                            _sortType = sortType;
                            // 수동 정렬로 변경 시 현재 엔트리 목록을 저장
                            if (sortType == EntrySortType.manual) {
                              // Note: currentPage is already checked above
                              // This code runs when sortType == manual, so currentPage is guaranteed to be non-null
                              // diary variable was removed as it's not used
                            }
                          });
                        },
                      );
                      break;
                    case 'background':
                      showBackgroundThemeDialog(
                        context,
                        widget.diaryId,
                        diary,
                      );
                      break;
                    case 'add_section':
                      if (currentPage != null) {
                        showAddSectionDialog(
                            context, widget.diaryId, currentPage.id, state);
                      }
                      break;
                    case 'add_page':
                      showAddPageDialog(context, widget.diaryId);
                      break;
                    case 'add':
                      if (currentPage != null) {
                        final bloc = context.read<BulletJournalBloc>();
                        final page = currentPage;
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AddEntryDialog(
                            bloc: bloc,
                            diaryId: widget.diaryId,
                            pageId: page.id,
                            page: page,
                          ),
                        );
                      }
                      break;
                    case 'kanban':
                      setState(() {
                        _isKanbanView = !_isKanbanView;
                      });
                      break;
                  }
                },
              ),
            ],
          ),
          body: currentPage == null
              ? const Center(child: CircularProgressIndicator())
              : DiaryBackground(
                  theme: diary.backgroundTheme,
                  child: Builder(
                    builder: (context) {
                      // 섹션이 있는 경우 섹션별 그룹화 표시 (엔트리가 없어도 섹션 헤더 표시)
                      if (hasSections) {
                        return _buildSectionedEntriesList(
                          context,
                          sections,
                          entriesBySection,
                          unassignedEntries,
                          currentPage!,
                          state,
                          _isKanbanView,
                        );
                      }

                      // 섹션이 없고 엔트리도 없는 경우
                      if (sortedEntries.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.note_outlined,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '엔트리가 없습니다',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        );
                      }

                      // 섹션이 없는 경우 - 항상 세로 나열
                      return ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: sortedEntries.length,
                        onReorder: (oldIndex, newIndex) {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final reorderedEntries = [...sortedEntries];
                          final movedEntry =
                              reorderedEntries.removeAt(oldIndex);
                          reorderedEntries.insert(newIndex, movedEntry);

                          setState(() {
                            _manualOrder = reorderedEntries;
                            _sortType = EntrySortType.manual;
                          });

                          context.read<BulletJournalBloc>().add(
                                BulletJournalEvent.reorderEntriesInPage(
                                  diaryId: widget.diaryId,
                                  pageId: currentPage!.id,
                                  reorderedEntries: reorderedEntries,
                                ),
                              );
                        },
                        itemBuilder: (context, index) {
                          final entry = sortedEntries[index];
                          return NoteEntryLine(
                            key: ValueKey(entry.id),
                            entry: entry,
                            state: state,
                            diaryId: widget.diaryId,
                            pageId: currentPage!.id,
                            onToggleTask: (taskId) {
                              context.read<BulletJournalBloc>().add(
                                    BulletJournalEvent.toggleTaskInPage(
                                      diaryId: widget.diaryId,
                                      pageId: currentPage!.id,
                                      entryId: entry.id,
                                      taskId: taskId,
                                    ),
                                  );
                            },
                            onSnooze: (taskId, duration) {
                              context.read<BulletJournalBloc>().add(
                                    BulletJournalEvent.snoozeTaskInPage(
                                      diaryId: widget.diaryId,
                                      pageId: currentPage!.id,
                                      entryId: entry.id,
                                      taskId: taskId,
                                      postpone: duration,
                                    ),
                                  );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSectionedEntriesList(
    BuildContext context,
    List<DiarySection> sections,
    Map<String, List<BulletEntry>> entriesBySection,
    List<BulletEntry> unassignedEntries,
    DiaryPage currentPage,
    BulletJournalState state,
    bool isKanbanView,
  ) {
    if (isKanbanView) {
      // 칸반보드 모드: 가로 스크롤, 섹션과 엔트리 모두 순서 변경 가능
      return LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;

          // 섹션 리스트 생성 (섹션 없음 포함)
          final allSectionItems = <dynamic>[];
          for (final section in sections) {
            allSectionItems.add(section);
          }
          allSectionItems.add(null); // null = "섹션 없음"

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: allSectionItems.asMap().entries.map((entry) {
                final sectionIndex = entry.key;
                final section = entry.value as DiarySection?;

                final sectionEntries = section != null
                    ? (entriesBySection[section.id] ?? [])
                    : unassignedEntries;

                return DragTarget<int>(
                  onAcceptWithDetails: (details) {
                    final draggedIndex = details.data;
                    if (draggedIndex == sectionIndex) return;

                    // 섹션 순서 변경
                    final reorderedSections = <DiarySection>[];

                    // 드래그된 섹션 찾기
                    if (draggedIndex < sections.length) {
                      final draggedSection = sections[draggedIndex];

                      // 목표 위치에 삽입
                      if (section != null) {
                        // 섹션으로 이동: 다른 섹션 앞에 삽입
                        final targetIndex = sections.indexOf(section);
                        for (int i = 0; i < sections.length; i++) {
                          if (i == draggedIndex) continue;
                          if (i == targetIndex) {
                            if (draggedIndex < targetIndex) {
                              // 앞에서 뒤로: 타겟 앞에 삽입
                              reorderedSections.add(draggedSection);
                            }
                            reorderedSections.add(sections[i]);
                            if (draggedIndex > targetIndex) {
                              // 뒤에서 앞으로: 타겟 뒤에 삽입
                              reorderedSections.add(draggedSection);
                            }
                          } else {
                            reorderedSections.add(sections[i]);
                          }
                        }
                      } else {
                        // "섹션 없음"으로 이동 = 맨 뒤로
                        reorderedSections.addAll(
                            sections.where((s) => s.id != draggedSection.id));
                        reorderedSections.add(draggedSection);
                      }
                    }

                    // order 업데이트
                    final updatedSections =
                        reorderedSections.asMap().entries.map((e) {
                      return e.value.copyWith(order: e.key);
                    }).toList();

                    context.read<BulletJournalBloc>().add(
                          BulletJournalEvent.reorderSectionsInPage(
                            diaryId: widget.diaryId,
                            pageId: currentPage.id,
                            reorderedSections: updatedSections,
                          ),
                        );
                  },
                  builder: (context, candidateData, rejectedData) {
                    return _buildKanbanSectionColumn(
                      context,
                      section,
                      sectionEntries,
                      sections,
                      entriesBySection,
                      unassignedEntries,
                      currentPage,
                      state,
                      screenHeight,
                      sectionIndex,
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      );
    } else {
      // [수정됨] 리스트 보기: 평탄화된 리스트(Flat List) 접근 방식 사용
      // 섹션 헤더와 엔트리를 하나의 리스트로 만들어 ReorderableListView에 넣습니다.
      // 이를 통해 섹션 순서 변경 및 엔트리의 섹션 간 이동이 모두 가능해집니다.

      // 1. 표시할 아이템 리스트 생성 (섹션 헤더 + 엔트리 혼합)
      final List<dynamic> flatItems = [];

      for (final section in sections) {
        flatItems.add(section); // 섹션 객체 자체를 헤더 식별자로 사용
        flatItems.addAll(entriesBySection[section.id] ?? []);
      }

      // 섹션 없음 항목 처리
      const unassignedHeaderId = 'unassigned_header';
      if (unassignedEntries.isNotEmpty) {
        flatItems.add(unassignedHeaderId);
        flatItems.addAll(unassignedEntries);
      } else if (sections.isEmpty) {
        // 섹션도 없고 엔트리만 있거나 아예 없는 경우
        return ReorderableListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: unassignedEntries.length,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) newIndex -= 1;
            final reorderedEntries = [...unassignedEntries];
            final movedEntry = reorderedEntries.removeAt(oldIndex);
            reorderedEntries.insert(newIndex, movedEntry);

            setState(() {
              _manualOrder = reorderedEntries;
              _sortType = EntrySortType.manual;
            });

            context.read<BulletJournalBloc>().add(
                  BulletJournalEvent.reorderEntriesInPage(
                    diaryId: widget.diaryId,
                    pageId: currentPage.id,
                    reorderedEntries: reorderedEntries,
                  ),
                );
          },
          itemBuilder: (context, index) {
            final entry = unassignedEntries[index];
            return NoteEntryLine(
              key: ValueKey(entry.id),
              entry: entry,
              state: state,
              diaryId: widget.diaryId,
              pageId: currentPage.id,
              onToggleTask: (taskId) {
                context.read<BulletJournalBloc>().add(
                      BulletJournalEvent.toggleTaskInPage(
                        diaryId: widget.diaryId,
                        pageId: currentPage.id,
                        entryId: entry.id,
                        taskId: taskId,
                      ),
                    );
              },
              onSnooze: (taskId, duration) {
                context.read<BulletJournalBloc>().add(
                      BulletJournalEvent.snoozeTaskInPage(
                        diaryId: widget.diaryId,
                        pageId: currentPage.id,
                        entryId: entry.id,
                        taskId: taskId,
                        postpone: duration,
                      ),
                    );
              },
              onDragEnd: null,
            );
          },
        );
      }

      return ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: flatItems.length,
        onReorder: (oldIndex, newIndex) {
          // 2. 순서 변경 로직
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }

          final item = flatItems.removeAt(oldIndex);
          flatItems.insert(newIndex, item);

          // 3. 재배치된 리스트를 기반으로 데이터 모델 업데이트
          String? currentSectionId;
          final List<BulletEntry> allNewOrderedEntries = [];
          int sectionOrderCounter = 0;

          for (final listItem in flatItems) {
            if (listItem is DiarySection) {
              // 섹션 헤더를 만남: 현재 섹션 컨텍스트 변경
              currentSectionId = listItem.id;

              // 섹션 순서가 변경되었는지 확인
              if (listItem.order != sectionOrderCounter) {
                context.read<BulletJournalBloc>().add(
                      BulletJournalEvent.updateSectionInPage(
                        diaryId: widget.diaryId,
                        pageId: currentPage.id,
                        sectionId: listItem.id,
                        updatedSection:
                            listItem.copyWith(order: sectionOrderCounter),
                      ),
                    );
              }
              sectionOrderCounter++;
            } else if (listItem == unassignedHeaderId) {
              // 섹션 없음 헤더
              currentSectionId = null;
            } else if (listItem is BulletEntry) {
              // 엔트리: 현재 섹션 ID 할당
              BulletEntry entryToSave = listItem;

              if (listItem.sectionId != currentSectionId) {
                // 섹션이 변경된 경우
                entryToSave = listItem.copyWith(sectionId: currentSectionId);
                context.read<BulletJournalBloc>().add(
                      BulletJournalEvent.assignEntryToSection(
                        diaryId: widget.diaryId,
                        pageId: currentPage.id,
                        entryId: listItem.id,
                        sectionId: currentSectionId,
                      ),
                    );
              }
              allNewOrderedEntries.add(entryToSave);
            }
          }

          setState(() {
            _manualOrder = allNewOrderedEntries;
            _sortType = EntrySortType.manual;
          });

          // 4. 전체 엔트리 순서 저장
          context.read<BulletJournalBloc>().add(
                BulletJournalEvent.reorderEntriesInPage(
                  diaryId: widget.diaryId,
                  pageId: currentPage.id,
                  reorderedEntries: allNewOrderedEntries,
                ),
              );
        },
        itemBuilder: (context, index) {
          final item = flatItems[index];

          // A. 섹션 헤더 렌더링
          if (item is DiarySection) {
            return ReorderableDragStartListener(
              key: ValueKey('section-${item.id}'),
              index: index,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert, size: 18),
                      onPressed: () => showSectionOptionsDialog(
                        context,
                        widget.diaryId,
                        currentPage,
                        item,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    dense: true,
                  ),
                ),
              ),
            );
          }

          // B. '섹션 없음' 헤더 렌더링
          if (item == unassignedHeaderId) {
            return ReorderableDragStartListener(
              key: const ValueKey('unassigned-header'),
              index: index,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '섹션 없음',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            );
          }

          // C. 엔트리 렌더링
          if (item is BulletEntry) {
            return ReorderableDragStartListener(
              key: ValueKey(item.id),
              index: index,
              child: NoteEntryLine(
                key: ValueKey(item.id),
                entry: item,
                state: state,
                diaryId: widget.diaryId,
                pageId: currentPage.id,
                onToggleTask: (taskId) {
                  context.read<BulletJournalBloc>().add(
                        BulletJournalEvent.toggleTaskInPage(
                          diaryId: widget.diaryId,
                          pageId: currentPage.id,
                          entryId: item.id,
                          taskId: taskId,
                        ),
                      );
                },
                onSnooze: (taskId, duration) {
                  context.read<BulletJournalBloc>().add(
                        BulletJournalEvent.snoozeTaskInPage(
                          diaryId: widget.diaryId,
                          pageId: currentPage.id,
                          entryId: item.id,
                          taskId: taskId,
                          postpone: duration,
                        ),
                      );
                },
                onDragEnd: null, // ReorderableListView 사용으로 인해 null
              ),
            );
          }

          return const SizedBox.shrink();
        },
      );
    }
  }

  Widget _buildKanbanSectionColumn(
    BuildContext context,
    DiarySection? section,
    List<BulletEntry> sectionEntries,
    List<DiarySection> sections,
    Map<String, List<BulletEntry>> entriesBySection,
    List<BulletEntry> unassignedEntries,
    DiaryPage currentPage,
    BulletJournalState state,
    double screenHeight,
    int sectionIndex,
  ) {
    return Container(
      width: 300,
      height: screenHeight - 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 제목 - 엔트리 드래그 지원
          // 섹션 드래그는 아이콘을 통해 별도로 처리
          DragTarget<String>(
            onWillAccept: (entryId) => true,
            onAcceptWithDetails: (details) {
              final entryId = details.data;
              final draggedEntry = findEntryById(
                entryId,
                sections,
                entriesBySection,
                unassignedEntries,
              );
              if (draggedEntry == null) return;

              final isSameSection = draggedEntry.sectionId == section?.id;
              if (!isSameSection) {
                // 다른 섹션에서 온 엔트리: 섹션 변경 + 맨 끝에 추가
                // 현재 페이지의 모든 엔트리를 기반으로 재구성
                final allPageEntries =
                    List<BulletEntry>.from(currentPage.entries);

                // 드래그된 엔트리 제거
                allPageEntries.removeWhere((e) => e.id == entryId);

                // 드래그된 엔트리를 새 섹션에 맞게 업데이트하여 맨 끝에 추가
                final updatedEntry =
                    draggedEntry.copyWith(sectionId: section?.id);
                allPageEntries.add(updatedEntry);

                setState(() {
                  _manualOrder = allPageEntries;
                  _sortType = EntrySortType.manual;
                });

                context.read<BulletJournalBloc>().add(
                      BulletJournalEvent.assignEntryToSection(
                        diaryId: widget.diaryId,
                        pageId: currentPage.id,
                        entryId: entryId,
                        sectionId: section?.id,
                      ),
                    );

                context.read<BulletJournalBloc>().add(
                      BulletJournalEvent.reorderEntriesInPage(
                        diaryId: widget.diaryId,
                        pageId: currentPage.id,
                        reorderedEntries: allPageEntries,
                      ),
                    );
              }
            },
            builder: (context, candidateData, rejectedData) {
              final isHighlighted = candidateData.isNotEmpty;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? Colors.teal.shade100
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // 섹션 드래그 핸들 - 이 아이콘을 롱탭해서 드래그하면 섹션 순서 변경
                    Listener(
                      onPointerDown: (event) {
                        // 포인터 다운 이벤트 처리
                      },
                      child: LongPressDraggable<int>(
                        key: ValueKey(
                            'section-handle-${section?.id ?? 'unassigned'}'),
                        data: sectionIndex,
                        delay: const Duration(
                            milliseconds: 200), // 엔트리 드래그와 구분하기 위한 지연
                        feedback: Material(
                          elevation: 8,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.teal, width: 2),
                            ),
                            child: Text(
                              section?.name ?? '섹션 없음',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: const Icon(Icons.drag_handle, size: 18),
                        ),
                        onDragEnd: (details) {
                          // 섹션 드래그 종료
                        },
                        child: const Icon(
                          Icons.drag_handle,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        section?.name ?? '섹션 없음',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    if (section != null)
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => showSectionOptionsDialog(
                          context,
                          widget.diaryId,
                          currentPage,
                          section,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: DragTarget<String>(
              onWillAccept: (entryId) => true,
              onAcceptWithDetails: (details) {
                final entryId = details.data;
                // 다른 섹션에서 온 엔트리를 현재 섹션의 맨 끝에 추가 (빈 공간에 드롭)
                final draggedEntry = findEntryById(
                  entryId,
                  sections,
                  entriesBySection,
                  unassignedEntries,
                );
                if (draggedEntry == null) return;

                final isSameSection = draggedEntry.sectionId == section?.id;
                if (!isSameSection) {
                  // 다른 섹션에서 온 엔트리: 섹션 변경 + 맨 끝에 추가
                  // 현재 페이지의 모든 엔트리를 기반으로 재구성
                  final allPageEntries =
                      List<BulletEntry>.from(currentPage.entries);

                  // 드래그된 엔트리 제거
                  allPageEntries.removeWhere((e) => e.id == entryId);

                  // 드래그된 엔트리를 새 섹션에 맞게 업데이트하여 맨 끝에 추가
                  final updatedEntry =
                      draggedEntry.copyWith(sectionId: section?.id);
                  allPageEntries.add(updatedEntry);

                  setState(() {
                    _manualOrder = allPageEntries;
                    _sortType = EntrySortType.manual;
                  });

                  context.read<BulletJournalBloc>().add(
                        BulletJournalEvent.assignEntryToSection(
                          diaryId: widget.diaryId,
                          pageId: currentPage.id,
                          entryId: entryId,
                          sectionId: section?.id,
                        ),
                      );

                  context.read<BulletJournalBloc>().add(
                        BulletJournalEvent.reorderEntriesInPage(
                          diaryId: widget.diaryId,
                          pageId: currentPage.id,
                          reorderedEntries: allPageEntries,
                        ),
                      );
                }
              },
              builder: (context, candidateData, rejectedData) {
                final isHighlighted = candidateData.isNotEmpty;
                return Container(
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? Colors.teal.shade50.withOpacity(0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: sectionEntries.length,
                    itemBuilder: (context, index) {
                      final entry = sectionEntries[index];
                      return LongPressDraggable<String>(
                        key: ValueKey(entry.id),
                        data: entry.id,
                        feedback: Material(
                          elevation: 4,
                          child: Container(
                            width: 280,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              entry.focus,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: NoteEntryLine(
                            key: ValueKey('${entry.id}-placeholder'),
                            entry: entry,
                            state: state,
                            diaryId: widget.diaryId,
                            pageId: currentPage.id,
                            onToggleTask: (taskId) {
                              context.read<BulletJournalBloc>().add(
                                    BulletJournalEvent.toggleTaskInPage(
                                      diaryId: widget.diaryId,
                                      pageId: currentPage.id,
                                      entryId: entry.id,
                                      taskId: taskId,
                                    ),
                                  );
                            },
                            onSnooze: (taskId, duration) {
                              context.read<BulletJournalBloc>().add(
                                    BulletJournalEvent.snoozeTaskInPage(
                                      diaryId: widget.diaryId,
                                      pageId: currentPage.id,
                                      entryId: entry.id,
                                      taskId: taskId,
                                      postpone: duration,
                                    ),
                                  );
                            },
                            onDragEnd: null,
                          ),
                        ),
                        onDragEnd: (details) {
                          // DragTarget에 드롭되지 않은 경우 아무것도 하지 않음
                        },
                        child: DragTarget<String>(
                          onWillAccept: (draggedEntryId) {
                            return draggedEntryId != entry.id;
                          },
                          onAcceptWithDetails: (details) {
                            final draggedEntryId = details.data;
                            if (draggedEntryId == entry.id) return;

                            // 드래그된 엔트리 찾기
                            final draggedEntry = findEntryById(
                              draggedEntryId,
                              sections,
                              entriesBySection,
                              unassignedEntries,
                            );
                            if (draggedEntry == null) return;

                            final isSameSection =
                                draggedEntry.sectionId == section?.id;

                            // 현재 페이지의 모든 엔트리를 기반으로 재구성
                            final allPageEntries =
                                List<BulletEntry>.from(currentPage.entries);

                            if (isSameSection) {
                              // 같은 섹션 내에서 순서 변경
                              final draggedIndex = sectionEntries
                                  .indexWhere((e) => e.id == draggedEntryId);
                              final targetIndex = index;
                              if (draggedIndex == -1) return;

                              // 전체 페이지 엔트리에서 드래그된 엔트리 찾기 및 제거
                              final draggedEntryInAll =
                                  allPageEntries.firstWhere(
                                (e) => e.id == draggedEntryId,
                              );
                              allPageEntries
                                  .removeWhere((e) => e.id == draggedEntryId);

                              // 현재 섹션의 다른 엔트리들 위치 찾기
                              final targetEntryInSection =
                                  sectionEntries[targetIndex];
                              final targetIndexInAll =
                                  allPageEntries.indexWhere(
                                (e) => e.id == targetEntryInSection.id,
                              );

                              // 목표 위치에 삽입
                              if (targetIndexInAll >= 0) {
                                allPageEntries.insert(
                                    targetIndexInAll, draggedEntryInAll);
                              } else {
                                allPageEntries.add(draggedEntryInAll);
                              }

                              setState(() {
                                _manualOrder = allPageEntries;
                                _sortType = EntrySortType.manual;
                              });

                              context.read<BulletJournalBloc>().add(
                                    BulletJournalEvent.reorderEntriesInPage(
                                      diaryId: widget.diaryId,
                                      pageId: currentPage.id,
                                      reorderedEntries: allPageEntries,
                                    ),
                                  );
                            } else {
                              // 다른 섹션에서 온 엔트리: 섹션 변경 + 순서 변경
                              // 드래그된 엔트리 제거
                              final draggedEntryInAll =
                                  allPageEntries.firstWhere(
                                (e) => e.id == draggedEntryId,
                              );
                              allPageEntries
                                  .removeWhere((e) => e.id == draggedEntryId);

                              // 현재 섹션의 목표 엔트리 위치 찾기
                              final targetEntryInSection =
                                  sectionEntries[index];
                              final targetIndexInAll =
                                  allPageEntries.indexWhere(
                                (e) => e.id == targetEntryInSection.id,
                              );

                              // 드래그된 엔트리를 새 섹션에 맞게 업데이트
                              final updatedEntry = draggedEntryInAll.copyWith(
                                sectionId: section?.id,
                              );

                              // 목표 위치에 삽입
                              if (targetIndexInAll >= 0) {
                                allPageEntries.insert(
                                    targetIndexInAll, updatedEntry);
                              } else {
                                allPageEntries.add(updatedEntry);
                              }

                              setState(() {
                                _manualOrder = allPageEntries;
                                _sortType = EntrySortType.manual;
                              });

                              context.read<BulletJournalBloc>().add(
                                    BulletJournalEvent.assignEntryToSection(
                                      diaryId: widget.diaryId,
                                      pageId: currentPage.id,
                                      entryId: draggedEntryId,
                                      sectionId: section?.id,
                                    ),
                                  );

                              context.read<BulletJournalBloc>().add(
                                    BulletJournalEvent.reorderEntriesInPage(
                                      diaryId: widget.diaryId,
                                      pageId: currentPage.id,
                                      reorderedEntries: allPageEntries,
                                    ),
                                  );
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            final isHighlighted = candidateData.isNotEmpty &&
                                candidateData.first != entry.id;
                            return Container(
                              decoration: BoxDecoration(
                                color: isHighlighted
                                    ? Colors.teal.shade50.withOpacity(0.5)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: NoteEntryLine(
                                key: ValueKey(entry.id),
                                entry: entry,
                                state: state,
                                diaryId: widget.diaryId,
                                pageId: currentPage.id,
                                onToggleTask: (taskId) {
                                  context.read<BulletJournalBloc>().add(
                                        BulletJournalEvent.toggleTaskInPage(
                                          diaryId: widget.diaryId,
                                          pageId: currentPage.id,
                                          entryId: entry.id,
                                          taskId: taskId,
                                        ),
                                      );
                                },
                                onSnooze: (taskId, duration) {
                                  context.read<BulletJournalBloc>().add(
                                        BulletJournalEvent.snoozeTaskInPage(
                                          diaryId: widget.diaryId,
                                          pageId: currentPage.id,
                                          entryId: entry.id,
                                          taskId: taskId,
                                          postpone: duration,
                                        ),
                                      );
                                },
                                onDragEnd: null,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
