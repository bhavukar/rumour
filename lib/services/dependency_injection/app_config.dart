import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour/components/connectivity_banner.dart';
import 'package:rumour/config/themes/app_theme.dart';
import 'package:rumour/services/dependency_injection/bloc_providers.dart';
import 'package:rumour/services/dependency_injection/repository_providers.dart';
import 'package:rumour/services/routes/app_router.dart';
import 'package:rumour/services/storage/local_storage_service.dart';
import 'package:rumour/services/theme/theme_cubit.dart';

class AppConfiguration extends StatelessWidget {
  final LocalStorageService localStorageService;

  const AppConfiguration({
    super.key,
    required this.localStorageService,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProviders(
      localStorageService: localStorageService,
      child: BlocProviders(
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'Rumour',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: AppRouter.router,
              builder: (context, child) => ConnectivityOverlay(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}
