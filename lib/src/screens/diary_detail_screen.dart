import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/bullet_journal_bloc.dart';
import '../models/diary.dart';
import '../models/diary_page.dart';
import '../models/diary_section.dart';
import '../models/bullet_entry.dart';
import '../utils/page_sort_utils.dart';
import '../widgets/diary_background.dart';
import 'diary_detail/utils/entry_sort_type.dart';
import 'diary_detail/utils/entry_sort_utils.dart';
import 'diary_detail/widgets/note_entry_line.dart';
import 'diary_detail/widgets/index_page_view.dart';
import 'diary_detail/dialogs/add_entry_dialog.dart';
import 'diary_detail/dialogs/background_theme_dialog.dart';
import 'diary_detail/dialogs/sort_dialog.dart';
import 'diary_detail/dialogs/page_bottom_sheet.dart';
import 'diary_detail/dialogs/page_dialogs.dart';
import 'diary_detail/dialogs/section_dialogs.dart';
import 'diary_detail/dialogs/add_timetable_dialog.dart';
import 'time_table_detail/time_table_detail_screen.dart';
import '../widgets/time_table_widget.dart';
import '../models/page_component.dart';
import '../constants/layout_order.dart';

/// 엔트리와 컴포넌트를 통합한 아이템 타입
class _UnifiedItem {
  final BulletEntry? entry;
  final PageComponent? component;
  final int order;

  _UnifiedItem.entry(this.entry, this.order) : component = null;
  _UnifiedItem.component(this.component, this.order) : entry = null;

  T when<T>({
    required T Function(BulletEntry entry, int order) entry,
    required T Function(PageComponent component, int order) component,
  }) {
    if (this.entry != null) {
      return entry(this.entry!, this.order);
    } else {
      return component(this.component!, this.order);
    }
  }
}

class DiaryDetailScreen extends StatefulWidget {
  const DiaryDetailScreen({super.key, required this.diaryId});

  final String diaryId;

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

// 커스텀 PageScrollPhysics로 마지막 페이지에서 다음 페이지로 넘어가려고 할 때 감지
class _CustomPageScrollPhysics extends ClampingScrollPhysics {
  final VoidCallback onReachEnd;
  final VoidCallback? onReachStart;

  const _CustomPageScrollPhysics({
    required this.onReachEnd,
    this.onReachStart,
  });

  @override
  _CustomPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _CustomPageScrollPhysics(
      onReachEnd: onReachEnd,
      onReachStart: onReachStart,
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // 첫 번째 페이지에서 왼쪽으로 스와이프하려고 할 때 감지
    if (value < position.minScrollExtent && onReachStart != null) {
      if (value < position.minScrollExtent - 50) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onReachStart?.call();
        });
      }
    }
    // 마지막 페이지에서 오른쪽으로 스와이프하려고 할 때 감지
    if (value > position.maxScrollExtent) {
      // 약간의 임계값을 두어 실제로 스와이프했을 때만 트리거
      if (value > position.maxScrollExtent + 50) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onReachEnd();
        });
      }
    }
    return super.applyBoundaryConditions(position, value);
  }
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  EntrySortType _sortType = EntrySortType.dateDescending;
  List<BulletEntry> _manualOrder = [];
  bool _isKanbanView = false; // 칸반보드 보기 모드
  PageController? _pageController; // PageView 컨트롤러
  int _currentPageIndex = 0; // 현재 페이지 인덱스 (PageView 내부용)
  bool _isShowingAddPageDialog = false; // 새 페이지 생성 다이얼로그 표시 중인지 여부

  List<String> _getPageLayoutOrder(DiaryPage page) {
    try {
      return List<String>.from(page.layoutOrder);
    } catch (_) {
      return <String>[];
    }
  }

  String _getComponentId(PageComponent component) {
    return component.map(
      section: (section) => section.id,
      timeTable: (timeTable) => timeTable.id,
    );
  }

  void _openTimeTableDetail(TimeTableComponent component, String pageId) {
    if (!mounted) return;
    context.push(
      '/time-table/${component.id}',
      extra: TimeTableDetailArgs(
        diaryId: widget.diaryId,
        pageId: pageId,
        component: component,
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // PageController의 position을 리스닝하여 마지막 페이지에서 다음으로 넘어가려고 할 때 감지
    _pageController?.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    // 이 메서드는 나중에 사용할 수 있지만, 현재는 onPageChanged에서 처리
  }

  @override
  void dispose() {
    _pageController?.removeListener(_onPageScroll);
    _pageController?.dispose();
    super.dispose();
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

        // 페이지 정렬 (인덱스 페이지가 맨 앞)
        final sortedPages = PageSortUtils.sortPages(diary.pages);
        
        // 인덱스 페이지가 없으면 생성 (페이지가 하나만 있어도)
        final hasIndexPage = sortedPages.any((p) => p.isIndexPage);
        if (!hasIndexPage && sortedPages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final indexPage = DiaryPage(
              id: 'index-page-${DateTime.now().millisecondsSinceEpoch}',
              name: null,
              entries: [],
              sections: [],
              createdAt: DateTime.now(),
              isIndexPage: true,
            );
            context.read<BulletJournalBloc>().add(
                  BulletJournalEvent.addPageToDiary(
                    diaryId: widget.diaryId,
                    page: indexPage,
                  ),
                );
          });
        }

        // 페이지가 없으면 기본 페이지 생성
        if (diary.pages.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final defaultPage = DiaryPage(
              id: 'page-${DateTime.now().millisecondsSinceEpoch}',
              name: null, // 이름 선택적
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
          final foundPage = sortedPages.firstWhere(
            (p) => p.id == diary.currentPageId,
            orElse: () => sortedPages.isNotEmpty
                ? sortedPages.first
                : DiaryPage(
                    id: '',
                    name: null,
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
        } else if (sortedPages.isNotEmpty) {
          final firstPage = sortedPages.first;
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
                if (currentPage != null && !currentPage.isIndexPage)
                  if (currentPage.name != null)
                    Text(
                      currentPage.name!,
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
                    value: 'add_timetable',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_view_week, size: 20),
                        SizedBox(width: 12),
                        Text('타임테이블 추가'),
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
                    case 'add_timetable':
                      if (currentPage != null) {
                        showAddTimeTableDialog(
                            context, widget.diaryId, currentPage.id);
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
              : _buildPageView(
                  context,
                  diary,
                  sortedPages,
                  currentPage,
                  hasSections,
                  sections,
                  entriesBySection,
                  unassignedEntries,
                  sortedEntries,
                  state,
                  _isKanbanView,
                ),
        );
      },
    );
  }

  /// 엔트리와 컴포넌트를 통합한 리스트 빌드
  Widget _buildUnifiedEntriesAndComponentsList(
    BuildContext context,
    List<BulletEntry> entries,
    List<PageComponent> components,
    DiaryPage page,
    BulletJournalState state,
  ) {
    final entryMap = {for (final entry in entries) entry.id: entry};
    final componentMap = {
      for (final component in components) _getComponentId(component): component
    };
    final sortedComponents = [...components]..sort(
        (a, b) {
          final orderA =
              a.map(section: (s) => s.order, timeTable: (t) => t.order);
          final orderB =
              b.map(section: (s) => s.order, timeTable: (t) => t.order);
          return orderA.compareTo(orderB);
        },
      );

    List<String> layoutOrder = _getPageLayoutOrder(page);
    bool layoutOrderUpdated = false;

    if (layoutOrder.isEmpty) {
      layoutOrder = [
        ...entries.map((e) => layoutEntryToken(e.id)),
        ...sortedComponents
            .map((c) => layoutComponentToken(_getComponentId(c))),
      ];
      layoutOrderUpdated = true;
    }

    final unifiedItems = <_UnifiedItem>[];
    final usedEntryIds = <String>{};
    final usedComponentIds = <String>{};
    final effectiveLayoutOrder = <String>[];

    void addEntryToList(BulletEntry entry) {
      unifiedItems.add(_UnifiedItem.entry(entry, unifiedItems.length));
      effectiveLayoutOrder.add(layoutEntryToken(entry.id));
      usedEntryIds.add(entry.id);
    }

    void addComponentToList(PageComponent component) {
      unifiedItems.add(_UnifiedItem.component(component, unifiedItems.length));
      effectiveLayoutOrder
          .add(layoutComponentToken(_getComponentId(component)));
      usedComponentIds.add(_getComponentId(component));
    }

    for (final token in layoutOrder) {
      if (token.startsWith(layoutEntryPrefix)) {
        final entryId = token.substring(layoutEntryPrefix.length);
        final entry = entryMap[entryId];
        if (entry != null) {
          if (!usedEntryIds.contains(entryId)) {
            addEntryToList(entry);
          }
        } else {
          layoutOrderUpdated = true;
        }
      } else if (token.startsWith(layoutComponentPrefix)) {
        final componentId = token.substring(layoutComponentPrefix.length);
        final component = componentMap[componentId];
        if (component != null) {
          if (!usedComponentIds.contains(componentId)) {
            addComponentToList(component);
          }
        } else {
          layoutOrderUpdated = true;
        }
      }
    }

    // 레이아웃 순서에 포함되지 않은 나머지 엔트리/컴포넌트 추가
    for (final entry in entries) {
      if (!usedEntryIds.contains(entry.id)) {
        addEntryToList(entry);
        layoutOrderUpdated = true;
      }
    }

    for (final component in sortedComponents) {
      final id = _getComponentId(component);
      if (!usedComponentIds.contains(id)) {
        addComponentToList(component);
        layoutOrderUpdated = true;
      }
    }

    if (layoutOrderUpdated && effectiveLayoutOrder.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<BulletJournalBloc>().add(
              BulletJournalEvent.updateLayoutOrderInPage(
                diaryId: widget.diaryId,
                pageId: page.id,
                layoutOrder: effectiveLayoutOrder,
              ),
            );
      });
    }

    return ReorderableListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: unifiedItems.length,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        // 현재 unifiedItems를 복사하여 수정
        final updatedItems = <_UnifiedItem>[...unifiedItems];
        final movedItem = updatedItems.removeAt(oldIndex);
        updatedItems.insert(newIndex, movedItem);

        // 순서 업데이트: 새로운 순서에 따라 엔트리와 컴포넌트 분리
        final reorderedEntries = <BulletEntry>[];
        final reorderedComponents = <PageComponent>[];
        final newLayoutOrder = <String>[];

        for (int i = 0; i < updatedItems.length; i++) {
          updatedItems[i].when(
            entry: (entry, _) {
              reorderedEntries.add(entry);
              newLayoutOrder.add(layoutEntryToken(entry.id));
            },
            component: (component, _) {
              // 새로운 위치를 order로 업데이트
              final updatedComponent = component.map(
                section: (s) => s.copyWith(order: i),
                timeTable: (t) => t.copyWith(order: i),
              );
              reorderedComponents.add(updatedComponent);
              newLayoutOrder.add(
                layoutComponentToken(_getComponentId(component)),
              );
            },
          );
        }

        // 상태 업데이트
        setState(() {
          _manualOrder = reorderedEntries;
          _sortType = EntrySortType.manual;
        });

        // 엔트리 순서 업데이트
        if (reorderedEntries.isNotEmpty) {
          context.read<BulletJournalBloc>().add(
                BulletJournalEvent.reorderEntriesInPage(
                  diaryId: widget.diaryId,
                  pageId: page.id,
                  reorderedEntries: reorderedEntries,
                ),
              );
        }

        // 컴포넌트 순서 업데이트
        if (reorderedComponents.isNotEmpty) {
          context.read<BulletJournalBloc>().add(
                BulletJournalEvent.reorderComponentsInPage(
                  diaryId: widget.diaryId,
                  pageId: page.id,
                  reorderedComponents: reorderedComponents,
                ),
              );
        }

        if (newLayoutOrder.isNotEmpty) {
          context.read<BulletJournalBloc>().add(
                BulletJournalEvent.updateLayoutOrderInPage(
                  diaryId: widget.diaryId,
                  pageId: page.id,
                  layoutOrder: newLayoutOrder,
                ),
              );
        }
      },
      itemBuilder: (context, index) {
        final item = unifiedItems[index];
        return item.when(
          entry: (entry, _) {
            return Container(
              key: ValueKey('entry-${entry.id}'),
              child: NoteEntryLine(
                key: ValueKey('entry-${entry.id}-content'),
                entry: entry,
                state: state,
                diaryId: widget.diaryId,
                pageId: page.id,
                onToggleTask: (taskId) {
                  context.read<BulletJournalBloc>().add(
                        BulletJournalEvent.toggleTaskInPage(
                          diaryId: widget.diaryId,
                          pageId: page.id,
                          entryId: entry.id,
                          taskId: taskId,
                        ),
                      );
                },
                onSnooze: (taskId, duration) {
                  context.read<BulletJournalBloc>().add(
                        BulletJournalEvent.snoozeTaskInPage(
                          diaryId: widget.diaryId,
                          pageId: page.id,
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
          component: (component, _) {
            return component.map(
              section: (section) => const SizedBox.shrink(),
              timeTable: (timeTable) => Container(
                key: ValueKey('component-${timeTable.id}'),
                child: TimeTableWidget(
                  key: ValueKey('component-${timeTable.id}-content'),
                  diaryId: widget.diaryId,
                  pageId: page.id,
                  component: timeTable,
                  onOpenDetail: () => _openTimeTableDetail(
                    timeTable,
                    page.id,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildComponentsList(
    BuildContext context,
    DiaryPage currentPage,
    bool isKanbanView,
  ) {
    // components 필드 마이그레이션 (기존 데이터 호환성)
    List<PageComponent> components = [];
    try {
      final componentsValue = currentPage.components;
      components = List<PageComponent>.from(componentsValue);
    } catch (e) {
      components = <PageComponent>[];
    }
    
    final layoutOrder = _getPageLayoutOrder(currentPage);
    final componentMap = {
      for (final component in components) _getComponentId(component): component
    };

    final orderedComponents = <PageComponent>[];
    final usedIds = <String>{};

    for (final token in layoutOrder) {
      if (token.startsWith(layoutComponentPrefix)) {
        final componentId = token.substring(layoutComponentPrefix.length);
        final component = componentMap[componentId];
        if (component != null && !usedIds.contains(componentId)) {
          orderedComponents.add(component);
          usedIds.add(componentId);
        }
      }
    }

    final fallbackSorted =
        [...components]..sort((a, b) {
            final orderA =
                a.map(section: (s) => s.order, timeTable: (t) => t.order);
            final orderB =
                b.map(section: (s) => s.order, timeTable: (t) => t.order);
            return orderA.compareTo(orderB);
          });

    for (final component in fallbackSorted) {
      final id = _getComponentId(component);
      if (!usedIds.contains(id)) {
        orderedComponents.add(component);
        usedIds.add(id);
      }
    }

    return Column(
      children: orderedComponents.map((component) {
        return component.map(
          section: (section) => const SizedBox.shrink(), // 섹션은 별도 처리
          timeTable: (timeTable) => LongPressDraggable<PageComponent>(
            key: ValueKey('component-${timeTable.id}'),
            data: component,
            delay: const Duration(milliseconds: 500),
            feedback: Material(
              elevation: 8,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal, width: 2),
                ),
                child: Text(
                  timeTable.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: TimeTableWidget(
                diaryId: widget.diaryId,
                pageId: currentPage.id,
                component: timeTable,
                isKanbanView: isKanbanView,
              ),
            ),
            child: TimeTableWidget(
              diaryId: widget.diaryId,
              pageId: currentPage.id,
              component: timeTable,
              isKanbanView: isKanbanView,
              onOpenDetail: () => _openTimeTableDetail(
                timeTable,
                currentPage.id,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionedEntriesList(
    BuildContext context,
    List<DiarySection> sections,
    Map<String, List<BulletEntry>> entriesBySection,
    List<BulletEntry> unassignedEntries,
    Map<String, List<TimeTableComponent>> timeTablesBySection,
    List<TimeTableComponent> unassignedTimeTables,
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
                final sectionTimeTables = section != null
                    ? (timeTablesBySection[section.id] ?? [])
                    : unassignedTimeTables;

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
                      sectionTimeTables,
                      sections,
                      entriesBySection,
                      unassignedEntries,
                      timeTablesBySection,
                      unassignedTimeTables,
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
      // 섹션 헤더와 엔트리/타임테이블을 하나의 리스트로 만들어 ReorderableListView에 넣습니다.
      final List<dynamic> flatItems = [];
      final layoutOrder = _getPageLayoutOrder(currentPage);

      List<dynamic> buildItemsForSection(
        List<BulletEntry> entries,
        List<TimeTableComponent> timeTables,
      ) {
        final items = <dynamic>[];
        final entryMap = {for (final entry in entries) entry.id: entry};
        final tableMap = {for (final table in timeTables) table.id: table};

        for (final token in layoutOrder) {
          if (token.startsWith(layoutEntryPrefix)) {
            final entryId = token.substring(layoutEntryPrefix.length);
            final entry = entryMap.remove(entryId);
            if (entry != null) {
              items.add(entry);
            }
          } else if (token.startsWith(layoutComponentPrefix)) {
            final componentId = token.substring(layoutComponentPrefix.length);
            final table = tableMap.remove(componentId);
            if (table != null) {
              items.add(table);
            }
          }
        }

        for (final entry in entries) {
          if (entryMap.remove(entry.id) != null) {
            items.add(entry);
          }
        }

        for (final table in timeTables) {
          if (tableMap.remove(table.id) != null) {
            items.add(table);
          }
        }

        return items;
      }

      for (final section in sections) {
        flatItems.add(section);
        flatItems.addAll(
          buildItemsForSection(
            entriesBySection[section.id] ?? [],
            timeTablesBySection[section.id] ?? [],
          ),
        );
      }

      const unassignedHeaderId = 'unassigned_header';
      final hasUnassignedItems =
          unassignedEntries.isNotEmpty || unassignedTimeTables.isNotEmpty;
      if (hasUnassignedItems) {
        flatItems.add(unassignedHeaderId);
        flatItems.addAll(
          buildItemsForSection(
            unassignedEntries,
            unassignedTimeTables,
          ),
        );
      }

      return ReorderableListView.builder(
        physics: const ClampingScrollPhysics(),
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
          final List<PageComponent> allNewOrderedComponents = [];
          final Set<String> orderedComponentIds = {};
          final List<String> newLayoutOrder = [];
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
              newLayoutOrder.add(layoutEntryToken(entryToSave.id));
            } else if (listItem is TimeTableComponent) {
              final shouldReassign = listItem.sectionId != currentSectionId;
              final updatedComponent = shouldReassign
                  ? listItem.copyWith(sectionId: currentSectionId)
                  : listItem;
              if (shouldReassign) {
                context.read<BulletJournalBloc>().add(
                      BulletJournalEvent.assignComponentToSection(
                        diaryId: widget.diaryId,
                        pageId: currentPage.id,
                        componentId: listItem.id,
                        sectionId: currentSectionId,
                      ),
                    );
              }
              allNewOrderedComponents.add(updatedComponent);
              orderedComponentIds.add(listItem.id);
              newLayoutOrder.add(layoutComponentToken(listItem.id));
            }
          }

          for (final component in currentPage.components) {
            final componentId = _getComponentId(component);
            final isTimeTable = component.map(
              section: (_) => false,
              timeTable: (_) => true,
            );
            if (!isTimeTable) continue;
            if (!orderedComponentIds.contains(componentId)) {
              allNewOrderedComponents.add(component);
              newLayoutOrder.add(layoutComponentToken(componentId));
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

          if (allNewOrderedComponents.isNotEmpty) {
            context.read<BulletJournalBloc>().add(
                  BulletJournalEvent.reorderComponentsInPage(
                    diaryId: widget.diaryId,
                    pageId: currentPage.id,
                    reorderedComponents: allNewOrderedComponents,
                  ),
                );
          }

          if (newLayoutOrder.isNotEmpty) {
            context.read<BulletJournalBloc>().add(
                  BulletJournalEvent.updateLayoutOrderInPage(
                    diaryId: widget.diaryId,
                    pageId: currentPage.id,
                    layoutOrder: newLayoutOrder,
                  ),
                );
          }
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

          if (item is TimeTableComponent) {
            return ReorderableDragStartListener(
              key: ValueKey('timetable-${item.id}'),
              index: index,
              child: TimeTableWidget(
                diaryId: widget.diaryId,
                pageId: currentPage.id,
                component: item,
                onOpenDetail: () => _openTimeTableDetail(
                  item,
                  currentPage.id,
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      );
    }
  }

  /// 섹션별 엔트리 맵과 섹션 없음 엔트리 리스트에서 특정 ID의 엔트리를 찾는 헬퍼 함수
  BulletEntry? findEntryById(
    String entryId,
    List<DiarySection> sections,
    Map<String, List<BulletEntry>> entriesBySection,
    List<BulletEntry> unassignedEntries,
  ) {
    // 섹션별 엔트리에서 찾기
    for (final section in sections) {
      final entries = entriesBySection[section.id] ?? [];
      try {
        final found = entries.firstWhere((e) => e.id == entryId);
        return found;
      } catch (e) {
        // 이 섹션에 없음, 다음 섹션 확인
        continue;
      }
    }

    // 섹션 없음 엔트리에서 찾기
    try {
      return unassignedEntries.firstWhere((e) => e.id == entryId);
    } catch (e) {
      return null;
    }
  }

  Widget _buildKanbanSectionColumn(
    BuildContext context,
    DiarySection? section,
    List<BulletEntry> sectionEntries,
    List<TimeTableComponent> sectionTimeTables,
    List<DiarySection> sections,
    Map<String, List<BulletEntry>> entriesBySection,
    List<BulletEntry> unassignedEntries,
    Map<String, List<TimeTableComponent>> timeTablesBySection,
    List<TimeTableComponent> unassignedTimeTables,
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
          // 섹션 제목 - 엔트리/타임테이블 드래그 지원
          // 섹션 드래그는 아이콘을 통해 별도로 처리
          DragTarget<Object>(
            onWillAccept: (data) => true,
            onAcceptWithDetails: (details) {
              final data = details.data;
              if (data is String) {
                // 엔트리 드래그
                final entryId = data;
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
              } else if (data is PageComponent) {
                // 타임테이블 드래그
                final draggedComponent = data;
                draggedComponent.maybeMap(
                  timeTable: (timeTable) {
                    final isSameSection = timeTable.sectionId == section?.id;
                    if (!isSameSection) {
                      context.read<BulletJournalBloc>().add(
                            BulletJournalEvent.assignComponentToSection(
                              diaryId: widget.diaryId,
                              pageId: currentPage.id,
                              componentId: timeTable.id,
                              sectionId: section?.id,
                            ),
                          );
                    }
                    return null;
                  },
                  orElse: () => null,
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
            child: DragTarget<Object>(
              onWillAccept: (data) => true,
              onAcceptWithDetails: (details) {
                final data = details.data;
                if (data is String) {
                  // 엔트리 드래그
                  final entryId = data;
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
                } else if (data is PageComponent) {
                  // 타임테이블 드래그
                  final draggedComponent = data;
                  draggedComponent.maybeMap(
                    timeTable: (timeTable) {
                      final isSameSection = timeTable.sectionId == section?.id;
                      if (!isSameSection) {
                        context.read<BulletJournalBloc>().add(
                              BulletJournalEvent.assignComponentToSection(
                                diaryId: widget.diaryId,
                                pageId: currentPage.id,
                                componentId: timeTable.id,
                                sectionId: section?.id,
                              ),
                            );
                      }
                      return null;
                    },
                    orElse: () => null,
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
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        ...sectionEntries.asMap().entries.map((entry) {
                          final index = entry.key;
                          final entryItem = entry.value;
                          return DragTarget<String>(
                            onWillAccept: (draggedEntryId) {
                              return draggedEntryId != entryItem.id;
                            },
                            onAcceptWithDetails: (details) {
                              final draggedEntryId = details.data;
                              if (draggedEntryId == entryItem.id) return;

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
                                if (draggedIndex == -1 ||
                                    draggedIndex == targetIndex) return;

                                // 전체 페이지 엔트리에서 드래그된 엔트리 찾기 및 제거
                                final draggedEntryInAll = allPageEntries.firstWhere(
                                  (e) => e.id == draggedEntryId,
                                );
                                allPageEntries
                                    .removeWhere((e) => e.id == draggedEntryId);

                                // 현재 섹션의 다른 엔트리들 위치 찾기
                                final targetEntryInSection =
                                    sectionEntries[targetIndex];
                                final targetIndexInAll = allPageEntries.indexWhere(
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
                                // 다른 섹션에서 온 엔트리: 섹션 변경 + 특정 위치에 삽입
                                // 드래그된 엔트리 제거
                                final draggedEntryInAll = allPageEntries.firstWhere(
                                  (e) => e.id == draggedEntryId,
                                );
                                allPageEntries
                                    .removeWhere((e) => e.id == draggedEntryId);

                                // 현재 섹션의 목표 엔트리 위치 찾기
                                final targetEntryInSection = sectionEntries[index];
                                final targetIndexInAll = allPageEntries.indexWhere(
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
                                  candidateData.first != entryItem.id;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 드래그 중일 때 위에 빈 공간 추가 (부드러운 애니메이션)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    height:
                                        isHighlighted ? 60 : 0, // 엔트리 높이와 비슷한 공간
                                    margin: EdgeInsets.only(
                                      bottom: isHighlighted ? 4 : 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isHighlighted
                                          ? Colors.teal.shade50.withOpacity(0.3)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                      border: isHighlighted
                                          ? Border.all(
                                              color: Colors.teal.shade300,
                                              width: 2,
                                              style: BorderStyle.solid,
                                            )
                                          : null,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isHighlighted
                                          ? Colors.teal.shade50.withOpacity(0.5)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: LongPressDraggable<String>(
                                      key: ValueKey('${entryItem.id}-cross-section'),
                                      data: entryItem.id,
                                      delay: const Duration(
                                          milliseconds: 300), // 롱탭으로 드래그 시작
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
                                                color:
                                                    Colors.black.withOpacity(0.2),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            entryItem.focus,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.5,
                                        child: NoteEntryLine(
                                          key: ValueKey('${entryItem.id}-placeholder'),
                                          entry: entryItem,
                                          state: state,
                                          diaryId: widget.diaryId,
                                          pageId: currentPage.id,
                                          onToggleTask: (taskId) {
                                            context.read<BulletJournalBloc>().add(
                                                  BulletJournalEvent
                                                      .toggleTaskInPage(
                                                    diaryId: widget.diaryId,
                                                    pageId: currentPage.id,
                                                    entryId: entryItem.id,
                                                    taskId: taskId,
                                                  ),
                                                );
                                          },
                                          onSnooze: (taskId, duration) {
                                            context.read<BulletJournalBloc>().add(
                                                  BulletJournalEvent
                                                      .snoozeTaskInPage(
                                                    diaryId: widget.diaryId,
                                                    pageId: currentPage.id,
                                                    entryId: entryItem.id,
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
                                      child: NoteEntryLine(
                                        key: ValueKey(entryItem.id),
                                        entry: entryItem,
                                        state: state,
                                        diaryId: widget.diaryId,
                                        pageId: currentPage.id,
                                        onToggleTask: (taskId) {
                                          context.read<BulletJournalBloc>().add(
                                                BulletJournalEvent.toggleTaskInPage(
                                                  diaryId: widget.diaryId,
                                                  pageId: currentPage.id,
                                                  entryId: entryItem.id,
                                                  taskId: taskId,
                                                ),
                                              );
                                        },
                                        onSnooze: (taskId, duration) {
                                          context.read<BulletJournalBloc>().add(
                                                BulletJournalEvent.snoozeTaskInPage(
                                                  diaryId: widget.diaryId,
                                                  pageId: currentPage.id,
                                                  entryId: entryItem.id,
                                                  taskId: taskId,
                                                  postpone: duration,
                                                ),
                                              );
                                        },
                                        onDragEnd: null,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }),
                        ...sectionTimeTables.map((timeTable) {
                          return DragTarget<PageComponent>(
                            onWillAccept: (data) {
                              if (data == null) return false;
                              return data.maybeMap(
                                timeTable: (t) => t.id != timeTable.id,
                                orElse: () => false,
                              );
                            },
                            onAcceptWithDetails: (details) {
                              final draggedComponent = details.data;
                              draggedComponent.maybeMap(
                                timeTable: (draggedTable) {
                                  if (draggedTable.id == timeTable.id) return;
                                  final isSameSection =
                                      draggedTable.sectionId == section?.id;
                                  if (!isSameSection) {
                                    // 다른 섹션에서 온 타임테이블: 섹션 변경
                                    context.read<BulletJournalBloc>().add(
                                          BulletJournalEvent
                                              .assignComponentToSection(
                                            diaryId: widget.diaryId,
                                            pageId: currentPage.id,
                                            componentId: draggedTable.id,
                                            sectionId: section?.id,
                                          ),
                                        );
                                  }
                                  // 타임테이블 순서 변경
                                  final allComponents =
                                      List<PageComponent>.from(
                                          currentPage.components);
                                  final draggedIndex = allComponents.indexWhere(
                                    (c) => c.maybeMap(
                                      timeTable: (t) => t.id == draggedTable.id,
                                      orElse: () => false,
                                    ),
                                  );
                                  final targetIndex = allComponents.indexWhere(
                                    (c) => c.maybeMap(
                                      timeTable: (t) => t.id == timeTable.id,
                                      orElse: () => false,
                                    ),
                                  );
                                  if (draggedIndex >= 0 && targetIndex >= 0 && draggedIndex != targetIndex) {
                                    final dragged = allComponents.removeAt(
                                        draggedIndex);
                                    final insertIndex = draggedIndex < targetIndex
                                        ? targetIndex - 1
                                        : targetIndex;
                                    allComponents.insert(insertIndex, dragged);
                                    context.read<BulletJournalBloc>().add(
                                          BulletJournalEvent
                                              .reorderComponentsInPage(
                                            diaryId: widget.diaryId,
                                            pageId: currentPage.id,
                                            reorderedComponents: allComponents,
                                          ),
                                        );
                                  }
                                  return null;
                                },
                                orElse: () => null,
                              );
                            },
                            builder: (context, candidateData, rejectedData) {
                              final isHighlighted = candidateData.isNotEmpty;
                              return LongPressDraggable<PageComponent>(
                                key: ValueKey(
                                    'timetable-draggable-${timeTable.id}'),
                                data: PageComponent.timeTable(
                                  id: timeTable.id,
                                  name: timeTable.name,
                                  createdAt: timeTable.createdAt,
                                  sectionId: timeTable.sectionId,
                                  order: timeTable.order,
                                  hourCount: timeTable.hourCount,
                                  dayCount: timeTable.dayCount,
                                  cells: timeTable.cells,
                                  rowHeaders: timeTable.rowHeaders,
                                  columnHeaders: timeTable.columnHeaders,
                                  expansionState: timeTable.expansionState,
                                ),
                                delay: const Duration(milliseconds: 300),
                                feedback: Material(
                                  elevation: 8,
                                  child: Container(
                                    width: 280,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.teal, width: 2),
                                    ),
                                    child: Text(
                                      timeTable.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: TimeTableWidget(
                                    diaryId: widget.diaryId,
                                    pageId: currentPage.id,
                                    component: timeTable,
                                    isKanbanView: true,
                                    onOpenDetail: () => _openTimeTableDetail(
                                      timeTable,
                                      currentPage.id,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: isHighlighted
                                        ? Border.all(
                                            color: Colors.teal.shade300,
                                            width: 2,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TimeTableWidget(
                                    diaryId: widget.diaryId,
                                    pageId: currentPage.id,
                                    component: timeTable,
                                    isKanbanView: true,
                                    onOpenDetail: () => _openTimeTableDetail(
                                      timeTable,
                                      currentPage.id,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView(
    BuildContext context,
    Diary diary,
    List<DiaryPage> sortedPages,
    DiaryPage currentPage,
    bool hasSections,
    List<DiarySection> sections,
    Map<String, List<BulletEntry>> entriesBySection,
    List<BulletEntry> unassignedEntries,
    List<BulletEntry> sortedEntries,
    BulletJournalState state,
    bool isKanbanView,
  ) {
    // 인덱스 페이지를 제외한 페이지 목록
    final nonIndexPages = sortedPages.where((p) => !p.isIndexPage).toList();
    final indexPage = sortedPages.firstWhere(
      (p) => p.isIndexPage,
      orElse: () => sortedPages.first,
    );

    // PageView에 표시할 페이지 목록 (인덱스 페이지가 맨 앞)
    final allPages = [indexPage, ...nonIndexPages];

    // 현재 페이지의 인덱스 찾기 (PageView 인덱스)
    int pageViewIndex = 0;
    if (currentPage.isIndexPage) {
      pageViewIndex = 0;
    } else {
      pageViewIndex =
          nonIndexPages.indexWhere((p) => p.id == currentPage.id) + 1;
      if (pageViewIndex == 0) {
        // 찾지 못한 경우 기본값
        pageViewIndex = 1;
      }
    }

    // PageController 초기화 및 동기화
    if (_pageController == null || !_pageController!.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController != null && _pageController!.hasClients) {
          if (_pageController!.page != pageViewIndex) {
            _pageController!.animateToPage(
              pageViewIndex,
              duration: const Duration(milliseconds: 1),
              curve: Curves.linear,
            );
          }
        }
      });
    } else {
      // 현재 인덱스와 다르면 애니메이션으로 이동
      if (_currentPageIndex != pageViewIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController != null && _pageController!.hasClients) {
            _pageController!.animateToPage(
              pageViewIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
        });

        // 마지막 페이지에서 다음 페이지로 넘어가려고 할 때는 _onPageScroll에서 처리

        // 페이지 변경 시 블록에 알림
        final page = allPages[index];
        if (page.id != currentPage.id) {
          context.read<BulletJournalBloc>().add(
                BulletJournalEvent.setCurrentPageInDiary(
                  diaryId: widget.diaryId,
                  pageId: page.id,
                ),
              );
        }
      },
      physics: _CustomPageScrollPhysics(
        onReachStart: () {
          // 첫 번째 일반 페이지(인덱스 1)에서 이전으로 가려고 할 때 인덱스 페이지로 이동
          if (_currentPageIndex == 1 && allPages.isNotEmpty && allPages[0].isIndexPage) {
            if (_pageController != null && _pageController!.hasClients) {
              _pageController!.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        },
        onReachEnd: () {
          // 마지막 페이지에서 다음 페이지로 넘어가려고 할 때 새 페이지 생성
          if (allPages.isNotEmpty &&
              !allPages[allPages.length - 1].isIndexPage &&
              !_isShowingAddPageDialog) {
            setState(() {
              _isShowingAddPageDialog = true;
            });
            showAddPageDialog(context, widget.diaryId).then((_) {
              if (mounted) {
                setState(() {
                  _isShowingAddPageDialog = false;
                });
              }
            }).catchError((_) {
              if (mounted) {
                setState(() {
                  _isShowingAddPageDialog = false;
                });
              }
            });
          }
        },
      ),
      itemCount: allPages.length,
      itemBuilder: (context, index) {
        // 최신 state를 가져오기 위해 BlocBuilder 사용
        return BlocBuilder<BulletJournalBloc, BulletJournalState>(
          builder: (context, latestState) {
            debugPrint(
                '[DiaryDetail] PageView itemBuilder 호출 - index: $index, state 변경 감지');
            // 최신 state에서 페이지 정보 다시 가져오기
            final latestDiary = latestState.diaries.firstWhere(
              (d) => d.id == widget.diaryId,
              orElse: () => diary,
            );
            final latestSortedPages =
                PageSortUtils.sortPages(latestDiary.pages);
            final latestNonIndexPages =
                latestSortedPages.where((p) => !p.isIndexPage).toList();
            final latestIndexPage = latestSortedPages.firstWhere(
              (p) => p.isIndexPage,
              orElse: () => latestSortedPages.first,
            );
            final latestAllPages = [latestIndexPage, ...latestNonIndexPages];

            final page = latestAllPages[index];
            debugPrint(
                '[DiaryDetail] 페이지 로드 - Page ID: ${page.id}, 엔트리 수: ${page.entries.length}');

            if (page.isIndexPage) {
              return IndexPageView(
                diary: latestDiary,
                diaryId: widget.diaryId,
                state: latestState,
              );
            }

            // 일반 페이지의 엔트리 및 섹션 정보 가져오기
            final pageEntries = page.entries;
            final pageSections = page.sections;
            final pageHasSections = pageSections.isNotEmpty;

            // 엔트리 상태 로깅
            for (final entry in pageEntries) {
              debugPrint(
                  '[DiaryDetail] 엔트리 상태 - Entry ID: ${entry.id}, Status ID: ${entry.keyStatus.id}, Status Label: ${entry.keyStatus.label}');
            }

            // 엔트리 정렬
            final pageSortedEntries = EntrySortUtils.sortEntries(
              pageEntries,
              _sortType,
              _manualOrder,
            );

            // 섹션별로 엔트리 그룹화
            Map<String, List<BulletEntry>> pageEntriesBySection = {};
            List<BulletEntry> pageUnassignedEntries = [];

            if (pageHasSections) {
              for (final section in pageSections) {
                pageEntriesBySection[section.id] = pageSortedEntries
                    .where((e) => e.sectionId == section.id)
                    .toList();
              }
              pageUnassignedEntries =
                  pageSortedEntries.where((e) => e.sectionId == null).toList();
            }

            return DiaryBackground(
              theme: latestDiary.backgroundTheme,
              child: Builder(
                builder: (context) {
                  // components 필드 마이그레이션 (기존 데이터 호환성)
                  List<PageComponent> pageComponents = [];
                  try {
                    final componentsValue = page.components;
                    pageComponents = List<PageComponent>.from(componentsValue);
                  } catch (e) {
                    // 기존 데이터에 components 필드가 없는 경우 빈 리스트 사용
                    pageComponents = <PageComponent>[];
                    // 마이그레이션: components 필드가 없는 경우 업데이트
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final migratedPage = page.copyWith(components: <PageComponent>[]);
                      context.read<BulletJournalBloc>().add(
                            BulletJournalEvent.updatePageInDiary(
                              diaryId: widget.diaryId,
                              pageId: page.id,
                              updatedPage: migratedPage,
                            ),
                          );
                    });
                  }
                  
                  final hasAnyComponents = pageComponents.isNotEmpty;
                  final timeTablesBySection = <String, List<TimeTableComponent>>{};
                  final unassignedTimeTables = <TimeTableComponent>[];

                  for (final component in pageComponents) {
                    component.maybeMap(
                      timeTable: (timeTable) {
                        final sectionId = timeTable.sectionId;
                        if (sectionId != null &&
                            pageSections.any((section) => section.id == sectionId)) {
                          timeTablesBySection
                              .putIfAbsent(sectionId, () => [])
                              .add(timeTable);
                        } else if (sectionId == null) {
                          unassignedTimeTables.add(timeTable);
                        } else {
                          unassignedTimeTables.add(timeTable);
                        }
                        return null;
                      },
                      orElse: () => null,
                    );
                  }

                  final headerComponents = pageComponents.where((component) {
                    return component.maybeMap(
                      timeTable: (timeTable) {
                        // 칸반 모드에서는 맨 위에 타임테이블을 표시하지 않음
                        if (isKanbanView) return false;
                        if (!pageHasSections) return true;
                        return timeTable.sectionId == null;
                      },
                      orElse: () => false,
                    );
                  }).toList();
                  final hasVisibleComponents = headerComponents.isNotEmpty;

                  List<String> pageLayoutOrder = _getPageLayoutOrder(page);
                  if (pageLayoutOrder.isEmpty &&
                      (pageSortedEntries.isNotEmpty || hasAnyComponents)) {
                    final defaultLayoutOrder = [
                      ...pageSortedEntries.map((entry) => layoutEntryToken(entry.id)),
                      ...pageComponents
                          .map((component) => layoutComponentToken(_getComponentId(component))),
                    ];
                    if (defaultLayoutOrder.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.read<BulletJournalBloc>().add(
                              BulletJournalEvent.updateLayoutOrderInPage(
                                diaryId: widget.diaryId,
                                pageId: page.id,
                                layoutOrder: defaultLayoutOrder,
                              ),
                            );
                      });
                      pageLayoutOrder = defaultLayoutOrder;
                    }
                  }

                  // 컴포넌트와 엔트리를 모두 표시
                  final componentsWidget = hasVisibleComponents
                      ? _buildComponentsList(
                          context,
                          page.copyWith(components: headerComponents),
                          isKanbanView,
                        )
                      : const SizedBox.shrink();

                  // 섹션이 있는 경우 섹션별 그룹화 표시
                  if (pageHasSections) {
                    return Column(
                      children: [
                        if (hasVisibleComponents)
                          Flexible(
                            child: SingleChildScrollView(
                              child: componentsWidget,
                            ),
                          ),
                        Expanded(
                          child: _buildSectionedEntriesList(
                            context,
                            pageSections,
                            pageEntriesBySection,
                            pageUnassignedEntries,
                            timeTablesBySection,
                            unassignedTimeTables,
                            page,
                            latestState,
                            isKanbanView,
                          ),
                        ),
                      ],
                    );
                  }

                  // 섹션이 없고 엔트리도 없는 경우
                  if (pageSortedEntries.isEmpty && !hasAnyComponents) {
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

                  // 컴포넌트만 있고 엔트리가 없는 경우
                  if (pageSortedEntries.isEmpty) {
                    return SingleChildScrollView(
                      child: componentsWidget,
                    );
                  }

                  // 섹션이 없는 경우
                  if (isKanbanView) {
                    // 칸반보드 모드: 섹션 없음으로 묶어서 표시
                    return Column(
                      children: [
                        if (hasVisibleComponents)
                          Flexible(
                            child: SingleChildScrollView(
                              child: componentsWidget,
                            ),
                          ),
                        Expanded(
                          child: _buildSectionedEntriesList(
                            context,
                            <DiarySection>[],
                            <String, List<BulletEntry>>{},
                            pageSortedEntries,
                            timeTablesBySection,
                            unassignedTimeTables,
                            page,
                            latestState,
                            isKanbanView,
                          ),
                        ),
                      ],
                    );
                  } else {
                    // 리스트 보기: 엔트리와 타임테이블 통합 표시
                    return _buildUnifiedEntriesAndComponentsList(
                      context,
                      pageSortedEntries,
                      pageComponents,
                      page,
                      latestState,
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
