import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../blocs/bullet_journal_bloc.dart';
import '../data/key_definitions.dart';
import '../models/bullet_entry.dart';
import '../models/key_definition.dart';
import 'key_bullet_icon.dart';

class BulletEntryCard extends StatelessWidget {
  const BulletEntryCard({
    super.key,
    required this.entry,
    required this.state,
    required this.onToggleTask,
    required this.onSnooze,
  });

  final BulletEntry entry;
  final BulletJournalState state;
  final void Function(String taskId) onToggleTask;
  final void Function(String taskId, Duration duration) onSnooze;

  static const _snoozeOptions = [
    {'label': '1일 미루기', 'duration': Duration(days: 1)},
    {'label': '3일 미루기', 'duration': Duration(days: 3)},
    {'label': '1주일 미루기', 'duration': Duration(days: 7)},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: 제목, 노트 아이콘(있을 때만), 날짜, 키 아이콘
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.focus,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (entry.note.trim().isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _openNoteDetail(context),
                    tooltip: '노트 보기',
                  ),
                ],
                const SizedBox(width: 8),
                Text(
                  _formattedDate(entry.date),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(width: 8),
                KeyBulletIcon(definition: _keyDefinitionForEntry(entry)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 32),
            ...entry.tasks.map((task) {
              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: KeyBulletIcon(definition: _definitionFor(task)),
                    title: Text(task.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_statusLabel(task.status)),
                        if (task.dueDate != null)
                          Text(
                            '마감: ${_formattedDateTime(task.dueDate!)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (task.snoozes.isNotEmpty)
                          Text(
                            '최근 미룸: ${_formattedDateTime(task.snoozes.last.postponedTo)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _statusIcon(task.status),
                        color: _statusColor(task.status),
                      ),
                      onPressed: () => onToggleTask(task.id),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showSnoozeOptions(context, task.id),
                      child: const Text('미루기'),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showSnoozeOptions(BuildContext context, String taskId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: _snoozeOptions.map((option) {
              final duration = option['duration'] as Duration;
              return ListTile(
                title: Text(option['label'] as String),
                onTap: () {
                  context.pop();
                  onSnooze(taskId, duration);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  static String _formattedDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  static String _formattedDateTime(DateTime dateTime) {
    return '${_formattedDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String _statusLabel(TaskStatus status) {
    return status.label;
  }

  static IconData _statusIcon(TaskStatus status) {
    if (status.id == TaskStatus.planned.id) {
      return Icons.circle_outlined;
    } else if (status.id == TaskStatus.inProgress.id) {
      return Icons.autorenew;
    } else if (status.id == TaskStatus.completed.id) {
      return Icons.check_circle;
    }
    return Icons.circle_outlined;
  }

  static Color _statusColor(TaskStatus status) {
    if (status.id == TaskStatus.planned.id) {
      return Colors.grey;
    } else if (status.id == TaskStatus.inProgress.id) {
      return Colors.amber;
    } else if (status.id == TaskStatus.completed.id) {
      return Colors.green;
    }
    return Colors.grey;
  }

  static const _defaultStatusKeyMapping = {
    'planned': 'key-incomplete',
    'inProgress': 'key-progress',
    'completed': 'key-completed',
  };

  void _openNoteDetail(BuildContext context) {
    context.push('/entry-note/${entry.id}', extra: entry);
  }

  KeyDefinition _keyDefinitionForEntry(BulletEntry entry) {
    try {
      final status = entry.keyStatus;
      final keyIds = state.statusKeyMapping[status.id] ??
          [_defaultStatusKeyMapping[status.id] ?? defaultKeyDefinitions.first.id];
      final keyId = keyIds.isNotEmpty ? keyIds.first : defaultKeyDefinitions.first.id;
      final allDefinitions = [...defaultKeyDefinitions, ...state.customKeys];
      return allDefinitions.firstWhere(
        (definition) => definition.id == keyId,
        orElse: () => defaultKeyDefinitions.first,
      );
    } catch (e) {
      // keyStatus가 없는 경우 기본 키 반환
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
}
