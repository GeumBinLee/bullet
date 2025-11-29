import 'package:flutter/foundation.dart';
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
  /// 여러 키가 할당된 경우 첫 번째 키를 반환
  static KeyDefinition getKeyDefinitionForStatus(
    TaskStatus status,
    BulletJournalState state,
  ) {
    try {
      const defaultStatusKeyMapping = {
        'planned': ['key-incomplete'],
        'inProgress': ['key-progress'],
        'completed': ['key-completed'],
      };
      
      final mappingValue = state.statusKeyMapping[status.id];
      List<String> keyIds;
      
      // 타입 체크: 이전 형식(Map<String, String>)과 새 형식(Map<String, List<String>>) 모두 지원
      if (mappingValue == null) {
        final defaultKeys = defaultStatusKeyMapping[status.id];
        if (defaultKeys != null) {
          keyIds = defaultKeys;
        } else {
          keyIds = [defaultKeyDefinitions.first.id];
        }
      } else {
        // 런타임 타입 변환 지원
        try {
          if (mappingValue is List) {
            keyIds = List<String>.from(mappingValue.map((e) => e.toString()));
          } else if (mappingValue is String) {
            // 이전 형식: 단일 문자열을 리스트로 변환
            final stringValue = mappingValue as String;
            keyIds = [stringValue];
          } else {
            keyIds = [defaultKeyDefinitions.first.id];
          }
        } catch (e) {
          keyIds = [defaultKeyDefinitions.first.id];
        }
      }
      
      // 여러 키가 있으면 첫 번째 키 사용
      final keyId =
          keyIds.isNotEmpty ? keyIds.first : defaultKeyDefinitions.first.id;
      final allDefinitions = [...defaultKeyDefinitions, ...state.customKeys];
      return allDefinitions.firstWhere(
        (definition) => definition.id == keyId,
        orElse: () => defaultKeyDefinitions.first,
      );
    } catch (e) {
      return defaultKeyDefinitions.first;
    }
  }

  /// Gets all key definitions for a task status
  static List<KeyDefinition> getAllKeyDefinitionsForStatus(
    TaskStatus status,
    BulletJournalState state,
  ) {
    try {
      const defaultStatusKeyMapping = {
        'planned': ['key-incomplete'],
        'inProgress': ['key-progress'],
        'completed': ['key-completed'],
      };
      
      final mappingValue = state.statusKeyMapping[status.id];
      List<String> keyIds;
      
      // 타입 체크: 이전 형식(Map<String, String>)과 새 형식(Map<String, List<String>>) 모두 지원
      if (mappingValue == null) {
        final defaultKeys = defaultStatusKeyMapping[status.id];
        if (defaultKeys != null) {
          keyIds = defaultKeys;
        } else {
          keyIds = [defaultKeyDefinitions.first.id];
        }
      } else {
        // 런타임 타입 변환 지원
        try {
          if (mappingValue is List) {
            keyIds = List<String>.from(mappingValue.map((e) => e.toString()));
          } else if (mappingValue is String) {
            // 이전 형식: 단일 문자열을 리스트로 변환
            final stringValue = mappingValue as String;
            keyIds = [stringValue];
          } else {
            keyIds = [defaultKeyDefinitions.first.id];
          }
        } catch (e) {
          keyIds = [defaultKeyDefinitions.first.id];
        }
      }
      
      final allDefinitions = [...defaultKeyDefinitions, ...state.customKeys];
      return keyIds
          .map((keyId) => allDefinitions.firstWhere(
                (definition) => definition.id == keyId,
                orElse: () => defaultKeyDefinitions.first,
              ))
          .toList();
    } catch (e) {
      return [defaultKeyDefinitions.first];
    }
  }

  /// Gets the task status for a key definition (역방향 조회)
  /// 하나의 키는 하나의 작업 상태를 가리킴
  static TaskStatus? getStatusForKey(
    KeyDefinition keyDef,
    BulletJournalState state,
  ) {
    try {
      debugPrint('[KeyDefinitionUtils] getStatusForKey 시작 - Key ID: ${keyDef.id}, Key Label: ${keyDef.label}');
      
      // key-snoozed는 태스크 전용 키이므로 엔트리 레벨에서는 사용 불가
      if (keyDef.id == 'key-snoozed') {
        debugPrint('[KeyDefinitionUtils] key-snoozed는 태스크 전용 키이므로 null 반환');
        return null;
      }

      // statusKeyMapping을 역방향으로 조회
      // 이전 형식(Map<String, String>)과 새 형식(Map<String, List<String>>) 모두 지원
      debugPrint('[KeyDefinitionUtils] statusKeyMapping 조회 시작 - 매핑 수: ${state.statusKeyMapping.length}');
      for (final entry in state.statusKeyMapping.entries) {
        final value = entry.value;
        bool containsKey = false;
        
        // 타입 체크: List인지 String인지 확인
        if (value is List) {
          final keyIds = List<String>.from(value.map((e) => e.toString()));
          containsKey = keyIds.contains(keyDef.id);
          debugPrint('[KeyDefinitionUtils] Status ${entry.key}의 키 리스트: $keyIds, 포함 여부: $containsKey');
        } else if (value is String) {
          // 이전 형식: Map<String, String>
          containsKey = value == keyDef.id;
          debugPrint('[KeyDefinitionUtils] Status ${entry.key}의 키: $value, 일치 여부: $containsKey');
        }
        
        if (containsKey) {
          final status = state.taskStatuses.firstWhere(
            (status) => status.id == entry.key,
            orElse: () => TaskStatus.planned,
          );
          debugPrint('[KeyDefinitionUtils] 매핑된 상태 찾음 - Status ID: ${status.id}, Status Label: ${status.label}');
          return status;
        }
      }
      
      // 매핑이 없으면 기본 매핑 확인
      debugPrint('[KeyDefinitionUtils] statusKeyMapping에서 찾지 못함, 기본 매핑 확인');
      const defaultStatusKeyMapping = {
        'planned': ['key-incomplete'],
        'inProgress': ['key-progress'],
        'completed': ['key-completed'],
        'memo': ['key-memo'],
        'etc': ['key-other'],
      };
      for (final entry in defaultStatusKeyMapping.entries) {
        if (entry.value.contains(keyDef.id)) {
          final status = state.taskStatuses.firstWhere(
            (status) => status.id == entry.key,
            orElse: () => TaskStatus.planned,
          );
          debugPrint('[KeyDefinitionUtils] 기본 매핑에서 찾음 - Status ID: ${status.id}, Status Label: ${status.label}');
          return status;
        }
      }
      
      debugPrint('[KeyDefinitionUtils] 매핑을 찾지 못함, 기본값 planned 반환');
      return TaskStatus.planned; // 기본값
    } catch (e) {
      debugPrint('[KeyDefinitionUtils] 오류 발생: $e');
      return TaskStatus.planned;
    }
  }

  /// Gets all available key definitions (기본 키 + 커스텀 키)
  static List<KeyDefinition> getAllAvailableKeys(BulletJournalState state) {
    return [...defaultKeyDefinitions, ...state.customKeys];
  }
}
