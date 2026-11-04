import 'package:equatable/equatable.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class RoomCodeChanged extends RoomEvent {
  final String roomCode;

  const RoomCodeChanged(this.roomCode);

  @override
  List<Object?> get props => [roomCode];
}

class JoinRoomSubmitted extends RoomEvent {
  final String roomCode;

  const JoinRoomSubmitted(this.roomCode);

  @override
  List<Object?> get props => [roomCode];
}

class CreateRoomSubmitted extends RoomEvent {
  const CreateRoomSubmitted();

  @override
  List<Object?> get props => [];
}
