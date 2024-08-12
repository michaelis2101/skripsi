import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ta_web/models/user_model.dart';
import 'package:ta_web/services/user_service.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? get currentUser => auth.currentUser;

  Future<void> signInWithEmailAndPassword({
    required String userEmail,
    required String userPassword,
  }) async {
    await auth.signInWithEmailAndPassword(
        email: userEmail, password: userPassword);
  }

  Future<void> signUpWithEmailAndPassword({
    required String userEmail,
    required String userPassword,
  }) async {
    await auth.createUserWithEmailAndPassword(
        email: userEmail, password: userPassword);
    // await signOut();
  }

  Future<UserCredential> register(
      String email, String password, String username) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);

    UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
        .createUserWithEmailAndPassword(email: email, password: password);

    var user = FirebaseAuth.instanceFor(app: app).currentUser;

    UserModel newUser =
        UserModel(username: username, email: user!.email!, uid: user.uid);
    await UserService().addNewUser(newUser);
    await UserService().addNewUsertoSB(newUser);
    await UserService().newSetting(user.email!);

    await app.delete();
    return Future.sync(() => userCredential);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
