import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/bullet_journal_bloc.dart';
import '../models/diary.dart';
import '../models/diary_page.dart';
import '../models/diary_section.dart';
import '../models/bullet_entry.dart';
import '../models/key_definition.dart';
import '../data/key_definitions.dart';
import '../widgets/key_bullet_icon.dart';
import '../widgets/diary_background.dart';
import '../utils/device_type.dart';

enum EntrySortType {
  dateAscending,
  dateDescending,
  byKey,
  manual,
}

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

  List<BulletEntry> _sortEntries(
    List<BulletEntry> entries,
    EntrySortType sortType,
  ) {
    if (sortType == EntrySortType.manual) {
      // 수동 정렬일 경우 저장된 순서 사용
      if (_manualOrder.isEmpty || _manualOrder.length != entries.length) {
        // 수동 정렬 순서가 없거나 엔트리 개수가 변경된 경우, 현재 엔트리 순서 사용
        return entries;
      }
      // 수동 정렬 순서에 맞춰 정렬 (존재하는 엔트리만, 최신 상태 사용)
      final entriesMap = {for (final entry in entries) entry.id: entry};
      final manualOrderIds = _manualOrder.map((e) => e.id).toSet();
      final orderedEntries = <BulletEntry>[];

      // 수동 순서대로 추가 (최신 엔트리 상태 사용)
      for (final manualEntry in _manualOrder) {
        // _manualOrder에 있는 엔트리 ID로 최신 엔트리를 찾음
        final latestEntry = entriesMap[manualEntry.id];
        if (latestEntry != null) {
          orderedEntries.add(latestEntry);
        }
      }

      // 수동 순서에 없는 새로운 엔트리들을 뒤에 추가
      for (final entry in entries) {
        if (!manualOrderIds.contains(entry.id)) {
          orderedEntries.add(entry);
        }
      }

      return orderedEntries;
    }

    final sorted = [...entries];
    switch (sortType) {
      case EntrySortType.dateAscending:
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
      case EntrySortType.dateDescending:
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
      case EntrySortType.byKey:
        sorted.sort((a, b) {
          final orderA = a.keyStatus.order;
          final orderB = b.keyStatus.order;
          if (orderA != orderB) {
            return orderA.compareTo(orderB);
          }
          // 같은 키일 경우 날짜 내림차순으로 정렬
          return b.date.compareTo(a.date);
        });
        break;
      case EntrySortType.manual:
        // 이미 위에서 처리됨
        break;
    }
    return sorted;
  }

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

        final sortedEntries = _sortEntries(currentEntries, _sortType);

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
                onPressed: () => _showPageBottomSheet(context, state, diary),
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
                      _showSortDialog(context, state);
                      break;
                    case 'background':
                      _showBackgroundThemeDialog(
                        context,
                        widget.diaryId,
                        diary,
                      );
                      break;
                    case 'add_section':
                      if (currentPage != null) {
                        _showAddSectionDialog(
                            context, widget.diaryId, currentPage.id);
                      }
                      break;
                    case 'add_page':
                      _showAddPageDialog(context, widget.diaryId);
                      break;
                    case 'add':
                      if (currentPage != null) {
                        _showAddEntryDialog(context, widget.diaryId,
                            currentPage.id, currentPage);
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
                          return _NoteEntryLine(
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

  void _showSortDialog(BuildContext context, BulletJournalState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('정렬'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<EntrySortType>(
              title: const Text('날짜순 정렬 (오름차순)'),
              subtitle: const Text('오래된 것부터'),
              value: EntrySortType.dateAscending,
              groupValue: _sortType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortType = value;
                  });
                  context.pop();
                }
              },
            ),
            RadioListTile<EntrySortType>(
              title: const Text('최신순'),
              subtitle: const Text('최신 것부터'),
              value: EntrySortType.dateDescending,
              groupValue: _sortType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortType = value;
                  });
                  context.pop();
                }
              },
            ),
            RadioListTile<EntrySortType>(
              title: const Text('키별 정렬'),
              subtitle: const Text('키 순서대로'),
              value: EntrySortType.byKey,
              groupValue: _sortType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortType = value;
                  });
                  context.pop();
                }
              },
            ),
            RadioListTile<EntrySortType>(
              title: const Text('수동 정렬'),
              subtitle: const Text('드래그로 순서 변경'),
              value: EntrySortType.manual,
              groupValue: _sortType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortType = value;
                    final diary = state.diaries.firstWhere(
                      (d) => d.id == widget.diaryId,
                      orElse: () => Diary(
                        id: '',
                        name: '',
                        description: '',
                        createdAt: DateTime.now(),
                      ),
                    );
                    if (_manualOrder.isEmpty ||
                        _manualOrder.length != diary.entries.length) {
                      _manualOrder = [...diary.entries];
                    }
                  });
                  context.pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  void _showPageBottomSheet(
    BuildContext context,
    BulletJournalState state,
    Diary diary,
  ) {
    final parentContext = context; // 상위 화면의 context 저장
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      '페이지',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.help_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '더보기(...)를 눌러 속지를 삭제 또는 복사 할수 있어요. 길게 눌러 속지의 순서를 변경할 수 있어요.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => bottomSheetContext.pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 기기 타입에 따른 열 개수 결정
                  final deviceType =
                      DeviceTypeDetector.getDeviceType(bottomSheetContext);
                  int crossAxisCount;
                  switch (deviceType) {
                    case DeviceType.mobile:
                      crossAxisCount = 2; // 모바일: 2열
                      break;
                    case DeviceType.tablet:
                      crossAxisCount = 5; // 태블릿: 3열
                      break;
                    case DeviceType.desktop:
                      crossAxisCount = 5; // 데스크톱: 5열
                      break;
                  }

                  // 화면 크기에 따라 동적으로 조정 (선택적)
                  final width = constraints.maxWidth;
                  if (width > 1200) {
                    crossAxisCount = 5; // 매우 큰 화면: 5열
                  } else if (width > 900) {
                    crossAxisCount = 4; // 큰 화면: 4열
                  } else if (width > 600 && crossAxisCount < 3) {
                    crossAxisCount = 3; // 중간 화면: 최소 3열
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75, // 카드 비율 (세로가 약간 더 김)
                    ),
                    itemCount: diary.pages.length + 1, // +1 for Add button
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Add button
                        return GestureDetector(
                          onTap: () {
                            bottomSheetContext.pop();
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              if (parentContext.mounted) {
                                _showAddPageDialog(
                                    parentContext, widget.diaryId);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final pageIndex = index - 1;
                      final page = diary.pages[pageIndex];
                      final isCurrent = page.id == diary.currentPageId;

                      return _PagePreviewCard(
                        page: page,
                        diary: diary,
                        state: state,
                        isCurrent: isCurrent,
                        onTap: () {
                          parentContext.read<BulletJournalBloc>().add(
                                BulletJournalEvent.setCurrentPageInDiary(
                                  diaryId: widget.diaryId,
                                  pageId: page.id,
                                ),
                              );
                          bottomSheetContext.pop();
                        },
                        onLongPress: () {
                          bottomSheetContext.pop();
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (parentContext.mounted) {
                              _showPageOptionsDialog(
                                  parentContext, diary, page);
                            }
                          });
                        },
                        onMorePress: () {
                          bottomSheetContext.pop();
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (parentContext.mounted) {
                              _showPageOptionsDialog(
                                  parentContext, diary, page);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPageOptionsDialog(
    BuildContext context,
    Diary diary,
    DiaryPage page,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(page.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('이름 변경'),
              onTap: () {
                context.pop();
                _showRenamePageDialog(context, diary, page);
              },
            ),
            ListTile(
              leading: Icon(
                page.isFavorite ? Icons.star : Icons.star_border,
              ),
              title: Text(page.isFavorite ? '즐겨찾기 해제' : '즐겨찾기'),
              onTap: () {
                context.read<BulletJournalBloc>().add(
                      BulletJournalEvent.togglePageFavoriteInDiary(
                        diaryId: widget.diaryId,
                        pageId: page.id,
                      ),
                    );
                context.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                context.pop();
                _showDeletePageDialog(context, diary, page);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  void _showAddPageDialog(BuildContext context, String diaryId) {
    final nameController = TextEditingController(text: '새 페이지');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('페이지 추가'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '페이지 이름',
            hintText: '페이지 이름을 입력하세요',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('페이지 이름을 입력해주세요')),
                );
                return;
              }

              final newPage = DiaryPage(
                id: 'page-${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text.trim(),
                entries: [],
                createdAt: DateTime.now(),
              );

              context.read<BulletJournalBloc>().add(
                    BulletJournalEvent.addPageToDiary(
                      diaryId: diaryId,
                      page: newPage,
                    ),
                  );

              context.read<BulletJournalBloc>().add(
                    BulletJournalEvent.setCurrentPageInDiary(
                      diaryId: diaryId,
                      pageId: newPage.id,
                    ),
                  );

              context.pop();
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showRenamePageDialog(
    BuildContext context,
    Diary diary,
    DiaryPage page,
  ) {
    final nameController = TextEditingController(text: page.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('페이지 이름 변경'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '페이지 이름',
            hintText: '페이지 이름을 입력하세요',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('페이지 이름을 입력해주세요')),
                );
                return;
              }

              context.read<BulletJournalBloc>().add(
                    BulletJournalEvent.updatePageInDiary(
                      diaryId: widget.diaryId,
                      pageId: page.id,
                      updatedPage:
                          page.copyWith(name: nameController.text.trim()),
                    ),
                  );

              context.pop();
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  void _showDeletePageDialog(
    BuildContext context,
    Diary diary,
    DiaryPage page,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('페이지 삭제'),
        content: Text(
          '${page.name} 페이지를 삭제하시겠습니까?\n페이지 내의 모든 엔트리가 삭제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<BulletJournalBloc>().add(
                    BulletJournalEvent.deletePageFromDiary(
                      diaryId: widget.diaryId,
                      pageId: page.id,
                    ),
                  );
              context.pop();
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSectionDialog(
      BuildContext context, String diaryId, String pageId) {
    final nameController = TextEditingController(text: '새 섹션');
    showDialog(
      context: context,
      builder: (dialogContext) =>
          BlocBuilder<BulletJournalBloc, BulletJournalState>(
        builder: (context, state) {
          final diary = state.diaries.firstWhere(
            (d) => d.id == diaryId,
            orElse: () => Diary(
              id: '',
              name: '',
              description: '',
              createdAt: DateTime.now(),
            ),
          );
          final page = diary.pages.firstWhere(
            (p) => p.id == pageId,
            orElse: () => DiaryPage(
              id: '',
              name: '',
              createdAt: DateTime.now(),
            ),
          );

          // 기존 섹션 이름 목록
          List<DiarySection> sections = <DiarySection>[];
          try {
            sections = List<DiarySection>.from(page.sections);
          } catch (e) {
            sections = <DiarySection>[];
          }
          final existingNames =
              sections.map((s) => s.name.toLowerCase()).toSet();

          return AlertDialog(
            title: const Text('섹션 추가'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '섹션 이름',
                hintText: '섹션 이름을 입력하세요',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  final trimmedName = nameController.text.trim();
                  if (trimmedName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('섹션 이름을 입력해주세요')),
                    );
                    return;
                  }

                  // 중복 체크
                  if (existingNames.contains(trimmedName.toLowerCase())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('동일한 이름의 섹션이 이미 존재합니다')),
                    );
                    return;
                  }

                  final newSection = DiarySection(
                    id: 'section-${DateTime.now().millisecondsSinceEpoch}',
                    name: trimmedName,
                    createdAt: DateTime.now(),
                  );

                  context.read<BulletJournalBloc>().add(
                        BulletJournalEvent.addSectionToPage(
                          diaryId: diaryId,
                          pageId: pageId,
                          section: newSection,
                        ),
                      );

                  context.pop();
                },
                child: const Text('추가'),
              ),
            ],
          );
        },
      ),
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
            return _NoteEntryLine(
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
                      onPressed: () => _showSectionOptionsDialog(
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
              child: _NoteEntryLine(
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

  void _showSectionOptionsDialog(
    BuildContext context,
    String diaryId,
    DiaryPage page,
    DiarySection section,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(section.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('이름 변경'),
              onTap: () {
                context.pop();
                _showRenameSectionDialog(context, diaryId, page, section);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                context.pop();
                _showDeleteSectionDialog(context, diaryId, page, section);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  void _showRenameSectionDialog(
    BuildContext context,
    String diaryId,
    DiaryPage page,
    DiarySection section,
  ) {
    final nameController = TextEditingController(text: section.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('섹션 이름 변경'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '섹션 이름',
            hintText: '섹션 이름을 입력하세요',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('섹션 이름을 입력해주세요')),
                );
                return;
              }

              context.read<BulletJournalBloc>().add(
                    BulletJournalEvent.updateSectionInPage(
                      diaryId: diaryId,
                      pageId: page.id,
                      sectionId: section.id,
                      updatedSection:
                          section.copyWith(name: nameController.text.trim()),
                    ),
                  );

              context.pop();
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
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
              final draggedEntry = _findEntryById(
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
                        onPressed: () => _showSectionOptionsDialog(
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
                final draggedEntry = _findEntryById(
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
                          child: _NoteEntryLine(
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
                            final draggedEntry = _findEntryById(
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
                              child: _NoteEntryLine(
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

  BulletEntry? _findEntryById(
    String entryId,
    List<DiarySection> sections,
    Map<String, List<BulletEntry>> entriesBySection,
    List<BulletEntry> unassignedEntries,
  ) {
    // 섹션 내 엔트리에서 찾기
    for (final section in sections) {
      final entries = entriesBySection[section.id] ?? [];
      try {
        final entry = entries.firstWhere((e) => e.id == entryId);
        return entry;
      } catch (e) {
        // 찾지 못함, 계속 진행
      }
    }
    // 섹션 없음 엔트리에서 찾기
    try {
      final unassignedEntry =
          unassignedEntries.firstWhere((e) => e.id == entryId);
      return unassignedEntry;
    } catch (e) {
      // 찾지 못함
    }
    return null;
  }

  void _showDeleteSectionDialog(
    BuildContext context,
    String diaryId,
    DiaryPage page,
    DiarySection section,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('섹션 삭제'),
        content: Text(
          '${section.name} 섹션을 삭제하시겠습니까?\n섹션 내의 엔트리는 "섹션 없음"으로 이동됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<BulletJournalBloc>().add(
                    BulletJournalEvent.deleteSectionFromPage(
                      diaryId: diaryId,
                      pageId: page.id,
                      sectionId: section.id,
                    ),
                  );
              context.pop();
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEntryDialog(
      BuildContext context, String diaryId, String pageId, DiaryPage page) {
    final bloc = context.read<BulletJournalBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => _AddEntryDialog(
        bloc: bloc,
        diaryId: diaryId,
        pageId: pageId,
        page: page,
      ),
    );
  }

  void _showBackgroundThemeDialog(
    BuildContext context,
    String diaryId,
    Diary diary,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('배경 테마 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<DiaryBackgroundTheme>(
              title: const Text('무지'),
              value: DiaryBackgroundTheme.plain,
              groupValue: diary.backgroundTheme,
              onChanged: (value) {
                if (value != null) {
                  context.read<BulletJournalBloc>().add(
                        BulletJournalEvent.updateDiary(
                          diaryId: diaryId,
                          updatedDiary: diary.copyWith(backgroundTheme: value),
                        ),
                      );
                  context.pop();
                }
              },
            ),
            RadioListTile<DiaryBackgroundTheme>(
              title: const Text('모눈'),
              value: DiaryBackgroundTheme.grid,
              groupValue: diary.backgroundTheme,
              onChanged: (value) {
                if (value != null) {
                  context.read<BulletJournalBloc>().add(
                        BulletJournalEvent.updateDiary(
                          diaryId: diaryId,
                          updatedDiary: diary.copyWith(backgroundTheme: value),
                        ),
                      );
                  context.pop();
                }
              },
            ),
            RadioListTile<DiaryBackgroundTheme>(
              title: const Text('줄글'),
              value: DiaryBackgroundTheme.lined,
              groupValue: diary.backgroundTheme,
              onChanged: (value) {
                if (value != null) {
                  context.read<BulletJournalBloc>().add(
                        BulletJournalEvent.updateDiary(
                          diaryId: diaryId,
                          updatedDiary: diary.copyWith(backgroundTheme: value),
                        ),
                      );
                  context.pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}

class _AddEntryDialog extends StatefulWidget {
  const _AddEntryDialog({
    required this.bloc,
    required this.diaryId,
    required this.pageId,
    required this.page,
  });

  final BulletJournalBloc bloc;
  final String diaryId;
  final String pageId;
  final DiaryPage page;

  @override
  State<_AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<_AddEntryDialog> {
  final _focusController = TextEditingController();
  final _noteController = TextEditingController();
  TaskStatus? _selectedStatus;
  DateTime _selectedDate = DateTime.now();
  bool _hasInitializedStatus = false;
  String? _selectedSectionId;

  @override
  void initState() {
    super.initState();
    // 기본값으로 '계획 중' 상태 선택
    final state = widget.bloc.state;
    if (state.taskStatuses.isNotEmpty) {
      _selectedStatus = state.taskStatuses.firstWhere(
        (s) => s.id == TaskStatus.planned.id,
        orElse: () => state.taskStatuses.first,
      );
      _hasInitializedStatus = true;
    }
  }

  @override
  void dispose() {
    _focusController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocBuilder<BulletJournalBloc, BulletJournalState>(
        builder: (context, state) {
          // initState에서 초기화하지 못한 경우 다시 시도
          if (!_hasInitializedStatus && state.taskStatuses.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                final plannedStatus = state.taskStatuses.firstWhere(
                  (s) => s.id == TaskStatus.planned.id,
                  orElse: () => state.taskStatuses.first,
                );
                setState(() {
                  _selectedStatus = plannedStatus;
                  _hasInitializedStatus = true;
                });
              }
            });
          }

          return AlertDialog(
            title: const Text('엔트리 추가'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _focusController,
                    decoration: const InputDecoration(
                      labelText: '제목',
                      hintText: '제목을 입력해주세요',
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '날짜',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(_formatDate(_selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: '노트',
                      hintText: '상세 내용',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // 섹션 선택 (페이지에 섹션이 있는 경우만)
                  if (widget.page.sections.isNotEmpty) ...[
                    DropdownButtonFormField<String?>(
                      value: _selectedSectionId,
                      decoration: const InputDecoration(
                        labelText: '섹션',
                        border: OutlineInputBorder(),
                        hintText: '섹션을 선택하세요 (선택 사항)',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('섹션 없음'),
                        ),
                        ...widget.page.sections.map((section) {
                          return DropdownMenuItem<String?>(
                            value: section.id,
                            child: Text(section.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSectionId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text('키 선택:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TaskStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: '작업 상태',
                      border: OutlineInputBorder(),
                      hintText: '엔트리의 기본 키를 선택하세요',
                    ),
                    items: state.taskStatuses.map((status) {
                      // 상태에 매핑된 키 찾기
                      final keyId = state.statusKeyMapping[status.id] ??
                          _getDefaultKeyId(status.id);
                      final allDefinitions = [
                        ...defaultKeyDefinitions,
                        ...state.customKeys,
                      ];
                      final keyDefinition = allDefinitions.firstWhere(
                        (def) => def.id == keyId,
                        orElse: () => defaultKeyDefinitions.first,
                      );

                      return DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            KeyBulletIcon(definition: keyDefinition),
                            const SizedBox(width: 12),
                            Text(status.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (_focusController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('제목를 입력해주세요')),
                    );
                    return;
                  }

                  if (_selectedStatus == null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('키를 선택해주세요')));
                    return;
                  }

                  // 섹션 할당 로직:
                  // - 섹션이 있는 경우: 선택한 섹션 ID 사용 (선택 안 하면 null = "섹션 없음")
                  // - 섹션이 없는 경우: sectionId를 null로 설정 (섹션 정보 없음)
                  final entry = BulletEntry(
                    id: 'entry-${DateTime.now().millisecondsSinceEpoch}',
                    date: _selectedDate,
                    focus: _focusController.text,
                    note: _noteController.text,
                    keyStatus: _selectedStatus!,
                    tasks: [],
                    sectionId: widget.page.sections.isNotEmpty
                        ? _selectedSectionId
                        : null,
                  );

                  widget.bloc.add(
                    BulletJournalEvent.addEntryToPage(
                      diaryId: widget.diaryId,
                      pageId: widget.pageId,
                      entry: entry,
                    ),
                  );

                  context.pop();
                },
                child: const Text('추가'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getDefaultKeyId(String statusId) {
    const defaultMapping = {
      'planned': 'key-incomplete',
      'inProgress': 'key-progress',
      'completed': 'key-completed',
      'memo': 'key-memo',
      'etc': 'key-other',
    };
    return defaultMapping[statusId] ?? 'key-incomplete';
  }
}

class _NoteEntryLine extends StatelessWidget {
  const _NoteEntryLine({
    super.key,
    required this.entry,
    required this.state,
    required this.diaryId,
    required this.pageId,
    required this.onToggleTask,
    required this.onSnooze,
    this.onDragEnd,
  });

  final BulletEntry entry;
  final BulletJournalState state;
  final String diaryId;
  final String pageId;
  final void Function(String taskId) onToggleTask;
  final void Function(String taskId, Duration duration) onSnooze;
  final void Function(String? sectionId)? onDragEnd;

  static const _defaultStatusKeyMapping = {
    'planned': 'key-incomplete',
    'inProgress': 'key-progress',
    'completed': 'key-completed',
  };

  KeyDefinition _keyDefinitionForEntry() {
    try {
      final status = entry.keyStatus;
      final keyId = state.statusKeyMapping[status.id] ??
          _defaultStatusKeyMapping[status.id] ??
          defaultKeyDefinitions.first.id;
      final allDefinitions = [...defaultKeyDefinitions, ...state.customKeys];
      return allDefinitions.firstWhere(
        (definition) => definition.id == keyId,
        orElse: () => defaultKeyDefinitions.first,
      );
    } catch (e) {
      return defaultKeyDefinitions.first;
    }
  }

  KeyDefinition _definitionFor(BulletTask task) {
    final isSnoozed = task.snoozes.isNotEmpty;
    final keyId = isSnoozed
        ? 'key-snoozed'
        : state.statusKeyMapping[task.status.id] ??
            _defaultStatusKeyMapping[task.status.id] ??
            defaultKeyDefinitions.first.id;
    final allDefinitions = [...defaultKeyDefinitions, ...state.customKeys];
    return allDefinitions.firstWhere(
      (definition) => definition.id == keyId,
      orElse: () => defaultKeyDefinitions.first,
    );
  }

  static String _formattedDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final keyDef = _keyDefinitionForEntry();

    final entryWidget = InkWell(
      onTap: () => context.push('/entry-note/${entry.id}', extra: entry),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 엔트리 라인: 키 아이콘 + 제목
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, right: 8.0),
                  child: KeyBulletIcon(definition: keyDef),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              entry.focus,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _formattedDate(entry.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (entry.note.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.note,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (entry.note.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.note_outlined,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
            // 작업 목록
            if (entry.tasks.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...entry.tasks.map((task) {
                final taskKeyDef = _definitionFor(task);
                return Padding(
                  padding: const EdgeInsets.only(left: 24.0, top: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0, right: 8.0),
                        child: KeyBulletIcon(definition: taskKeyDef),
                      ),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            decoration:
                                task.status.id == TaskStatus.completed.id
                                    ? TextDecoration.lineThrough
                                    : null,
                            color: task.status.id == TaskStatus.completed.id
                                ? Colors.grey.shade600
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          task.status.id == TaskStatus.completed.id
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 18,
                          color: task.status.id == TaskStatus.completed.id
                              ? Colors.green
                              : Colors.grey,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => onToggleTask(task.id),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );

    // 드래그 앤 드롭이 가능한 경우 Draggable로 감싸기
    if (onDragEnd != null) {
      return Draggable<String>(
        data: entry.id,
        feedback: Material(
          elevation: 4,
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
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
          child: entryWidget,
        ),
        child: entryWidget,
      );
    }

    return entryWidget;
  }
}

class _PagePreviewCard extends StatelessWidget {
  const _PagePreviewCard({
    required this.page,
    required this.diary,
    required this.state,
    required this.isCurrent,
    required this.onTap,
    required this.onLongPress,
    required this.onMorePress,
  });

  final DiaryPage page;
  final Diary diary;
  final BulletJournalState state;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMorePress;

  Widget _buildPagePreview(
    List<DiarySection> sections,
    Map<String, List<BulletEntry>> entriesBySection,
    List<BulletEntry> unassignedEntries,
    bool hasSections,
    DiaryPage page,
    BulletJournalState state,
  ) {
    if (hasSections) {
      // 섹션이 있는 경우 섹션별로 표시
      const unassignedHeaderId = 'unassigned_header';
      final List<dynamic> flatItems = [];

      for (final section in sections) {
        flatItems.add(section);
        flatItems.addAll(entriesBySection[section.id] ?? []);
      }

      if (unassignedEntries.isNotEmpty) {
        flatItems.add(unassignedHeaderId);
        flatItems.addAll(unassignedEntries);
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: flatItems.length,
        itemBuilder: (context, index) {
          final item = flatItems[index];

          // 섹션 헤더
          if (item is DiarySection) {
            return Container(
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  dense: true,
                ),
              ),
            );
          }

          // '섹션 없음' 헤더
          if (item == unassignedHeaderId) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '섹션 없음',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
            );
          }

          // 엔트리
          if (item is BulletEntry) {
            return _NoteEntryLine(
              key: ValueKey(item.id),
              entry: item,
              state: state,
              diaryId: diary.id,
              pageId: page.id,
              onToggleTask: (_) {},
              onSnooze: (_, __) {},
              onDragEnd: null,
            );
          }

          return const SizedBox.shrink();
        },
      );
    } else {
      // 섹션이 없는 경우
      if (page.entries.isEmpty) {
        return const Center(
          child: Text(
            '빈 페이지',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: page.entries.length,
        itemBuilder: (context, index) {
          final entry = page.entries[index];
          return _NoteEntryLine(
            key: ValueKey(entry.id),
            entry: entry,
            state: state,
            diaryId: diary.id,
            pageId: page.id,
            onToggleTask: (_) {},
            onSnooze: (_, __) {},
            onDragEnd: null,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 섹션별로 엔트리 그룹화
    List<DiarySection> sections = <DiarySection>[];
    try {
      final sectionsValue = page.sections;
      sections = List<DiarySection>.from(sectionsValue);
    } catch (e) {
      sections = <DiarySection>[];
    }
    sections.sort((a, b) => a.order.compareTo(b.order));

    final hasSections = sections.isNotEmpty;
    Map<String, List<BulletEntry>> entriesBySection = {};
    List<BulletEntry> unassignedEntries = [];

    if (hasSections) {
      for (final section in sections) {
        entriesBySection[section.id] =
            page.entries.where((e) => e.sectionId == section.id).toList();
      }
      unassignedEntries =
          page.entries.where((e) => e.sectionId == null).toList();
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isCurrent
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isCurrent ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page preview - 실제 화면 그대로 축소해서 표시
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Transform.scale(
                  scale: 0.25,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 4,
                    height: MediaQuery.of(context).size.height * 4,
                    child: DiaryBackground(
                      theme: diary.backgroundTheme,
                      child: _buildPagePreview(
                        sections,
                        entriesBySection,
                        unassignedEntries,
                        hasSections,
                        page,
                        state,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Page name and more button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isCurrent
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  if (page.isFavorite)
                    Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.amber.shade700,
                    ),
                  if (page.isFavorite) const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      page.name,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isCurrent
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Colors.grey.shade800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 14),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    onPressed: onMorePress,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
