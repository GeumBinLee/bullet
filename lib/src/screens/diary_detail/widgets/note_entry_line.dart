import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/bullet_entry.dart';
import '../../../models/key_definition.dart';
import '../../../data/key_definitions.dart';
import '../../../widgets/key_bullet_icon.dart';
import '../../../utils/entry_formatter.dart';

class NoteEntryLine extends StatelessWidget {
  const NoteEntryLine({
    super.key,
    required this.entry,
    required this.state,
    required this.diaryId,
    required this.pageId,
    required this.onToggleTask,
    required this.onSnooze,
    this.onDragEnd,
  });

  final BulletEntry entry;
  final BulletJournalState state;
  final String diaryId;
  final String pageId;
  final void Function(String taskId) onToggleTask;
  final void Function(String taskId, Duration duration) onSnooze;
  final void Function(String? sectionId)? onDragEnd;

  static const _defaultStatusKeyMapping = {
    'planned': 'key-incomplete',
    'inProgress': 'key-progress',
    'completed': 'key-completed',
  };

  KeyDefinition _keyDefinitionForEntry() {
    try {
      final status = entry.keyStatus;
      debugPrint('[NoteEntryLine] 키 정의 가져오기 - Entry ID: ${entry.id}, Status ID: ${status.id}, Status Label: ${status.label}');
      final keyIds = state.statusKeyMapping[status.id] ??
          [_defaultStatusKeyMapping[status.id] ?? defaultKeyDefinitions.first.id];
      final keyId = keyIds.isNotEmpty ? keyIds.first : defaultKeyDefinitions.first.id;
      debugPrint('[NoteEntryLine] 매핑된 키 ID: $keyId');
      final allDefinitions = [...defaultKeyDefinitions, ...state.customKeys];
      final keyDef = allDefinitions.firstWhere(
        (definition) => definition.id == keyId,
        orElse: () => defaultKeyDefinitions.first,
      );
      debugPrint('[NoteEntryLine] 최종 키 정의 - Key ID: ${keyDef.id}, Key Label: ${keyDef.label}');
      return keyDef;
    } catch (e) {
      debugPrint('[NoteEntryLine] 오류 발생: $e');
      return defaultKeyDefinitions.first;
    }
  }

  KeyDefinition _definitionFor(BulletTask task) {
    final isSnoozed = task.snoozes.isNotEmpty;
    final keyIds = isSnoozed
        ? ['key-snoozed']
        : state.statusKeyMapping[task.status.id] ??
            [_defaultStatusKeyMapping[task.status.id] ?? defaultKeyDefinitions.first.id];
    final keyId = keyIds.isNotEmpty ? keyIds.first : defaultKeyDefinitions.first.id;
    final allDefinitions = [...defaultKeyDefinitions, ...state.customKeys];
    return allDefinitions.firstWhere(
      (definition) => definition.id == keyId,
      orElse: () => defaultKeyDefinitions.first,
    );
  }


  @override
  Widget build(BuildContext context) {
    final keyDef = _keyDefinitionForEntry();

    final entryWidget = InkWell(
      onTap: () => context.push('/entry-note/${entry.id}', extra: entry),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 엔트리 라인: 키 아이콘 + 제목
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, right: 8.0),
                  child: KeyBulletIcon(definition: keyDef),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              entry.focus,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              EntryFormatter.formattedDate(entry.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (entry.note.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.note,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (entry.note.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.note_outlined,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
            // 작업 목록
            if (entry.tasks.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...entry.tasks.map((task) {
                final taskKeyDef = _definitionFor(task);
                return Padding(
                  padding: const EdgeInsets.only(left: 24.0, top: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0, right: 8.0),
                        child: KeyBulletIcon(definition: taskKeyDef),
                      ),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            decoration: task.status.id == TaskStatus.completed.id
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.status.id == TaskStatus.completed.id
                                ? Colors.grey.shade600
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          task.status.id == TaskStatus.completed.id
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 18,
                          color: task.status.id == TaskStatus.completed.id
                              ? Colors.green
                              : Colors.grey,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => onToggleTask(task.id),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );

    // 드래그 앤 드롭이 가능한 경우 Draggable로 감싸기
    if (onDragEnd != null) {
      return Draggable<String>(
        data: entry.id,
        feedback: Material(
          elevation: 4,
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              entry.focus,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: entryWidget,
        ),
        child: entryWidget,
      );
    }

    return entryWidget;
  }
}

