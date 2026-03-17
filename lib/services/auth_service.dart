import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email & password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw AuthException('Email đã được sử dụng');
      } else {
        throw AuthException(e.message ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      throw AuthException('Đăng ký thất bại');
    }
  }

  // Login with email & password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw AuthException('Sai mật khẩu');
      } else if (e.code == 'user-not-found') {
        throw AuthException('Tài khoản không tồn tại');
      } else {
        throw AuthException(e.message ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      throw AuthException('Đăng nhập thất bại');
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
