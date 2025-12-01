import 'package:freezed_annotation/freezed_annotation.dart';

import 'bullet_entry.dart';
import 'diary_section.dart';
import 'page_component.dart';

part 'diary_page.freezed.dart';

@freezed
class DiaryPage with _$DiaryPage {
  const factory DiaryPage({
    required String id,
    String? name, // 페이지 이름 (선택적)
    @Default(<BulletEntry>[]) List<BulletEntry> entries,
    @Default(<DiarySection>[]) List<DiarySection> sections,
    @Default(<PageComponent>[])
    List<PageComponent> components, // 페이지 컴포넌트 (섹션, 타임테이블 등)
    @Default(<String>[]) List<String> layoutOrder, // 엔트리/컴포넌트 통합 순서
    required DateTime createdAt,
    @Default(false) bool isFavorite,
    @Default(false) bool isIndexPage, // 인덱스 페이지 여부
    int? order, // 페이지 순서 (선택적)
  }) = _DiaryPage;
}
