// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCKIkD7Ll4RhwvOm0Q7HDVVdvfpi_Dp__k',
    appId: '1:691182546838:web:54de0ee796b1cd0038b7b7',
    messagingSenderId: '691182546838',
    projectId: 'chatoid-8e188',
    authDomain: 'chatoid-8e188.firebaseapp.com',
    storageBucket: 'chatoid-8e188.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMSvMO7fZHPQQ1y27Fukg3Ipk7ipzvbuI',
    appId: '1:691182546838:android:90842747eb01c57a38b7b7',
    messagingSenderId: '691182546838',
    projectId: 'chatoid-8e188',
    storageBucket: 'chatoid-8e188.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD7S4NeROlG3lxGBaSGlYLQwXzzJ5v9tP4',
    appId: '1:691182546838:ios:dc2a0b9fef8711e138b7b7',
    messagingSenderId: '691182546838',
    projectId: 'chatoid-8e188',
    storageBucket: 'chatoid-8e188.appspot.com',
    iosBundleId: 'com.example.chatoid',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD7S4NeROlG3lxGBaSGlYLQwXzzJ5v9tP4',
    appId: '1:691182546838:ios:dc2a0b9fef8711e138b7b7',
    messagingSenderId: '691182546838',
    projectId: 'chatoid-8e188',
    storageBucket: 'chatoid-8e188.appspot.com',
    iosBundleId: 'com.example.chatoid',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCKIkD7Ll4RhwvOm0Q7HDVVdvfpi_Dp__k',
    appId: '1:691182546838:web:7203d0b1b73f114038b7b7',
    messagingSenderId: '691182546838',
    projectId: 'chatoid-8e188',
    authDomain: 'chatoid-8e188.firebaseapp.com',
    storageBucket: 'chatoid-8e188.appspot.com',
  );
}