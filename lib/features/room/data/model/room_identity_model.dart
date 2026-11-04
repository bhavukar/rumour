import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rumour/utilities/timestamp_converter.dart';

part 'room_identity_model.g.dart';

@CopyWith()
@JsonSerializable(explicitToJson: true)
class RoomIdentityModel extends Equatable {
  final String id;
  final String roomId;
  @JsonKey(defaultValue: 'Brave Badger')
  final String displayName;
  final String mentionTag;
  final String? avatarUrl;
  @TimestampConverter()
  final DateTime createdAt;

  const RoomIdentityModel({
    required this.id,
    required this.roomId,
    this.displayName = 'Brave Badger',
    required this.mentionTag,
    this.avatarUrl,
    required this.createdAt,
  });

  factory RoomIdentityModel.fromJson(Map<String, dynamic> json) =>
      _$RoomIdentityModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomIdentityModelToJson(this);

  static RoomIdentityModel fromJsonString(String source) =>
      RoomIdentityModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toJsonString() => json.encode(toJson());

  Map<String, dynamic> toFirestore() {
    final data = toJson();
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();
    return data;
  }

  factory RoomIdentityModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return RoomIdentityModel.fromJson({
      ...data,
      'id': snapshot.id,
    });
  }

  @override
  List<Object?> get props =>
      [id, roomId, displayName, mentionTag, avatarUrl, createdAt];
}
