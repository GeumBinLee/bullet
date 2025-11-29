// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bullet_journal_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BulletJournalState {
  List<BulletEntry> get entries => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  List<KeyDefinition> get customKeys => throw _privateConstructorUsedError;
  List<TaskStatus> get taskStatuses => throw _privateConstructorUsedError;
  Map<String, List<String>> get statusKeyMapping =>
      throw _privateConstructorUsedError;
  List<Diary> get diaries => throw _privateConstructorUsedError;

  /// Create a copy of BulletJournalState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BulletJournalStateCopyWith<BulletJournalState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BulletJournalStateCopyWith<$Res> {
  factory $BulletJournalStateCopyWith(
          BulletJournalState value, $Res Function(BulletJournalState) then) =
      _$BulletJournalStateCopyWithImpl<$Res, BulletJournalState>;
  @useResult
  $Res call(
      {List<BulletEntry> entries,
      bool isLoading,
      List<KeyDefinition> customKeys,
      List<TaskStatus> taskStatuses,
      Map<String, List<String>> statusKeyMapping,
      List<Diary> diaries});
}

/// @nodoc
class _$BulletJournalStateCopyWithImpl<$Res, $Val extends BulletJournalState>
    implements $BulletJournalStateCopyWith<$Res> {
  _$BulletJournalStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BulletJournalState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entries = null,
    Object? isLoading = null,
    Object? customKeys = null,
    Object? taskStatuses = null,
    Object? statusKeyMapping = null,
    Object? diaries = null,
  }) {
    return _then(_value.copyWith(
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<BulletEntry>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      customKeys: null == customKeys
          ? _value.customKeys
          : customKeys // ignore: cast_nullable_to_non_nullable
              as List<KeyDefinition>,
      taskStatuses: null == taskStatuses
          ? _value.taskStatuses
          : taskStatuses // ignore: cast_nullable_to_non_nullable
              as List<TaskStatus>,
      statusKeyMapping: null == statusKeyMapping
          ? _value.statusKeyMapping
          : statusKeyMapping // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      diaries: null == diaries
          ? _value.diaries
          : diaries // ignore: cast_nullable_to_non_nullable
              as List<Diary>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BulletJournalStateImplCopyWith<$Res>
    implements $BulletJournalStateCopyWith<$Res> {
  factory _$$BulletJournalStateImplCopyWith(_$BulletJournalStateImpl value,
          $Res Function(_$BulletJournalStateImpl) then) =
      __$$BulletJournalStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<BulletEntry> entries,
      bool isLoading,
      List<KeyDefinition> customKeys,
      List<TaskStatus> taskStatuses,
      Map<String, List<String>> statusKeyMapping,
      List<Diary> diaries});
}

/// @nodoc
class __$$BulletJournalStateImplCopyWithImpl<$Res>
    extends _$BulletJournalStateCopyWithImpl<$Res, _$BulletJournalStateImpl>
    implements _$$BulletJournalStateImplCopyWith<$Res> {
  __$$BulletJournalStateImplCopyWithImpl(_$BulletJournalStateImpl _value,
      $Res Function(_$BulletJournalStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of BulletJournalState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entries = null,
    Object? isLoading = null,
    Object? customKeys = null,
    Object? taskStatuses = null,
    Object? statusKeyMapping = null,
    Object? diaries = null,
  }) {
    return _then(_$BulletJournalStateImpl(
      entries: null == entries
          ? _value._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<BulletEntry>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      customKeys: null == customKeys
          ? _value._customKeys
          : customKeys // ignore: cast_nullable_to_non_nullable
              as List<KeyDefinition>,
      taskStatuses: null == taskStatuses
          ? _value._taskStatuses
          : taskStatuses // ignore: cast_nullable_to_non_nullable
              as List<TaskStatus>,
      statusKeyMapping: null == statusKeyMapping
          ? _value._statusKeyMapping
          : statusKeyMapping // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      diaries: null == diaries
          ? _value._diaries
          : diaries // ignore: cast_nullable_to_non_nullable
              as List<Diary>,
    ));
  }
}

/// @nodoc

class _$BulletJournalStateImpl implements _BulletJournalState {
  const _$BulletJournalStateImpl(
      {final List<BulletEntry> entries = const <BulletEntry>[],
      this.isLoading = true,
      final List<KeyDefinition> customKeys = const <KeyDefinition>[],
      final List<TaskStatus> taskStatuses = TaskStatus.defaultStatuses,
      final Map<String, List<String>> statusKeyMapping = const {},
      final List<Diary> diaries = const <Diary>[]})
      : _entries = entries,
        _customKeys = customKeys,
        _taskStatuses = taskStatuses,
        _statusKeyMapping = statusKeyMapping,
        _diaries = diaries;

  final List<BulletEntry> _entries;
  @override
  @JsonKey()
  List<BulletEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  @JsonKey()
  final bool isLoading;
  final List<KeyDefinition> _customKeys;
  @override
  @JsonKey()
  List<KeyDefinition> get customKeys {
    if (_customKeys is EqualUnmodifiableListView) return _customKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customKeys);
  }

  final List<TaskStatus> _taskStatuses;
  @override
  @JsonKey()
  List<TaskStatus> get taskStatuses {
    if (_taskStatuses is EqualUnmodifiableListView) return _taskStatuses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_taskStatuses);
  }

  final Map<String, List<String>> _statusKeyMapping;
  @override
  @JsonKey()
  Map<String, List<String>> get statusKeyMapping {
    if (_statusKeyMapping is EqualUnmodifiableMapView) return _statusKeyMapping;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_statusKeyMapping);
  }

  final List<Diary> _diaries;
  @override
  @JsonKey()
  List<Diary> get diaries {
    if (_diaries is EqualUnmodifiableListView) return _diaries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_diaries);
  }

  @override
  String toString() {
    return 'BulletJournalState(entries: $entries, isLoading: $isLoading, customKeys: $customKeys, taskStatuses: $taskStatuses, statusKeyMapping: $statusKeyMapping, diaries: $diaries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BulletJournalStateImpl &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality()
                .equals(other._customKeys, _customKeys) &&
            const DeepCollectionEquality()
                .equals(other._taskStatuses, _taskStatuses) &&
            const DeepCollectionEquality()
                .equals(other._statusKeyMapping, _statusKeyMapping) &&
            const DeepCollectionEquality().equals(other._diaries, _diaries));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_entries),
      isLoading,
      const DeepCollectionEquality().hash(_customKeys),
      const DeepCollectionEquality().hash(_taskStatuses),
      const DeepCollectionEquality().hash(_statusKeyMapping),
      const DeepCollectionEquality().hash(_diaries));

  /// Create a copy of BulletJournalState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BulletJournalStateImplCopyWith<_$BulletJournalStateImpl> get copyWith =>
      __$$BulletJournalStateImplCopyWithImpl<_$BulletJournalStateImpl>(
          this, _$identity);
}

abstract class _BulletJournalState implements BulletJournalState {
  const factory _BulletJournalState(
      {final List<BulletEntry> entries,
      final bool isLoading,
      final List<KeyDefinition> customKeys,
      final List<TaskStatus> taskStatuses,
      final Map<String, List<String>> statusKeyMapping,
      final List<Diary> diaries}) = _$BulletJournalStateImpl;

  @override
  List<BulletEntry> get entries;
  @override
  bool get isLoading;
  @override
  List<KeyDefinition> get customKeys;
  @override
  List<TaskStatus> get taskStatuses;
  @override
  Map<String, List<String>> get statusKeyMapping;
  @override
  List<Diary> get diaries;

  /// Create a copy of BulletJournalState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BulletJournalStateImplCopyWith<_$BulletJournalStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
