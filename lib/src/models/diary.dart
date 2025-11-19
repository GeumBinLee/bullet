import 'package:freezed_annotation/freezed_annotation.dart';

import 'bullet_entry.dart';
import 'diary_page.dart';

part 'diary.freezed.dart';

enum DiaryBackgroundTheme {
  grid, // 모눈
  plain, // 무지
  lined, // 줄글
}

@freezed
class Diary with _$Diary {
  const factory Diary({
    required String id,
    required String name,
    required String description,
    @Default(<BulletEntry>[]) List<BulletEntry> entries,
    @Default(<DiaryPage>[]) List<DiaryPage> pages,
    required DateTime createdAt,
    @Default(0xFF4CAF50) int colorValue,
    String? password,
    @Default(DiaryBackgroundTheme.plain) DiaryBackgroundTheme backgroundTheme,
    String? currentPageId, // 현재 선택된 페이지 ID
  }) = _Diary;
}

