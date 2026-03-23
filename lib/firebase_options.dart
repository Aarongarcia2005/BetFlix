import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase configuration for BetFlix
/// Project: betflix-955fc
/// Sender ID: 279904923799
/// Package: betflix.com
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAIp9l_-7L6x5L6x5L6x5L6x5L6x5L6x5L',
    appId: '1:279904923799:web:c2a338013ea4457934f9d2',
    messagingSenderId: '279904923799',
    projectId: 'betflix-955fc',
    authDomain: 'betflix-955fc.firebaseapp.com',
    databaseURL: 'https://betflix-955fc.firebaseio.com',
    storageBucket: 'betflix-955fc.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAIp9l_-7L6x5L6x5L6x5L6x5L6x5L6x5L',
    appId: '1:279904923799:android:c2a338013ea4457934f9d2',
    messagingSenderId: '279904923799',
    projectId: 'betflix-955fc',
    databaseURL: 'https://betflix-955fc.firebaseio.com',
    storageBucket: 'betflix-955fc.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAIp9l_-7L6x5L6x5L6x5L6x5L6x5L6x5L',
    appId: '1:279904923799:ios:c2a338013ea4457934f9d2',
    messagingSenderId: '279904923799',
    projectId: 'betflix-955fc',
    databaseURL: 'https://betflix-955fc.firebaseio.com',
    storageBucket: 'betflix-955fc.appspot.com',
  );
}
