import 'auth_service.dart';

class AuthState {
  static bool get isSignedIn => AuthService.instance.isAuthenticated;
  static User? get currentUser => AuthService.instance.currentUser;
  
  static void signIn() {
    // Kept for backwards compatibility, but actual sign in happens through AuthService
  }
  
  static void signOut() {
    AuthService.instance.signOut();
  }
}
