// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DiaryPage {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<BulletEntry> get entries => throw _privateConstructorUsedError;
  List<DiarySection> get sections => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  int? get order => throw _privateConstructorUsedError;

  /// Create a copy of DiaryPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiaryPageCopyWith<DiaryPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryPageCopyWith<$Res> {
  factory $DiaryPageCopyWith(DiaryPage value, $Res Function(DiaryPage) then) =
      _$DiaryPageCopyWithImpl<$Res, DiaryPage>;
  @useResult
  $Res call(
      {String id,
      String name,
      List<BulletEntry> entries,
      List<DiarySection> sections,
      DateTime createdAt,
      bool isFavorite,
      int? order});
}

/// @nodoc
class _$DiaryPageCopyWithImpl<$Res, $Val extends DiaryPage>
    implements $DiaryPageCopyWith<$Res> {
  _$DiaryPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiaryPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? entries = null,
    Object? sections = null,
    Object? createdAt = null,
    Object? isFavorite = null,
    Object? order = freezed,
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
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<BulletEntry>,
      sections: null == sections
          ? _value.sections
          : sections // ignore: cast_nullable_to_non_nullable
              as List<DiarySection>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiaryPageImplCopyWith<$Res>
    implements $DiaryPageCopyWith<$Res> {
  factory _$$DiaryPageImplCopyWith(
          _$DiaryPageImpl value, $Res Function(_$DiaryPageImpl) then) =
      __$$DiaryPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      List<BulletEntry> entries,
      List<DiarySection> sections,
      DateTime createdAt,
      bool isFavorite,
      int? order});
}

/// @nodoc
class __$$DiaryPageImplCopyWithImpl<$Res>
    extends _$DiaryPageCopyWithImpl<$Res, _$DiaryPageImpl>
    implements _$$DiaryPageImplCopyWith<$Res> {
  __$$DiaryPageImplCopyWithImpl(
      _$DiaryPageImpl _value, $Res Function(_$DiaryPageImpl) _then)
      : super(_value, _then);

  /// Create a copy of DiaryPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? entries = null,
    Object? sections = null,
    Object? createdAt = null,
    Object? isFavorite = null,
    Object? order = freezed,
  }) {
    return _then(_$DiaryPageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      entries: null == entries
          ? _value._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<BulletEntry>,
      sections: null == sections
          ? _value._sections
          : sections // ignore: cast_nullable_to_non_nullable
              as List<DiarySection>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$DiaryPageImpl implements _DiaryPage {
  const _$DiaryPageImpl(
      {required this.id,
      required this.name,
      final List<BulletEntry> entries = const <BulletEntry>[],
      final List<DiarySection> sections = const <DiarySection>[],
      required this.createdAt,
      this.isFavorite = false,
      this.order})
      : _entries = entries,
        _sections = sections;

  @override
  final String id;
  @override
  final String name;
  final List<BulletEntry> _entries;
  @override
  @JsonKey()
  List<BulletEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  final List<DiarySection> _sections;
  @override
  @JsonKey()
  List<DiarySection> get sections {
    if (_sections is EqualUnmodifiableListView) return _sections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sections);
  }

  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  final int? order;

  @override
  String toString() {
    return 'DiaryPage(id: $id, name: $name, entries: $entries, sections: $sections, createdAt: $createdAt, isFavorite: $isFavorite, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryPageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            const DeepCollectionEquality().equals(other._sections, _sections) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_entries),
      const DeepCollectionEquality().hash(_sections),
      createdAt,
      isFavorite,
      order);

  /// Create a copy of DiaryPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryPageImplCopyWith<_$DiaryPageImpl> get copyWith =>
      __$$DiaryPageImplCopyWithImpl<_$DiaryPageImpl>(this, _$identity);
}

abstract class _DiaryPage implements DiaryPage {
  const factory _DiaryPage(
      {required final String id,
      required final String name,
      final List<BulletEntry> entries,
      final List<DiarySection> sections,
      required final DateTime createdAt,
      final bool isFavorite,
      final int? order}) = _$DiaryPageImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  List<BulletEntry> get entries;
  @override
  List<DiarySection> get sections;
  @override
  DateTime get createdAt;
  @override
  bool get isFavorite;
  @override
  int? get order;

  /// Create a copy of DiaryPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiaryPageImplCopyWith<_$DiaryPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
