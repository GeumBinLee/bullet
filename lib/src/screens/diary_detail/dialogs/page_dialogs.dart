import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/diary.dart';
import '../../../models/diary_page.dart';

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

