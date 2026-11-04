import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour/features/room/data/repositories/room_repository.dart';
import 'package:rumour/features/room/presentation/bloc/room_event.dart';
import 'package:rumour/features/room/presentation/bloc/room_state.dart';
import 'package:rumour/services/logger/logger_service.dart';
import 'package:rumour/services/firebase/api_error.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  static const String _tag = 'RoomBloc';
  final RoomRepository roomRepository;

  RoomBloc({required this.roomRepository}) : super(const RoomInitial()) {
    on<RoomCodeChanged>(_onRoomCodeChanged);
    on<JoinRoomSubmitted>(_onJoinRoomSubmitted);
    on<CreateRoomSubmitted>(_onCreateRoomSubmitted);
  }

  void _onRoomCodeChanged(RoomCodeChanged event, Emitter<RoomState> emit) {
    emit(RoomInitial(roomCode: event.roomCode.toUpperCase()));
  }

  Future<void> _onJoinRoomSubmitted(
    JoinRoomSubmitted event,
    Emitter<RoomState> emit,
  ) async {
    final cleanCode = event.roomCode.trim().toUpperCase();
    LoggerService.info('Join room submitted for code: "$cleanCode"', tag: _tag);

    if (cleanCode.length < 4) {
      LoggerService.warn('Room code "$cleanCode" is less than 4 characters',
          tag: _tag);
      emit(const RoomJoinFailure('Please enter at least 4 characters'));
      return;
    }

    emit(RoomJoining(cleanCode));

    try {
      final identityResult =
          await roomRepository.getOrCreateIdentity(cleanCode);
      LoggerService.info(
        'Identity for room $cleanCode: "${identityResult.identity.displayName}" (isNew: ${identityResult.isNew})',
        tag: _tag,
      );

      final room = await roomRepository.joinOrCreateRoom(
        roomCode: cleanCode,
        identity: identityResult.identity,
      );

      LoggerService.info(
        'Successfully joined room ${room.code} with memberCount ${room.memberCount}',
        tag: _tag,
      );

      emit(RoomJoinedSuccess(
        identity: identityResult.identity,
        room: room,
        isNewIdentity: identityResult.isNew,
      ));
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to join room $cleanCode',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      final apiError = ApiError.fromException(e);
      emit(RoomJoinFailure(apiError.userMessage));
    }
  }

  Future<void> _onCreateRoomSubmitted(
    CreateRoomSubmitted event,
    Emitter<RoomState> emit,
  ) async {
    LoggerService.info('Create room requested', tag: _tag);
    emit(const RoomCreating());

    try {
      final result = await roomRepository.createRoom();
      LoggerService.info(
        'Successfully created room ${result.room.code} with creator "${result.identity.displayName}"',
        tag: _tag,
      );

      emit(RoomJoinedSuccess(
        identity: result.identity,
        room: result.room,
        isNewIdentity: true,
      ));
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to create room',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      final apiError = ApiError.fromException(e);
      emit(RoomJoinFailure(apiError.userMessage));
    }
  }
}
