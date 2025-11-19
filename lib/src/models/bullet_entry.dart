import 'package:freezed_annotation/freezed_annotation.dart';

part 'bullet_entry.freezed.dart';

@freezed
class SnoozeInfo with _$SnoozeInfo {
  const factory SnoozeInfo({
    required DateTime requestedAt,
    required DateTime postponedTo,
  }) = _SnoozeInfo;
}

@freezed
class BulletTask with _$BulletTask {
  const factory BulletTask({
    required String id,
    required String title,
    required TaskStatus status,
    DateTime? dueDate,
    @Default(<SnoozeInfo>[]) List<SnoozeInfo> snoozes,
  }) = _BulletTask;
}

@freezed
class BulletEntry with _$BulletEntry {
  const factory BulletEntry({
    required String id,
    required DateTime date,
    required String focus,
    required String note,
    required TaskStatus keyStatus,
    required List<BulletTask> tasks,
    String? sectionId, // 섹션 ID (선택적)
  }) = _BulletEntry;
}

@freezed
class TaskStatus with _$TaskStatus {
  const factory TaskStatus({
    required String id,
    required String label,
    required int order,
  }) = _TaskStatus;

  const TaskStatus._();

  static const TaskStatus planned = TaskStatus(
    id: 'planned',
    label: '계획 중',
    order: 0,
  );
  static const TaskStatus inProgress = TaskStatus(
    id: 'inProgress',
    label: '진행 중',
    order: 1,
  );
  static const TaskStatus completed = TaskStatus(
    id: 'completed',
    label: '완료',
    order: 2,
  );
  static const TaskStatus memo = TaskStatus(
    id: 'memo',
    label: '메모',
    order: 3,
  );
  static const TaskStatus etc = TaskStatus(
    id: 'etc',
    label: '기타',
    order: 4,
  );

  static const List<TaskStatus> defaultStatuses = [
    planned,
    inProgress,
    completed,
    memo,
    etc,
  ];

  TaskStatus next(List<TaskStatus> allStatuses) {
    final sortedStatuses = [...allStatuses]..sort((a, b) => a.order.compareTo(b.order));
    final currentIndex = sortedStatuses.indexWhere((s) => s.id == id);
    if (currentIndex == -1) return this;
    final nextIndex = (currentIndex + 1) % sortedStatuses.length;
    return sortedStatuses[nextIndex];
  }
}

enum BulletMood {
  calm,
  energized,
  reflective;
}

