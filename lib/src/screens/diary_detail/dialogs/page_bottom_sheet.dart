import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/diary.dart';
import '../../../models/diary_page.dart';
import '../../../blocs/bullet_journal_bloc.dart';
import '../../../utils/device_type.dart';
import '../../../utils/page_sort_utils.dart';
import '../widgets/page_preview_card.dart';
import 'page_dialogs.dart';

void showPageBottomSheet(
  BuildContext context,
  BulletJournalState state,
  Diary diary,
  String diaryId,
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
                  onPressed: () => Navigator.of(bottomSheetContext).pop(),
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

                return BlocBuilder<BulletJournalBloc, BulletJournalState>(
                  builder: (context, latestState) {
                    // 최신 상태에서 다이어리 정보 가져오기
                    final latestDiary = latestState.diaries.firstWhere(
                      (d) => d.id == diaryId,
                      orElse: () => diary,
                    );
                    final latestSortedPages =
                        PageSortUtils.sortPages(latestDiary.pages);

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75, // 카드 비율 (세로가 약간 더 김)
                      ),
                      itemCount:
                          latestSortedPages.length + 1, // +1 for Add button
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Add button
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(bottomSheetContext).pop();
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                if (parentContext.mounted) {
                                  showAddPageDialog(parentContext, diaryId);
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
                        final page = latestSortedPages[pageIndex];
                        final isCurrent = page.id == latestDiary.currentPageId;
                        // 페이지 번호 계산 (전체 순서 기준, 인덱스 페이지 포함)
                        final pageNumber = pageIndex;

                        return DragTarget<String>(
                          onWillAccept: (data) => data != page.id,
                          onAccept: (draggedPageId) {
                            // 페이지 순서 변경
                            final draggedPage = latestSortedPages.firstWhere(
                              (p) => p.id == draggedPageId,
                            );
                            final targetIndex = latestSortedPages.indexOf(page);
                            final draggedIndex =
                                latestSortedPages.indexOf(draggedPage);

                            if (draggedIndex != targetIndex) {
                              final reorderedPages =
                                  List<DiaryPage>.from(latestSortedPages);
                              reorderedPages.removeAt(draggedIndex);
                              reorderedPages.insert(
                                draggedIndex < targetIndex
                                    ? targetIndex - 1
                                    : targetIndex,
                                draggedPage,
                              );

                              parentContext.read<BulletJournalBloc>().add(
                                    BulletJournalEvent.reorderPagesInDiary(
                                      diaryId: diaryId,
                                      reorderedPages: reorderedPages,
                                    ),
                                  );
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            final isHighlighted = candidateData.isNotEmpty;
                            return LongPressDraggable<String>(
                              data: page.id,
                              delay: const Duration(milliseconds: 200),
                              feedback: Material(
                                elevation: 8,
                                child: Opacity(
                                  opacity: 0.8,
                                  child: SizedBox(
                                    width: 150,
                                    height: 200,
                                    child: PagePreviewCard(
                                      page: page,
                                      diary: latestDiary,
                                      state: latestState,
                                      isCurrent: isCurrent,
                                      pageNumber: pageNumber,
                                      onTap: () {},
                                      onLongPress: () {},
                                      onMorePress: () {},
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: PagePreviewCard(
                                  page: page,
                                  diary: latestDiary,
                                  state: latestState,
                                  isCurrent: isCurrent,
                                  pageNumber: pageNumber,
                                  onTap: () {},
                                  onLongPress: () {},
                                  onMorePress: () {},
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: isHighlighted
                                      ? Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: PagePreviewCard(
                                  page: page,
                                  diary: latestDiary,
                                  state: latestState,
                                  isCurrent: isCurrent,
                                  pageNumber: pageNumber,
                                  onTap: () {
                                    parentContext.read<BulletJournalBloc>().add(
                                          BulletJournalEvent
                                              .setCurrentPageInDiary(
                                            diaryId: diaryId,
                                            pageId: page.id,
                                          ),
                                        );
                                    Navigator.of(bottomSheetContext).pop();
                                  },
                                  onLongPress: () {
                                    // 롱탭은 드래그로 처리되므로 여기서는 아무것도 하지 않음
                                  },
                                  onMorePress: () {
                                    Navigator.of(bottomSheetContext).pop();
                                    Future.delayed(
                                        const Duration(milliseconds: 100), () {
                                      if (parentContext.mounted) {
                                        showPageOptionsDialog(
                                          parentContext,
                                          diaryId,
                                          latestDiary,
                                          page,
                                        );
                                      }
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        );
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
