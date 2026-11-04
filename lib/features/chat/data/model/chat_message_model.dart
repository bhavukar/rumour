import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rumour/utilities/timestamp_converter.dart';

part 'chat_message_model.g.dart';

@CopyWith()
@JsonSerializable(explicitToJson: true)
class ChatMessageModel extends Equatable {
  final String id;
  @JsonKey(defaultValue: '')
  final String roomId;
  @JsonKey(defaultValue: 'anonymous')
  final String senderId;
  @JsonKey(defaultValue: 'Anonymous')
  final String senderName;
  @JsonKey(defaultValue: '')
  final String senderMention;
  final String? senderAvatarUrl;
  @JsonKey(defaultValue: '')
  final String text;
  @TimestampConverter()
  final DateTime createdAt;
  @JsonKey(defaultValue: 'text')
  final String type;
  final String? replyToId;
  final String? replyToSenderName;
  final String? replyToText;
  @JsonKey(defaultValue: false)
  final bool isPending;

  const ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.senderName = 'Anonymous',
    this.senderMention = '',
    this.senderAvatarUrl,
    this.text = '',
    required this.createdAt,
    this.type = 'text',
    this.replyToId,
    this.replyToSenderName,
    this.replyToText,
    this.isPending = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  factory ChatMessageModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChatMessageModel.fromJson({
      ...data,
      'id': doc.id,
      'roomId': data['roomId'] ?? doc.reference.parent.parent?.id ?? '',
      'senderId': data['senderId'] ?? 'anonymous',
      'senderName': data['senderName'] ?? 'Anonymous',
      'text': data['text'] ?? '',
      'isPending': doc.metadata.hasPendingWrites,
    });
  }

  Map<String, dynamic> toFirestore() {
    final data = toJson();
    data['id'] = id;
    data.remove('isPending');
    data['createdAt'] = FieldValue.serverTimestamp();
    if (senderAvatarUrl == null || senderAvatarUrl!.isEmpty) {
      data.remove('senderAvatarUrl');
    }
    if (replyToId == null || replyToId!.isEmpty) {
      data.remove('replyToId');
    }
    if (replyToSenderName == null || replyToSenderName!.isEmpty) {
      data.remove('replyToSenderName');
    }
    if (replyToText == null || replyToText!.isEmpty) {
      data.remove('replyToText');
    }
    return data;
  }

  bool isMine(String currentUserId) => senderId == currentUserId;

  bool get isReply => replyToText != null && replyToText!.isNotEmpty;

  bool get isSystem => type == 'system';

  @override
  List<Object?> get props => [
        id,
        roomId,
        senderId,
        senderName,
        senderMention,
        senderAvatarUrl,
        text,
        createdAt,
        type,
        replyToId,
        replyToSenderName,
        replyToText,
        isPending,
      ];
}
