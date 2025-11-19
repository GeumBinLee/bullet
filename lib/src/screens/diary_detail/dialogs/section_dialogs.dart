import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/diary.dart';
import '../../../models/diary_page.dart';
import '../../../models/diary_section.dart';

void showAddSectionDialog(
  BuildContext context,
  String diaryId,
  String pageId,
  BulletJournalState state,
) {
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
                    const SnackBar(
                        content: Text('동일한 이름의 섹션이 이미 존재합니다')),
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

void showSectionOptionsDialog(
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
              showRenameSectionDialog(context, diaryId, page, section);
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
              showDeleteSectionDialog(context, diaryId, page, section);
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

void showRenameSectionDialog(
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

void showDeleteSectionDialog(
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

