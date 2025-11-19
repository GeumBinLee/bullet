import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/bullet_entry.dart';

class AddStatusDialog extends StatefulWidget {
  const AddStatusDialog({super.key, required this.bloc});

  final BulletJournalBloc bloc;

  static void show(BuildContext context) {
    final bloc = context.read<BulletJournalBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AddStatusDialog(bloc: bloc),
    );
  }

  @override
  State<AddStatusDialog> createState() => _AddStatusDialogState();
}

class _AddStatusDialogState extends State<AddStatusDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocBuilder<BulletJournalBloc, BulletJournalState>(
        builder: (context, state) {
          final maxOrder = state.taskStatuses.isEmpty
              ? 0
              : state.taskStatuses
                  .map((s) => s.order)
                  .reduce((a, b) => a > b ? a : b);
          return AlertDialog(
            title: const Text('작업 상태 추가'),
            content: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '상태 이름',
                hintText: '예: 검토 중, 보류',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (_nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('상태 이름을 입력해주세요')),
                    );
                    return;
                  }

                  final newStatus = TaskStatus(
                    id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                    label: _nameController.text,
                    order: maxOrder + 1,
                  );

                  widget.bloc.add(BulletJournalEvent.addTaskStatus(newStatus));

                  context.pop();
                },
                child: const Text('추가'),
              ),
            ],
          );
        },
      ),
    );
  }
}

