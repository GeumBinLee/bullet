import 'package:flutter/material.dart';

import '../../../models/bullet_entry.dart';
import '../../../blocs/bullet_journal_bloc.dart';
import '../../../widgets/key_bullet_icon.dart';
import '../../../utils/entry_formatter.dart';
import '../../../utils/key_definition_utils.dart';
import '../../../data/key_definitions.dart';

/// Widget for displaying entry details in a responsive layout
class EntryDetailLayout extends StatelessWidget {
  const EntryDetailLayout({
    super.key,
    required this.entry,
    required this.state,
    required this.isEditing,
    required this.focusController,
    required this.noteController,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.useTwoColumn,
  });

  final BulletEntry entry;
  final BulletJournalState state;
  final bool isEditing;
  final TextEditingController focusController;
  final TextEditingController noteController;
  final TaskStatus? selectedStatus;
  final ValueChanged<TaskStatus?> onStatusChanged;
  final bool useTwoColumn;

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<TaskStatus>(
      value: selectedStatus,
      decoration: const InputDecoration(
        labelText: '작업 상태',
        border: OutlineInputBorder(),
      ),
      items: state.taskStatuses.map((status) {
        final keyId = state.statusKeyMapping[status.id] ??
            KeyDefinitionUtils.getDefaultKeyId(status.id);
        final allDefinitions = [
          ...defaultKeyDefinitions,
          ...state.customKeys,
        ];
        final keyDefinition = allDefinitions.firstWhere(
          (def) => def.id == keyId,
          orElse: () => defaultKeyDefinitions.first,
        );
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              KeyBulletIcon(definition: keyDefinition),
              const SizedBox(width: 12),
              Text(status.label),
            ],
          ),
        );
      }).toList(),
      onChanged: onStatusChanged,
    );
  }

  Widget _buildStatusDisplay(BuildContext context) {
    final status = selectedStatus ?? entry.keyStatus;
    return Row(
      children: [
        KeyBulletIcon(
          definition: KeyDefinitionUtils.getKeyDefinitionForStatus(status, state),
        ),
        const SizedBox(width: 8),
        Text(
          status.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEditing)
          TextField(
            controller: focusController,
            decoration: const InputDecoration(
              labelText: '제목',
              border: OutlineInputBorder(),
            ),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          )
        else
          Text(
            entry.focus,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        const SizedBox(height: 8),
        Text(
          EntryFormatter.formattedDate(entry.date),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        if (isEditing) ...[
          const SizedBox(height: 16),
          const Text('키 선택:'),
          const SizedBox(height: 8),
          _buildStatusDropdown(),
        ] else ...[
          const SizedBox(height: 8),
          _buildStatusDisplay(context),
        ],
      ],
    );
  }

  Widget _buildNoteSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEditing)
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: '노트',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
            minLines: useTwoColumn ? 15 : 10,
            style: Theme.of(context).textTheme.bodyLarge,
          )
        else
          Text(
            entry.note,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (useTwoColumn) {
      // 2열 레이아웃 (제목/날짜 왼쪽, 노트 오른쪽)
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽: 제목과 날짜
            Expanded(
              flex: 1,
              child: _buildTitleSection(context),
            ),
            const SizedBox(width: 24),
            // 오른쪽: 노트
            Expanded(
              flex: 2,
              child: _buildNoteSection(context),
            ),
          ],
        ),
      );
    } else {
      // 1열 레이아웃 (모바일 또는 세로 방향)
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleSection(context),
            const Divider(height: 32),
            _buildNoteSection(context),
          ],
        ),
      );
    }
  }
}

