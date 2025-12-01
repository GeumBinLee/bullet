import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_component.freezed.dart';

/// 타임테이블의 셀 데이터
@freezed
class TimeTableCell with _$TimeTableCell {
  const factory TimeTableCell({
    required int row,
    required int column,
    @Default('') String content,
  }) = _TimeTableCell;
}

/// 페이지에 들어갈 수 있는 컴포넌트의 기본 타입
@freezed
class PageComponent with _$PageComponent {
  /// 섹션 컴포넌트 (기존 DiarySection과 호환)
  const factory PageComponent.section({
    required String id,
    required String name,
    required DateTime createdAt,
    @Default(0) int order,
  }) = SectionComponent;

  /// 타임테이블 컴포넌트
  const factory PageComponent.timeTable({
    required String id,
    required String name,
    required DateTime createdAt,
    @Default(0) int order,
    @Default(24) int hourCount, // 시간 수 (기본 24시간)
    @Default(7) int dayCount, // 요일 수 (기본 7일)
    @Default(<TimeTableCell>[]) List<TimeTableCell> cells,
    @Default(<String>[]) List<String> rowHeaders, // 행 헤더 (시간대)
    @Default(<String>[]) List<String> columnHeaders, // 열 헤더 (요일 등)
    @Default('partial') String expansionState, // 'collapsed', 'partial', 'expanded'
  }) = TimeTableComponent;
}

