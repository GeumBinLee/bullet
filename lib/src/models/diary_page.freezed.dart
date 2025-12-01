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
  String? get name => throw _privateConstructorUsedError; // 페이지 이름 (선택적)
  List<BulletEntry> get entries => throw _privateConstructorUsedError;
  List<DiarySection> get sections => throw _privateConstructorUsedError;
  List<PageComponent> get components =>
      throw _privateConstructorUsedError; // 페이지 컴포넌트 (섹션, 타임테이블 등)
  List<String> get layoutOrder =>
      throw _privateConstructorUsedError; // 엔트리/컴포넌트 통합 순서
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  bool get isIndexPage => throw _privateConstructorUsedError; // 인덱스 페이지 여부
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
      String? name,
      List<BulletEntry> entries,
      List<DiarySection> sections,
      List<PageComponent> components,
      List<String> layoutOrder,
      DateTime createdAt,
      bool isFavorite,
      bool isIndexPage,
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
    Object? name = freezed,
    Object? entries = null,
    Object? sections = null,
    Object? components = null,
    Object? layoutOrder = null,
    Object? createdAt = null,
    Object? isFavorite = null,
    Object? isIndexPage = null,
    Object? order = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<BulletEntry>,
      sections: null == sections
          ? _value.sections
          : sections // ignore: cast_nullable_to_non_nullable
              as List<DiarySection>,
      components: null == components
          ? _value.components
          : components // ignore: cast_nullable_to_non_nullable
              as List<PageComponent>,
      layoutOrder: null == layoutOrder
          ? _value.layoutOrder
          : layoutOrder // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isIndexPage: null == isIndexPage
          ? _value.isIndexPage
          : isIndexPage // ignore: cast_nullable_to_non_nullable
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
      String? name,
      List<BulletEntry> entries,
      List<DiarySection> sections,
      List<PageComponent> components,
      List<String> layoutOrder,
      DateTime createdAt,
      bool isFavorite,
      bool isIndexPage,
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
    Object? name = freezed,
    Object? entries = null,
    Object? sections = null,
    Object? components = null,
    Object? layoutOrder = null,
    Object? createdAt = null,
    Object? isFavorite = null,
    Object? isIndexPage = null,
    Object? order = freezed,
  }) {
    return _then(_$DiaryPageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      entries: null == entries
          ? _value._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<BulletEntry>,
      sections: null == sections
          ? _value._sections
          : sections // ignore: cast_nullable_to_non_nullable
              as List<DiarySection>,
      components: null == components
          ? _value._components
          : components // ignore: cast_nullable_to_non_nullable
              as List<PageComponent>,
      layoutOrder: null == layoutOrder
          ? _value._layoutOrder
          : layoutOrder // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isIndexPage: null == isIndexPage
          ? _value.isIndexPage
          : isIndexPage // ignore: cast_nullable_to_non_nullable
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
      this.name,
      final List<BulletEntry> entries = const <BulletEntry>[],
      final List<DiarySection> sections = const <DiarySection>[],
      final List<PageComponent> components = const <PageComponent>[],
      final List<String> layoutOrder = const <String>[],
      required this.createdAt,
      this.isFavorite = false,
      this.isIndexPage = false,
      this.order})
      : _entries = entries,
        _sections = sections,
        _components = components,
        _layoutOrder = layoutOrder;

  @override
  final String id;
  @override
  final String? name;
// 페이지 이름 (선택적)
  final List<BulletEntry> _entries;
// 페이지 이름 (선택적)
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

  final List<PageComponent> _components;
  @override
  @JsonKey()
  List<PageComponent> get components {
    if (_components is EqualUnmodifiableListView) return _components;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_components);
  }

// 페이지 컴포넌트 (섹션, 타임테이블 등)
  final List<String> _layoutOrder;
// 페이지 컴포넌트 (섹션, 타임테이블 등)
  @override
  @JsonKey()
  List<String> get layoutOrder {
    if (_layoutOrder is EqualUnmodifiableListView) return _layoutOrder;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_layoutOrder);
  }

// 엔트리/컴포넌트 통합 순서
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  @JsonKey()
  final bool isIndexPage;
// 인덱스 페이지 여부
  @override
  final int? order;

  @override
  String toString() {
    return 'DiaryPage(id: $id, name: $name, entries: $entries, sections: $sections, components: $components, layoutOrder: $layoutOrder, createdAt: $createdAt, isFavorite: $isFavorite, isIndexPage: $isIndexPage, order: $order)';
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
            const DeepCollectionEquality()
                .equals(other._components, _components) &&
            const DeepCollectionEquality()
                .equals(other._layoutOrder, _layoutOrder) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.isIndexPage, isIndexPage) ||
                other.isIndexPage == isIndexPage) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_entries),
      const DeepCollectionEquality().hash(_sections),
      const DeepCollectionEquality().hash(_components),
      const DeepCollectionEquality().hash(_layoutOrder),
      createdAt,
      isFavorite,
      isIndexPage,
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
      final String? name,
      final List<BulletEntry> entries,
      final List<DiarySection> sections,
      final List<PageComponent> components,
      final List<String> layoutOrder,
      required final DateTime createdAt,
      final bool isFavorite,
      final bool isIndexPage,
      final int? order}) = _$DiaryPageImpl;

  @override
  String get id;
  @override
  String? get name; // 페이지 이름 (선택적)
  @override
  List<BulletEntry> get entries;
  @override
  List<DiarySection> get sections;
  @override
  List<PageComponent> get components; // 페이지 컴포넌트 (섹션, 타임테이블 등)
  @override
  List<String> get layoutOrder; // 엔트리/컴포넌트 통합 순서
  @override
  DateTime get createdAt;
  @override
  bool get isFavorite;
  @override
  bool get isIndexPage; // 인덱스 페이지 여부
  @override
  int? get order;

  /// Create a copy of DiaryPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiaryPageImplCopyWith<_$DiaryPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
