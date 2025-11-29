import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/diary.dart';
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

                // 페이지 정렬 (인덱스 페이지가 맨 앞)
                final sortedPages = PageSortUtils.sortPages(diary.pages);
                
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75, // 카드 비율 (세로가 약간 더 김)
                  ),
                  itemCount: sortedPages.length + 1, // +1 for Add button
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Add button
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(bottomSheetContext).pop();
                          Future.delayed(const Duration(milliseconds: 100), () {
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
                    final page = sortedPages[pageIndex];
                    final isCurrent = page.id == diary.currentPageId;

                    return PagePreviewCard(
                      page: page,
                      diary: diary,
                      state: state,
                      isCurrent: isCurrent,
                      onTap: () {
                        parentContext.read<BulletJournalBloc>().add(
                              BulletJournalEvent.setCurrentPageInDiary(
                                diaryId: diaryId,
                                pageId: page.id,
                              ),
                            );
                        Navigator.of(bottomSheetContext).pop();
                      },
                      onLongPress: () {
                        Navigator.of(bottomSheetContext).pop();
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (parentContext.mounted) {
                            showPageOptionsDialog(
                              parentContext,
                              diaryId,
                              diary,
                              page,
                            );
                          }
                        });
                      },
                      onMorePress: () {
                        Navigator.of(bottomSheetContext).pop();
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (parentContext.mounted) {
                            showPageOptionsDialog(
                              parentContext,
                              diaryId,
                              diary,
                              page,
                            );
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

