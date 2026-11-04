// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RoomModelCWProxy {
  RoomModel code(String code);

  RoomModel memberCount(int memberCount);

  RoomModel createdAt(DateTime createdAt);

  RoomModel lastMessageAt(DateTime? lastMessageAt);

  RoomModel createdBy(String? createdBy);

  RoomModel lastMessageText(String? lastMessageText);

  RoomModel lastMessageSender(String? lastMessageSender);

  RoomModel lastMessageSenderId(String? lastMessageSenderId);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RoomModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RoomModel(...).copyWith(id: 12, name: "My name")
  /// ```
  RoomModel call({
    String code,
    int memberCount,
    DateTime createdAt,
    DateTime? lastMessageAt,
    String? createdBy,
    String? lastMessageText,
    String? lastMessageSender,
    String? lastMessageSenderId,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRoomModel.copyWith(...)` or call `instanceOfRoomModel.copyWith.fieldName(value)` for a single field.
class _$RoomModelCWProxyImpl implements _$RoomModelCWProxy {
  const _$RoomModelCWProxyImpl(this._value);

  final RoomModel _value;

  @override
  RoomModel code(String code) => call(code: code);

  @override
  RoomModel memberCount(int memberCount) => call(memberCount: memberCount);

  @override
  RoomModel createdAt(DateTime createdAt) => call(createdAt: createdAt);

  @override
  RoomModel lastMessageAt(DateTime? lastMessageAt) =>
      call(lastMessageAt: lastMessageAt);

  @override
  RoomModel createdBy(String? createdBy) => call(createdBy: createdBy);

  @override
  RoomModel lastMessageText(String? lastMessageText) =>
      call(lastMessageText: lastMessageText);

  @override
  RoomModel lastMessageSender(String? lastMessageSender) =>
      call(lastMessageSender: lastMessageSender);

  @override
  RoomModel lastMessageSenderId(String? lastMessageSenderId) =>
      call(lastMessageSenderId: lastMessageSenderId);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RoomModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RoomModel(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RoomModel call({
    Object? code = const $CopyWithPlaceholder(),
    Object? memberCount = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? lastMessageAt = const $CopyWithPlaceholder(),
    Object? createdBy = const $CopyWithPlaceholder(),
    Object? lastMessageText = const $CopyWithPlaceholder(),
    Object? lastMessageSender = const $CopyWithPlaceholder(),
    Object? lastMessageSenderId = const $CopyWithPlaceholder(),
  }) {
    return RoomModel(
      code: code == const $CopyWithPlaceholder() || code == null
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      memberCount:
          memberCount == const $CopyWithPlaceholder() || memberCount == null
              ? _value.memberCount
              // ignore: cast_nullable_to_non_nullable
              : memberCount as int,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      lastMessageAt: lastMessageAt == const $CopyWithPlaceholder()
          ? _value.lastMessageAt
          // ignore: cast_nullable_to_non_nullable
          : lastMessageAt as DateTime?,
      createdBy: createdBy == const $CopyWithPlaceholder()
          ? _value.createdBy
          // ignore: cast_nullable_to_non_nullable
          : createdBy as String?,
      lastMessageText: lastMessageText == const $CopyWithPlaceholder()
          ? _value.lastMessageText
          // ignore: cast_nullable_to_non_nullable
          : lastMessageText as String?,
      lastMessageSender: lastMessageSender == const $CopyWithPlaceholder()
          ? _value.lastMessageSender
          // ignore: cast_nullable_to_non_nullable
          : lastMessageSender as String?,
      lastMessageSenderId: lastMessageSenderId == const $CopyWithPlaceholder()
          ? _value.lastMessageSenderId
          // ignore: cast_nullable_to_non_nullable
          : lastMessageSenderId as String?,
    );
  }
}

extension $RoomModelCopyWith on RoomModel {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRoomModel.copyWith(...)` or `instanceOfRoomModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RoomModelCWProxy get copyWith => _$RoomModelCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomModel _$RoomModelFromJson(Map<String, dynamic> json) => RoomModel(
      code: json['code'] as String,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 1,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      lastMessageAt:
          const NullableTimestampConverter().fromJson(json['lastMessageAt']),
      createdBy: json['createdBy'] as String?,
      lastMessageText: json['lastMessageText'] as String?,
      lastMessageSender: json['lastMessageSender'] as String?,
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
    );

Map<String, dynamic> _$RoomModelToJson(RoomModel instance) => <String, dynamic>{
      'code': instance.code,
      'memberCount': instance.memberCount,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'lastMessageAt':
          const NullableTimestampConverter().toJson(instance.lastMessageAt),
      'createdBy': instance.createdBy,
      'lastMessageText': instance.lastMessageText,
      'lastMessageSender': instance.lastMessageSender,
      'lastMessageSenderId': instance.lastMessageSenderId,
    };
