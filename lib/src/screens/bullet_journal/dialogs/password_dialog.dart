import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/diary.dart';

class PasswordDialog {
  static void show(BuildContext context, Diary diary) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${diary.name} 잠금 해제'),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: '비밀번호',
            hintText: '비밀번호를 입력하세요',
          ),
          obscureText: true,
          autofocus: true,
          onSubmitted: (value) {
            if (value == diary.password) {
              context.pop();
              context.push('/diary/${diary.id}');
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다')));
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              if (passwordController.text == diary.password) {
                context.pop();
                context.push('/diary/${diary.id}');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('비밀번호가 일치하지 않습니다')),
                );
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

