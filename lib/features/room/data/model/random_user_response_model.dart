import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'random_user_response_model.g.dart';

@CopyWith()
@JsonSerializable(explicitToJson: true)
class RandomUserResponseModel extends Equatable {
  final List<RandomUserResultModel> results;

  const RandomUserResponseModel({
    required this.results,
  });

  factory RandomUserResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RandomUserResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$RandomUserResponseModelToJson(this);

  @override
  List<Object?> get props => [results];
}

@CopyWith()
@JsonSerializable(explicitToJson: true)
class RandomUserResultModel extends Equatable {
  final RandomUserNameModel name;
  final RandomUserLoginModel login;
  final RandomUserPictureModel? picture;

  const RandomUserResultModel({
    required this.name,
    required this.login,
    this.picture,
  });

  factory RandomUserResultModel.fromJson(Map<String, dynamic> json) =>
      _$RandomUserResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$RandomUserResultModelToJson(this);

  @override
  List<Object?> get props => [name, login, picture];
}

@CopyWith()
@JsonSerializable(explicitToJson: true)
class RandomUserNameModel extends Equatable {
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String first;
  @JsonKey(defaultValue: '')
  final String last;

  const RandomUserNameModel({
    this.title = '',
    this.first = '',
    this.last = '',
  });

  factory RandomUserNameModel.fromJson(Map<String, dynamic> json) =>
      _$RandomUserNameModelFromJson(json);

  Map<String, dynamic> toJson() => _$RandomUserNameModelToJson(this);

  @override
  List<Object?> get props => [title, first, last];
}

@CopyWith()
@JsonSerializable(explicitToJson: true)
class RandomUserLoginModel extends Equatable {
  @JsonKey(defaultValue: '')
  final String uuid;
  @JsonKey(defaultValue: '')
  final String username;

  const RandomUserLoginModel({
    this.uuid = '',
    this.username = '',
  });

  factory RandomUserLoginModel.fromJson(Map<String, dynamic> json) =>
      _$RandomUserLoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$RandomUserLoginModelToJson(this);

  @override
  List<Object?> get props => [uuid, username];
}

@CopyWith()
@JsonSerializable(explicitToJson: true)
class RandomUserPictureModel extends Equatable {
  final String? large;
  final String? medium;
  final String? thumbnail;

  const RandomUserPictureModel({
    this.large,
    this.medium,
    this.thumbnail,
  });

  factory RandomUserPictureModel.fromJson(Map<String, dynamic> json) =>
      _$RandomUserPictureModelFromJson(json);

  Map<String, dynamic> toJson() => _$RandomUserPictureModelToJson(this);

  @override
  List<Object?> get props => [large, medium, thumbnail];
}
