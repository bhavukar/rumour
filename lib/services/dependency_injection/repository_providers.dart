import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour/features/chat/data/repositories/chat_repository.dart';
import 'package:rumour/features/chat/data/source/chat_remote_source.dart';
import 'package:rumour/features/room/data/repositories/room_repository.dart';
import 'package:rumour/features/room/data/source/room_local_source.dart';
import 'package:rumour/features/room/data/source/room_remote_source.dart';
import 'package:rumour/services/storage/local_storage_service.dart';

class RepositoryProviders extends StatelessWidget {
  final Widget child;
  final LocalStorageService localStorageService;

  const RepositoryProviders({
    super.key,
    required this.child,
    required this.localStorageService,
  });

  @override
  Widget build(BuildContext context) {
    final roomLocalSource =
        RoomLocalSource(storageService: localStorageService);
    final roomRemoteSource = RoomRemoteSource();
    final chatRemoteSource = ChatRemoteSource();

    final roomRepository = RoomRepository(
      localSource: roomLocalSource,
      remoteSource: roomRemoteSource,
    );

    final chatRepository = ChatRepository(
      remoteSource: chatRemoteSource,
      localStorageService: localStorageService,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalStorageService>.value(
            value: localStorageService),
        RepositoryProvider<RoomLocalSource>.value(value: roomLocalSource),
        RepositoryProvider<RoomRemoteSource>.value(value: roomRemoteSource),
        RepositoryProvider<ChatRemoteSource>.value(value: chatRemoteSource),
        RepositoryProvider<RoomRepository>.value(value: roomRepository),
        RepositoryProvider<ChatRepository>.value(value: chatRepository),
      ],
      child: child,
    );
  }
}
