import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../utils/entry_sort_type.dart';

typedef SortCallback = void Function(EntrySortType sortType);

void showSortDialog(
  BuildContext context,
  BulletJournalState state,
  EntrySortType currentSortType,
  String diaryId,
  SortCallback onSortChanged,
) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('정렬'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          RadioListTile<EntrySortType>(
            title: const Text('날짜순 정렬 (오름차순)'),
            subtitle: const Text('오래된 것부터'),
            value: EntrySortType.dateAscending,
            groupValue: currentSortType,
            onChanged: (value) {
              if (value != null) {
                onSortChanged(value);
                context.pop();
              }
            },
          ),
          RadioListTile<EntrySortType>(
            title: const Text('최신순'),
            subtitle: const Text('최신 것부터'),
            value: EntrySortType.dateDescending,
            groupValue: currentSortType,
            onChanged: (value) {
              if (value != null) {
                onSortChanged(value);
                context.pop();
              }
            },
          ),
          RadioListTile<EntrySortType>(
            title: const Text('키별 정렬'),
            subtitle: const Text('키 순서대로'),
            value: EntrySortType.byKey,
            groupValue: currentSortType,
            onChanged: (value) {
              if (value != null) {
                onSortChanged(value);
                context.pop();
              }
            },
          ),
          RadioListTile<EntrySortType>(
            title: const Text('수동 정렬'),
            subtitle: const Text('드래그로 순서 변경'),
            value: EntrySortType.manual,
            groupValue: currentSortType,
            onChanged: (value) {
              if (value != null) {
                onSortChanged(value);
                // 수동 정렬 순서 초기화는 DiaryDetailScreen에서 처리
                context.pop();
              }
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
      ],
    ),
  );
}

