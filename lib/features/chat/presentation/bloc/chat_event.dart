import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:rumour/features/chat/data/model/chat_message_model.dart';
import 'package:rumour/features/room/data/model/room_identity_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {
  final String roomCode;

  const ChatStarted(this.roomCode);

  @override
  List<Object?> get props => [roomCode];
}

class MessagesUpdated extends ChatEvent {
  final List<ChatMessageModel> messages;
  final DocumentSnapshot<Map<String, dynamic>>? oldestDoc;

  const MessagesUpdated({
    required this.messages,
    this.oldestDoc,
  });

  @override
  List<Object?> get props => [messages, oldestDoc];
}

class LoadOlderMessages extends ChatEvent {}

class MessageSent extends ChatEvent {
  final RoomIdentityModel sender;
  final String text;
  final ChatMessageModel? replyTo;

  const MessageSent({
    required this.sender,
    required this.text,
    this.replyTo,
  });

  @override
  List<Object?> get props => [sender, text, replyTo];
}
