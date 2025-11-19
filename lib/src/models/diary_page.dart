import 'package:freezed_annotation/freezed_annotation.dart';

import 'bullet_entry.dart';
import 'diary_section.dart';

part 'diary_page.freezed.dart';

@freezed
class DiaryPage with _$DiaryPage {
  const factory DiaryPage({
    required String id,
    required String name,
    @Default(<BulletEntry>[]) List<BulletEntry> entries,
    @Default(<DiarySection>[]) List<DiarySection> sections,
    required DateTime createdAt,
    @Default(false) bool isFavorite,
    int? order, // 페이지 순서 (선택적)
  }) = _DiaryPage;
}

