import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/diary_page.dart';
import '../../../models/bullet_entry.dart';
import '../../../models/key_definition.dart';
import '../../../utils/key_definition_utils.dart';
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
  KeyDefinition? _selectedKey;
  DateTime _selectedDate = DateTime.now();
  bool _hasInitializedKey = false;
  String? _selectedSectionId;

  @override
  void initState() {
    super.initState();
    // 기본값으로 '계획 중' 상태에 매핑된 첫 번째 키 선택
    final state = widget.bloc.state;
    if (state.taskStatuses.isNotEmpty) {
      final plannedStatus = state.taskStatuses.firstWhere(
        (s) => s.id == TaskStatus.planned.id,
        orElse: () => state.taskStatuses.first,
      );
      final keys = KeyDefinitionUtils.getAllKeyDefinitionsForStatus(
        plannedStatus,
        state,
      );
      if (keys.isNotEmpty) {
        _selectedKey = keys.first;
        _hasInitializedKey = true;
      }
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocBuilder<BulletJournalBloc, BulletJournalState>(
        builder: (context, state) {
          // initState에서 초기화하지 못한 경우 다시 시도
          if (!_hasInitializedKey && state.taskStatuses.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                final plannedStatus = state.taskStatuses.firstWhere(
                  (s) => s.id == TaskStatus.planned.id,
                  orElse: () => state.taskStatuses.first,
                );
                final keys = KeyDefinitionUtils.getAllKeyDefinitionsForStatus(
                  plannedStatus,
                  state,
                );
                if (keys.isNotEmpty) {
                  setState(() {
                    _selectedKey = keys.first;
                    _hasInitializedKey = true;
                  });
                }
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
                  DropdownButtonFormField<KeyDefinition>(
                    value: _selectedKey,
                    decoration: const InputDecoration(
                      labelText: '키',
                      border: OutlineInputBorder(),
                      hintText: '키를 선택하세요',
                    ),
                    items: KeyDefinitionUtils.getAllAvailableKeys(state)
                        .where((keyDef) => keyDef.id != 'key-snoozed') // key-snoozed는 태스크 전용
                        .map((keyDef) {
                      // 키에 매핑된 작업 상태 찾기
                      final status = KeyDefinitionUtils.getStatusForKey(keyDef, state);
                      return DropdownMenuItem(
                        value: keyDef,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            KeyBulletIcon(definition: keyDef),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                status != null
                                    ? '${keyDef.label} (${status.label})'
                                    : keyDef.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedKey = value;
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

                  if (_selectedKey == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('키를 선택해주세요')),
                    );
                    return;
                  }

                  // 키에서 작업 상태 자동 결정
                  final status = KeyDefinitionUtils.getStatusForKey(
                    _selectedKey!,
                    state,
                  );
                  if (status == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('키에 매핑된 작업 상태를 찾을 수 없습니다')),
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
                    keyStatus: status,
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

