import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour/services/logger/logger_service.dart';

enum ConnectivityStatus {
  connected,
  disconnected,
}

class ConnectivityState extends Equatable {
  final ConnectivityStatus status;
  final bool wasDisconnected;

  const ConnectivityState({
    required this.status,
    this.wasDisconnected = false,
  });

  bool get isConnected => status == ConnectivityStatus.connected;
  bool get isDisconnected => status == ConnectivityStatus.disconnected;

  ConnectivityState copyWith({
    ConnectivityStatus? status,
    bool? wasDisconnected,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      wasDisconnected: wasDisconnected ?? this.wasDisconnected,
    );
  }

  @override
  List<Object?> get props => [status, wasDisconnected];
}

class ConnectivityCubit extends Cubit<ConnectivityState>
    with WidgetsBindingObserver {
  static const String _tag = 'ConnectivityCubit';
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _disconnectDebounceTimer;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  ConnectivityCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(const ConnectivityState(status: ConnectivityStatus.connected)) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    if (state == AppLifecycleState.resumed) {
      checkConnection();
    } else {
      _disconnectDebounceTimer?.cancel();
    }
  }

  Future<void> _init() async {
    try {
      final initialResults = await _connectivity.checkConnectivity();
      _updateStatus(initialResults);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to check initial connectivity',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }

    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) => _updateStatus(results),
      onError: (e, stackTrace) {
        LoggerService.error(
          'Error in connectivity change stream',
          tag: _tag,
          error: e,
          stackTrace: stackTrace,
        );
      },
    );
  }

  Future<void> checkConnection() async {
    try {
      LoggerService.info('Manual connectivity check requested', tag: _tag);
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results, isManual: true);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error during manual connectivity check',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _updateStatus(List<ConnectivityResult> results,
      {bool isManual = false}) {
    final isNone =
        results.isEmpty || results.every((r) => r == ConnectivityResult.none);

    if (_lifecycleState != AppLifecycleState.resumed && !isManual) {
      return;
    }

    if (isNone) {
      if (_disconnectDebounceTimer == null ||
          !_disconnectDebounceTimer!.isActive) {
        _disconnectDebounceTimer?.cancel();
        _disconnectDebounceTimer =
            Timer(const Duration(milliseconds: 2500), () {
          if (!isClosed && _lifecycleState == AppLifecycleState.resumed) {
            LoggerService.warn(
              'Internet connection lost: Device confirmed offline',
              tag: _tag,
            );
            emit(state.copyWith(
                status: ConnectivityStatus.disconnected,
                wasDisconnected: true));
          }
        });
      }
    } else {
      _disconnectDebounceTimer?.cancel();

      if (state.isDisconnected || state.wasDisconnected) {
        LoggerService.info(
          'Internet connection active: $results',
          tag: _tag,
        );
      }
      emit(state.copyWith(status: ConnectivityStatus.connected));
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _disconnectDebounceTimer?.cancel();
    _subscription?.cancel();
    return super.close();
  }
}
