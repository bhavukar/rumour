import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rumour/utilities/timestamp_converter.dart';

part 'user_model.g.dart';

@CopyWith()
@JsonSerializable(explicitToJson: true)
class UserModel extends Equatable {
  final String id;
  @JsonKey(defaultValue: true)
  final bool isAnonymous;
  @TimestampConverter()
  final DateTime createdAt;
  @TimestampConverter()
  final DateTime lastSeenAt;
  final String? displayName;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    this.isAnonymous = true,
    required this.createdAt,
    required this.lastSeenAt,
    this.displayName,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return UserModel.fromJson({
      ...data,
      'id': snapshot.id,
    });
  }

  Map<String, dynamic> toFirestoreCreate() {
    final data = toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['lastSeenAt'] = FieldValue.serverTimestamp();
    if (displayName == null || displayName!.isEmpty) {
      data.remove('displayName');
    }
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      data.remove('avatarUrl');
    }
    return data;
  }

  Map<String, dynamic> toFirestoreUpdate() {
    return {
      'lastSeenAt': FieldValue.serverTimestamp(),
      if (displayName != null) 'displayName': displayName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }

  @override
  List<Object?> get props =>
      [id, isAnonymous, createdAt, lastSeenAt, displayName, avatarUrl];
}
