import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthBase {
  User get currentUser;
  Future<User> signInWithGoogle();
  Stream<User> authStateChanges();
  Future<void> singOut();
}

class Auth implements AuthBase {
  final firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<User> authStateChanges() => firebaseAuth.authStateChanges();

  @override
  User get currentUser => firebaseAuth.currentUser;

  @override
  Future<User> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken != null) {
        final userCredential = await firebaseAuth
            .signInWithCredential(GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        ));
        return userCredential.user;
      } else {
        throw FirebaseAuthException(
            code: 'ERROR_MISSING_GOOGLE_ID_TOKEN',
            message: 'Missing Google id token');
      }
    } else {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in arborted by user',
      );
    }
  }

  @override
  Future<void> singOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }
}
