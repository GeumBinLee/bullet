// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_component.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TimeTableCell {
  int get row => throw _privateConstructorUsedError;
  int get column => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;

  /// Create a copy of TimeTableCell
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeTableCellCopyWith<TimeTableCell> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeTableCellCopyWith<$Res> {
  factory $TimeTableCellCopyWith(
          TimeTableCell value, $Res Function(TimeTableCell) then) =
      _$TimeTableCellCopyWithImpl<$Res, TimeTableCell>;
  @useResult
  $Res call({int row, int column, String content});
}

/// @nodoc
class _$TimeTableCellCopyWithImpl<$Res, $Val extends TimeTableCell>
    implements $TimeTableCellCopyWith<$Res> {
  _$TimeTableCellCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeTableCell
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? row = null,
    Object? column = null,
    Object? content = null,
  }) {
    return _then(_value.copyWith(
      row: null == row
          ? _value.row
          : row // ignore: cast_nullable_to_non_nullable
              as int,
      column: null == column
          ? _value.column
          : column // ignore: cast_nullable_to_non_nullable
              as int,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeTableCellImplCopyWith<$Res>
    implements $TimeTableCellCopyWith<$Res> {
  factory _$$TimeTableCellImplCopyWith(
          _$TimeTableCellImpl value, $Res Function(_$TimeTableCellImpl) then) =
      __$$TimeTableCellImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int row, int column, String content});
}

/// @nodoc
class __$$TimeTableCellImplCopyWithImpl<$Res>
    extends _$TimeTableCellCopyWithImpl<$Res, _$TimeTableCellImpl>
    implements _$$TimeTableCellImplCopyWith<$Res> {
  __$$TimeTableCellImplCopyWithImpl(
      _$TimeTableCellImpl _value, $Res Function(_$TimeTableCellImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeTableCell
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? row = null,
    Object? column = null,
    Object? content = null,
  }) {
    return _then(_$TimeTableCellImpl(
      row: null == row
          ? _value.row
          : row // ignore: cast_nullable_to_non_nullable
              as int,
      column: null == column
          ? _value.column
          : column // ignore: cast_nullable_to_non_nullable
              as int,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TimeTableCellImpl implements _TimeTableCell {
  const _$TimeTableCellImpl(
      {required this.row, required this.column, this.content = ''});

  @override
  final int row;
  @override
  final int column;
  @override
  @JsonKey()
  final String content;

  @override
  String toString() {
    return 'TimeTableCell(row: $row, column: $column, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeTableCellImpl &&
            (identical(other.row, row) || other.row == row) &&
            (identical(other.column, column) || other.column == column) &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, row, column, content);

  /// Create a copy of TimeTableCell
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeTableCellImplCopyWith<_$TimeTableCellImpl> get copyWith =>
      __$$TimeTableCellImplCopyWithImpl<_$TimeTableCellImpl>(this, _$identity);
}

abstract class _TimeTableCell implements TimeTableCell {
  const factory _TimeTableCell(
      {required final int row,
      required final int column,
      final String content}) = _$TimeTableCellImpl;

  @override
  int get row;
  @override
  int get column;
  @override
  String get content;

  /// Create a copy of TimeTableCell
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeTableCellImplCopyWith<_$TimeTableCellImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PageComponent {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id, String name, DateTime createdAt, int order)
        section,
    required TResult Function(
            String id,
            String name,
            DateTime createdAt,
            int order,
            int hourCount,
            int dayCount,
            List<TimeTableCell> cells,
            List<String> rowHeaders,
            List<String> columnHeaders,
            String expansionState)
        timeTable,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String name, DateTime createdAt, int order)?
        section,
    TResult? Function(
            String id,
            String name,
            DateTime createdAt,
            int order,
            int hourCount,
            int dayCount,
            List<TimeTableCell> cells,
            List<String> rowHeaders,
            List<String> columnHeaders,
            String expansionState)?
        timeTable,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String name, DateTime createdAt, int order)?
        section,
    TResult Function(
            String id,
            String name,
            DateTime createdAt,
            int order,
            int hourCount,
            int dayCount,
            List<TimeTableCell> cells,
            List<String> rowHeaders,
            List<String> columnHeaders,
            String expansionState)?
        timeTable,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SectionComponent value) section,
    required TResult Function(TimeTableComponent value) timeTable,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SectionComponent value)? section,
    TResult? Function(TimeTableComponent value)? timeTable,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SectionComponent value)? section,
    TResult Function(TimeTableComponent value)? timeTable,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of PageComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PageComponentCopyWith<PageComponent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageComponentCopyWith<$Res> {
  factory $PageComponentCopyWith(
          PageComponent value, $Res Function(PageComponent) then) =
      _$PageComponentCopyWithImpl<$Res, PageComponent>;
  @useResult
  $Res call({String id, String name, DateTime createdAt, int order});
}

/// @nodoc
class _$PageComponentCopyWithImpl<$Res, $Val extends PageComponent>
    implements $PageComponentCopyWith<$Res> {
  _$PageComponentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PageComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? order = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SectionComponentImplCopyWith<$Res>
    implements $PageComponentCopyWith<$Res> {
  factory _$$SectionComponentImplCopyWith(_$SectionComponentImpl value,
          $Res Function(_$SectionComponentImpl) then) =
      __$$SectionComponentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, DateTime createdAt, int order});
}

/// @nodoc
class __$$SectionComponentImplCopyWithImpl<$Res>
    extends _$PageComponentCopyWithImpl<$Res, _$SectionComponentImpl>
    implements _$$SectionComponentImplCopyWith<$Res> {
  __$$SectionComponentImplCopyWithImpl(_$SectionComponentImpl _value,
      $Res Function(_$SectionComponentImpl) _then)
      : super(_value, _then);

  /// Create a copy of PageComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? order = null,
  }) {
    return _then(_$SectionComponentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SectionComponentImpl implements SectionComponent {
  const _$SectionComponentImpl(
      {required this.id,
      required this.name,
      required this.createdAt,
      this.order = 0});

  @override
  final String id;
  @override
  final String name;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int order;

  @override
  String toString() {
    return 'PageComponent.section(id: $id, name: $name, createdAt: $createdAt, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SectionComponentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, createdAt, order);

  /// Create a copy of PageComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SectionComponentImplCopyWith<_$SectionComponentImpl> get copyWith =>
      __$$SectionComponentImplCopyWithImpl<_$SectionComponentImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id, String name, DateTime createdAt, int order)
        section,
    required TResult Function(
            String id,
            String name,
            DateTime createdAt,
            int order,
            int hourCount,
            int dayCount,
            List<TimeTableCell> cells,
            List<String> rowHeaders,
            List<String> columnHeaders,
            String expansionState)
        timeTable,
  }) {
    return section(id, name, createdAt, order);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String name, DateTime createdAt, int order)?
        section,
    TResult? Function(
            String id,
            String name,
            DateTime createdAt,
            int order,
            int hourCount,
            int dayCount,
            List<TimeTableCell> cells,
            List<String> rowHeaders,
            List<String> columnHeaders,
            String expansionState)?
        timeTable,
  }) {
    return section?.call(id, name, createdAt, order);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String name, DateTime createdAt, int order)?
        section,
    TResult Function(
            String id,
            String name,
            DateTime createdAt,
            int order,
            int hourCount,
            int dayCount,
            List<TimeTableCell> cells,
            List<String> rowHeaders,
            List<String> columnHeaders,
            String expansionState)?
        timeTable,
    required TResult orElse(),
  }) {
    if (section != null) {
      return section(id, name, createdAt, order);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SectionComponent value) section,
    required TResult Function(TimeTableComponent value) timeTable,
  }) {
    return section(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SectionComponent value)? section,
    TResult? Function(TimeTableComponent value)? timeTable,
  }) {
    return section?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SectionComponent value)? section,
    TResult Function(TimeTableComponent value)? timeTable,
    required TResult orElse(),
  }) {
    if (section != null) {
      return section(this);
    }
    return orElse();
  }
}

abstract class SectionComponent implements PageComponent {
  const factory SectionComponent(
      {required final String id,
      required final String name,
      required final DateTime createdAt,
      final int order}) = _$SectionComponentImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  DateTime get createdAt;
  @override
  int get order;

  /// Create a copy of PageComponent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SectionComponentImplCopyWith<_$SectionComponentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TimeTableComponentImplCopyWith<$Res>
    implements $PageComponentCopyWith<$Res> {
  factory _$$TimeTableComponentImplCopyWith(_$TimeTableComponentImpl value,
          $Res Function(_$TimeTableComponentImpl) then) =
      __$$TimeTableComponentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      DateTime createdAt,
      int order,
      int hourCount,
      int dayCount,
      List<TimeTableCell> cells,
      List<String> rowHeaders,
      List<String> columnHeaders,
      String expansionState});
}

/// @nodoc
class __$$TimeTableComponentImplCopyWithImpl<$Res>
    extends _$PageComponentCopyWithImpl<$Res, _$TimeTableComponentImpl>
    implements _$$TimeTableComponentImplCopyWith<$Res> {
  __$$TimeTableComponentImplCopyWithImpl(_$TimeTableComponentImpl _value,
      $Res Function(_$TimeTableComponentImpl) _then)
      : super(_value, _then);

  /// Create a copy of PageComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? order = null,
    Object? hourCount = null,
    Object? dayCount = null,
    Object? cells = null,
    Object? rowHeaders = null,
    Object? columnHeaders = null,
    Object? expansionState = null,
  }) {
    return _then(_$TimeTableComponentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      hourCount: null == hourCount
          ? _value.hourCount
          : hourCount // ignore: cast_nullable_to_non_nullable
              as int,
      dayCount: null == dayCount
          ? _value.dayCount
          : dayCount // ignore: cast_nullable_to_non_nullable
              as int,
      cells: null == cells
          ? _value._cells
          : cells // ignore: cast_nullable_to_non_nullable
              as List<TimeTableCell>,
      rowHeaders: null == rowHeaders
          ? _value._rowHeaders
          : rowHeaders // ignore: cast_nullable_to_non_nullable
              as List<String>,
      columnHeaders: null == columnHeaders
          ? _value._columnHeaders
          : columnHeaders // ignore: cast_nullable_to_non_nullable
              as List<String>,
      expansionState: null == expansionState
          ? _value.expansionState
          : expansionState // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TimeTableComponentImpl implements TimeTableComponent {
  const _$TimeTableComponentImpl(
      {required this.id,
      required this.name,
      required this.createdAt,
      this.order = 0,
      this.hourCount = 24,
      this.dayCount = 7,
      final List<TimeTableCell> cells = const <TimeTableCell>[],
      final List<String> rowHeaders = const <String>[],
      final List<String> columnHeaders = const <String>[],
      this.expansionState = 'partial'})
      : _cells = cells,
        _rowHeaders = rowHeaders,
        _columnHeaders = columnHeaders;

  @override
  final String id;
  @override
  final String name;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int order;
  @override
  @JsonKey()
  final int hourCount;
// 시간 수 (기본 24시간)
  @override
  @JsonKey()
  final int dayCount;
// 요일 수 (기본 7일)
  final List<TimeTableCell> _cells;
// 요일 수 (기본 7일)
  @override
  @JsonKey()
  List<TimeTableCell> get cells {
    if (_cells is EqualUnmodifiableListView) return _cells;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cells);
  }

  final List<String> _rowHeaders;
  @override
  @JsonKey()
  List<String> get rowHeaders {
    if (_rowHeaders is EqualUnmodifiableListView) return _rowHeaders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rowHeaders);
  }

// 행 헤더 (시간대)
  final List<String> _columnHeaders;
// 행 헤더 (시간대)
  @override
  @JsonKey()
  List<String> get columnHeaders {
    if (_columnHeaders is EqualUnmodifiableListView) return _columnHeaders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_columnHeaders);
  }

// 열 헤더 (요일 등)
  @override
  @JsonKey()
  final String expansionState;

  @override
  String toString() {
    return 'PageComponent.timeTable(id: $id, name: $name, createdAt: $createdAt, order: $order, hourCount: $hourCount, dayCount: $dayCount, cells: $cells, rowHeaders: $rowHeaders, columnHeaders: $columnHeaders, expansionState: $expansionState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeTableComponentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.hourCount, hourCount) ||
                other.hourCount == hourCount) &&
            (identical(other.dayCount, dayCount) ||
                other.dayCount == dayCount) &&
            const DeepCollectionEquality().equals(other._cells, _cells) &&
            const DeepCollectionEquality()
                .equals(other._rowHeaders, _rowHeaders) &&
            const DeepCollectionEquality()
                .equals(other._columnHeaders, _columnHeaders) &&
            (identical(other.expansionState, expansionState) ||
                other.expansionState == expansionState));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      createdAt,
      order,
      hourCount,
      dayCount,
      const DeepCollectionEquality().hash(_cells),
      const DeepCollectionEquality().hash(_rowHeaders),
      const DeepCollectionEquality().hash(_columnHeaders),
      expansionState);

  /// Create a copy of PageComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeTableComponentImplCopyWith<_$TimeTableComponentImpl> get copyWith =>
      __$$TimeTableComponentImplCopyWithImpl<_$TimeTableComponentImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id, String name, DateTime createdAt, int order)
        section,
    required TResult Function(
            String id,
            String name,
            DateTime createdAt,
            int order,
            int hourCount,
            int dayCount,
            List<TimeTableCell> cells,
            List<String> rowHeaders,
            List<String> columnHeaders,
            String expansionState)
        timeTable,
  }) {
    return timeTable(id, name, createdAt, order, hourCount, dayCount, cells,
        rowHeaders, columnHeaders, expansionState);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String name, DateTime createdAt, int order)?
        section,
    TResult? Function(
            String id,
            String name,
            DateTime createdAt,
            int order,
            int hourCount,
            int dayCount,
            List<TimeTableCell> cells,
            List<String> rowHeaders,
            List<String> columnHeaders,
            String expansionState)?
        timeTable,
  }) {
    return timeTable?.call(id, name, createdAt, order, hourCount, dayCount,
        cells, rowHeaders, columnHeaders, expansionState);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String name, DateTime createdAt, int order)?
        section,
    TResult Function(
            String id,
            String name,
            DateTime createdAt,
            int order,
            int hourCount,
            int dayCount,
            List<TimeTableCell> cells,
            List<String> rowHeaders,
            List<String> columnHeaders,
            String expansionState)?
        timeTable,
    required TResult orElse(),
  }) {
    if (timeTable != null) {
      return timeTable(id, name, createdAt, order, hourCount, dayCount, cells,
          rowHeaders, columnHeaders, expansionState);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SectionComponent value) section,
    required TResult Function(TimeTableComponent value) timeTable,
  }) {
    return timeTable(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SectionComponent value)? section,
    TResult? Function(TimeTableComponent value)? timeTable,
  }) {
    return timeTable?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SectionComponent value)? section,
    TResult Function(TimeTableComponent value)? timeTable,
    required TResult orElse(),
  }) {
    if (timeTable != null) {
      return timeTable(this);
    }
    return orElse();
  }
}

abstract class TimeTableComponent implements PageComponent {
  const factory TimeTableComponent(
      {required final String id,
      required final String name,
      required final DateTime createdAt,
      final int order,
      final int hourCount,
      final int dayCount,
      final List<TimeTableCell> cells,
      final List<String> rowHeaders,
      final List<String> columnHeaders,
      final String expansionState}) = _$TimeTableComponentImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  DateTime get createdAt;
  @override
  int get order;
  int get hourCount; // 시간 수 (기본 24시간)
  int get dayCount; // 요일 수 (기본 7일)
  List<TimeTableCell> get cells;
  List<String> get rowHeaders; // 행 헤더 (시간대)
  List<String> get columnHeaders; // 열 헤더 (요일 등)
  String get expansionState;

  /// Create a copy of PageComponent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeTableComponentImplCopyWith<_$TimeTableComponentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
