class AuthState {
  static bool _isSignedIn = false;
  
  static bool get isSignedIn => _isSignedIn;
  
  static void signIn() {
    _isSignedIn = true;
  }
  
  static void signOut() {
    _isSignedIn = false;
  }
}
