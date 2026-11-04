// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_identity_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RoomIdentityModelCWProxy {
  RoomIdentityModel id(String id);

  RoomIdentityModel roomId(String roomId);

  RoomIdentityModel displayName(String displayName);

  RoomIdentityModel mentionTag(String mentionTag);

  RoomIdentityModel avatarUrl(String? avatarUrl);

  RoomIdentityModel createdAt(DateTime createdAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RoomIdentityModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RoomIdentityModel(...).copyWith(id: 12, name: "My name")
  /// ```
  RoomIdentityModel call({
    String id,
    String roomId,
    String displayName,
    String mentionTag,
    String? avatarUrl,
    DateTime createdAt,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRoomIdentityModel.copyWith(...)` or call `instanceOfRoomIdentityModel.copyWith.fieldName(value)` for a single field.
class _$RoomIdentityModelCWProxyImpl implements _$RoomIdentityModelCWProxy {
  const _$RoomIdentityModelCWProxyImpl(this._value);

  final RoomIdentityModel _value;

  @override
  RoomIdentityModel id(String id) => call(id: id);

  @override
  RoomIdentityModel roomId(String roomId) => call(roomId: roomId);

  @override
  RoomIdentityModel displayName(String displayName) =>
      call(displayName: displayName);

  @override
  RoomIdentityModel mentionTag(String mentionTag) =>
      call(mentionTag: mentionTag);

  @override
  RoomIdentityModel avatarUrl(String? avatarUrl) => call(avatarUrl: avatarUrl);

  @override
  RoomIdentityModel createdAt(DateTime createdAt) => call(createdAt: createdAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RoomIdentityModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RoomIdentityModel(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RoomIdentityModel call({
    Object? id = const $CopyWithPlaceholder(),
    Object? roomId = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? mentionTag = const $CopyWithPlaceholder(),
    Object? avatarUrl = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return RoomIdentityModel(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      roomId: roomId == const $CopyWithPlaceholder() || roomId == null
          ? _value.roomId
          // ignore: cast_nullable_to_non_nullable
          : roomId as String,
      displayName:
          displayName == const $CopyWithPlaceholder() || displayName == null
              ? _value.displayName
              // ignore: cast_nullable_to_non_nullable
              : displayName as String,
      mentionTag:
          mentionTag == const $CopyWithPlaceholder() || mentionTag == null
              ? _value.mentionTag
              // ignore: cast_nullable_to_non_nullable
              : mentionTag as String,
      avatarUrl: avatarUrl == const $CopyWithPlaceholder()
          ? _value.avatarUrl
          // ignore: cast_nullable_to_non_nullable
          : avatarUrl as String?,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $RoomIdentityModelCopyWith on RoomIdentityModel {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRoomIdentityModel.copyWith(...)` or `instanceOfRoomIdentityModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RoomIdentityModelCWProxy get copyWith =>
      _$RoomIdentityModelCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomIdentityModel _$RoomIdentityModelFromJson(Map<String, dynamic> json) =>
    RoomIdentityModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      displayName: json['displayName'] as String? ?? 'Brave Badger',
      mentionTag: json['mentionTag'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$RoomIdentityModelToJson(RoomIdentityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'displayName': instance.displayName,
      'mentionTag': instance.mentionTag,
      'avatarUrl': instance.avatarUrl,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
