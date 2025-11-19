import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/diary_page.dart';
import '../../../models/bullet_entry.dart';
import '../../../data/key_definitions.dart';
import '../../../widgets/key_bullet_icon.dart';

class AddEntryDialog extends StatefulWidget {
  const AddEntryDialog({
    super.key,
    required this.bloc,
    required this.diaryId,
    required this.pageId,
    required this.page,
  });

  final BulletJournalBloc bloc;
  final String diaryId;
  final String pageId;
  final DiaryPage page;

  @override
  State<AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<AddEntryDialog> {
  final _focusController = TextEditingController();
  final _noteController = TextEditingController();
  TaskStatus? _selectedStatus;
  DateTime _selectedDate = DateTime.now();
  bool _hasInitializedStatus = false;
  String? _selectedSectionId;

  @override
  void initState() {
    super.initState();
    // 기본값으로 '계획 중' 상태 선택
    final state = widget.bloc.state;
    if (state.taskStatuses.isNotEmpty) {
      _selectedStatus = state.taskStatuses.firstWhere(
        (s) => s.id == TaskStatus.planned.id,
        orElse: () => state.taskStatuses.first,
      );
      _hasInitializedStatus = true;
    }
  }

  @override
  void dispose() {
    _focusController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _getDefaultKeyId(String statusId) {
    const defaultMapping = {
      'planned': 'key-incomplete',
      'inProgress': 'key-progress',
      'completed': 'key-completed',
    };
    return defaultMapping[statusId] ?? defaultKeyDefinitions.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocBuilder<BulletJournalBloc, BulletJournalState>(
        builder: (context, state) {
          // initState에서 초기화하지 못한 경우 다시 시도
          if (!_hasInitializedStatus && state.taskStatuses.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                final plannedStatus = state.taskStatuses.firstWhere(
                  (s) => s.id == TaskStatus.planned.id,
                  orElse: () => state.taskStatuses.first,
                );
                setState(() {
                  _selectedStatus = plannedStatus;
                  _hasInitializedStatus = true;
                });
              }
            });
          }

          return AlertDialog(
            title: const Text('엔트리 추가'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _focusController,
                    decoration: const InputDecoration(
                      labelText: '제목',
                      hintText: '제목을 입력해주세요',
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '날짜',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(_formatDate(_selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: '노트',
                      hintText: '상세 내용',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // 섹션 선택 (페이지에 섹션이 있는 경우만)
                  if (widget.page.sections.isNotEmpty) ...[
                    DropdownButtonFormField<String?>(
                      value: _selectedSectionId,
                      decoration: const InputDecoration(
                        labelText: '섹션',
                        border: OutlineInputBorder(),
                        hintText: '섹션을 선택하세요 (선택 사항)',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('섹션 없음'),
                        ),
                        ...widget.page.sections.map((section) {
                          return DropdownMenuItem<String?>(
                            value: section.id,
                            child: Text(section.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSectionId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text('키 선택:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TaskStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: '작업 상태',
                      border: OutlineInputBorder(),
                      hintText: '엔트리의 기본 키를 선택하세요',
                    ),
                    items: state.taskStatuses.map((status) {
                      // 상태에 매핑된 키 찾기
                      final keyId = state.statusKeyMapping[status.id] ??
                          _getDefaultKeyId(status.id);
                      final allDefinitions = [
                        ...defaultKeyDefinitions,
                        ...state.customKeys,
                      ];
                      final keyDefinition = allDefinitions.firstWhere(
                        (def) => def.id == keyId,
                        orElse: () => defaultKeyDefinitions.first,
                      );

                      return DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            KeyBulletIcon(definition: keyDefinition),
                            const SizedBox(width: 12),
                            Text(status.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
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
                  if (_focusController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('제목를 입력해주세요')),
                    );
                    return;
                  }

                  if (_selectedStatus == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('키를 선택해주세요')),
                    );
                    return;
                  }

                  // 섹션 할당 로직:
                  // - 섹션이 있는 경우: 선택한 섹션 ID 사용 (선택 안 하면 null = "섹션 없음")
                  // - 섹션이 없는 경우: sectionId를 null로 설정 (섹션 정보 없음)
                  final entry = BulletEntry(
                    id: 'entry-${DateTime.now().millisecondsSinceEpoch}',
                    date: _selectedDate,
                    focus: _focusController.text,
                    note: _noteController.text,
                    keyStatus: _selectedStatus!,
                    tasks: [],
                    sectionId: widget.page.sections.isNotEmpty
                        ? _selectedSectionId
                        : null,
                  );

                  widget.bloc.add(
                    BulletJournalEvent.addEntryToPage(
                      diaryId: widget.diaryId,
                      pageId: widget.pageId,
                      entry: entry,
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
}

