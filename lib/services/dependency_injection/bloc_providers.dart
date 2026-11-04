import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour/features/room/data/repositories/room_repository.dart';
import 'package:rumour/features/room/presentation/bloc/room_bloc.dart';
import 'package:rumour/services/network/connectivity_cubit.dart';
import 'package:rumour/services/storage/local_storage_service.dart';
import 'package:rumour/services/theme/theme_cubit.dart';

class BlocProviders extends StatelessWidget {
  final Widget child;

  const BlocProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(
            localStorageService: context.read<LocalStorageService>(),
          ),
        ),
        BlocProvider<ConnectivityCubit>(
          create: (_) => ConnectivityCubit(),
        ),
        BlocProvider<RoomBloc>(
          create: (context) => RoomBloc(
            roomRepository: context.read<RoomRepository>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
