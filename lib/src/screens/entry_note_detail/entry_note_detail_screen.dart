import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../models/bullet_entry.dart';
import '../../blocs/bullet_journal_bloc.dart';
import '../../utils/device_type.dart';
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
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('키를 선택해주세요')),
      );
      return;
    }

    final bloc = context.read<BulletJournalBloc>();
    EntryUpdateUtils.findDiaryIdAndPageIdAndUpdate(
      bloc,
      widget.entry,
      _focusController.text,
      _noteController.text,
      _selectedStatus,
    );

    // 저장하기 전에 마지막 저장 상태 ID 업데이트
    final savedStatusId = _selectedStatus?.id ?? widget.entry.keyStatus.id;

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
                  selectedStatus: _selectedStatus,
                  onStatusChanged: (status) {
                    setState(() {
                      _selectedStatus = status;
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

