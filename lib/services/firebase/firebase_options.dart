import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:rumour/services/firebase/env_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: EnvConfig.get('FIREBASE_API_KEY_ANDROID'),
        appId: EnvConfig.get('FIREBASE_APP_ID_ANDROID'),
        messagingSenderId: EnvConfig.get('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: EnvConfig.get('FIREBASE_PROJECT_ID'),
        storageBucket: EnvConfig.get('FIREBASE_STORAGE_BUCKET'),
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: EnvConfig.get('FIREBASE_API_KEY_IOS'),
        appId: EnvConfig.get('FIREBASE_APP_ID_IOS'),
        messagingSenderId: EnvConfig.get('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: EnvConfig.get('FIREBASE_PROJECT_ID'),
        storageBucket: EnvConfig.get('FIREBASE_STORAGE_BUCKET'),
        iosBundleId: 'com.voiceclub.rumour',
      );
}
