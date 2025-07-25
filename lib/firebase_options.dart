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
    apiKey: 'AIzaSyBJXgkYFgg_2a4ysCaNo2LfFB0e60smiFo',
    appId: '1:748051239619:web:69c4a5687839084bd28876',
    messagingSenderId: '748051239619',
    projectId: 'meduminder',
    authDomain: 'meduminder.firebaseapp.com',
    storageBucket: 'meduminder.firebasestorage.app',
    measurementId: 'G-TG3H34SJJK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDnlyRIeCtE-ma2XFcNBA4e37H5axz0jF8',
    appId: '1:748051239619:android:131714ecd9abb67dd28876',
    messagingSenderId: '748051239619',
    projectId: 'meduminder',
    storageBucket: 'meduminder.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWAA3xmFiHEn4dCYcMYwC5Y2QXQux8RSA',
    appId: '1:748051239619:ios:e2d6abe615b0f4bed28876',
    messagingSenderId: '748051239619',
    projectId: 'meduminder',
    storageBucket: 'meduminder.firebasestorage.app',
    iosBundleId: 'com.example.meduminder',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCWAA3xmFiHEn4dCYcMYwC5Y2QXQux8RSA',
    appId: '1:748051239619:ios:e2d6abe615b0f4bed28876',
    messagingSenderId: '748051239619',
    projectId: 'meduminder',
    storageBucket: 'meduminder.firebasestorage.app',
    iosBundleId: 'com.example.meduminder',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBJXgkYFgg_2a4ysCaNo2LfFB0e60smiFo',
    appId: '1:748051239619:web:4a78c65d54c04805d28876',
    messagingSenderId: '748051239619',
    projectId: 'meduminder',
    authDomain: 'meduminder.firebaseapp.com',
    storageBucket: 'meduminder.firebasestorage.app',
    measurementId: 'G-73357D0X3Q',
  );
}
