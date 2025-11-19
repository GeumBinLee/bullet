import 'package:flutter/material.dart';

/// Shows a dialog asking if the user wants to discard unsaved changes
Future<bool> showUnsavedChangesDialog(BuildContext context) async {
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

