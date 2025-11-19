import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/bullet_entry.dart';
import '../../../models/key_definition.dart';
import '../widgets/drawing_controller.dart';
import '../widgets/drawing_painter.dart';

class CustomKeyDialog extends StatefulWidget {
  const CustomKeyDialog({super.key, required this.bloc});

  final BulletJournalBloc bloc;

  static void show(BuildContext context) {
    final bloc = context.read<BulletJournalBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => CustomKeyDialog(bloc: bloc),
    );
  }

  @override
  State<CustomKeyDialog> createState() => _CustomKeyDialogState();
}

class _CustomKeyDialogState extends State<CustomKeyDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _textController = TextEditingController();
  final _drawingController = DrawingController();
  TaskStatus? _selectedStatus;
  bool _useText = false; // true면 텍스트, false면 그림

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocBuilder<BulletJournalBloc, BulletJournalState>(
        builder: (context, state) {
          return AlertDialog(
            title: const Text('커스텀 키 추가'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '키 이름',
                      hintText: '예: 별표',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '설명',
                      hintText: '이 키를 언제 사용하나요?',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('작업 상태 종류 선택:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TaskStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: '상태 종류',
                      border: OutlineInputBorder(),
                    ),
                    items: state.taskStatuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('그림 그리기'),
                        icon: Icon(Icons.edit),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('텍스트 입력'),
                        icon: Icon(Icons.text_fields),
                      ),
                    ],
                    selected: {_useText},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _useText = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_useText) ...[
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: '키 텍스트',
                        hintText: '예: ★, ⭐, ✓',
                        helperText: '표시할 텍스트나 기호를 입력하세요 (최대 3자)',
                      ),
                      maxLength: 3,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ] else ...[
                    const Text('그림 그리기:'),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRect(
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              final localPosition = details.localPosition;
                              final clampedX = localPosition.dx.clamp(0.0, 200.0);
                              final clampedY = localPosition.dy.clamp(0.0, 200.0);
                              _drawingController.addPoint(
                                Offset(clampedX, clampedY),
                              );
                            });
                          },
                          onPanStart: (details) {
                            setState(() {
                              final localPosition = details.localPosition;
                              final clampedX = localPosition.dx.clamp(0.0, 200.0);
                              final clampedY = localPosition.dy.clamp(0.0, 200.0);
                              _drawingController.addPoint(
                                Offset(clampedX, clampedY),
                              );
                            });
                          },
                          onPanEnd: (_) {
                            setState(() {
                              _drawingController.endStroke();
                            });
                          },
                          child: CustomPaint(
                            size: const Size(200, 200),
                            painter: DrawingPainter(_drawingController.paths),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _drawingController.clear();
                        });
                      },
                      child: const Text('지우기'),
                    ),
                  ],
                ],
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
                      const SnackBar(content: Text('키 이름을 입력해주세요')),
                    );
                    return;
                  }
                  if (_selectedStatus == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('작업 상태 종류를 선택해주세요')),
                    );
                    return;
                  }

                  if (!_useText && _drawingController.paths.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('그림을 그리거나 텍스트를 입력해주세요')),
                    );
                    return;
                  }

                  if (_useText && _textController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('텍스트를 입력해주세요')),
                    );
                    return;
                  }

                  String svgData;
                  if (_useText) {
                    svgData = _textToSvg(_textController.text);
                  } else {
                    svgData = _drawingController.toSvg();
                  }

                  final definition = KeyDefinition(
                    id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                    label: _nameController.text,
                    description: _descriptionController.text,
                    shape: KeyShape.custom,
                    svgData: svgData,
                  );

                  widget.bloc.add(BulletJournalEvent.addCustomKey(definition));

                  widget.bloc.add(
                    BulletJournalEvent.updateStatusKey(
                      status: _selectedStatus!,
                      keyId: definition.id,
                    ),
                  );

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

  String _textToSvg(String text) {
    return '''
<svg width="24" height="24" xmlns="http://www.w3.org/2000/svg">
  <text x="12" y="18" font-family="Arial, sans-serif" font-size="16" text-anchor="middle" dominant-baseline="middle">$text</text>
</svg>
''';
  }
}

