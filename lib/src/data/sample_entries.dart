import '../models/bullet_entry.dart';

final List<BulletEntry> sampleEntries = [
  BulletEntry(
    id: 'entry-1',
    date: DateTime.now().subtract(const Duration(days: 1)),
    focus: '주간 리뷰 & 다음 주 계획',
    note:
        '지난주 완료한 업무 목록과 집중했던 루틴을 다시 살펴보고, 다음 주에는 스프린트 회고와 러닝 루틴을 고정한다.',
    keyStatus: TaskStatus.memo,
    tasks: [
      BulletTask(
        id: 'task-1',
        title: 'Sprint 회고 문서 작성',
        status: TaskStatus.completed,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BulletTask(
        id: 'task-2',
        title: '피트니스 루틴 다이어리 업데이트',
        status: TaskStatus.inProgress,
        dueDate: DateTime.now(),
      ),
      BulletTask(
        id: 'task-3',
        title: '다음 주 주요 목표 설정',
        status: TaskStatus.planned,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        snoozes: [
          SnoozeInfo(
            requestedAt: DateTime.now().subtract(const Duration(days: 1)),
            postponedTo: DateTime.now().add(const Duration(days: 2)),
          ),
        ],
      ),
    ],
  ),
  BulletEntry(
    id: 'entry-2',
    date: DateTime.now(),
    focus: '크리에이티브 페인트 세션',
    note:
        '출근 전 30분을 개인 창작 시간으로 활용. 명상과 함께 도구 정리도 끝냈다.',
    keyStatus: TaskStatus.planned,
    tasks: [
      BulletTask(
        id: 'task-4',
        title: '페인팅 스탠드 정리',
        status: TaskStatus.completed,
        dueDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      BulletTask(
        id: 'task-5',
        title: '새로운 색 혼합 실험',
        status: TaskStatus.inProgress,
        dueDate: DateTime.now().add(const Duration(hours: 4)),
      ),
      BulletTask(
        id: 'task-6',
        title: '저녁에 포트폴리오 스냅샷 촬영',
        status: TaskStatus.planned,
        dueDate: DateTime.now().add(const Duration(hours: 12)),
      ),
    ],
  ),
  BulletEntry(
    id: 'entry-3',
    date: DateTime.now().add(const Duration(days: 1)),
    focus: '고객 미팅 & 데모 준비',
    note:
        '데모 시나리오 리허설을 오전에 하고, 고객 피드백을 리뷰해서 백로그에 반영한다.',
    keyStatus: TaskStatus.inProgress,
    tasks: [
      BulletTask(
        id: 'task-7',
        title: '데모 스크립트 리허설(오전)',
        status: TaskStatus.planned,
        dueDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
      ),
      BulletTask(
        id: 'task-8',
        title: '고객 피드백 문서화',
        status: TaskStatus.planned,
        dueDate: DateTime.now().add(const Duration(days: 1, hours: 5)),
      ),
      BulletTask(
        id: 'task-9',
        title: '팀 회고 공유',
        status: TaskStatus.planned,
        dueDate: DateTime.now().add(const Duration(days: 1, hours: 7)),
      ),
    ],
  ),
];

