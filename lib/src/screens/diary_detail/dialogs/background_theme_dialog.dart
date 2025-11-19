import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/diary.dart';

void showBackgroundThemeDialog(
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

