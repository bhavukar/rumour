// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UserModelCWProxy {
  UserModel id(String id);

  UserModel isAnonymous(bool isAnonymous);

  UserModel createdAt(DateTime createdAt);

  UserModel lastSeenAt(DateTime lastSeenAt);

  UserModel displayName(String? displayName);

  UserModel avatarUrl(String? avatarUrl);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `UserModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UserModel(...).copyWith(id: 12, name: "My name")
  /// ```
  UserModel call({
    String id,
    bool isAnonymous,
    DateTime createdAt,
    DateTime lastSeenAt,
    String? displayName,
    String? avatarUrl,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfUserModel.copyWith(...)` or call `instanceOfUserModel.copyWith.fieldName(value)` for a single field.
class _$UserModelCWProxyImpl implements _$UserModelCWProxy {
  const _$UserModelCWProxyImpl(this._value);

  final UserModel _value;

  @override
  UserModel id(String id) => call(id: id);

  @override
  UserModel isAnonymous(bool isAnonymous) => call(isAnonymous: isAnonymous);

  @override
  UserModel createdAt(DateTime createdAt) => call(createdAt: createdAt);

  @override
  UserModel lastSeenAt(DateTime lastSeenAt) => call(lastSeenAt: lastSeenAt);

  @override
  UserModel displayName(String? displayName) => call(displayName: displayName);

  @override
  UserModel avatarUrl(String? avatarUrl) => call(avatarUrl: avatarUrl);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `UserModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UserModel(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  UserModel call({
    Object? id = const $CopyWithPlaceholder(),
    Object? isAnonymous = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? lastSeenAt = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
    Object? avatarUrl = const $CopyWithPlaceholder(),
  }) {
    return UserModel(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      isAnonymous:
          isAnonymous == const $CopyWithPlaceholder() || isAnonymous == null
              ? _value.isAnonymous
              // ignore: cast_nullable_to_non_nullable
              : isAnonymous as bool,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      lastSeenAt:
          lastSeenAt == const $CopyWithPlaceholder() || lastSeenAt == null
              ? _value.lastSeenAt
              // ignore: cast_nullable_to_non_nullable
              : lastSeenAt as DateTime,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      avatarUrl: avatarUrl == const $CopyWithPlaceholder()
          ? _value.avatarUrl
          // ignore: cast_nullable_to_non_nullable
          : avatarUrl as String?,
    );
  }
}

extension $UserModelCopyWith on UserModel {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfUserModel.copyWith(...)` or `instanceOfUserModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UserModelCWProxy get copyWith => _$UserModelCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      isAnonymous: json['isAnonymous'] as bool? ?? true,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      lastSeenAt: const TimestampConverter().fromJson(json['lastSeenAt']),
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'isAnonymous': instance.isAnonymous,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'lastSeenAt': const TimestampConverter().toJson(instance.lastSeenAt),
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
    };
