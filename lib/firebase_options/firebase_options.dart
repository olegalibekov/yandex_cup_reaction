// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDr8nFgvzIyXYaMKMT8E-Xl49_rhSacoyw',
    appId: '1:1001121796318:android:f5e7e46bb8eeddf76ab24f',
    messagingSenderId: '1001121796318',
    projectId: 'yandexcupreaction',
    storageBucket: 'yandexcupreaction.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCBxHNujIGwJsVBCSdOtgHT4qfEFDW5Yu8',
    appId: '1:1001121796318:ios:74be0a97c5fe15196ab24f',
    messagingSenderId: '1001121796318',
    projectId: 'yandexcupreaction',
    storageBucket: 'yandexcupreaction.appspot.com',
    iosClientId: '1001121796318-tv799fl4svsjvmo2dspf6uc0c66a6te2.apps.googleusercontent.com',
    iosBundleId: 'com.example.yandexCupReaction',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCBxHNujIGwJsVBCSdOtgHT4qfEFDW5Yu8',
    appId: '1:1001121796318:ios:74be0a97c5fe15196ab24f',
    messagingSenderId: '1001121796318',
    projectId: 'yandexcupreaction',
    storageBucket: 'yandexcupreaction.appspot.com',
    iosClientId: '1001121796318-tv799fl4svsjvmo2dspf6uc0c66a6te2.apps.googleusercontent.com',
    iosBundleId: 'com.example.yandexCupReaction',
  );
}
