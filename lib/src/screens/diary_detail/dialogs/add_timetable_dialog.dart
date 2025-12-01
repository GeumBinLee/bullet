import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/page_component.dart';

class AddTimeTableDialog extends StatefulWidget {
  const AddTimeTableDialog({
    super.key,
    required this.diaryId,
    required this.pageId,
  });

  final String diaryId;
  final String pageId;

  @override
  State<AddTimeTableDialog> createState() => _AddTimeTableDialogState();
}

class _AddTimeTableDialogState extends State<AddTimeTableDialog> {
  final _nameController = TextEditingController(text: '시간표');
  int _hourCount = 24;
  int _dayCount = 7;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addTimeTable() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    // 기본 행/열 헤더 생성
    final rowHeaders = List.generate(_hourCount, (i) => '$i:00');
    final columnHeaders =
        ['월', '화', '수', '목', '금', '토', '일'].sublist(0, _dayCount);

    final component = PageComponent.timeTable(
      id: 'timetable-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      createdAt: DateTime.now(),
      hourCount: _hourCount,
      dayCount: _dayCount,
      rowHeaders: rowHeaders,
      columnHeaders: columnHeaders,
      cells: [],
      expansionState: 'partial', // 기본값: 3줄 미리보기
    );

    context.read<BulletJournalBloc>().add(
          BulletJournalEvent.addComponentToPage(
            diaryId: widget.diaryId,
            pageId: widget.pageId,
            component: component,
          ),
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('타임테이블 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '타임테이블 이름',
                hintText: '예: 주간 시간표',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            const Text(
              '시간 수',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _hourCount.toDouble(),
              min: 1,
              max: 48,
              divisions: 47,
              label: '$_hourCount시간',
              onChanged: (value) {
                setState(() {
                  _hourCount = value.toInt();
                });
              },
            ),
            Text('$_hourCount시간',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            const Text(
              '요일 수',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _dayCount.toDouble(),
              min: 1,
              max: 7,
              divisions: 6,
              label: '$_dayCount일',
              onChanged: (value) {
                setState(() {
                  _dayCount = value.toInt();
                });
              },
            ),
            Text('$_dayCount일', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _addTimeTable,
          child: const Text('추가'),
        ),
      ],
    );
  }
}

/// 타임테이블 추가 다이얼로그 표시 함수
void showAddTimeTableDialog(
  BuildContext context,
  String diaryId,
  String pageId,
) {
  showDialog(
    context: context,
    builder: (context) => AddTimeTableDialog(
      diaryId: diaryId,
      pageId: pageId,
    ),
  );
}
