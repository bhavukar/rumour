import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rumour/utilities/timestamp_converter.dart';

part 'room_member_model.g.dart';

@CopyWith()
@JsonSerializable(explicitToJson: true)
class RoomMemberModel extends Equatable {
  final String id;
  @JsonKey(defaultValue: 'Anonymous')
  final String displayName;
  final String? avatarUrl;
  @TimestampConverter()
  final DateTime joinedAt;

  const RoomMemberModel({
    required this.id,
    this.displayName = 'Anonymous',
    this.avatarUrl,
    required this.joinedAt,
  });

  factory RoomMemberModel.fromJson(Map<String, dynamic> json) =>
      _$RoomMemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomMemberModelToJson(this);

  Map<String, dynamic> toFirestore() {
    final data = toJson();
    data['id'] = id;
    data['joinedAt'] = FieldValue.serverTimestamp();
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      data.remove('avatarUrl');
    }
    return data;
  }

  factory RoomMemberModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return RoomMemberModel.fromJson({
      ...data,
      'id': snapshot.id,
    });
  }

  @override
  List<Object?> get props => [id, displayName, avatarUrl, joinedAt];
}
