import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/bullet_journal_screen.dart';
import '../screens/diary_detail_screen.dart';
import '../screens/entry_note_detail_screen.dart';
import '../models/bullet_entry.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BulletJournalScreen(),
      routes: [
        GoRoute(
          path: 'diary/:diaryId',
          builder: (context, state) {
            final diaryId = state.pathParameters['diaryId']!;
            return DiaryDetailScreen(diaryId: diaryId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/entry-note/:entryId',
      builder: (context, state) {
        final entry = state.extra as BulletEntry?;
        if (entry == null) {
          return const Scaffold(
            body: Center(child: Text('엔트리를 찾을 수 없습니다')),
          );
        }
        return EntryNoteDetailScreen(entry: entry);
      },
    ),
  ],
);

