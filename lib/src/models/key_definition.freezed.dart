// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'key_definition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$KeyDefinition {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  KeyShape get shape => throw _privateConstructorUsedError;
  String? get svgData => throw _privateConstructorUsedError;

  /// Create a copy of KeyDefinition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KeyDefinitionCopyWith<KeyDefinition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeyDefinitionCopyWith<$Res> {
  factory $KeyDefinitionCopyWith(
          KeyDefinition value, $Res Function(KeyDefinition) then) =
      _$KeyDefinitionCopyWithImpl<$Res, KeyDefinition>;
  @useResult
  $Res call(
      {String id,
      String label,
      String description,
      KeyShape shape,
      String? svgData});
}

/// @nodoc
class _$KeyDefinitionCopyWithImpl<$Res, $Val extends KeyDefinition>
    implements $KeyDefinitionCopyWith<$Res> {
  _$KeyDefinitionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KeyDefinition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? description = null,
    Object? shape = null,
    Object? svgData = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      shape: null == shape
          ? _value.shape
          : shape // ignore: cast_nullable_to_non_nullable
              as KeyShape,
      svgData: freezed == svgData
          ? _value.svgData
          : svgData // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KeyDefinitionImplCopyWith<$Res>
    implements $KeyDefinitionCopyWith<$Res> {
  factory _$$KeyDefinitionImplCopyWith(
          _$KeyDefinitionImpl value, $Res Function(_$KeyDefinitionImpl) then) =
      __$$KeyDefinitionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      String description,
      KeyShape shape,
      String? svgData});
}

/// @nodoc
class __$$KeyDefinitionImplCopyWithImpl<$Res>
    extends _$KeyDefinitionCopyWithImpl<$Res, _$KeyDefinitionImpl>
    implements _$$KeyDefinitionImplCopyWith<$Res> {
  __$$KeyDefinitionImplCopyWithImpl(
      _$KeyDefinitionImpl _value, $Res Function(_$KeyDefinitionImpl) _then)
      : super(_value, _then);

  /// Create a copy of KeyDefinition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? description = null,
    Object? shape = null,
    Object? svgData = freezed,
  }) {
    return _then(_$KeyDefinitionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      shape: null == shape
          ? _value.shape
          : shape // ignore: cast_nullable_to_non_nullable
              as KeyShape,
      svgData: freezed == svgData
          ? _value.svgData
          : svgData // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$KeyDefinitionImpl implements _KeyDefinition {
  const _$KeyDefinitionImpl(
      {required this.id,
      required this.label,
      required this.description,
      required this.shape,
      this.svgData});

  @override
  final String id;
  @override
  final String label;
  @override
  final String description;
  @override
  final KeyShape shape;
  @override
  final String? svgData;

  @override
  String toString() {
    return 'KeyDefinition(id: $id, label: $label, description: $description, shape: $shape, svgData: $svgData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeyDefinitionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.shape, shape) || other.shape == shape) &&
            (identical(other.svgData, svgData) || other.svgData == svgData));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, label, description, shape, svgData);

  /// Create a copy of KeyDefinition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KeyDefinitionImplCopyWith<_$KeyDefinitionImpl> get copyWith =>
      __$$KeyDefinitionImplCopyWithImpl<_$KeyDefinitionImpl>(this, _$identity);
}

abstract class _KeyDefinition implements KeyDefinition {
  const factory _KeyDefinition(
      {required final String id,
      required final String label,
      required final String description,
      required final KeyShape shape,
      final String? svgData}) = _$KeyDefinitionImpl;

  @override
  String get id;
  @override
  String get label;
  @override
  String get description;
  @override
  KeyShape get shape;
  @override
  String? get svgData;

  /// Create a copy of KeyDefinition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KeyDefinitionImplCopyWith<_$KeyDefinitionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
