import 'package:flutter/material.dart';

import '../../../widgets/diary_background.dart';
import '../../../models/diary.dart';
import '../../../models/diary_page.dart';
import '../../../models/diary_section.dart';
import '../../../models/bullet_entry.dart';
import '../../../blocs/bullet_journal_bloc.dart';
import 'note_entry_line.dart';

class PagePreviewCard extends StatelessWidget {
  const PagePreviewCard({
    super.key,
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
            return NoteEntryLine(
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
          return NoteEntryLine(
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

