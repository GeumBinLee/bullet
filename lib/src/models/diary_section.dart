import 'package:freezed_annotation/freezed_annotation.dart';

part 'diary_section.freezed.dart';

@freezed
class DiarySection with _$DiarySection {
  const factory DiarySection({
    required String id,
    required String name,
    required DateTime createdAt,
    @Default(0) int order,
  }) = _DiarySection;
}

