import 'package:firebase/firebase.dart' as fb;

class FirebaseHelper {
  static fb.Database initDatabase() {
    try {
      if (fb.apps.isEmpty) {
        fb.initializeApp(
          apiKey: "add_your_own",
          authDomain: "add_your_own",
          databaseURL: "add_your_own",
          projectId: "add_your_own",
          messagingSenderId: "add_your_own",
        );
      }
    } on fb.FirebaseJsNotLoadedException catch (e) {
      print(e);
    }
    return fb.database();
  }
}
