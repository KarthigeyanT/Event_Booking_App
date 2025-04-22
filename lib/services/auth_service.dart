import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    } catch (e) {
      throw const AuthException();
    }
  }

  static Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    } catch (e) {
      throw const AuthException();
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  static Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    }
  }
}

class AuthException implements Exception {
  final String message;
  
  const AuthException([this.message = 'An unknown error occurred']);

  factory AuthException.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const AuthException('Email is not valid');
      case 'user-disabled':
        return const AuthException('This account has been disabled');
      case 'user-not-found':
        return const AuthException('No account found with this email');
      case 'wrong-password':
        return const AuthException('Incorrect password');
      case 'email-already-in-use':
        return const AuthException('Email already in use');
      case 'operation-not-allowed':
        return const AuthException('Operation not allowed');
      case 'weak-password':
        return const AuthException('Password is too weak');
      default:
        return const AuthException();
    }
  }
}
