import '../models/key_definition.dart';
import '../data/key_definitions.dart';
import '../models/bullet_entry.dart';
import '../blocs/bullet_journal_bloc.dart';

/// Utility class for working with key definitions
class KeyDefinitionUtils {
  /// Gets the default key ID for a status ID
  static String getDefaultKeyId(String statusId) {
    const defaultMapping = {
      'planned': 'key-incomplete',
      'inProgress': 'key-progress',
      'completed': 'key-completed',
      'memo': 'key-memo',
      'etc': 'key-other',
    };
    return defaultMapping[statusId] ?? 'key-incomplete';
  }

  /// Gets the key definition for a task status
  static KeyDefinition getKeyDefinitionForStatus(
    TaskStatus status,
    BulletJournalState state,
  ) {
    try {
      const defaultStatusKeyMapping = {
        'planned': 'key-incomplete',
        'inProgress': 'key-progress',
        'completed': 'key-completed',
      };
      final keyId = state.statusKeyMapping[status.id] ??
          defaultStatusKeyMapping[status.id] ??
          defaultKeyDefinitions.first.id;
      final allDefinitions = [...defaultKeyDefinitions, ...state.customKeys];
      return allDefinitions.firstWhere(
        (definition) => definition.id == keyId,
        orElse: () => defaultKeyDefinitions.first,
      );
    } catch (e) {
      return defaultKeyDefinitions.first;
    }
  }
}

