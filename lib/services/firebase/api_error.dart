import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

/// Strongly-typed API and Firebase error handler that maps low-level
/// platform/network/Firestore exceptions to human-readable user messages.
class ApiError {
  final String code;
  final String userMessage;
  final String? technicalDetails;
  final Object? originalException;

  const ApiError({
    required this.code,
    required this.userMessage,
    this.technicalDetails,
    this.originalException,
  });

  @override
  String toString() => 'ApiError(code: $code, message: $userMessage)';

  /// Analyzes any caught exception and maps it to a structured [ApiError].
  factory ApiError.fromException(Object error) {
    if (error is FirebaseException) {
      return ApiError._fromFirebaseException(error);
    } else if (error is SocketException) {
      return const ApiError(
        code: 'no_internet',
        userMessage:
            'No internet connection. Please check your network settings and try again.',
      );
    } else if (error is TimeoutException) {
      return const ApiError(
        code: 'timeout',
        userMessage:
            'Connection timed out. The server took too long to respond.',
      );
    } else if (error is FormatException) {
      return const ApiError(
        code: 'invalid_format',
        userMessage: 'Invalid data format received.',
      );
    }

    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('connection')) {
      return const ApiError(
        code: 'network_error',
        userMessage: 'Network error encountered. Please check your connection.',
      );
    }

    return ApiError(
      code: 'unexpected_error',
      userMessage: 'Something went wrong. Please try again.',
      technicalDetails: error.toString(),
      originalException: error,
    );
  }

  static ApiError _fromFirebaseException(FirebaseException exception) {
    final code = exception.code.toLowerCase().trim();
    switch (code) {
      case 'permission-denied':
        return ApiError(
          code: code,
          userMessage:
              'You do not have permission to perform this action in this room.',
          originalException: exception,
        );
      case 'unavailable':
        return ApiError(
          code: code,
          userMessage:
              'Chat service is temporarily unavailable. Reconnecting...',
          originalException: exception,
        );
      case 'not-found':
        return ApiError(
          code: code,
          userMessage: 'The requested room or message could not be found.',
          originalException: exception,
        );
      case 'already-exists':
        return ApiError(
          code: code,
          userMessage:
              'This room code is already active. Please enter a different code or join it directly.',
          originalException: exception,
        );
      case 'resource-exhausted':
        return ApiError(
          code: code,
          userMessage:
              'Rate limit exceeded. Please wait a few seconds before trying again.',
          originalException: exception,
        );
      case 'cancelled':
        return ApiError(
          code: code,
          userMessage: 'The operation was cancelled.',
          originalException: exception,
        );
      case 'data-loss':
        return ApiError(
          code: code,
          userMessage:
              'Unrecoverable data loss occurred. Please rejoin the room.',
          originalException: exception,
        );
      case 'unauthenticated':
        return ApiError(
          code: code,
          userMessage:
              'Session expired or unauthenticated. Please relaunch the app.',
          originalException: exception,
        );
      case 'deadline-exceeded':
        return ApiError(
          code: code,
          userMessage:
              'Operation timed out. Please check your connection and retry.',
          originalException: exception,
        );
      case 'failed-precondition':
        return ApiError(
          code: code,
          userMessage:
              'Unable to perform operation because the room state has changed.',
          originalException: exception,
        );
      case 'out-of-range':
        return ApiError(
          code: code,
          userMessage: 'Message or room parameter is out of valid range.',
          originalException: exception,
        );
      case 'unimplemented':
        return ApiError(
          code: code,
          userMessage:
              'This action is not supported by the current server protocol.',
          originalException: exception,
        );
      case 'internal':
        return ApiError(
          code: code,
          userMessage:
              'A backend service error occurred. Please try again shortly.',
          originalException: exception,
        );
      case 'invalid-argument':
        return ApiError(
          code: code,
          userMessage: 'Invalid room or message content provided.',
          originalException: exception,
        );
      case 'network-request-failed':
        return ApiError(
          code: code,
          userMessage:
              'Network request failed. Please check your network connection.',
          originalException: exception,
        );
      default:
        return ApiError(
          code: code.isNotEmpty ? code : 'firebase_error',
          userMessage: exception.message?.isNotEmpty == true
              ? exception.message!
              : 'Service error encountered. Please try again shortly.',
          technicalDetails: exception.message,
          originalException: exception,
        );
    }
  }
}
