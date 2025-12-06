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
    this.isKanbanView = false,
    this.isDetailView = false,
    this.onOpenDetail,
  });

  final String diaryId;
  final String pageId;
  final TimeTableComponent component;
  final bool isKanbanView;
  final bool isDetailView;
  final VoidCallback? onOpenDetail;

  @override
  State<TimeTableWidget> createState() => _TimeTableWidgetState();
}

enum TimeTableExpansionState {
  collapsed, // 완전히 접힌 상태 (제목만)
  partial, // 3행까지만 보이는 상태
  expanded, // 완전히 펼친 상태
}

// 드래그 데이터 클래스
class _HeaderDragData {
  const _HeaderDragData({
    required this.isRowHeader,
    required this.isColumnHeader,
    required this.index,
    required this.text,
  });

  final bool isRowHeader;
  final bool isColumnHeader;
  final int index;
  final String text;
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

  @override
  void didUpdateWidget(TimeTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.component.expansionState != widget.component.expansionState) {
      _expansionState = _parseExpansionState(widget.component.expansionState);
    }
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

  IconData _getExpansionIcon(TimeTableExpansionState state) {
    switch (state) {
      case TimeTableExpansionState.collapsed:
        return Icons.expand_more;
      case TimeTableExpansionState.partial:
        return Icons.unfold_more;
      case TimeTableExpansionState.expanded:
        return Icons.expand_less;
    }
  }

  int _getVisibleRowCount(TimeTableExpansionState state) {
    switch (state) {
      case TimeTableExpansionState.collapsed:
        return 0;
      case TimeTableExpansionState.partial:
        return math.min(3, widget.component.hourCount);
      case TimeTableExpansionState.expanded:
        return widget.component.hourCount;
    }
  }

  String _getCellKey(int row, int column) => '$row-$column';

  /// (row, column)이 속한 병합 셀(위쪽 기준 셀)을 찾는다.
  TimeTableCell? _findBaseMergedCell(int row, int column) {
    for (final cell in widget.component.cells) {
      if (cell.column != column) continue;
      final span = cell.rowSpan;
      if (row >= cell.row && row < cell.row + span) {
        return cell;
      }
    }
    return null;
  }

  bool _isMergedTailCell(int row, int column) {
    final cell = _findBaseMergedCell(row, column);
    if (cell == null) return false;
    return cell.rowSpan > 1 && cell.row < row && row < cell.row + cell.rowSpan;
  }

  TimeTableCell _getCell(int row, int column) {
    // 먼저 정확히 일치하는 셀을 찾는다.
    final exact = widget.component.cells.firstWhere(
      (c) => c.row == row && c.column == column,
      orElse: () => TimeTableCell(row: row, column: column, content: ''),
    );

    // 병합된 셀(위쪽 기준 셀)이 있으면 그 셀을 사용
    final base = _findBaseMergedCell(row, column);
    if (base != null) return base;

    return exact;
  }

  String _getCellContent(int row, int column) => _getCell(row, column).content;

  String? _getCellBackgroundColorHex(int row, int column) =>
      _getCell(row, column).backgroundColorHex;

  Color? _getCellBackgroundColor(int row, int column) {
    final hex = _getCell(row, column).backgroundColorHex;
    if (hex == null || hex.isEmpty) return null;
    try {
      var value = int.parse(hex.replaceFirst('#', ''), radix: 16);
      if (value <= 0xFFFFFF) {
        value |= 0xFF000000;
      }
      return Color(value);
    } catch (_) {
      return null;
    }
  }

  TextEditingController _getController(int row, int column) {
    final base = _findBaseMergedCell(row, column);
    final baseRow = base?.row ?? row;
    final key = _getCellKey(baseRow, column);
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(
        text: _getCellContent(row, column),
      );
    }
    return _controllers[key]!;
  }

  void _updateCell(
    int row,
    int column,
    String content, {
    String? backgroundColorHex,
  }) {
    // 병합 셀이면 위쪽 기준 셀 좌표로 업데이트
    final base = _findBaseMergedCell(row, column);
    final targetRow = base?.row ?? row;

    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateTimeTableCell(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            componentId: widget.component.id,
            row: targetRow,
            column: column,
            content: content,
            backgroundColorHex: backgroundColorHex,
          ),
        );
  }

  /// 선택한 셀을 바로 아래 행과 병합 (세로 병합 전용, 같은 열만)
  void _mergeCellDown(int row, int column) {
    if (row >= widget.component.hourCount - 1) return;

    final base = _findBaseMergedCell(row, column);
    final baseRow = base?.row ?? row;
    final currentSpan = base?.rowSpan ?? 1;
    final lastRow = baseRow + currentSpan - 1;

    if (lastRow >= widget.component.hourCount - 1) return;
    final targetRow = lastRow + 1;

    // 병합 대상 행이 이미 다른 병합 셀에 속해 있다면 병합 불가
    final overlapping = _findBaseMergedCell(targetRow, column);
    if (overlapping != null && overlapping.row != baseRow) {
      return;
    }

    final cells = List<TimeTableCell>.from(widget.component.cells);

    // 기준 셀 찾기 (없으면 새로 생성)
    final existingIndex =
        cells.indexWhere((c) => c.row == baseRow && c.column == column);
    TimeTableCell baseCell;
    if (existingIndex >= 0) {
      baseCell = cells[existingIndex];
    } else {
      baseCell = TimeTableCell(
        row: baseRow,
        column: column,
        content: _getCellContent(row, column),
        backgroundColorHex: _getCellBackgroundColorHex(row, column),
      );
      cells.add(baseCell);
    }

    final newSpan = baseCell.rowSpan + (targetRow - lastRow);
    final updatedBase = baseCell.copyWith(rowSpan: newSpan);

    // 기준 셀 교체
    final idx = cells.indexWhere((c) => c.row == baseRow && c.column == column);
    if (idx >= 0) {
      cells[idx] = updatedBase;
    }

    // 병합 범위 안에 있는 하위 셀 제거 (기존 내용은 버림)
    cells.removeWhere(
        (c) => c.column == column && c.row > baseRow && c.row <= targetRow);

    final updatedComponent = widget.component.copyWith(cells: cells);
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateComponentInPage(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            componentId: widget.component.id,
            updatedComponent: updatedComponent,
          ),
        );
  }

  /// 병합 해제 (이 셀이 속한 병합 그룹을 모두 해제)
  void _unmergeCell(int row, int column) {
    final base = _findBaseMergedCell(row, column);
    if (base == null || base.rowSpan <= 1) return;

    final baseRow = base.row;

    final cells = List<TimeTableCell>.from(widget.component.cells);
    final idx =
        cells.indexWhere((c) => c.row == baseRow && c.column == base.column);
    if (idx < 0) return;

    // 기준 셀의 rowSpan만 1로 되돌린다.
    cells[idx] = base.copyWith(rowSpan: 1);

    final updatedComponent = widget.component.copyWith(cells: cells);
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateComponentInPage(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            componentId: widget.component.id,
            updatedComponent: updatedComponent,
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

  Future<void> _showColumnResizeDialog(int columnIndex) async {
    final screenSize = MediaQuery.of(context).size;
    final availableWidth = screenSize.width - 200;
    final baseWidth = widget.component.dayCount > 0
        ? availableWidth / widget.component.dayCount
        : 80.0;

    final currentWidths = List<double>.from(widget.component.columnWidths);
    while (currentWidths.length <= columnIndex) {
      currentWidths.add(0);
    }
    final currentWidth =
        currentWidths[columnIndex] > 0 ? currentWidths[columnIndex] : baseWidth;
    double tempWidth = currentWidth;

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('열 너비 조절'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${tempWidth.toStringAsFixed(0)} px'),
            Slider(
              value: tempWidth.clamp(50.0, 500.0),
              min: 50,
              max: 500,
              onChanged: (value) {
                setState(() {
                  tempWidth = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, tempWidth),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (result == null) return;

    currentWidths[columnIndex] = result;
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateTimeTableColumnWidths(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            componentId: widget.component.id,
            columnWidths: currentWidths,
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

  void _moveRow(int from, int to) {
    if (to < 0 || to >= widget.component.hourCount) return;

    final headers = widget.component.rowHeaders.isNotEmpty
        ? List<String>.from(widget.component.rowHeaders)
        : List.generate(widget.component.hourCount, (i) => '$i:00');
    if (from < 0 || from >= headers.length) return;
    final movedHeader = headers.removeAt(from);
    headers.insert(to, movedHeader);

    final cells = widget.component.cells.map((cell) {
      if (cell.row == from) {
        return cell.copyWith(row: to);
      }
      if (from < to && cell.row > from && cell.row <= to) {
        return cell.copyWith(row: cell.row - 1);
      }
      if (from > to && cell.row >= to && cell.row < from) {
        return cell.copyWith(row: cell.row + 1);
      }
      return cell;
    }).toList();

    final updatedComponent = widget.component.copyWith(
      rowHeaders: headers,
      cells: cells,
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

  void _moveColumn(int from, int to) {
    if (to < 0 || to >= widget.component.dayCount) return;

    final headers = widget.component.columnHeaders.isNotEmpty
        ? List<String>.from(widget.component.columnHeaders)
        : ['월', '화', '수', '목', '금', '토', '일']
            .sublist(0, widget.component.dayCount);
    if (from < 0 || from >= headers.length) return;
    final movedHeader = headers.removeAt(from);
    headers.insert(to, movedHeader);

    final cells = widget.component.cells.map((cell) {
      if (cell.column == from) {
        return cell.copyWith(column: to);
      }
      if (from < to && cell.column > from && cell.column <= to) {
        return cell.copyWith(column: cell.column - 1);
      }
      if (from > to && cell.column >= to && cell.column < from) {
        return cell.copyWith(column: cell.column + 1);
      }
      return cell;
    }).toList();

    final updatedComponent = widget.component.copyWith(
      columnHeaders: headers,
      cells: cells,
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

  void _resizeColumnByDelta(int columnIndex, double delta) {
    if (widget.component.dayCount <= 0) return;

    final screenSize = MediaQuery.of(context).size;
    final baseWidth = screenSize.width / widget.component.dayCount;

    final currentWidths = List<double>.from(widget.component.columnWidths);
    while (currentWidths.length <= columnIndex) {
      currentWidths.add(0);
    }
    final currentWidth =
        currentWidths[columnIndex] > 0 ? currentWidths[columnIndex] : baseWidth;
    final newWidth = (currentWidth + delta).clamp(50.0, 600.0);
    currentWidths[columnIndex] = newWidth;

    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateTimeTableColumnWidths(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            componentId: widget.component.id,
            columnWidths: currentWidths,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveExpansionState = widget.isDetailView
        ? TimeTableExpansionState.expanded
        : widget.isKanbanView
            ? TimeTableExpansionState.collapsed
            : _expansionState;
    final rowHeaders = widget.component.rowHeaders.isNotEmpty
        ? widget.component.rowHeaders
        : List.generate(widget.component.hourCount, (i) => '$i:00');

    final columnHeaders = widget.component.columnHeaders.isNotEmpty
        ? widget.component.columnHeaders
        : ['월', '화', '수', '목', '금', '토', '일']
            .sublist(0, widget.component.dayCount);

    // 화면 크기에 기반한 기본 열 너비 계산 (전체 화면을 dayCount로 나눈 값)
    final screenSize = MediaQuery.of(context).size;
    final baseColumnWidth = widget.component.dayCount > 0
        ? screenSize.width / widget.component.dayCount
        : 80.0;

    // 열 너비 설정 (0~dayCount-1 → Table 상에서는 1~dayCount 인덱스)
    final Map<int, TableColumnWidth> columnWidths = {
      0: const IntrinsicColumnWidth(), // 첫 번째 열: 행 헤더
    };
    for (var i = 0; i < widget.component.dayCount; i++) {
      double width = baseColumnWidth;
      if (i < widget.component.columnWidths.length &&
          widget.component.columnWidths[i] > 0) {
        width = widget.component.columnWidths[i];
      }
      columnWidths[i + 1] = FixedColumnWidth(width);
    }

    // 상세 화면 모드: 카드와 헤더 없이 표만 표시
    if (widget.isDetailView) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          // 기본 그리드 형태: 모든 셀 사이에 선을 표시
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: columnWidths,
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: [
            // 헤더 행
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              children: [
                _buildHeaderCell(''),
                ...List.generate(
                  columnHeaders.length,
                  (index) => _buildHeaderCell(
                    columnHeaders[index],
                    isColumnHeader: true,
                    index: index,
                  ),
                ),
              ],
            ),
            // 데이터 행들 (모든 행 표시)
            ...List.generate(widget.component.hourCount, (row) {
              return TableRow(
                children: [
                  _buildHeaderCell(
                    rowHeaders[row],
                    isRowHeader: true,
                    index: row,
                  ),
                  ...List.generate(widget.component.dayCount, (column) {
                    return TableCell(
                      // 셀 내용에 맞춰 행 높이가 자동으로 결정되도록, top 정렬 사용
                      verticalAlignment: TableCellVerticalAlignment.top,
                      child: _buildEditableCell(row, column),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      );
    }

    // 일반 모드: 카드와 헤더 포함
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
                  child: InkWell(
                    onTap: widget.onOpenDetail,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        widget.component.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.onOpenDetail != null)
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 20),
                    tooltip: '상세 보기',
                    onPressed: widget.onOpenDetail,
                  ),
                if (!widget.isKanbanView)
                  IconButton(
                    icon: Icon(
                      _getExpansionIcon(effectiveExpansionState),
                      size: 20,
                    ),
                    tooltip: effectiveExpansionState ==
                            TimeTableExpansionState.collapsed
                        ? '펼치기'
                        : effectiveExpansionState ==
                                TimeTableExpansionState.partial
                            ? '더 펼치기'
                            : '접기',
                    onPressed: _toggleExpansion,
                  ),
                if (widget.isKanbanView)
                  IconButton(
                    icon: const Icon(Icons.unfold_more, size: 20),
                    tooltip: '칸반 보기에서는 접힌 상태로 표시돼요',
                    onPressed: null,
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
            if (effectiveExpansionState !=
                TimeTableExpansionState.collapsed) ...[
              const SizedBox(height: 12),
              // 타임테이블
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columnWidths: columnWidths,
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    // 헤더 행
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade100),
                      children: [
                        _buildHeaderCell(''),
                        ...List.generate(
                          columnHeaders.length,
                          (index) => _buildHeaderCell(
                            columnHeaders[index],
                            isColumnHeader: true,
                            index: index,
                          ),
                        ),
                      ],
                    ),
                    // 데이터 행들
                    ...List.generate(
                        _getVisibleRowCount(effectiveExpansionState), (row) {
                      return TableRow(
                        children: [
                          _buildHeaderCell(
                            rowHeaders[row],
                            isRowHeader: true,
                            index: row,
                          ),
                          ...List.generate(widget.component.dayCount, (column) {
                            return TableCell(
                              verticalAlignment: TableCellVerticalAlignment.top,
                              child: _buildEditableCell(row, column),
                            );
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

  Widget _buildHeaderCell(
    String text, {
    bool isRowHeader = false,
    bool isColumnHeader = false,
    int index = 0,
  }) {
    Future<void> handleTap() async {
      if (!isRowHeader && !isColumnHeader) return;
      final controller = TextEditingController(text: text);
      final result = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(isRowHeader ? '행 이름 수정' : '열 이름 수정'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '이름을 입력하세요',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('저장'),
            ),
          ],
        ),
      );
      if (result == null || result.isEmpty) return;

      if (isRowHeader) {
        // 행 이름 업데이트
        final headers = widget.component.rowHeaders.isNotEmpty
            ? List<String>.from(widget.component.rowHeaders)
            : List.generate(widget.component.hourCount, (i) => '$i:00');
        if (index < 0 || index >= headers.length) return;
        headers[index] = result;
        final updated = widget.component.copyWith(rowHeaders: headers);
        context.read<BulletJournalBloc>().add(
              BulletJournalEvent.updateComponentInPage(
                diaryId: widget.diaryId,
                pageId: widget.pageId,
                componentId: widget.component.id,
                updatedComponent: updated,
              ),
            );
      } else if (isColumnHeader) {
        // 열 이름 업데이트
        final headers = widget.component.columnHeaders.isNotEmpty
            ? List<String>.from(widget.component.columnHeaders)
            : ['월', '화', '수', '목', '금', '토', '일']
                .sublist(0, widget.component.dayCount);
        if (index < 0 || index >= headers.length) return;
        headers[index] = result;
        final updated = widget.component.copyWith(columnHeaders: headers);
        context.read<BulletJournalBloc>().add(
              BulletJournalEvent.updateComponentInPage(
                diaryId: widget.diaryId,
                pageId: widget.pageId,
                componentId: widget.component.id,
                updatedComponent: updated,
              ),
            );
      }
    }

    Future<void> handleReorderOrResize() async {
      if (!isRowHeader && !isColumnHeader) return;

      if (isColumnHeader) {
        final canMoveLeft = index > 0;
        final canMoveRight = index < widget.component.dayCount - 1;

        final result = await showDialog<String>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('열 조정'),
            content: const Text('원하는 작업을 선택하세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 'resize'),
                child: const Text('너비 조절'),
              ),
              if (canMoveLeft)
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'left'),
                  child: const Text('왼쪽으로 이동'),
                ),
              if (canMoveRight)
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'right'),
                  child: const Text('오른쪽으로 이동'),
                ),
            ],
          ),
        );
        if (result == null) return;

        if (result == 'resize') {
          await _showColumnResizeDialog(index);
        } else {
          final target = result == 'left' ? index - 1 : index + 1;
          _moveColumn(index, target);
        }
      } else if (isRowHeader) {
        final result = await showDialog<String>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('행 조정'),
            content: const Text('원하는 작업을 선택하세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('취소'),
              ),
              if (index > 0)
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'up'),
                  child: const Text('위로 이동'),
                ),
              if (index < widget.component.hourCount - 1)
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'down'),
                  child: const Text('아래로 이동'),
                ),
            ],
          ),
        );
        if (result == null) return;

        final target = result == 'up' ? index - 1 : index + 1;
        _moveRow(index, target);
      }
    }

    // 드래그 앤 드롭을 위한 데이터 클래스
    final dragData = _HeaderDragData(
      isRowHeader: isRowHeader,
      isColumnHeader: isColumnHeader,
      index: index,
      text: text,
    );

    return DragTarget<_HeaderDragData>(
      onWillAccept: (data) {
        if (data == null) return false;
        // 같은 타입의 헤더만 드롭 가능
        if (isRowHeader && !data.isRowHeader) return false;
        if (isColumnHeader && !data.isColumnHeader) return false;
        // 자기 자신은 드롭 불가
        if (data.index == index) return false;
        return true;
      },
      onAcceptWithDetails: (details) {
        final draggedData = details.data;
        if (isRowHeader && draggedData.isRowHeader) {
          _moveRow(draggedData.index, index);
        } else if (isColumnHeader && draggedData.isColumnHeader) {
          _moveColumn(draggedData.index, index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return LongPressDraggable<_HeaderDragData>(
          data: dragData,
          delay: const Duration(milliseconds: 300),
          feedback: Material(
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.teal, width: 2),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: Container(
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
            ),
          ),
          child: InkWell(
            onTap: handleTap,
            onLongPress: handleReorderOrResize,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isHighlighted ? Colors.teal.shade100 : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: () {
                final textWidget = Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );

                if (isColumnHeader) {
                  // 열 헤더: 오른쪽에 얇은 리사이즈 핸들 추가
                  return Row(
                    children: [
                      Expanded(child: Center(child: textWidget)),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragUpdate: (details) =>
                            _resizeColumnByDelta(index, details.delta.dx),
                        child: SizedBox(
                          width: 8,
                          child: Center(
                            child: Container(
                              width: 2,
                              height: 20,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (isRowHeader) {
                  // 행 헤더: 텍스트만 표시 (행 높이는 셀 내용에 따라 자동 결정)
                  return Center(child: textWidget);
                }

                // 일반 헤더
                return Center(child: textWidget);
              }(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditableCell(int row, int column) {
    final base = _findBaseMergedCell(row, column);
    final baseRow = base?.row ?? row;
    final key = _getCellKey(baseRow, column);
    final isMergedTail = _isMergedTailCell(row, column);
    // 병합된 영역의 아랫부분 셀에서는 편집 위젯을 그리지 않는다.
    final isEditing = _editingCellKey == key && !isMergedTail;
    final backgroundColor = _getCellBackgroundColor(row, column);

    return GestureDetector(
      onTap: () {
        setState(() {
          _editingCellKey = key;
        });
      },
      onLongPress: () async {
        // 셀 옵션: 색상 변경 / 아래 행과 병합 / 병합 해제
        final result = await showDialog<String>(
          context: context,
          builder: (dialogContext) {
            return SimpleDialog(
              title: const Text('셀 옵션'),
              children: [
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(dialogContext, 'color'),
                  child: const Text('셀 색상 변경'),
                ),
                if (!isMergedTail && row < widget.component.hourCount - 1)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(dialogContext, 'merge_down'),
                    child: const Text('아래 행과 병합'),
                  ),
                if (base != null && base.rowSpan > 1)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(dialogContext, 'unmerge'),
                    child: const Text('병합 해제'),
                  ),
              ],
            );
          },
        );

        if (result == null) return;

        if (result == 'color') {
          final selected = await showDialog<Color?>(
            context: context,
            builder: (dialogContext) {
              final candidates = <Color>[
                Colors.transparent,
                Colors.yellow.shade200,
                Colors.lightBlue.shade200,
                Colors.green.shade200,
                Colors.pink.shade200,
                Colors.purple.shade200,
              ];
              return AlertDialog(
                title: const Text('셀 색상 선택'),
                content: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: candidates.map((c) {
                    final isNone = c == Colors.transparent;
                    return InkWell(
                      onTap: () => Navigator.pop(dialogContext, c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isNone ? Colors.white : c,
                          border: Border.all(color: Colors.grey),
                        ),
                        child: isNone
                            ? const Center(
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                ),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );

          if (selected == null) return;
          final hex = selected == Colors.transparent
              ? null
              : '#${selected.value.toRadixString(16).padLeft(8, '0')}';
          _updateCell(
            row,
            column,
            _getCellContent(row, column),
            backgroundColorHex: hex,
          );
        } else if (result == 'merge_down') {
          _mergeCellDown(row, column);
        } else if (result == 'unmerge') {
          _unmergeCell(row, column);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          // 색상만 칠하고, 실제 그리드 선은 TableBorder에 맡긴다.
          color: backgroundColor,
        ),
        alignment: Alignment.topLeft,
        child: isEditing
            ? TextField(
                controller: _getController(row, column),
                autofocus: true,
                maxLines: null,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(4),
                  isDense: true,
                  filled: true,
                  fillColor: backgroundColor,
                ),
                onChanged: (value) {
                  _updateCell(
                    row,
                    column,
                    value,
                    backgroundColorHex: _getCellBackgroundColorHex(row, column),
                  );
                },
                onSubmitted: (value) {
                  setState(() {
                    _editingCellKey = null;
                  });
                },
              )
            : (isMergedTail
                ? const SizedBox.shrink()
                : Text(
                    _getCellContent(row, column),
                    style: const TextStyle(fontSize: 12),
                  )),
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
