import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/diary.dart';
import '../../../models/diary_page.dart';
import '../../../utils/page_sort_utils.dart';

Future<void> showAddPageDialog(BuildContext context, String diaryId) async {
  final nameController = TextEditingController();
  await showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('페이지 추가'),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: '페이지 이름 (선택사항)',
          hintText: '페이지 이름을 입력하세요 (비워두면 이름 없음)',
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
            final newPage = DiaryPage(
              id: 'page-${DateTime.now().millisecondsSinceEpoch}',
              name: nameController.text.trim().isEmpty
                  ? null
                  : nameController.text.trim(),
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

void showPageOptionsDialog(
  BuildContext context,
  String diaryId,
  Diary diary,
  DiaryPage page,
) {
  // 현재 페이지의 위치 찾기
  final sortedPages = PageSortUtils.sortPages(diary.pages);
  final currentPageIndex = sortedPages.indexWhere((p) => p.id == page.id);
  final canAddBefore = currentPageIndex > 0; // 인덱스 페이지 앞에는 추가 불가
  final canAddAfter = currentPageIndex >= 0; // 모든 페이지 뒤에는 추가 가능

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(page.name ?? '이름 없음'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!page.isIndexPage)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('이름 변경'),
              onTap: () {
                context.pop();
                showRenamePageDialog(context, diaryId, diary, page);
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
                      diaryId: diaryId,
                      pageId: page.id,
                    ),
                  );
              context.pop();
            },
          ),
          // 앞 페이지 추가
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('앞 페이지 추가'),
            enabled: canAddBefore,
            onTap: canAddBefore
                ? () {
                    context.pop();
                    showAddPageBeforeDialog(context, diaryId, diary, page);
                  }
                : null,
          ),
          // 뒷 페이지 추가
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('뒷 페이지 추가'),
            enabled: canAddAfter,
            onTap: canAddAfter
                ? () {
                    context.pop();
                    showAddPageAfterDialog(context, diaryId, diary, page);
                  }
                : null,
          ),
          if (!page.isIndexPage)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                context.pop();
                showDeletePageDialog(context, diaryId, diary, page);
              },
            ),
          if (page.isIndexPage)
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text(
                '인덱스 페이지는 삭제할 수 없습니다',
                style: TextStyle(color: Colors.grey),
              ),
              enabled: false,
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

void showRenamePageDialog(
  BuildContext context,
  String diaryId,
  Diary diary,
  DiaryPage page,
) {
  // 인덱스 페이지는 이름 변경 불가
  if (page.isIndexPage) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인덱스 페이지는 이름을 변경할 수 없습니다')),
    );
    return;
  }

  final nameController = TextEditingController(text: page.name ?? '');
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('페이지 이름 변경'),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: '페이지 이름 (선택사항)',
          hintText: '페이지 이름을 입력하세요 (비워두면 이름 없음)',
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
            context.read<BulletJournalBloc>().add(
                  BulletJournalEvent.updatePageInDiary(
                    diaryId: diaryId,
                    pageId: page.id,
                    updatedPage: page.copyWith(
                      name: nameController.text.trim().isEmpty
                          ? null
                          : nameController.text.trim(),
                    ),
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

void showDeletePageDialog(
  BuildContext context,
  String diaryId,
  Diary diary,
  DiaryPage page,
) {
  // 인덱스 페이지는 삭제 불가
  if (page.isIndexPage) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인덱스 페이지는 삭제할 수 없습니다')),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('페이지 삭제'),
      content: Text(
        '${page.name ?? '이름 없음'} 페이지를 삭제하시겠습니까?\n페이지 내의 모든 엔트리가 삭제됩니다.',
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
                    diaryId: diaryId,
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

Future<void> showAddPageBeforeDialog(
  BuildContext context,
  String diaryId,
  Diary diary,
  DiaryPage targetPage,
) async {
  final nameController = TextEditingController();
  await showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('앞 페이지 추가'),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: '페이지 이름 (선택사항)',
          hintText: '페이지 이름을 입력하세요 (비워두면 이름 없음)',
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
            final newPage = DiaryPage(
              id: 'page-${DateTime.now().millisecondsSinceEpoch}',
              name: nameController.text.trim().isEmpty
                  ? null
                  : nameController.text.trim(),
              entries: [],
              createdAt: DateTime.now(),
            );

            // 현재 페이지 목록 가져오기
            final sortedPages = PageSortUtils.sortPages(diary.pages);
            final targetIndex = sortedPages.indexWhere((p) => p.id == targetPage.id);
            
            // 새 페이지를 타겟 페이지 앞에 삽입
            final reorderedPages = List<DiaryPage>.from(sortedPages);
            reorderedPages.insert(targetIndex, newPage);

            context.read<BulletJournalBloc>().add(
                  BulletJournalEvent.addPageToDiary(
                    diaryId: diaryId,
                    page: newPage,
                  ),
                );

            context.read<BulletJournalBloc>().add(
                  BulletJournalEvent.reorderPagesInDiary(
                    diaryId: diaryId,
                    reorderedPages: reorderedPages,
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

Future<void> showAddPageAfterDialog(
  BuildContext context,
  String diaryId,
  Diary diary,
  DiaryPage targetPage,
) async {
  final nameController = TextEditingController();
  await showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('뒷 페이지 추가'),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: '페이지 이름 (선택사항)',
          hintText: '페이지 이름을 입력하세요 (비워두면 이름 없음)',
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
            final newPage = DiaryPage(
              id: 'page-${DateTime.now().millisecondsSinceEpoch}',
              name: nameController.text.trim().isEmpty
                  ? null
                  : nameController.text.trim(),
              entries: [],
              createdAt: DateTime.now(),
            );

            // 현재 페이지 목록 가져오기
            final sortedPages = PageSortUtils.sortPages(diary.pages);
            final targetIndex = sortedPages.indexWhere((p) => p.id == targetPage.id);
            
            // 새 페이지를 타겟 페이지 뒤에 삽입
            final reorderedPages = List<DiaryPage>.from(sortedPages);
            reorderedPages.insert(targetIndex + 1, newPage);

            context.read<BulletJournalBloc>().add(
                  BulletJournalEvent.addPageToDiary(
                    diaryId: diaryId,
                    page: newPage,
                  ),
                );

            context.read<BulletJournalBloc>().add(
                  BulletJournalEvent.reorderPagesInDiary(
                    diaryId: diaryId,
                    reorderedPages: reorderedPages,
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

