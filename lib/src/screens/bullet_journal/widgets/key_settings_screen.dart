import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../data/key_definitions.dart';
import '../../../models/bullet_entry.dart';
import '../../../widgets/key_bullet_icon.dart';
import '../dialogs/custom_key_dialog.dart';
import '../dialogs/add_status_dialog.dart';

class KeySettingsScreen extends StatelessWidget {
  const KeySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('키 설정')),
      body: BlocBuilder<BulletJournalBloc, BulletJournalState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '기본 키',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...defaultKeyDefinitions.map((definition) {
                // 여러 상태에 매핑될 수 있으므로 리스트로 찾기
                final mappedStatusIds = state.statusKeyMapping.entries
                    .where((e) => e.value.contains(definition.id))
                    .map((e) => e.key)
                    .toList();
                return ListTile(
                  leading: KeyBulletIcon(definition: definition),
                  title: Text(definition.label),
                  subtitle: Text(definition.description),
                  trailing: mappedStatusIds.isNotEmpty
                      ? Wrap(
                          spacing: 4,
                          children: mappedStatusIds.map((statusId) {
                            return Chip(
                              label: Text(
                                _statusLabelForChip(statusId, state),
                              ),
                              backgroundColor: Colors.teal.shade100,
                            );
                          }).toList(),
                        )
                      : null,
                );
              }),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '커스텀 키',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (state.customKeys.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '커스텀 키가 없습니다. 아래 버튼을 눌러 추가하세요.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...state.customKeys.map((definition) {
                  // 여러 상태에 매핑될 수 있으므로 리스트로 찾기
                  final mappedStatusIds = state.statusKeyMapping.entries
                      .where((e) => e.value.contains(definition.id))
                      .map((e) => e.key)
                      .toList();
                  return ListTile(
                    leading: KeyBulletIcon(definition: definition),
                    title: Text(definition.label),
                    subtitle: Text(definition.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (mappedStatusIds.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            children: mappedStatusIds.map((statusId) {
                              return Chip(
                                label: Text(
                                  _statusLabelForChip(statusId, state),
                                ),
                                backgroundColor: Colors.teal.shade100,
                              );
                            }).toList(),
                          ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            ...state.taskStatuses.map((status) {
                              final isAlreadyAssigned = mappedStatusIds.contains(status.id);
                              return PopupMenuItem(
                                value: 'assign_${status.id}',
                                enabled: !isAlreadyAssigned,
                                child: Text(
                                  isAlreadyAssigned 
                                      ? '${status.label}에 사용됨' 
                                      : '${status.label}에 사용',
                                ),
                              );
                            }),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                '삭제',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'delete') {
                              context.read<BulletJournalBloc>().add(
                                    BulletJournalEvent.deleteCustomKey(
                                      definition.id,
                                    ),
                                  );
                            } else if (value.startsWith('assign_')) {
                              final statusId = value.replaceFirst(
                                'assign_',
                                '',
                              );
                              final status = state.taskStatuses.firstWhere(
                                (s) => s.id == statusId,
                              );
                              context.read<BulletJournalBloc>().add(
                                    BulletJournalEvent.updateStatusKey(
                                      status: status,
                                      keyId: definition.id,
                                    ),
                                  );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '작업 상태 종류',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '커스텀 작업 상태를 삭제하면, 해당 상태를 사용하던 작업들이 "기타"로 자동 변경됩니다.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...state.taskStatuses.map((status) {
                final isDefault = TaskStatus.defaultStatuses.any(
                  (s) => s.id == status.id,
                );
                // 기본 엔트리와 다이어리 엔트리 모두에서 사용 중인지 확인
                bool hasTasks = state.entries.any(
                  (entry) =>
                      entry.tasks.any((task) => task.status.id == status.id),
                );
                if (!hasTasks) {
                  hasTasks = state.diaries.any(
                    (diary) => diary.entries.any(
                      (entry) => entry.tasks.any(
                        (task) => task.status.id == status.id,
                      ),
                    ),
                  );
                }
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Text(
                      '${status.order + 1}',
                      style: TextStyle(color: Colors.teal.shade900),
                    ),
                  ),
                  title: Text(status.label),
                  subtitle: Text('순서: ${status.order + 1}'),
                  trailing: isDefault
                      ? const Chip(
                          label: Text('기본'),
                          backgroundColor: Colors.grey,
                        )
                      : hasTasks
                          ? const Chip(
                              label: Text('사용 중'),
                              backgroundColor: Colors.orange,
                            )
                          : IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // 해당 상태를 사용하는 작업 개수 확인
                                int taskCount = 0;
                                for (final entry in state.entries) {
                                  taskCount += entry.tasks
                                      .where(
                                          (task) => task.status.id == status.id)
                                      .length;
                                }
                                for (final diary in state.diaries) {
                                  for (final entry in diary.entries) {
                                    taskCount += entry.tasks
                                        .where(
                                          (task) => task.status.id == status.id,
                                        )
                                        .length;
                                  }
                                  for (final page in diary.pages) {
                                    for (final entry in page.entries) {
                                      taskCount += entry.tasks
                                          .where(
                                            (task) =>
                                                task.status.id == status.id,
                                          )
                                          .length;
                                    }
                                  }
                                }

                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: Text('${status.label} 삭제'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${status.label} 작업 상태를 삭제하시겠습니까?\n해당 상태를 사용하던 작업들이 자동으로 "기타"로 변경됩니다.',
                                        ),
                                        if (taskCount > 0) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12.0),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.orange.shade200,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.warning_amber_rounded,
                                                  size: 20,
                                                  color:
                                                      Colors.orange.shade700,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    '이 상태를 사용하는 작업 $taskCount개가 "기타"로 자동 변경됩니다.',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors
                                                          .orange.shade900,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => context.pop(),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<BulletJournalBloc>()
                                              .add(
                                                BulletJournalEvent
                                                    .deleteTaskStatus(
                                                  status.id,
                                                ),
                                              );
                                          context.pop();
                                        },
                                        child: const Text(
                                          '삭제',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                );
              }),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('작업 상태 추가'),
                subtitle: const Text('새로운 작업 상태 종류 추가'),
                onTap: () => AddStatusDialog.show(context),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '키 추가',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('커스텀 키 추가'),
                subtitle: const Text('그림을 그려서 불렛 모양 만들기'),
                onTap: () => CustomKeyDialog.show(context),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _statusLabelForChip(
      String statusId, BulletJournalState state) {
    final status = state.taskStatuses.firstWhere(
      (s) => s.id == statusId,
      orElse: () => TaskStatus(id: statusId, label: statusId, order: 999),
    );
    return status.label;
  }
}

