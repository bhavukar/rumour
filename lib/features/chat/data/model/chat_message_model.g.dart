// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatMessageModelCWProxy {
  ChatMessageModel id(String id);

  ChatMessageModel roomId(String roomId);

  ChatMessageModel senderId(String senderId);

  ChatMessageModel senderName(String senderName);

  ChatMessageModel senderMention(String senderMention);

  ChatMessageModel senderAvatarUrl(String? senderAvatarUrl);

  ChatMessageModel text(String text);

  ChatMessageModel createdAt(DateTime createdAt);

  ChatMessageModel type(String type);

  ChatMessageModel replyToId(String? replyToId);

  ChatMessageModel replyToSenderName(String? replyToSenderName);

  ChatMessageModel replyToText(String? replyToText);

  ChatMessageModel isPending(bool isPending);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ChatMessageModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ChatMessageModel(...).copyWith(id: 12, name: "My name")
  /// ```
  ChatMessageModel call({
    String id,
    String roomId,
    String senderId,
    String senderName,
    String senderMention,
    String? senderAvatarUrl,
    String text,
    DateTime createdAt,
    String type,
    String? replyToId,
    String? replyToSenderName,
    String? replyToText,
    bool isPending,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfChatMessageModel.copyWith(...)` or call `instanceOfChatMessageModel.copyWith.fieldName(value)` for a single field.
class _$ChatMessageModelCWProxyImpl implements _$ChatMessageModelCWProxy {
  const _$ChatMessageModelCWProxyImpl(this._value);

  final ChatMessageModel _value;

  @override
  ChatMessageModel id(String id) => call(id: id);

  @override
  ChatMessageModel roomId(String roomId) => call(roomId: roomId);

  @override
  ChatMessageModel senderId(String senderId) => call(senderId: senderId);

  @override
  ChatMessageModel senderName(String senderName) =>
      call(senderName: senderName);

  @override
  ChatMessageModel senderMention(String senderMention) =>
      call(senderMention: senderMention);

  @override
  ChatMessageModel senderAvatarUrl(String? senderAvatarUrl) =>
      call(senderAvatarUrl: senderAvatarUrl);

  @override
  ChatMessageModel text(String text) => call(text: text);

  @override
  ChatMessageModel createdAt(DateTime createdAt) => call(createdAt: createdAt);

  @override
  ChatMessageModel type(String type) => call(type: type);

  @override
  ChatMessageModel replyToId(String? replyToId) => call(replyToId: replyToId);

  @override
  ChatMessageModel replyToSenderName(String? replyToSenderName) =>
      call(replyToSenderName: replyToSenderName);

  @override
  ChatMessageModel replyToText(String? replyToText) =>
      call(replyToText: replyToText);

  @override
  ChatMessageModel isPending(bool isPending) => call(isPending: isPending);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ChatMessageModel(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ChatMessageModel(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  ChatMessageModel call({
    Object? id = const $CopyWithPlaceholder(),
    Object? roomId = const $CopyWithPlaceholder(),
    Object? senderId = const $CopyWithPlaceholder(),
    Object? senderName = const $CopyWithPlaceholder(),
    Object? senderMention = const $CopyWithPlaceholder(),
    Object? senderAvatarUrl = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? replyToId = const $CopyWithPlaceholder(),
    Object? replyToSenderName = const $CopyWithPlaceholder(),
    Object? replyToText = const $CopyWithPlaceholder(),
    Object? isPending = const $CopyWithPlaceholder(),
  }) {
    return ChatMessageModel(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      roomId: roomId == const $CopyWithPlaceholder() || roomId == null
          ? _value.roomId
          // ignore: cast_nullable_to_non_nullable
          : roomId as String,
      senderId: senderId == const $CopyWithPlaceholder() || senderId == null
          ? _value.senderId
          // ignore: cast_nullable_to_non_nullable
          : senderId as String,
      senderName:
          senderName == const $CopyWithPlaceholder() || senderName == null
              ? _value.senderName
              // ignore: cast_nullable_to_non_nullable
              : senderName as String,
      senderMention:
          senderMention == const $CopyWithPlaceholder() || senderMention == null
              ? _value.senderMention
              // ignore: cast_nullable_to_non_nullable
              : senderMention as String,
      senderAvatarUrl: senderAvatarUrl == const $CopyWithPlaceholder()
          ? _value.senderAvatarUrl
          // ignore: cast_nullable_to_non_nullable
          : senderAvatarUrl as String?,
      text: text == const $CopyWithPlaceholder() || text == null
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String,
      replyToId: replyToId == const $CopyWithPlaceholder()
          ? _value.replyToId
          // ignore: cast_nullable_to_non_nullable
          : replyToId as String?,
      replyToSenderName: replyToSenderName == const $CopyWithPlaceholder()
          ? _value.replyToSenderName
          // ignore: cast_nullable_to_non_nullable
          : replyToSenderName as String?,
      replyToText: replyToText == const $CopyWithPlaceholder()
          ? _value.replyToText
          // ignore: cast_nullable_to_non_nullable
          : replyToText as String?,
      isPending: isPending == const $CopyWithPlaceholder() || isPending == null
          ? _value.isPending
          // ignore: cast_nullable_to_non_nullable
          : isPending as bool,
    );
  }
}

extension $ChatMessageModelCopyWith on ChatMessageModel {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfChatMessageModel.copyWith(...)` or `instanceOfChatMessageModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatMessageModelCWProxy get copyWith => _$ChatMessageModelCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? 'anonymous',
      senderName: json['senderName'] as String? ?? 'Anonymous',
      senderMention: json['senderMention'] as String? ?? '',
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      text: json['text'] as String? ?? '',
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      type: json['type'] as String? ?? 'text',
      replyToId: json['replyToId'] as String?,
      replyToSenderName: json['replyToSenderName'] as String?,
      replyToText: json['replyToText'] as String?,
      isPending: json['isPending'] as bool? ?? false,
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderMention': instance.senderMention,
      'senderAvatarUrl': instance.senderAvatarUrl,
      'text': instance.text,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'type': instance.type,
      'replyToId': instance.replyToId,
      'replyToSenderName': instance.replyToSenderName,
      'replyToText': instance.replyToText,
      'isPending': instance.isPending,
    };
