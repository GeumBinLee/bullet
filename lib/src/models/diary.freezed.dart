// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Diary {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<BulletEntry> get entries => throw _privateConstructorUsedError;
  List<DiaryPage> get pages => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get colorValue => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  DiaryBackgroundTheme get backgroundTheme =>
      throw _privateConstructorUsedError;
  String? get currentPageId => throw _privateConstructorUsedError;

  /// Create a copy of Diary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiaryCopyWith<Diary> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryCopyWith<$Res> {
  factory $DiaryCopyWith(Diary value, $Res Function(Diary) then) =
      _$DiaryCopyWithImpl<$Res, Diary>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      List<BulletEntry> entries,
      List<DiaryPage> pages,
      DateTime createdAt,
      int colorValue,
      String? password,
      DiaryBackgroundTheme backgroundTheme,
      String? currentPageId});
}

/// @nodoc
class _$DiaryCopyWithImpl<$Res, $Val extends Diary>
    implements $DiaryCopyWith<$Res> {
  _$DiaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Diary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? entries = null,
    Object? pages = null,
    Object? createdAt = null,
    Object? colorValue = null,
    Object? password = freezed,
    Object? backgroundTheme = null,
    Object? currentPageId = freezed,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<BulletEntry>,
      pages: null == pages
          ? _value.pages
          : pages // ignore: cast_nullable_to_non_nullable
              as List<DiaryPage>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      colorValue: null == colorValue
          ? _value.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundTheme: null == backgroundTheme
          ? _value.backgroundTheme
          : backgroundTheme // ignore: cast_nullable_to_non_nullable
              as DiaryBackgroundTheme,
      currentPageId: freezed == currentPageId
          ? _value.currentPageId
          : currentPageId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiaryImplCopyWith<$Res> implements $DiaryCopyWith<$Res> {
  factory _$$DiaryImplCopyWith(
          _$DiaryImpl value, $Res Function(_$DiaryImpl) then) =
      __$$DiaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      List<BulletEntry> entries,
      List<DiaryPage> pages,
      DateTime createdAt,
      int colorValue,
      String? password,
      DiaryBackgroundTheme backgroundTheme,
      String? currentPageId});
}

/// @nodoc
class __$$DiaryImplCopyWithImpl<$Res>
    extends _$DiaryCopyWithImpl<$Res, _$DiaryImpl>
    implements _$$DiaryImplCopyWith<$Res> {
  __$$DiaryImplCopyWithImpl(
      _$DiaryImpl _value, $Res Function(_$DiaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of Diary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? entries = null,
    Object? pages = null,
    Object? createdAt = null,
    Object? colorValue = null,
    Object? password = freezed,
    Object? backgroundTheme = null,
    Object? currentPageId = freezed,
  }) {
    return _then(_$DiaryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      entries: null == entries
          ? _value._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<BulletEntry>,
      pages: null == pages
          ? _value._pages
          : pages // ignore: cast_nullable_to_non_nullable
              as List<DiaryPage>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      colorValue: null == colorValue
          ? _value.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundTheme: null == backgroundTheme
          ? _value.backgroundTheme
          : backgroundTheme // ignore: cast_nullable_to_non_nullable
              as DiaryBackgroundTheme,
      currentPageId: freezed == currentPageId
          ? _value.currentPageId
          : currentPageId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$DiaryImpl implements _Diary {
  const _$DiaryImpl(
      {required this.id,
      required this.name,
      required this.description,
      final List<BulletEntry> entries = const <BulletEntry>[],
      final List<DiaryPage> pages = const <DiaryPage>[],
      required this.createdAt,
      this.colorValue = 0xFF4CAF50,
      this.password,
      this.backgroundTheme = DiaryBackgroundTheme.plain,
      this.currentPageId})
      : _entries = entries,
        _pages = pages;

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  final List<BulletEntry> _entries;
  @override
  @JsonKey()
  List<BulletEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  final List<DiaryPage> _pages;
  @override
  @JsonKey()
  List<DiaryPage> get pages {
    if (_pages is EqualUnmodifiableListView) return _pages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pages);
  }

  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int colorValue;
  @override
  final String? password;
  @override
  @JsonKey()
  final DiaryBackgroundTheme backgroundTheme;
  @override
  final String? currentPageId;

  @override
  String toString() {
    return 'Diary(id: $id, name: $name, description: $description, entries: $entries, pages: $pages, createdAt: $createdAt, colorValue: $colorValue, password: $password, backgroundTheme: $backgroundTheme, currentPageId: $currentPageId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            const DeepCollectionEquality().equals(other._pages, _pages) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.backgroundTheme, backgroundTheme) ||
                other.backgroundTheme == backgroundTheme) &&
            (identical(other.currentPageId, currentPageId) ||
                other.currentPageId == currentPageId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      const DeepCollectionEquality().hash(_entries),
      const DeepCollectionEquality().hash(_pages),
      createdAt,
      colorValue,
      password,
      backgroundTheme,
      currentPageId);

  /// Create a copy of Diary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryImplCopyWith<_$DiaryImpl> get copyWith =>
      __$$DiaryImplCopyWithImpl<_$DiaryImpl>(this, _$identity);
}

abstract class _Diary implements Diary {
  const factory _Diary(
      {required final String id,
      required final String name,
      required final String description,
      final List<BulletEntry> entries,
      final List<DiaryPage> pages,
      required final DateTime createdAt,
      final int colorValue,
      final String? password,
      final DiaryBackgroundTheme backgroundTheme,
      final String? currentPageId}) = _$DiaryImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  List<BulletEntry> get entries;
  @override
  List<DiaryPage> get pages;
  @override
  DateTime get createdAt;
  @override
  int get colorValue;
  @override
  String? get password;
  @override
  DiaryBackgroundTheme get backgroundTheme;
  @override
  String? get currentPageId;

  /// Create a copy of Diary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiaryImplCopyWith<_$DiaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
