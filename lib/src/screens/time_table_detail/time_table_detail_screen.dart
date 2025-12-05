import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/bullet_journal_bloc.dart';
import '../../models/diary.dart';
import '../../models/diary_page.dart';
import '../../models/page_component.dart';
import '../../widgets/time_table_widget.dart';

class TimeTableDetailArgs {
  const TimeTableDetailArgs({
    required this.diaryId,
    required this.pageId,
    required this.component,
  });

  final String diaryId;
  final String pageId;
  final TimeTableComponent component;
}

class TimeTableDetailScreen extends StatelessWidget {
  const TimeTableDetailScreen({
    super.key,
    required this.args,
  });

  final TimeTableDetailArgs args;

  TimeTableComponent? _findLatestComponent(BulletJournalState state) {
    for (final Diary diary in state.diaries) {
      if (diary.id != args.diaryId) continue;
      for (final DiaryPage page in diary.pages) {
        if (page.id != args.pageId) continue;
        for (final PageComponent component in page.components) {
          final result = component.maybeMap(
            timeTable: (timeTable) =>
                timeTable.id == args.component.id ? timeTable : null,
            orElse: () => null,
          );
          if (result != null) {
            return result;
          }
        }
      }
    }
    return null;
  }

  void _addRow(BuildContext context, TimeTableComponent component) {
    final newRowHeaders = [
      ...component.rowHeaders,
      '${component.hourCount}:00'
    ];
    final updatedComponent = component.copyWith(
      hourCount: component.hourCount + 1,
      rowHeaders: newRowHeaders,
    );
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateComponentInPage(
            diaryId: args.diaryId,
            pageId: args.pageId,
            componentId: component.id,
            updatedComponent: updatedComponent,
          ),
        );
  }

  void _removeRow(BuildContext context, TimeTableComponent component) {
    if (component.hourCount <= 1) return;
    final newRowHeaders = component.rowHeaders
        .sublist(0, component.rowHeaders.length - 1);
    final newCells = component.cells
        .where((cell) => cell.row < component.hourCount - 1)
        .toList();
    final updatedComponent = component.copyWith(
      hourCount: component.hourCount - 1,
      rowHeaders: newRowHeaders,
      cells: newCells,
    );
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateComponentInPage(
            diaryId: args.diaryId,
            pageId: args.pageId,
            componentId: component.id,
            updatedComponent: updatedComponent,
          ),
        );
  }

  void _addColumn(BuildContext context, TimeTableComponent component) {
    final newColumnHeaders = [
      ...component.columnHeaders,
      '열 ${component.dayCount + 1}'
    ];
    final updatedComponent = component.copyWith(
      dayCount: component.dayCount + 1,
      columnHeaders: newColumnHeaders,
    );
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateComponentInPage(
            diaryId: args.diaryId,
            pageId: args.pageId,
            componentId: component.id,
            updatedComponent: updatedComponent,
          ),
        );
  }

  void _removeColumn(BuildContext context, TimeTableComponent component) {
    if (component.dayCount <= 1) return;
    final newColumnHeaders = component.columnHeaders
        .sublist(0, component.columnHeaders.length - 1);
    final newCells = component.cells
        .where((cell) => cell.column < component.dayCount - 1)
        .toList();
    final updatedComponent = component.copyWith(
      dayCount: component.dayCount - 1,
      columnHeaders: newColumnHeaders,
      cells: newCells,
    );
    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.updateComponentInPage(
            diaryId: args.diaryId,
            pageId: args.pageId,
            componentId: component.id,
            updatedComponent: updatedComponent,
          ),
        );
  }

  void _showDeleteConfirmation(BuildContext context) {
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
                      diaryId: args.diaryId,
                      pageId: args.pageId,
                      componentId: args.component.id,
                    ),
                  );
              Navigator.pop(dialogContext);
              if (context.mounted) {
                context.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulletJournalBloc, BulletJournalState>(
      builder: (context, state) {
        final latestComponent =
            _findLatestComponent(state) ?? args.component;

        return Scaffold(
          appBar: AppBar(
            title: Text(latestComponent.name),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
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
                        Text('타임테이블 삭제',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'add_row':
                      _addRow(context, latestComponent);
                      break;
                    case 'remove_row':
                      _removeRow(context, latestComponent);
                      break;
                    case 'add_column':
                      _addColumn(context, latestComponent);
                      break;
                    case 'remove_column':
                      _removeColumn(context, latestComponent);
                      break;
                    case 'delete':
                      _showDeleteConfirmation(context);
                      break;
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: TimeTableWidget(
              diaryId: args.diaryId,
              pageId: args.pageId,
              component: latestComponent,
              isDetailView: true,
            ),
          ),
        );
      },
    );
  }
}


