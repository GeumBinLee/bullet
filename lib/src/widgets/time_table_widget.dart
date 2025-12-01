import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/bullet_journal_bloc.dart';
import '../models/page_component.dart';

class TimeTableWidget extends StatefulWidget {
  const TimeTableWidget({
    super.key,
    required this.diaryId,
    required this.pageId,
    required this.component,
  });

  final String diaryId;
  final String pageId;
  final TimeTableComponent component;

  @override
  State<TimeTableWidget> createState() => _TimeTableWidgetState();
}

enum TimeTableExpansionState {
  collapsed, // 완전히 접힌 상태 (제목만)
  partial, // 3행까지만 보이는 상태
  expanded, // 완전히 펼친 상태
}

class _TimeTableWidgetState extends State<TimeTableWidget> {
  String? _editingCellKey;
  final Map<String, TextEditingController> _controllers = {};
  late TimeTableExpansionState _expansionState;

  @override
  void initState() {
    super.initState();
    // 컴포넌트에서 저장된 확장 상태 로드, 없으면 기본값 'partial' (3줄 미리보기)
    final savedState = widget.component.expansionState;
    _expansionState = _parseExpansionState(savedState);
  }

  TimeTableExpansionState _parseExpansionState(String state) {
    switch (state) {
      case 'collapsed':
        return TimeTableExpansionState.collapsed;
      case 'expanded':
        return TimeTableExpansionState.expanded;
      case 'partial':
      default:
        return TimeTableExpansionState.partial;
    }
  }

  String _expansionStateToString(TimeTableExpansionState state) {
    switch (state) {
      case TimeTableExpansionState.collapsed:
        return 'collapsed';
      case TimeTableExpansionState.partial:
        return 'partial';
      case TimeTableExpansionState.expanded:
        return 'expanded';
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      switch (_expansionState) {
        case TimeTableExpansionState.collapsed:
          _expansionState = TimeTableExpansionState.partial;
          break;
        case TimeTableExpansionState.partial:
          _expansionState = TimeTableExpansionState.expanded;
          break;
        case TimeTableExpansionState.expanded:
          _expansionState = TimeTableExpansionState.collapsed;
          break;
      }
    });

    // 확장 상태를 컴포넌트에 저장
    final updatedComponent = widget.component.copyWith(
      expansionState: _expansionStateToString(_expansionState),
    );
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateComponentInPage(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            componentId: widget.component.id,
            updatedComponent: updatedComponent,
          ),
        );
  }

  IconData _getExpansionIcon() {
    switch (_expansionState) {
      case TimeTableExpansionState.collapsed:
        return Icons.expand_more;
      case TimeTableExpansionState.partial:
        return Icons.unfold_more;
      case TimeTableExpansionState.expanded:
        return Icons.expand_less;
    }
  }

  int _getVisibleRowCount() {
    switch (_expansionState) {
      case TimeTableExpansionState.collapsed:
        return 0;
      case TimeTableExpansionState.partial:
        return math.min(3, widget.component.hourCount);
      case TimeTableExpansionState.expanded:
        return widget.component.hourCount;
    }
  }

  String _getCellKey(int row, int column) => '$row-$column';

  String _getCellContent(int row, int column) {
    final cell = widget.component.cells.firstWhere(
      (c) => c.row == row && c.column == column,
      orElse: () => TimeTableCell(row: row, column: column, content: ''),
    );
    return cell.content;
  }

  TextEditingController _getController(int row, int column) {
    final key = _getCellKey(row, column);
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(
        text: _getCellContent(row, column),
      );
    }
    return _controllers[key]!;
  }

  void _updateCell(int row, int column, String content) {
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateTimeTableCell(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            componentId: widget.component.id,
            row: row,
            column: column,
            content: content,
          ),
        );
  }

  void _addRow() {
    final newRowHeaders = [
      ...widget.component.rowHeaders,
      '${widget.component.hourCount}:00'
    ];
    final updatedComponent = widget.component.copyWith(
      hourCount: widget.component.hourCount + 1,
      rowHeaders: newRowHeaders,
    );
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateComponentInPage(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            componentId: widget.component.id,
            updatedComponent: updatedComponent,
          ),
        );
  }

  void _removeRow() {
    if (widget.component.hourCount <= 1) return;
    final newRowHeaders = widget.component.rowHeaders
        .sublist(0, widget.component.rowHeaders.length - 1);
    final newCells = widget.component.cells
        .where((cell) => cell.row < widget.component.hourCount - 1)
        .toList();
    final updatedComponent = widget.component.copyWith(
      hourCount: widget.component.hourCount - 1,
      rowHeaders: newRowHeaders,
      cells: newCells,
    );
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateComponentInPage(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            componentId: widget.component.id,
            updatedComponent: updatedComponent,
          ),
        );
  }

  void _addColumn() {
    final newColumnHeaders = [
      ...widget.component.columnHeaders,
      '열 ${widget.component.dayCount + 1}'
    ];
    final updatedComponent = widget.component.copyWith(
      dayCount: widget.component.dayCount + 1,
      columnHeaders: newColumnHeaders,
    );
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateComponentInPage(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            componentId: widget.component.id,
            updatedComponent: updatedComponent,
          ),
        );
  }

  void _removeColumn() {
    if (widget.component.dayCount <= 1) return;
    final newColumnHeaders = widget.component.columnHeaders
        .sublist(0, widget.component.columnHeaders.length - 1);
    final newCells = widget.component.cells
        .where((cell) => cell.column < widget.component.dayCount - 1)
        .toList();
    final updatedComponent = widget.component.copyWith(
      dayCount: widget.component.dayCount - 1,
      columnHeaders: newColumnHeaders,
      cells: newCells,
    );
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateComponentInPage(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            componentId: widget.component.id,
            updatedComponent: updatedComponent,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final rowHeaders = widget.component.rowHeaders.isNotEmpty
        ? widget.component.rowHeaders
        : List.generate(widget.component.hourCount, (i) => '$i:00');

    final columnHeaders = widget.component.columnHeaders.isNotEmpty
        ? widget.component.columnHeaders
        : ['월', '화', '수', '목', '금', '토', '일']
            .sublist(0, widget.component.dayCount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(Icons.calendar_view_week, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.component.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 접기/펼치기 버튼
                IconButton(
                  icon: Icon(_getExpansionIcon(), size: 20),
                  tooltip: _expansionState == TimeTableExpansionState.collapsed
                      ? '펼치기'
                      : _expansionState == TimeTableExpansionState.partial
                          ? '더 펼치기'
                          : '접기',
                  onPressed: _toggleExpansion,
                ),
                // 행/열 추가/삭제 버튼
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'add_row',
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 20),
                          SizedBox(width: 8),
                          Text('행 추가'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove_row',
                      child: Row(
                        children: [
                          Icon(Icons.remove, size: 20),
                          SizedBox(width: 8),
                          Text('행 삭제'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'add_column',
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 20),
                          SizedBox(width: 8),
                          Text('열 추가'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove_column',
                      child: Row(
                        children: [
                          Icon(Icons.remove, size: 20),
                          SizedBox(width: 8),
                          Text('열 삭제'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('타임테이블 삭제', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'add_row':
                        _addRow();
                        break;
                      case 'remove_row':
                        _removeRow();
                        break;
                      case 'add_column':
                        _addColumn();
                        break;
                      case 'remove_column':
                        _removeColumn();
                        break;
                      case 'delete':
                        _showDeleteConfirmation();
                        break;
                    }
                  },
                ),
              ],
            ),
            if (_expansionState != TimeTableExpansionState.collapsed) ...[
              const SizedBox(height: 12),
              // 타임테이블
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  defaultColumnWidth: const FixedColumnWidth(100),
                  children: [
                    // 헤더 행
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade100),
                      children: [
                        _buildHeaderCell(''),
                        ...columnHeaders
                            .map((header) => _buildHeaderCell(header)),
                      ],
                    ),
                    // 데이터 행들
                    ...List.generate(_getVisibleRowCount(), (row) {
                      return TableRow(
                        children: [
                          _buildHeaderCell(rowHeaders[row]),
                          ...List.generate(widget.component.dayCount, (column) {
                            return _buildEditableCell(row, column);
                          }),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEditableCell(int row, int column) {
    final key = _getCellKey(row, column);
    final isEditing = _editingCellKey == key;

    return GestureDetector(
      onTap: () {
        setState(() {
          _editingCellKey = key;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        child: isEditing
            ? TextField(
                controller: _getController(row, column),
                autofocus: true,
                maxLines: null,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(4),
                  isDense: true,
                ),
                onChanged: (value) {
                  _updateCell(row, column, value);
                },
                onSubmitted: (value) {
                  setState(() {
                    _editingCellKey = null;
                  });
                },
              )
            : Container(
                padding: const EdgeInsets.all(4),
                alignment: Alignment.topLeft,
                constraints: const BoxConstraints(minHeight: 40),
                child: Text(
                  _getCellContent(row, column),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('타임테이블 삭제'),
        content: const Text('이 타임테이블을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<BulletJournalBloc>().add(
                    BulletJournalEvent.deleteComponentFromPage(
                      diaryId: widget.diaryId,
                      pageId: widget.pageId,
                      componentId: widget.component.id,
                    ),
                  );
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
