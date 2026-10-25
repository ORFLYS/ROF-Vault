// File generated for ROF Vault Firebase configuration
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        return windows;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAkD-kWRZIwMMDS9OqtylQz2LlZRkDB_VA',
    appId: '1:223442812537:android:0f2bd95d4c8799d8925ea8',
    messagingSenderId: '223442812537',
    projectId: 'scs-vault',
    storageBucket: 'scs-vault.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAkD-kWRZIwMMDS9OqtylQz2LlZRkDB_VA',
    appId: '1:223442812537:android:0f2bd95d4c8799d8925ea8',
    messagingSenderId: '223442812537',
    projectId: 'scs-vault',
    storageBucket: 'scs-vault.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAkD-kWRZIwMMDS9OqtylQz2LlZRkDB_VA',
    appId: '1:223442812537:web:scsvaultweb',
    messagingSenderId: '223442812537',
    projectId: 'scs-vault',
    storageBucket: 'scs-vault.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAkD-kWRZIwMMDS9OqtylQz2LlZRkDB_VA',
    appId: '1:223442812537:ios:scsvaultios',
    messagingSenderId: '223442812537',
    projectId: 'scs-vault',
    storageBucket: 'scs-vault.firebasestorage.app',
    iosBundleId: 'com.antigravity.scsvault',
  );
}
