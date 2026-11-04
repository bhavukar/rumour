import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rumour/features/room/data/model/user_model.dart';
import 'package:rumour/services/analytics/analytics_service.dart';
import 'package:rumour/services/crashlytics/crashlytics_service.dart';
import 'package:rumour/services/firebase/firebase_options.dart';
import 'package:rumour/services/logger/logger_service.dart';

class FirebaseService {
  static const String _tag = 'FirebaseService';
  static FirebaseAuth? _mockAuth;
  static FirebaseFirestore? _mockFirestore;

  static void setMockInstances({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) {
    _mockAuth = auth;
    _mockFirestore = firestore;
  }

  static Future<void> initialize() async {
    try {
      LoggerService.info('Initializing Firebase...', tag: _tag);
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      LoggerService.info('Firebase & Firestore offline persistence enabled',
          tag: _tag);

      await ensureAnonymousAuth();
    } catch (e, stackTrace) {
      LoggerService.warn(
        'FirebaseService init warning (expected if running without live google-services in test environment): $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<User?> ensureAnonymousAuth() async {
    try {
      final auth = _mockAuth ?? FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user == null) {
        LoggerService.info('Signing in anonymously with Firebase Auth...',
            tag: _tag);
        final userCredential = await auth.signInAnonymously();
        user = userCredential.user;
        LoggerService.info(
            'Successfully signed in anonymously with UID: ${user?.uid}',
            tag: _tag);
      } else {
        LoggerService.debug(
            'Reusing existing Firebase Auth anonymous user: ${user.uid}',
            tag: _tag);
      }

      if (user != null) {
        CrashlyticsService.setUserIdentifier(user.uid);
        AnalyticsService.setUserId(user.uid);
        await syncUserToFirestore(user);
      }

      return user;
    } catch (e, stackTrace) {
      LoggerService.warn(
        'Anonymous auth failed (or offline/mock mode): $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static Future<void> syncUserToFirestore(User user) async {
    try {
      final userDocRef = firestore.collection('users').doc(user.uid);
      final docSnap = await userDocRef.get();

      if (!docSnap.exists) {
        final newUser = UserModel(
          id: user.uid,
          isAnonymous: user.isAnonymous,
          createdAt: DateTime.now(),
          lastSeenAt: DateTime.now(),
        );
        await userDocRef.set(newUser.toFirestoreCreate());
        LoggerService.info(
            'Created Firestore user document for anonymous UID: ${user.uid}',
            tag: _tag);
      } else {
        await userDocRef.update({
          'lastSeenAt': FieldValue.serverTimestamp(),
        });
        LoggerService.debug(
            'Updated lastSeenAt for user ${user.uid} in Firestore',
            tag: _tag);
      }
    } catch (e, stackTrace) {
      LoggerService.warn(
        'Failed to sync user ${user.uid} to Firestore ($e)',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static FirebaseFirestore get firestore =>
      _mockFirestore ?? FirebaseFirestore.instance;
  static FirebaseAuth get auth => _mockAuth ?? FirebaseAuth.instance;
  static User? get currentUser {
    try {
      return auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  static Future<User?> resetSession() async {
    try {
      final authInstance = _mockAuth ?? FirebaseAuth.instance;
      await authInstance.signOut();
      LoggerService.info(
        'Signed out of Firebase Auth. Creating new anonymous user...',
        tag: _tag,
      );
      return await ensureAnonymousAuth();
    } catch (e, stackTrace) {
      LoggerService.warn(
        'Error resetting anonymous session: $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
