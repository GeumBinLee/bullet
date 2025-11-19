import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/bullet_entry.dart';
import '../models/key_definition.dart';
import '../models/diary.dart';

part 'bullet_journal_state.freezed.dart';

Map<String, String> _defaultStatusKeyMapping() => {
      TaskStatus.planned.id: 'key-incomplete',
      TaskStatus.inProgress.id: 'key-progress',
      TaskStatus.completed.id: 'key-completed',
    };

@freezed
class BulletJournalState with _$BulletJournalState {
  const factory BulletJournalState({
    @Default(<BulletEntry>[]) List<BulletEntry> entries,
    @Default(true) bool isLoading,
    @Default(<KeyDefinition>[]) List<KeyDefinition> customKeys,
    @Default(TaskStatus.defaultStatuses) List<TaskStatus> taskStatuses,
    @Default({}) Map<String, String> statusKeyMapping,
    @Default(<Diary>[]) List<Diary> diaries,
  }) = _BulletJournalState;
}

/// Extension to provide default status key mapping for initial state
extension BulletJournalStateExtension on BulletJournalState {
  static Map<String, String> defaultStatusKeyMapping() =>
      _defaultStatusKeyMapping();
}

