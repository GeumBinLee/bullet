// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary_section.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DiarySection {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Create a copy of DiarySection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiarySectionCopyWith<DiarySection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiarySectionCopyWith<$Res> {
  factory $DiarySectionCopyWith(
          DiarySection value, $Res Function(DiarySection) then) =
      _$DiarySectionCopyWithImpl<$Res, DiarySection>;
  @useResult
  $Res call({String id, String name, DateTime createdAt, int order});
}

/// @nodoc
class _$DiarySectionCopyWithImpl<$Res, $Val extends DiarySection>
    implements $DiarySectionCopyWith<$Res> {
  _$DiarySectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiarySection
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
abstract class _$$DiarySectionImplCopyWith<$Res>
    implements $DiarySectionCopyWith<$Res> {
  factory _$$DiarySectionImplCopyWith(
          _$DiarySectionImpl value, $Res Function(_$DiarySectionImpl) then) =
      __$$DiarySectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, DateTime createdAt, int order});
}

/// @nodoc
class __$$DiarySectionImplCopyWithImpl<$Res>
    extends _$DiarySectionCopyWithImpl<$Res, _$DiarySectionImpl>
    implements _$$DiarySectionImplCopyWith<$Res> {
  __$$DiarySectionImplCopyWithImpl(
      _$DiarySectionImpl _value, $Res Function(_$DiarySectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of DiarySection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? order = null,
  }) {
    return _then(_$DiarySectionImpl(
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

class _$DiarySectionImpl implements _DiarySection {
  const _$DiarySectionImpl(
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
    return 'DiarySection(id: $id, name: $name, createdAt: $createdAt, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiarySectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, createdAt, order);

  /// Create a copy of DiarySection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiarySectionImplCopyWith<_$DiarySectionImpl> get copyWith =>
      __$$DiarySectionImplCopyWithImpl<_$DiarySectionImpl>(this, _$identity);
}

abstract class _DiarySection implements DiarySection {
  const factory _DiarySection(
      {required final String id,
      required final String name,
      required final DateTime createdAt,
      final int order}) = _$DiarySectionImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  DateTime get createdAt;
  @override
  int get order;

  /// Create a copy of DiarySection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiarySectionImplCopyWith<_$DiarySectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
