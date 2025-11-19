import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/diary.dart';
import '../dialogs/password_dialog.dart';
import 'diary_tab.dart';

class DiaryCard extends StatelessWidget {
  const DiaryCard({super.key, required this.diary});

  final Diary diary;

  @override
  Widget build(BuildContext context) {
    // 전체 페이지 엔트리 개수 계산
    int totalEntries = diary.entries.length;
    for (final page in diary.pages) {
      totalEntries += page.entries.length;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 0,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          if (diary.password != null && diary.password!.isNotEmpty) {
            PasswordDialog.show(context, diary);
          } else {
            DiaryTab.navigateToDiary(context, diary);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: Color(diary.colorValue),
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 노트 아이콘과 잠금 아이콘
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note,
                      size: 48,
                      color: Color(diary.colorValue),
                    ),
                    if (diary.password != null &&
                        diary.password!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.lock,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // 이름과 더보기 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        diary.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                '삭제',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('다이어리 삭제'),
                              content: Text(
                                '${diary.name} 다이어리를 삭제하시겠습니까?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<BulletJournalBloc>().add(
                                          BulletJournalEvent.deleteDiary(
                                            diary.id,
                                          ),
                                        );
                                    context.pop();
                                  },
                                  child: const Text(
                                    '삭제',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                if (diary.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    diary.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '$totalEntries개의 엔트리',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

