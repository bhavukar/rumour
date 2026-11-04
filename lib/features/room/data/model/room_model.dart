import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rumour/utilities/timestamp_converter.dart';

part 'room_model.g.dart';

@CopyWith()
@JsonSerializable(explicitToJson: true)
class RoomModel extends Equatable {
  final String code;
  @JsonKey(defaultValue: 1)
  final int memberCount;
  @TimestampConverter()
  final DateTime createdAt;
  @NullableTimestampConverter()
  final DateTime? lastMessageAt;
  final String? createdBy;
  final String? lastMessageText;
  final String? lastMessageSender;
  final String? lastMessageSenderId;

  const RoomModel({
    required this.code,
    this.memberCount = 1,
    required this.createdAt,
    this.lastMessageAt,
    this.createdBy,
    this.lastMessageText,
    this.lastMessageSender,
    this.lastMessageSenderId,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomModelToJson(this);

  Map<String, dynamic> toFirestore() {
    final data = toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    if (lastMessageAt != null) {
      data['lastMessageAt'] = Timestamp.fromDate(lastMessageAt!);
    } else {
      data.remove('lastMessageAt');
    }
    if (lastMessageText == null) data.remove('lastMessageText');
    if (lastMessageSender == null) data.remove('lastMessageSender');
    if (lastMessageSenderId == null) data.remove('lastMessageSenderId');
    return data;
  }

  factory RoomModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return RoomModel.fromJson({
      ...data,
      'code': snapshot.id,
    });
  }

  @override
  List<Object?> get props => [
        code,
        memberCount,
        createdAt,
        lastMessageAt,
        createdBy,
        lastMessageText,
        lastMessageSender,
        lastMessageSenderId,
      ];
}
