import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../models/bullet_entry.dart';
import '../blocs/bullet_journal_bloc.dart';
import '../utils/device_type.dart';
import '../data/key_definitions.dart';
import '../models/key_definition.dart';
import '../widgets/key_bullet_icon.dart';

class EntryNoteDetailScreen extends StatefulWidget {
  const EntryNoteDetailScreen({
    super.key,
    required this.entry,
  });

  final BulletEntry entry;

  @override
  State<EntryNoteDetailScreen> createState() => _EntryNoteDetailScreenState();
}

class _EntryNoteDetailScreenState extends State<EntryNoteDetailScreen> {
  late TextEditingController _focusController;
  late TextEditingController _noteController;
  bool _isEditing = false;
  TaskStatus? _selectedStatus;
  String? _lastSavedStatusId; // 마지막으로 저장한 키 상태 ID 추적

  @override
  void initState() {
    super.initState();
    _focusController = TextEditingController(text: widget.entry.focus);
    _noteController = TextEditingController(text: widget.entry.note);
    _selectedStatus = widget.entry.keyStatus;
    _lastSavedStatusId = widget.entry.keyStatus.id;
  }

  @override
  void dispose() {
    _focusController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool _hasChanges(BulletEntry currentEntry) {
    return _focusController.text != currentEntry.focus ||
        _noteController.text != currentEntry.note ||
        _selectedStatus?.id != currentEntry.keyStatus.id;
  }

  Future<bool> _onWillPop(BulletEntry currentEntry) async {
    if (_isEditing && _hasChanges(currentEntry)) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('변경사항이 저장되지 않았습니다'),
          content: const Text('변경사항을 저장하지 않고 나가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('나가기'),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  void _findDiaryIdAndPageIdAndUpdate() {
    final bloc = context.read<BulletJournalBloc>();
    final state = bloc.state;

    // 엔트리가 어느 다이어리와 페이지에 속하는지 찾기
    String? diaryId;
    String? pageId;
    for (final diary in state.diaries) {
      // 다이어리 레벨 엔트리 확인
      if (diary.entries.any((e) => e.id == widget.entry.id)) {
        diaryId = diary.id;
        break;
      }
      // 페이지 레벨 엔트리 확인
      for (final page in diary.pages) {
        if (page.entries.any((e) => e.id == widget.entry.id)) {
          diaryId = diary.id;
          pageId = page.id;
          break;
        }
      }
      if (diaryId != null) break;
    }

    final updatedEntry = widget.entry.copyWith(
      focus: _focusController.text,
      note: _noteController.text,
      keyStatus: _selectedStatus ?? widget.entry.keyStatus,
    );

    // 저장하기 전에 마지막 저장 상태 ID 업데이트
    final savedStatusId = _selectedStatus?.id ?? widget.entry.keyStatus.id;

    if (diaryId != null && pageId != null) {
      // 페이지 레벨 엔트리 업데이트
      bloc.add(
        BulletJournalEvent.updateEntryInPage(
          diaryId: diaryId,
          pageId: pageId,
          entryId: widget.entry.id,
          updatedEntry: updatedEntry,
        ),
      );
    } else if (diaryId != null) {
      // 다이어리 레벨 엔트리 업데이트
      bloc.add(
        BulletJournalEvent.updateEntryInDiary(
          diaryId: diaryId,
          entryId: widget.entry.id,
          updatedEntry: updatedEntry,
        ),
      );
    } else {
      // 기본 엔트리
      bloc.add(
        BulletJournalEvent.updateEntry(
          entryId: widget.entry.id,
          updatedEntry: updatedEntry,
        ),
      );
    }

    // 편집 모드 종료 전에 _selectedStatus가 반영되도록 보장
    // Bloc이 상태를 업데이트하면 BlocBuilder가 다시 빌드되므로,
    // 그때 _getCurrentEntry가 업데이트된 엔트리를 반환할 것입니다.
    setState(() {
      _isEditing = false;
      _lastSavedStatusId = savedStatusId;
    });
  }

  BulletEntry _getCurrentEntry(BulletJournalState state) {
    // 다이어리와 페이지에서 찾기
    for (final diary in state.diaries) {
      // 다이어리 레벨 엔트리 확인
      try {
        final entry = diary.entries.firstWhere(
          (e) => e.id == widget.entry.id,
        );
        return entry;
      } catch (e) {
        // 엔트리를 찾지 못함, 계속 진행
      }
      // 페이지 레벨 엔트리 확인
      for (final page in diary.pages) {
        try {
          final entry = page.entries.firstWhere(
            (e) => e.id == widget.entry.id,
          );
          return entry;
        } catch (e) {
          // 엔트리를 찾지 못함, 계속 진행
        }
      }
    }
    // 기본 엔트리에서 찾기
    try {
      final entry = state.entries.firstWhere(
        (e) => e.id == widget.entry.id,
      );
      return entry;
    } catch (e) {
      // 엔트리를 찾지 못함, 원본 반환
      return widget.entry;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulletJournalBloc, BulletJournalState>(
      builder: (context, state) {
        final currentEntry = _getCurrentEntry(state);

        // state가 변경되어 엔트리가 업데이트되었고 편집 모드가 아닐 때 컨트롤러 업데이트
        if (!_isEditing) {
          final shouldUpdate = currentEntry.focus != _focusController.text ||
              currentEntry.note != _noteController.text ||
              (currentEntry.keyStatus.id != _selectedStatus?.id &&
                  // 마지막 저장 상태와 다른 경우에만 업데이트
                  // (저장 직후에는 _lastSavedStatusId와 일치하므로 업데이트하지 않음)
                  currentEntry.keyStatus.id != _lastSavedStatusId);
          
          if (shouldUpdate) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _focusController.text = currentEntry.focus;
                _noteController.text = currentEntry.note;
                // state의 엔트리가 실제로 변경된 경우에만 keyStatus 업데이트
                if (currentEntry.keyStatus.id != _lastSavedStatusId) {
                  _selectedStatus = currentEntry.keyStatus;
                  _lastSavedStatusId = currentEntry.keyStatus.id;
                }
              }
            });
          }
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;
            final shouldPop = await _onWillPop(currentEntry);
            if (shouldPop && context.mounted) {
              context.pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('노트 상세'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  final shouldPop = await _onWillPop(currentEntry);
                  if (shouldPop && context.mounted) {
                    context.pop();
                  }
                },
              ),
              actions: [
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    tooltip: '수정',
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.check),
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
                      _findDiaryIdAndPageIdAndUpdate();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('수정되었습니다')),
                      );
                    },
                    tooltip: '저장',
                  ),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final deviceType = DeviceTypeDetector.getDeviceType(context);
                final orientation = DeviceTypeDetector.getDeviceOrientation(context);
                
                // 태블릿/데스크톱 가로 방향에서는 2열 레이아웃 사용
                final useTwoColumn = (deviceType == DeviceType.tablet || 
                                     deviceType == DeviceType.desktop) &&
                                    orientation == DeviceOrientation.landscape;

                if (useTwoColumn) {
                  // 2열 레이아웃 (제목/날짜 왼쪽, 노트 오른쪽)
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 왼쪽: 제목과 날짜
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isEditing)
                                TextField(
                                  controller: _focusController,
                                  decoration: const InputDecoration(
                                    labelText: '제목',
                                    border: OutlineInputBorder(),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                )
                              else
                                Text(
                                  currentEntry.focus,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                _formattedDate(currentEntry.date),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                              if (_isEditing) ...[
                                const SizedBox(height: 16),
                                const Text('키 선택:'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<TaskStatus>(
                                  value: _selectedStatus,
                                  decoration: const InputDecoration(
                                    labelText: '작업 상태',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: state.taskStatuses.map((status) {
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
                              ] else ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    KeyBulletIcon(
                                      definition: _getKeyDefinitionForStatus(
                                        _selectedStatus ?? currentEntry.keyStatus,
                                        state,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      (_selectedStatus ?? currentEntry.keyStatus).label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // 오른쪽: 노트
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isEditing)
                                TextField(
                                  controller: _noteController,
                                  decoration: const InputDecoration(
                                    labelText: '노트',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: null,
                                  minLines: 15,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                )
                              else
                                Text(
                                  currentEntry.note,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // 1열 레이아웃 (모바일 또는 세로 방향)
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isEditing)
                          TextField(
                            controller: _focusController,
                            decoration: const InputDecoration(
                              labelText: '제목',
                              border: OutlineInputBorder(),
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          )
                        else
                          Text(
                            currentEntry.focus,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          _formattedDate(currentEntry.date),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 16),
                          const Text('키 선택:'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<TaskStatus>(
                            value: _selectedStatus,
                            decoration: const InputDecoration(
                              labelText: '작업 상태',
                              border: OutlineInputBorder(),
                            ),
                            items: state.taskStatuses.map((status) {
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
                        ] else ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              KeyBulletIcon(
                                definition: _getKeyDefinitionForStatus(
                                  _selectedStatus ?? currentEntry.keyStatus,
                                  state,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (_selectedStatus ?? currentEntry.keyStatus).label,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 32),
                        if (_isEditing)
                          TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              labelText: '노트',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: null,
                            minLines: 10,
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                        else
                          Text(
                            currentEntry.note,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  static String _formattedDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  KeyDefinition _getKeyDefinitionForStatus(
    TaskStatus status,
    BulletJournalState state,
  ) {
    try {
      const defaultStatusKeyMapping = {
        'planned': 'key-incomplete',
        'inProgress': 'key-progress',
        'completed': 'key-completed',
      };
      final keyId = state.statusKeyMapping[status.id] ??
          defaultStatusKeyMapping[status.id] ??
          defaultKeyDefinitions.first.id;
      final allDefinitions = [...defaultKeyDefinitions, ...state.customKeys];
      return allDefinitions.firstWhere(
        (definition) => definition.id == keyId,
        orElse: () => defaultKeyDefinitions.first,
      );
    } catch (e) {
      return defaultKeyDefinitions.first;
    }
  }

  String _getDefaultKeyId(String statusId) {
    const defaultMapping = {
      'planned': 'key-incomplete',
      'inProgress': 'key-progress',
      'completed': 'key-completed',
      'memo': 'key-memo',
      'etc': 'key-other',
    };
    return defaultMapping[statusId] ?? 'key-incomplete';
  }
}
