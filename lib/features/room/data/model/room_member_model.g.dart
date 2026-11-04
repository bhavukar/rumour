// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_member_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RoomMemberModelCWProxy {
  RoomMemberModel id(String id);

  RoomMemberModel displayName(String displayName);

  RoomMemberModel avatarUrl(String? avatarUrl);

  RoomMemberModel joinedAt(DateTime joinedAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RoomMemberModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RoomMemberModel(...).copyWith(id: 12, name: "My name")
  /// ```
  RoomMemberModel call({
    String id,
    String displayName,
    String? avatarUrl,
    DateTime joinedAt,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRoomMemberModel.copyWith(...)` or call `instanceOfRoomMemberModel.copyWith.fieldName(value)` for a single field.
class _$RoomMemberModelCWProxyImpl implements _$RoomMemberModelCWProxy {
  const _$RoomMemberModelCWProxyImpl(this._value);

  final RoomMemberModel _value;

  @override
  RoomMemberModel id(String id) => call(id: id);

  @override
  RoomMemberModel displayName(String displayName) =>
      call(displayName: displayName);

  @override
  RoomMemberModel avatarUrl(String? avatarUrl) => call(avatarUrl: avatarUrl);

  @override
  RoomMemberModel joinedAt(DateTime joinedAt) => call(joinedAt: joinedAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RoomMemberModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RoomMemberModel(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RoomMemberModel call({
    Object? id = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? avatarUrl = const $CopyWithPlaceholder(),
    Object? joinedAt = const $CopyWithPlaceholder(),
  }) {
    return RoomMemberModel(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      displayName:
          displayName == const $CopyWithPlaceholder() || displayName == null
              ? _value.displayName
              // ignore: cast_nullable_to_non_nullable
              : displayName as String,
      avatarUrl: avatarUrl == const $CopyWithPlaceholder()
          ? _value.avatarUrl
          // ignore: cast_nullable_to_non_nullable
          : avatarUrl as String?,
      joinedAt: joinedAt == const $CopyWithPlaceholder() || joinedAt == null
          ? _value.joinedAt
          // ignore: cast_nullable_to_non_nullable
          : joinedAt as DateTime,
    );
  }
}

extension $RoomMemberModelCopyWith on RoomMemberModel {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRoomMemberModel.copyWith(...)` or `instanceOfRoomMemberModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RoomMemberModelCWProxy get copyWith => _$RoomMemberModelCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomMemberModel _$RoomMemberModelFromJson(Map<String, dynamic> json) =>
    RoomMemberModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? 'Anonymous',
      avatarUrl: json['avatarUrl'] as String?,
      joinedAt: const TimestampConverter().fromJson(json['joinedAt']),
    );

Map<String, dynamic> _$RoomMemberModelToJson(RoomMemberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'joinedAt': const TimestampConverter().toJson(instance.joinedAt),
    };
