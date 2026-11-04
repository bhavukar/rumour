import 'package:equatable/equatable.dart';
import 'package:rumour/features/room/data/model/room_identity_model.dart';
import 'package:rumour/features/room/data/model/room_model.dart';

abstract class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {
  final String roomCode;

  const RoomInitial({this.roomCode = ''});

  @override
  List<Object?> get props => [roomCode];
}

class RoomJoining extends RoomState {
  final String roomCode;

  const RoomJoining(this.roomCode);

  @override
  List<Object?> get props => [roomCode];
}

class RoomCreating extends RoomState {
  const RoomCreating();

  @override
  List<Object?> get props => [];
}

class RoomJoinedSuccess extends RoomState {
  final RoomIdentityModel identity;
  final RoomModel room;
  final bool isNewIdentity;

  const RoomJoinedSuccess({
    required this.identity,
    required this.room,
    required this.isNewIdentity,
  });

  @override
  List<Object?> get props => [identity, room, isNewIdentity];
}

class RoomJoinFailure extends RoomState {
  final String error;

  const RoomJoinFailure(this.error);

  @override
  List<Object?> get props => [error];
}
