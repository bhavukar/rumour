// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'random_user_response_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RandomUserResponseModelCWProxy {
  RandomUserResponseModel results(List<RandomUserResultModel> results);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RandomUserResponseModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RandomUserResponseModel(...).copyWith(id: 12, name: "My name")
  /// ```
  RandomUserResponseModel call({
    List<RandomUserResultModel> results,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRandomUserResponseModel.copyWith(...)` or call `instanceOfRandomUserResponseModel.copyWith.fieldName(value)` for a single field.
class _$RandomUserResponseModelCWProxyImpl
    implements _$RandomUserResponseModelCWProxy {
  const _$RandomUserResponseModelCWProxyImpl(this._value);

  final RandomUserResponseModel _value;

  @override
  RandomUserResponseModel results(List<RandomUserResultModel> results) =>
      call(results: results);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RandomUserResponseModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RandomUserResponseModel(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RandomUserResponseModel call({
    Object? results = const $CopyWithPlaceholder(),
  }) {
    return RandomUserResponseModel(
      results: results == const $CopyWithPlaceholder() || results == null
          ? _value.results
          // ignore: cast_nullable_to_non_nullable
          : results as List<RandomUserResultModel>,
    );
  }
}

extension $RandomUserResponseModelCopyWith on RandomUserResponseModel {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRandomUserResponseModel.copyWith(...)` or `instanceOfRandomUserResponseModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RandomUserResponseModelCWProxy get copyWith =>
      _$RandomUserResponseModelCWProxyImpl(this);
}

abstract class _$RandomUserResultModelCWProxy {
  RandomUserResultModel name(RandomUserNameModel name);

  RandomUserResultModel login(RandomUserLoginModel login);

  RandomUserResultModel picture(RandomUserPictureModel? picture);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RandomUserResultModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RandomUserResultModel(...).copyWith(id: 12, name: "My name")
  /// ```
  RandomUserResultModel call({
    RandomUserNameModel name,
    RandomUserLoginModel login,
    RandomUserPictureModel? picture,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRandomUserResultModel.copyWith(...)` or call `instanceOfRandomUserResultModel.copyWith.fieldName(value)` for a single field.
class _$RandomUserResultModelCWProxyImpl
    implements _$RandomUserResultModelCWProxy {
  const _$RandomUserResultModelCWProxyImpl(this._value);

  final RandomUserResultModel _value;

  @override
  RandomUserResultModel name(RandomUserNameModel name) => call(name: name);

  @override
  RandomUserResultModel login(RandomUserLoginModel login) => call(login: login);

  @override
  RandomUserResultModel picture(RandomUserPictureModel? picture) =>
      call(picture: picture);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RandomUserResultModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RandomUserResultModel(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RandomUserResultModel call({
    Object? name = const $CopyWithPlaceholder(),
    Object? login = const $CopyWithPlaceholder(),
    Object? picture = const $CopyWithPlaceholder(),
  }) {
    return RandomUserResultModel(
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as RandomUserNameModel,
      login: login == const $CopyWithPlaceholder() || login == null
          ? _value.login
          // ignore: cast_nullable_to_non_nullable
          : login as RandomUserLoginModel,
      picture: picture == const $CopyWithPlaceholder()
          ? _value.picture
          // ignore: cast_nullable_to_non_nullable
          : picture as RandomUserPictureModel?,
    );
  }
}

extension $RandomUserResultModelCopyWith on RandomUserResultModel {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRandomUserResultModel.copyWith(...)` or `instanceOfRandomUserResultModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RandomUserResultModelCWProxy get copyWith =>
      _$RandomUserResultModelCWProxyImpl(this);
}

abstract class _$RandomUserNameModelCWProxy {
  RandomUserNameModel title(String title);

  RandomUserNameModel first(String first);

  RandomUserNameModel last(String last);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RandomUserNameModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RandomUserNameModel(...).copyWith(id: 12, name: "My name")
  /// ```
  RandomUserNameModel call({
    String title,
    String first,
    String last,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRandomUserNameModel.copyWith(...)` or call `instanceOfRandomUserNameModel.copyWith.fieldName(value)` for a single field.
class _$RandomUserNameModelCWProxyImpl implements _$RandomUserNameModelCWProxy {
  const _$RandomUserNameModelCWProxyImpl(this._value);

  final RandomUserNameModel _value;

  @override
  RandomUserNameModel title(String title) => call(title: title);

  @override
  RandomUserNameModel first(String first) => call(first: first);

  @override
  RandomUserNameModel last(String last) => call(last: last);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RandomUserNameModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RandomUserNameModel(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RandomUserNameModel call({
    Object? title = const $CopyWithPlaceholder(),
    Object? first = const $CopyWithPlaceholder(),
    Object? last = const $CopyWithPlaceholder(),
  }) {
    return RandomUserNameModel(
      title: title == const $CopyWithPlaceholder() || title == null
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      first: first == const $CopyWithPlaceholder() || first == null
          ? _value.first
          // ignore: cast_nullable_to_non_nullable
          : first as String,
      last: last == const $CopyWithPlaceholder() || last == null
          ? _value.last
          // ignore: cast_nullable_to_non_nullable
          : last as String,
    );
  }
}

extension $RandomUserNameModelCopyWith on RandomUserNameModel {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRandomUserNameModel.copyWith(...)` or `instanceOfRandomUserNameModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RandomUserNameModelCWProxy get copyWith =>
      _$RandomUserNameModelCWProxyImpl(this);
}

abstract class _$RandomUserLoginModelCWProxy {
  RandomUserLoginModel uuid(String uuid);

  RandomUserLoginModel username(String username);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RandomUserLoginModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RandomUserLoginModel(...).copyWith(id: 12, name: "My name")
  /// ```
  RandomUserLoginModel call({
    String uuid,
    String username,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRandomUserLoginModel.copyWith(...)` or call `instanceOfRandomUserLoginModel.copyWith.fieldName(value)` for a single field.
class _$RandomUserLoginModelCWProxyImpl
    implements _$RandomUserLoginModelCWProxy {
  const _$RandomUserLoginModelCWProxyImpl(this._value);

  final RandomUserLoginModel _value;

  @override
  RandomUserLoginModel uuid(String uuid) => call(uuid: uuid);

  @override
  RandomUserLoginModel username(String username) => call(username: username);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RandomUserLoginModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RandomUserLoginModel(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RandomUserLoginModel call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? username = const $CopyWithPlaceholder(),
  }) {
    return RandomUserLoginModel(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      username: username == const $CopyWithPlaceholder() || username == null
          ? _value.username
          // ignore: cast_nullable_to_non_nullable
          : username as String,
    );
  }
}

extension $RandomUserLoginModelCopyWith on RandomUserLoginModel {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRandomUserLoginModel.copyWith(...)` or `instanceOfRandomUserLoginModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RandomUserLoginModelCWProxy get copyWith =>
      _$RandomUserLoginModelCWProxyImpl(this);
}

abstract class _$RandomUserPictureModelCWProxy {
  RandomUserPictureModel large(String? large);

  RandomUserPictureModel medium(String? medium);

  RandomUserPictureModel thumbnail(String? thumbnail);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RandomUserPictureModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RandomUserPictureModel(...).copyWith(id: 12, name: "My name")
  /// ```
  RandomUserPictureModel call({
    String? large,
    String? medium,
    String? thumbnail,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRandomUserPictureModel.copyWith(...)` or call `instanceOfRandomUserPictureModel.copyWith.fieldName(value)` for a single field.
class _$RandomUserPictureModelCWProxyImpl
    implements _$RandomUserPictureModelCWProxy {
  const _$RandomUserPictureModelCWProxyImpl(this._value);

  final RandomUserPictureModel _value;

  @override
  RandomUserPictureModel large(String? large) => call(large: large);

  @override
  RandomUserPictureModel medium(String? medium) => call(medium: medium);

  @override
  RandomUserPictureModel thumbnail(String? thumbnail) =>
      call(thumbnail: thumbnail);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RandomUserPictureModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RandomUserPictureModel(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RandomUserPictureModel call({
    Object? large = const $CopyWithPlaceholder(),
    Object? medium = const $CopyWithPlaceholder(),
    Object? thumbnail = const $CopyWithPlaceholder(),
  }) {
    return RandomUserPictureModel(
      large: large == const $CopyWithPlaceholder()
          ? _value.large
          // ignore: cast_nullable_to_non_nullable
          : large as String?,
      medium: medium == const $CopyWithPlaceholder()
          ? _value.medium
          // ignore: cast_nullable_to_non_nullable
          : medium as String?,
      thumbnail: thumbnail == const $CopyWithPlaceholder()
          ? _value.thumbnail
          // ignore: cast_nullable_to_non_nullable
          : thumbnail as String?,
    );
  }
}

extension $RandomUserPictureModelCopyWith on RandomUserPictureModel {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRandomUserPictureModel.copyWith(...)` or `instanceOfRandomUserPictureModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RandomUserPictureModelCWProxy get copyWith =>
      _$RandomUserPictureModelCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RandomUserResponseModel _$RandomUserResponseModelFromJson(
        Map<String, dynamic> json) =>
    RandomUserResponseModel(
      results: (json['results'] as List<dynamic>)
          .map((e) => RandomUserResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RandomUserResponseModelToJson(
        RandomUserResponseModel instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
    };

RandomUserResultModel _$RandomUserResultModelFromJson(
        Map<String, dynamic> json) =>
    RandomUserResultModel(
      name: RandomUserNameModel.fromJson(json['name'] as Map<String, dynamic>),
      login:
          RandomUserLoginModel.fromJson(json['login'] as Map<String, dynamic>),
      picture: json['picture'] == null
          ? null
          : RandomUserPictureModel.fromJson(
              json['picture'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RandomUserResultModelToJson(
        RandomUserResultModel instance) =>
    <String, dynamic>{
      'name': instance.name.toJson(),
      'login': instance.login.toJson(),
      'picture': instance.picture?.toJson(),
    };

RandomUserNameModel _$RandomUserNameModelFromJson(Map<String, dynamic> json) =>
    RandomUserNameModel(
      title: json['title'] as String? ?? '',
      first: json['first'] as String? ?? '',
      last: json['last'] as String? ?? '',
    );

Map<String, dynamic> _$RandomUserNameModelToJson(
        RandomUserNameModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'first': instance.first,
      'last': instance.last,
    };

RandomUserLoginModel _$RandomUserLoginModelFromJson(
        Map<String, dynamic> json) =>
    RandomUserLoginModel(
      uuid: json['uuid'] as String? ?? '',
      username: json['username'] as String? ?? '',
    );

Map<String, dynamic> _$RandomUserLoginModelToJson(
        RandomUserLoginModel instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'username': instance.username,
    };

RandomUserPictureModel _$RandomUserPictureModelFromJson(
        Map<String, dynamic> json) =>
    RandomUserPictureModel(
      large: json['large'] as String?,
      medium: json['medium'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );

Map<String, dynamic> _$RandomUserPictureModelToJson(
        RandomUserPictureModel instance) =>
    <String, dynamic>{
      'large': instance.large,
      'medium': instance.medium,
      'thumbnail': instance.thumbnail,
    };
