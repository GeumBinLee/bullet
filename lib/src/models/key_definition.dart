import 'package:freezed_annotation/freezed_annotation.dart';

part 'key_definition.freezed.dart';

enum KeyShape {
  dot,
  check,
  triangle,
  arrow,
  memo,
  other,
  custom;
}

@freezed
class KeyDefinition with _$KeyDefinition {
  const factory KeyDefinition({
    required String id,
    required String label,
    required String description,
    required KeyShape shape,
    String? svgData,
  }) = _KeyDefinition;
}

