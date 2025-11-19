import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/diary.dart';

class AddDiaryDialog extends StatefulWidget {
  const AddDiaryDialog({super.key, required this.bloc});

  final BulletJournalBloc bloc;

  static void show(BuildContext context) {
    final bloc = context.read<BulletJournalBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AddDiaryDialog(bloc: bloc),
    );
  }

  @override
  State<AddDiaryDialog> createState() => _AddDiaryDialogState();
}

class _AddDiaryDialogState extends State<AddDiaryDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();
  int _selectedColor = 0xFF4CAF50;
  bool _usePassword = false;

  static const List<int> _colorOptions = [
    0xFF4CAF50, // Green
    0xFF2196F3, // Blue
    0xFF9C27B0, // Purple
    0xFFFF9800, // Orange
    0xFFE91E63, // Pink
    0xFF00BCD4, // Cyan
    0xFFFF5722, // Deep Orange
    0xFF795548, // Brown
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('다이어리 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '다이어리 이름',
                hintText: '예: 개인 일기, 업무 일지',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '설명',
                hintText: '이 다이어리에 대해 설명해주세요',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('색상 선택:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Colors.black
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('비밀번호 설정'),
              value: _usePassword,
              onChanged: (value) {
                setState(() {
                  _usePassword = value ?? false;
                  if (!_usePassword) {
                    _passwordController.clear();
                  }
                });
              },
            ),
            if (_usePassword) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  hintText: '비밀번호를 입력하세요',
                ),
                obscureText: true,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('취소')),
        TextButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('다이어리 이름을 입력해주세요')));
              return;
            }

            if (_usePassword && _passwordController.text.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('비밀번호를 입력해주세요')));
              return;
            }

            final diary = Diary(
              id: 'diary-${DateTime.now().millisecondsSinceEpoch}',
              name: _nameController.text,
              description: _descriptionController.text,
              createdAt: DateTime.now(),
              colorValue: _selectedColor,
              password: _usePassword ? _passwordController.text : null,
            );

            widget.bloc.add(BulletJournalEvent.addDiary(diary));

            context.pop();
          },
          child: const Text('추가'),
        ),
      ],
    );
  }
}

