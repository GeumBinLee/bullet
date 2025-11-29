import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../models/bullet_entry.dart';
import '../../models/key_definition.dart';
import '../../blocs/bullet_journal_bloc.dart';
import '../../utils/device_type.dart';
import '../../utils/key_definition_utils.dart';
import 'utils/entry_finder_utils.dart';
import 'utils/entry_update_utils.dart';
import 'dialogs/unsaved_changes_dialog.dart';
import 'widgets/entry_detail_layout.dart';

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
  KeyDefinition? _selectedKey;
  String? _lastSavedStatusId; // 마지막으로 저장한 키 상태 ID 추적

  @override
  void initState() {
    super.initState();
    _focusController = TextEditingController(text: widget.entry.focus);
    _noteController = TextEditingController(text: widget.entry.note);
    _lastSavedStatusId = widget.entry.keyStatus.id;
    // 현재 엔트리의 키 상태에 매핑된 키를 찾아서 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<BulletJournalBloc>().state;
        // 현재 엔트리의 상태에 매핑된 키 중 첫 번째 키를 찾기
        final keyDefinitions = KeyDefinitionUtils.getAllKeyDefinitionsForStatus(
          widget.entry.keyStatus,
          state,
        );
        if (keyDefinitions.isNotEmpty) {
          // 현재 엔트리가 사용하는 키를 찾거나, 첫 번째 키 사용
          final currentKey = KeyDefinitionUtils.getKeyDefinitionForStatus(
            widget.entry.keyStatus,
            state,
          );
          _selectedKey = keyDefinitions.firstWhere(
            (key) => key.id == currentKey.id,
            orElse: () => keyDefinitions.first,
          );
        } else {
          // 매핑된 키가 없으면 모든 키에서 현재 상태에 해당하는 키 찾기
          final allKeys = KeyDefinitionUtils.getAllAvailableKeys(state);
          for (final key in allKeys) {
            final status = KeyDefinitionUtils.getStatusForKey(key, state);
            if (status?.id == widget.entry.keyStatus.id) {
              _selectedKey = key;
              break;
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _focusController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool _hasChanges(BulletEntry currentEntry) {
    // 키가 변경되면 상태도 변경될 수 있으므로 키로 비교
    final currentKey = KeyDefinitionUtils.getKeyDefinitionForStatus(
      currentEntry.keyStatus,
      context.read<BulletJournalBloc>().state,
    );
    return _focusController.text != currentEntry.focus ||
        _noteController.text != currentEntry.note ||
        _selectedKey?.id != currentKey.id;
  }

  Future<bool> _onWillPop(BulletEntry currentEntry) async {
    if (_isEditing && _hasChanges(currentEntry)) {
      return await showUnsavedChangesDialog(context);
    }
    return true;
  }

  void _handleSave() {
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
    final state = context.read<BulletJournalBloc>().state;
    final status = KeyDefinitionUtils.getStatusForKey(_selectedKey!, state);
    if (status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('키에 매핑된 작업 상태를 찾을 수 없습니다')),
      );
      return;
    }

    debugPrint('[EntryDetail] 저장 시작 - Entry ID: ${widget.entry.id}');
    debugPrint('[EntryDetail] 선택된 키: ${_selectedKey!.id}, 라벨: ${_selectedKey!.label}');
    debugPrint('[EntryDetail] 결정된 상태: ${status.id}, 라벨: ${status.label}');
    debugPrint('[EntryDetail] 현재 엔트리 상태: ${widget.entry.keyStatus.id}');

    final bloc = context.read<BulletJournalBloc>();
    EntryUpdateUtils.findDiaryIdAndPageIdAndUpdate(
      bloc,
      widget.entry,
      _focusController.text,
      _noteController.text,
      status,
    );

    // 저장하기 전에 마지막 저장 상태 ID 업데이트
    final savedStatusId = status.id;

    setState(() {
      _isEditing = false;
      _lastSavedStatusId = savedStatusId;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('수정되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulletJournalBloc, BulletJournalState>(
      builder: (context, state) {
        final currentEntry = EntryFinderUtils.getCurrentEntry(
          widget.entry.id,
          state,
          widget.entry,
        );

        // state가 변경되어 엔트리가 업데이트되었고 편집 모드가 아닐 때 컨트롤러 업데이트
        if (!_isEditing) {
          final currentKey = KeyDefinitionUtils.getKeyDefinitionForStatus(
            currentEntry.keyStatus,
            state,
          );
          final shouldUpdate = currentEntry.focus != _focusController.text ||
              currentEntry.note != _noteController.text ||
              (currentKey.id != _selectedKey?.id &&
                  // 마지막 저장 상태와 다른 경우에만 업데이트
                  // (저장 직후에는 _lastSavedStatusId와 일치하므로 업데이트하지 않음)
                  currentEntry.keyStatus.id != _lastSavedStatusId);

          if (shouldUpdate) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _focusController.text = currentEntry.focus;
                _noteController.text = currentEntry.note;
                // state의 엔트리가 실제로 변경된 경우에만 키 업데이트
                if (currentEntry.keyStatus.id != _lastSavedStatusId) {
                  _selectedKey = currentKey;
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
                    onPressed: _handleSave,
                    tooltip: '저장',
                  ),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final deviceType = DeviceTypeDetector.getDeviceType(context);
                final orientation =
                    DeviceTypeDetector.getDeviceOrientation(context);

                // 태블릿/데스크톱 가로 방향에서는 2열 레이아웃 사용
                final useTwoColumn = (deviceType == DeviceType.tablet ||
                        deviceType == DeviceType.desktop) &&
                    orientation == DeviceOrientation.landscape;

                return EntryDetailLayout(
                  entry: currentEntry,
                  state: state,
                  isEditing: _isEditing,
                  focusController: _focusController,
                  noteController: _noteController,
                  selectedKey: _selectedKey,
                  onKeyChanged: (keyDef) {
                    setState(() {
                      _selectedKey = keyDef;
                    });
                  },
                  useTwoColumn: useTwoColumn,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

