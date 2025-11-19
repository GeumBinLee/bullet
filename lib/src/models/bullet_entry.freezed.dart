// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bullet_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SnoozeInfo {
  DateTime get requestedAt => throw _privateConstructorUsedError;
  DateTime get postponedTo => throw _privateConstructorUsedError;

  /// Create a copy of SnoozeInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnoozeInfoCopyWith<SnoozeInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnoozeInfoCopyWith<$Res> {
  factory $SnoozeInfoCopyWith(
          SnoozeInfo value, $Res Function(SnoozeInfo) then) =
      _$SnoozeInfoCopyWithImpl<$Res, SnoozeInfo>;
  @useResult
  $Res call({DateTime requestedAt, DateTime postponedTo});
}

/// @nodoc
class _$SnoozeInfoCopyWithImpl<$Res, $Val extends SnoozeInfo>
    implements $SnoozeInfoCopyWith<$Res> {
  _$SnoozeInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnoozeInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestedAt = null,
    Object? postponedTo = null,
  }) {
    return _then(_value.copyWith(
      requestedAt: null == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      postponedTo: null == postponedTo
          ? _value.postponedTo
          : postponedTo // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnoozeInfoImplCopyWith<$Res>
    implements $SnoozeInfoCopyWith<$Res> {
  factory _$$SnoozeInfoImplCopyWith(
          _$SnoozeInfoImpl value, $Res Function(_$SnoozeInfoImpl) then) =
      __$$SnoozeInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime requestedAt, DateTime postponedTo});
}

/// @nodoc
class __$$SnoozeInfoImplCopyWithImpl<$Res>
    extends _$SnoozeInfoCopyWithImpl<$Res, _$SnoozeInfoImpl>
    implements _$$SnoozeInfoImplCopyWith<$Res> {
  __$$SnoozeInfoImplCopyWithImpl(
      _$SnoozeInfoImpl _value, $Res Function(_$SnoozeInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnoozeInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requestedAt = null,
    Object? postponedTo = null,
  }) {
    return _then(_$SnoozeInfoImpl(
      requestedAt: null == requestedAt
          ? _value.requestedAt
          : requestedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      postponedTo: null == postponedTo
          ? _value.postponedTo
          : postponedTo // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$SnoozeInfoImpl implements _SnoozeInfo {
  const _$SnoozeInfoImpl(
      {required this.requestedAt, required this.postponedTo});

  @override
  final DateTime requestedAt;
  @override
  final DateTime postponedTo;

  @override
  String toString() {
    return 'SnoozeInfo(requestedAt: $requestedAt, postponedTo: $postponedTo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnoozeInfoImpl &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            (identical(other.postponedTo, postponedTo) ||
                other.postponedTo == postponedTo));
  }

  @override
  int get hashCode => Object.hash(runtimeType, requestedAt, postponedTo);

  /// Create a copy of SnoozeInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnoozeInfoImplCopyWith<_$SnoozeInfoImpl> get copyWith =>
      __$$SnoozeInfoImplCopyWithImpl<_$SnoozeInfoImpl>(this, _$identity);
}

abstract class _SnoozeInfo implements SnoozeInfo {
  const factory _SnoozeInfo(
      {required final DateTime requestedAt,
      required final DateTime postponedTo}) = _$SnoozeInfoImpl;

  @override
  DateTime get requestedAt;
  @override
  DateTime get postponedTo;

  /// Create a copy of SnoozeInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnoozeInfoImplCopyWith<_$SnoozeInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BulletTask {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  TaskStatus get status => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  List<SnoozeInfo> get snoozes => throw _privateConstructorUsedError;

  /// Create a copy of BulletTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BulletTaskCopyWith<BulletTask> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BulletTaskCopyWith<$Res> {
  factory $BulletTaskCopyWith(
          BulletTask value, $Res Function(BulletTask) then) =
      _$BulletTaskCopyWithImpl<$Res, BulletTask>;
  @useResult
  $Res call(
      {String id,
      String title,
      TaskStatus status,
      DateTime? dueDate,
      List<SnoozeInfo> snoozes});

  $TaskStatusCopyWith<$Res> get status;
}

/// @nodoc
class _$BulletTaskCopyWithImpl<$Res, $Val extends BulletTask>
    implements $BulletTaskCopyWith<$Res> {
  _$BulletTaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BulletTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? status = null,
    Object? dueDate = freezed,
    Object? snoozes = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      snoozes: null == snoozes
          ? _value.snoozes
          : snoozes // ignore: cast_nullable_to_non_nullable
              as List<SnoozeInfo>,
    ) as $Val);
  }

  /// Create a copy of BulletTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TaskStatusCopyWith<$Res> get status {
    return $TaskStatusCopyWith<$Res>(_value.status, (value) {
      return _then(_value.copyWith(status: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BulletTaskImplCopyWith<$Res>
    implements $BulletTaskCopyWith<$Res> {
  factory _$$BulletTaskImplCopyWith(
          _$BulletTaskImpl value, $Res Function(_$BulletTaskImpl) then) =
      __$$BulletTaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      TaskStatus status,
      DateTime? dueDate,
      List<SnoozeInfo> snoozes});

  @override
  $TaskStatusCopyWith<$Res> get status;
}

/// @nodoc
class __$$BulletTaskImplCopyWithImpl<$Res>
    extends _$BulletTaskCopyWithImpl<$Res, _$BulletTaskImpl>
    implements _$$BulletTaskImplCopyWith<$Res> {
  __$$BulletTaskImplCopyWithImpl(
      _$BulletTaskImpl _value, $Res Function(_$BulletTaskImpl) _then)
      : super(_value, _then);

  /// Create a copy of BulletTask
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? status = null,
    Object? dueDate = freezed,
    Object? snoozes = null,
  }) {
    return _then(_$BulletTaskImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      snoozes: null == snoozes
          ? _value._snoozes
          : snoozes // ignore: cast_nullable_to_non_nullable
              as List<SnoozeInfo>,
    ));
  }
}

/// @nodoc

class _$BulletTaskImpl implements _BulletTask {
  const _$BulletTaskImpl(
      {required this.id,
      required this.title,
      required this.status,
      this.dueDate,
      final List<SnoozeInfo> snoozes = const <SnoozeInfo>[]})
      : _snoozes = snoozes;

  @override
  final String id;
  @override
  final String title;
  @override
  final TaskStatus status;
  @override
  final DateTime? dueDate;
  final List<SnoozeInfo> _snoozes;
  @override
  @JsonKey()
  List<SnoozeInfo> get snoozes {
    if (_snoozes is EqualUnmodifiableListView) return _snoozes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_snoozes);
  }

  @override
  String toString() {
    return 'BulletTask(id: $id, title: $title, status: $status, dueDate: $dueDate, snoozes: $snoozes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BulletTaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            const DeepCollectionEquality().equals(other._snoozes, _snoozes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, status, dueDate,
      const DeepCollectionEquality().hash(_snoozes));

  /// Create a copy of BulletTask
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BulletTaskImplCopyWith<_$BulletTaskImpl> get copyWith =>
      __$$BulletTaskImplCopyWithImpl<_$BulletTaskImpl>(this, _$identity);
}

abstract class _BulletTask implements BulletTask {
  const factory _BulletTask(
      {required final String id,
      required final String title,
      required final TaskStatus status,
      final DateTime? dueDate,
      final List<SnoozeInfo> snoozes}) = _$BulletTaskImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  TaskStatus get status;
  @override
  DateTime? get dueDate;
  @override
  List<SnoozeInfo> get snoozes;

  /// Create a copy of BulletTask
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BulletTaskImplCopyWith<_$BulletTaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BulletEntry {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get focus => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  TaskStatus get keyStatus => throw _privateConstructorUsedError;
  List<BulletTask> get tasks => throw _privateConstructorUsedError;
  String? get sectionId => throw _privateConstructorUsedError;

  /// Create a copy of BulletEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BulletEntryCopyWith<BulletEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BulletEntryCopyWith<$Res> {
  factory $BulletEntryCopyWith(
          BulletEntry value, $Res Function(BulletEntry) then) =
      _$BulletEntryCopyWithImpl<$Res, BulletEntry>;
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String focus,
      String note,
      TaskStatus keyStatus,
      List<BulletTask> tasks,
      String? sectionId});

  $TaskStatusCopyWith<$Res> get keyStatus;
}

/// @nodoc
class _$BulletEntryCopyWithImpl<$Res, $Val extends BulletEntry>
    implements $BulletEntryCopyWith<$Res> {
  _$BulletEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BulletEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? focus = null,
    Object? note = null,
    Object? keyStatus = null,
    Object? tasks = null,
    Object? sectionId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      focus: null == focus
          ? _value.focus
          : focus // ignore: cast_nullable_to_non_nullable
              as String,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      keyStatus: null == keyStatus
          ? _value.keyStatus
          : keyStatus // ignore: cast_nullable_to_non_nullable
              as TaskStatus,
      tasks: null == tasks
          ? _value.tasks
          : tasks // ignore: cast_nullable_to_non_nullable
              as List<BulletTask>,
      sectionId: freezed == sectionId
          ? _value.sectionId
          : sectionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of BulletEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TaskStatusCopyWith<$Res> get keyStatus {
    return $TaskStatusCopyWith<$Res>(_value.keyStatus, (value) {
      return _then(_value.copyWith(keyStatus: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BulletEntryImplCopyWith<$Res>
    implements $BulletEntryCopyWith<$Res> {
  factory _$$BulletEntryImplCopyWith(
          _$BulletEntryImpl value, $Res Function(_$BulletEntryImpl) then) =
      __$$BulletEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String focus,
      String note,
      TaskStatus keyStatus,
      List<BulletTask> tasks,
      String? sectionId});

  @override
  $TaskStatusCopyWith<$Res> get keyStatus;
}

/// @nodoc
class __$$BulletEntryImplCopyWithImpl<$Res>
    extends _$BulletEntryCopyWithImpl<$Res, _$BulletEntryImpl>
    implements _$$BulletEntryImplCopyWith<$Res> {
  __$$BulletEntryImplCopyWithImpl(
      _$BulletEntryImpl _value, $Res Function(_$BulletEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of BulletEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? focus = null,
    Object? note = null,
    Object? keyStatus = null,
    Object? tasks = null,
    Object? sectionId = freezed,
  }) {
    return _then(_$BulletEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      focus: null == focus
          ? _value.focus
          : focus // ignore: cast_nullable_to_non_nullable
              as String,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      keyStatus: null == keyStatus
          ? _value.keyStatus
          : keyStatus // ignore: cast_nullable_to_non_nullable
              as TaskStatus,
      tasks: null == tasks
          ? _value._tasks
          : tasks // ignore: cast_nullable_to_non_nullable
              as List<BulletTask>,
      sectionId: freezed == sectionId
          ? _value.sectionId
          : sectionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$BulletEntryImpl implements _BulletEntry {
  const _$BulletEntryImpl(
      {required this.id,
      required this.date,
      required this.focus,
      required this.note,
      required this.keyStatus,
      required final List<BulletTask> tasks,
      this.sectionId})
      : _tasks = tasks;

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final String focus;
  @override
  final String note;
  @override
  final TaskStatus keyStatus;
  final List<BulletTask> _tasks;
  @override
  List<BulletTask> get tasks {
    if (_tasks is EqualUnmodifiableListView) return _tasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tasks);
  }

  @override
  final String? sectionId;

  @override
  String toString() {
    return 'BulletEntry(id: $id, date: $date, focus: $focus, note: $note, keyStatus: $keyStatus, tasks: $tasks, sectionId: $sectionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BulletEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.focus, focus) || other.focus == focus) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.keyStatus, keyStatus) ||
                other.keyStatus == keyStatus) &&
            const DeepCollectionEquality().equals(other._tasks, _tasks) &&
            (identical(other.sectionId, sectionId) ||
                other.sectionId == sectionId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, date, focus, note, keyStatus,
      const DeepCollectionEquality().hash(_tasks), sectionId);

  /// Create a copy of BulletEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BulletEntryImplCopyWith<_$BulletEntryImpl> get copyWith =>
      __$$BulletEntryImplCopyWithImpl<_$BulletEntryImpl>(this, _$identity);
}

abstract class _BulletEntry implements BulletEntry {
  const factory _BulletEntry(
      {required final String id,
      required final DateTime date,
      required final String focus,
      required final String note,
      required final TaskStatus keyStatus,
      required final List<BulletTask> tasks,
      final String? sectionId}) = _$BulletEntryImpl;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  String get focus;
  @override
  String get note;
  @override
  TaskStatus get keyStatus;
  @override
  List<BulletTask> get tasks;
  @override
  String? get sectionId;

  /// Create a copy of BulletEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BulletEntryImplCopyWith<_$BulletEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TaskStatus {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Create a copy of TaskStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskStatusCopyWith<TaskStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskStatusCopyWith<$Res> {
  factory $TaskStatusCopyWith(
          TaskStatus value, $Res Function(TaskStatus) then) =
      _$TaskStatusCopyWithImpl<$Res, TaskStatus>;
  @useResult
  $Res call({String id, String label, int order});
}

/// @nodoc
class _$TaskStatusCopyWithImpl<$Res, $Val extends TaskStatus>
    implements $TaskStatusCopyWith<$Res> {
  _$TaskStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? order = null,
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
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskStatusImplCopyWith<$Res>
    implements $TaskStatusCopyWith<$Res> {
  factory _$$TaskStatusImplCopyWith(
          _$TaskStatusImpl value, $Res Function(_$TaskStatusImpl) then) =
      __$$TaskStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String label, int order});
}

/// @nodoc
class __$$TaskStatusImplCopyWithImpl<$Res>
    extends _$TaskStatusCopyWithImpl<$Res, _$TaskStatusImpl>
    implements _$$TaskStatusImplCopyWith<$Res> {
  __$$TaskStatusImplCopyWithImpl(
      _$TaskStatusImpl _value, $Res Function(_$TaskStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? order = null,
  }) {
    return _then(_$TaskStatusImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$TaskStatusImpl extends _TaskStatus {
  const _$TaskStatusImpl(
      {required this.id, required this.label, required this.order})
      : super._();

  @override
  final String id;
  @override
  final String label;
  @override
  final int order;

  @override
  String toString() {
    return 'TaskStatus(id: $id, label: $label, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskStatusImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, label, order);

  /// Create a copy of TaskStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskStatusImplCopyWith<_$TaskStatusImpl> get copyWith =>
      __$$TaskStatusImplCopyWithImpl<_$TaskStatusImpl>(this, _$identity);
}

abstract class _TaskStatus extends TaskStatus {
  const factory _TaskStatus(
      {required final String id,
      required final String label,
      required final int order}) = _$TaskStatusImpl;
  const _TaskStatus._() : super._();

  @override
  String get id;
  @override
  String get label;
  @override
  int get order;

  /// Create a copy of TaskStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskStatusImplCopyWith<_$TaskStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
