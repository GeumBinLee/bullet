import '../models/key_definition.dart';

const List<KeyDefinition> defaultKeyDefinitions = [
  KeyDefinition(
    id: 'key-incomplete',
    label: '미완료 (점)',
    description: '새로 추가하는 계획을 표시할 때 사용.',
    shape: KeyShape.dot,
  ),
  KeyDefinition(
    id: 'key-progress',
    label: '진행중 (세모)',
    description: '현재 작업 중인 항목을 표시.',
    shape: KeyShape.triangle,
  ),
  KeyDefinition(
    id: 'key-completed',
    label: '완료 (체크)',
    description: '완료된 작업을 나중에 보기 위함.',
    shape: KeyShape.check,
  ),
  KeyDefinition(
    id: 'key-snoozed',
    label: '미룸 (화살표)',
    description: '일정이 연기되었을 때 상태 표시.',
    shape: KeyShape.arrow,
  ),
  KeyDefinition(
    id: 'key-memo',
    label: '메모 (대시)',
    description: '중요한 정보나 메모를 기록할 때 사용.',
    shape: KeyShape.memo,
  ),
  KeyDefinition(
    id: 'key-other',
    label: '기타 (별표)',
    description: '기타 항목이나 특별한 의미를 표시할 때 사용.',
    shape: KeyShape.other,
  ),
];

