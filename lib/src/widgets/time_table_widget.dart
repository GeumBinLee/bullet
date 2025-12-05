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

  TimeTableCell _getCell(int row, int column) {
    return widget.component.cells.firstWhere(
      (c) => c.row == row && c.column == column,
      orElse: () => TimeTableCell(row: row, column: column, content: ''),
    );
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
    final key = _getCellKey(row, column);
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
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateTimeTableCell(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            componentId: widget.component.id,
            row: row,
            column: column,
            content: content,
            backgroundColorHex: backgroundColorHex,
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

  void _handleColumnResize(int columnIndex, double delta) {
    final currentWidths = List<double>.from(widget.component.columnWidths);
    // 리스트 크기가 충분하지 않으면 확장
    while (currentWidths.length <= columnIndex) {
      currentWidths.add(0);
    }
    final currentWidth = currentWidths[columnIndex] > 0
        ? currentWidths[columnIndex]
        : 100.0; // 기본 너비
    final newWidth = (currentWidth + delta).clamp(50.0, 500.0);
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

  void _handleRowResize(int rowIndex, double delta) {
    final currentHeights = List<double>.from(widget.component.rowHeights);
    // 리스트 크기가 충분하지 않으면 확장
    while (currentHeights.length <= rowIndex) {
      currentHeights.add(0);
    }
    final currentHeight =
        currentHeights[rowIndex] > 0 ? currentHeights[rowIndex] : 40.0; // 기본 높이
    final newHeight = (currentHeight + delta).clamp(30.0, 300.0);
    currentHeights[rowIndex] = newHeight;
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateTimeTableRowHeights(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            componentId: widget.component.id,
            rowHeights: currentHeights,
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

    // 열 너비와 행 높이 설정
    final columnWidths = <int, TableColumnWidth>{};
    for (int i = 0; i < widget.component.dayCount + 1; i++) {
      // 첫 번째 열은 행 헤더
      if (i == 0) {
        columnWidths[i] = const IntrinsicColumnWidth();
      } else {
        final columnIndex = i - 1;
        if (columnIndex < widget.component.columnWidths.length &&
            widget.component.columnWidths[columnIndex] > 0) {
          columnWidths[i] =
              FixedColumnWidth(widget.component.columnWidths[columnIndex]);
        } else {
          columnWidths[i] = const IntrinsicColumnWidth();
        }
      }
    }

    // 상세 화면 모드: 카드와 헤더 없이 표만 표시
    if (widget.isDetailView) {
      return SingleChildScrollView(
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
                      verticalAlignment: TableCellVerticalAlignment.fill,
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
                              verticalAlignment:
                                  TableCellVerticalAlignment.fill,
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

    Future<void> handleReorder() async {
      if (!isRowHeader && !isColumnHeader) return;

      // 열의 경우: 왼쪽/오른쪽 이동, 끝단 체크
      if (isColumnHeader) {
        final canMoveLeft = index > 0;
        final canMoveRight = index < widget.component.dayCount - 1;

        if (!canMoveLeft && !canMoveRight) return; // 양쪽 끝이면 이동 불가

        final result = await showDialog<String>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('열 위치 조정'),
            content: const Text('위치 조정을 선택하세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('취소'),
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

        final target = result == 'left' ? index - 1 : index + 1;
        _moveColumn(index, target);
      } else if (isRowHeader) {
        // 행의 경우: 위/아래 이동 (기존 로직 유지)
        final canMoveUp = index > 0;
        final canMoveDown = index < widget.component.hourCount - 1;

        if (!canMoveUp && !canMoveDown) return; // 양쪽 끝이면 이동 불가

        final result = await showDialog<String>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('행 위치 조정'),
            content: const Text('위치 조정을 선택하세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('취소'),
              ),
              if (canMoveUp)
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, 'up'),
                  child: const Text('위로 이동'),
                ),
              if (canMoveDown)
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
          child: Stack(
            children: [
              InkWell(
                onTap: handleTap,
                onLongPress: handleReorder,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? Colors.teal.shade100
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
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
              // 열 헤더의 경우 오른쪽 경계에 리사이저
              if (isColumnHeader)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      _handleColumnResize(index, details.delta.dx);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeColumn,
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Container(
                            width: 2,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // 행 헤더의 경우 아래쪽 경계에 리사이저
              if (isRowHeader)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 4,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      _handleRowResize(index, details.delta.dy);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeRow,
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Container(
                            height: 2,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditableCell(int row, int column) {
    final key = _getCellKey(row, column);
    final isEditing = _editingCellKey == key;
    final backgroundColor = _getCellBackgroundColor(row, column);

    return GestureDetector(
      onTap: () {
        setState(() {
          _editingCellKey = key;
        });
      },
      onLongPress: () async {
        // 셀 배경색 선택
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
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        constraints: BoxConstraints(
          minHeight: row < widget.component.rowHeights.length &&
                  widget.component.rowHeights[row] > 0
              ? widget.component.rowHeights[row]
              : 40.0,
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
            : Text(
                _getCellContent(row, column),
                style: const TextStyle(fontSize: 12),
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
