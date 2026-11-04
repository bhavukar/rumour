import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour/features/chat/data/model/chat_message_model.dart';
import 'package:rumour/features/chat/data/repositories/chat_repository.dart';
import 'package:rumour/features/chat/presentation/bloc/chat_event.dart';
import 'package:rumour/features/chat/presentation/bloc/chat_state.dart';
import 'package:rumour/services/logger/logger_service.dart';
import 'package:rumour/services/firebase/api_error.dart';
import 'package:uuid/uuid.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  static const String _tag = 'ChatBloc';
  final ChatRepository chatRepository;
  final String roomCode;
  final String? currentUserId;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _messagesSubscription;
  final Set<String> _olderMessageIds = {};

  ChatBloc({
    required this.chatRepository,
    required this.roomCode,
    this.currentUserId,
  }) : super(ChatInitial()) {
    on<ChatStarted>(_onChatStarted);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<LoadOlderMessages>(_onLoadOlderMessages);
    on<MessageSent>(_onMessageSent);
  }

  void _onChatStarted(ChatStarted event, Emitter<ChatState> emit) {
    LoggerService.info('Starting chat stream for room: ${event.roomCode}',
        tag: _tag);

    final cached = chatRepository.getCachedMessages(event.roomCode);
    if (cached.isNotEmpty) {
      LoggerService.info(
        'Instantly loaded ${cached.length} cached messages from local storage for room ${event.roomCode}',
        tag: _tag,
      );
      emit(ChatLoaded(messages: cached, hasMoreOlder: true));
    } else {
      emit(ChatLoading());
    }

    _messagesSubscription?.cancel();
    _messagesSubscription =
        chatRepository.streamMessagesSnapshot(event.roomCode).listen(
      (snapshot) {
        final streamed = snapshot.docs
            .map((doc) => ChatMessageModel.fromFirestore(doc))
            .toList();

        final oldest = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        LoggerService.debug(
          'Received stream update for room ${event.roomCode}: ${streamed.length} messages',
          tag: _tag,
        );

        add(MessagesUpdated(messages: streamed, oldestDoc: oldest));
      },
      onError: (error, stackTrace) {
        LoggerService.error(
          'Error in chat stream for room ${event.roomCode}',
          tag: _tag,
          error: error,
          stackTrace: stackTrace,
        );
        emit(ChatError(error.toString()));
      },
    );
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    DocumentSnapshot<Map<String, dynamic>>? lastDoc;
    List<ChatMessageModel> existingOlder = [];

    if (state is ChatLoaded) {
      final current = state as ChatLoaded;
      lastDoc = current.lastDocument ?? event.oldestDoc;
      existingOlder = current.messages
          .where((m) => _olderMessageIds.contains(m.id))
          .toList();
    } else {
      lastDoc = event.oldestDoc;
    }

    final combined = <ChatMessageModel>[...event.messages];
    for (final old in existingOlder) {
      if (!combined.any((m) => m.id == old.id)) {
        combined.add(old);
      }
    }

    if (state is ChatLoaded) {
      final current = state as ChatLoaded;
      for (final pending in current.messages.where((m) => m.isPending)) {
        if (!combined.any((m) => m.id == pending.id)) {
          combined.add(pending);
        }
      }
    }

    combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    chatRepository.cacheMessages(roomCode, combined);

    emit(ChatLoaded(
      messages: combined,
      lastDocument: lastDoc,
      hasMoreOlder:
          (state is ChatLoaded) ? (state as ChatLoaded).hasMoreOlder : true,
    ));
  }

  Future<void> _onLoadOlderMessages(
    LoadOlderMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    if (current.isLoadingOlder ||
        !current.hasMoreOlder ||
        current.lastDocument == null) {
      return;
    }

    LoggerService.info('Loading older messages for room $roomCode...',
        tag: _tag);
    emit(current.copyWith(isLoadingOlder: true));

    try {
      final result = await chatRepository.fetchOlderMessages(
        roomCode: roomCode,
        lastDocument: current.lastDocument!,
      );

      for (final msg in result.messages) {
        _olderMessageIds.add(msg.id);
      }

      final existingIds = current.messages.map((m) => m.id).toSet();
      final newUnique =
          result.messages.where((m) => !existingIds.contains(m.id)).toList();

      final combined = [...current.messages, ...newUnique];
      combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      LoggerService.info(
        'Appended ${newUnique.length} older messages (total: ${combined.length}, hasMore: ${result.hasMore})',
        tag: _tag,
      );

      emit(current.copyWith(
          messages: combined,
          isLoadingOlder: false,
          hasMoreOlder: result.hasMore,
          lastDocument: result.lastVisible ?? current.lastDocument));
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to load older messages for room $roomCode',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      final apiError = ApiError.fromException(e);
      emit(current.copyWith(
          isLoadingOlder: false, errorMessage: apiError.userMessage));
    }
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final clean = event.text.trim();
    if (clean.isEmpty) return;

    if (state is ChatLoaded) {
      final current = state as ChatLoaded;
      final optimisticId = const Uuid().v4();
      final optimisticMessage = ChatMessageModel(
        id: optimisticId,
        roomId: roomCode,
        senderId: event.sender.id,
        senderName: event.sender.displayName,
        senderMention: event.sender.mentionTag,
        senderAvatarUrl: event.sender.avatarUrl,
        text: clean,
        createdAt: DateTime.now(),
        type: 'text',
        replyToId: event.replyTo?.id,
        replyToSenderName: event.replyTo?.senderName,
        replyToText: event.replyTo?.text,
        isPending: true,
      );

      final optimisticList = [optimisticMessage, ...current.messages];
      chatRepository.cacheMessages(roomCode, optimisticList);
      emit(current.copyWith(messages: optimisticList, isSending: false));

      try {
        LoggerService.info(
            'Sending message in room $roomCode from ${event.sender.displayName}',
            tag: _tag);
        await chatRepository.sendMessage(
          roomCode: roomCode,
          sender: event.sender,
          text: clean,
          messageId: optimisticId,
          replyToId: event.replyTo?.id,
          replyToSenderName: event.replyTo?.senderName,
          replyToText: event.replyTo?.text,
        );
      } catch (e, stackTrace) {
        LoggerService.error(
          'Failed to send message in room $roomCode',
          tag: _tag,
          error: e,
          stackTrace: stackTrace,
        );
        final apiError = ApiError.fromException(e);
        emit(current.copyWith(errorMessage: apiError.userMessage));
      }
    }
  }

  @override
  Future<void> close() {
    LoggerService.debug('Closing chat bloc for room $roomCode', tag: _tag);
    _messagesSubscription?.cancel();
    return super.close();
  }
}
