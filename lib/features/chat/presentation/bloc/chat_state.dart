import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:rumour/features/chat/data/model/chat_message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessageModel> messages;
  final bool isLoadingOlder;
  final bool hasMoreOlder;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool isSending;
  final String? errorMessage;

  const ChatLoaded({
    required this.messages,
    this.isLoadingOlder = false,
    this.hasMoreOlder = true,
    this.lastDocument,
    this.isSending = false,
    this.errorMessage,
  });

  ChatLoaded copyWith({
    List<ChatMessageModel>? messages,
    bool? isLoadingOlder,
    bool? hasMoreOlder,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    bool? isSending,
    String? errorMessage,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      lastDocument: lastDocument ?? this.lastDocument,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isLoadingOlder,
        hasMoreOlder,
        lastDocument,
        isSending,
        errorMessage,
      ];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
