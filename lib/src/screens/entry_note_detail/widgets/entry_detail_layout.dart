import 'package:flutter/material.dart';

import '../../../models/bullet_entry.dart';
import '../../../models/key_definition.dart';
import '../../../blocs/bullet_journal_bloc.dart';
import '../../../widgets/key_bullet_icon.dart';
import '../../../utils/entry_formatter.dart';
import '../../../utils/key_definition_utils.dart';

/// Widget for displaying entry details in a responsive layout
class EntryDetailLayout extends StatelessWidget {
  const EntryDetailLayout({
    super.key,
    required this.entry,
    required this.state,
    required this.isEditing,
    required this.focusController,
    required this.noteController,
    required this.useTwoColumn,
    this.selectedKey,
    this.onKeyChanged,
  });

  final BulletEntry entry;
  final BulletJournalState state;
  final bool isEditing;
  final TextEditingController focusController;
  final TextEditingController noteController;
  final bool useTwoColumn;
  final KeyDefinition? selectedKey;
  final ValueChanged<KeyDefinition?>? onKeyChanged;

  Widget _buildKeyDropdown() {
    final allKeys = KeyDefinitionUtils.getAllAvailableKeys(state);
    
    // key-snoozed는 태스크 전용 키이므로 엔트리 레벨에서는 제외
    final entryKeys = allKeys.where((keyDef) => keyDef.id != 'key-snoozed').toList();
    
    if (entryKeys.isEmpty) return const SizedBox.shrink();
    
    return DropdownButtonFormField<KeyDefinition>(
      value: selectedKey,
      decoration: const InputDecoration(
        labelText: '키',
        border: OutlineInputBorder(),
        hintText: '키를 선택하세요',
      ),
      items: entryKeys.map((keyDef) {
        // 키에 매핑된 작업 상태 찾기
        final status = KeyDefinitionUtils.getStatusForKey(keyDef, state);
        return DropdownMenuItem(
          value: keyDef,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              KeyBulletIcon(definition: keyDef),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  status != null
                      ? '${keyDef.label} (${status.label})'
                      : keyDef.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onKeyChanged,
    );
  }

  Widget _buildStatusDisplay(BuildContext context) {
    final status = entry.keyStatus;
    final keyDef = selectedKey ?? KeyDefinitionUtils.getKeyDefinitionForStatus(status, state);
    return Row(
      children: [
        KeyBulletIcon(definition: keyDef),
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
          _buildKeyDropdown(),
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

