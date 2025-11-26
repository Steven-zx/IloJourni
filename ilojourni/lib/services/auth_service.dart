import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class User {
  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'createdAt': createdAt.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._();
  AuthService._();
  static AuthService get instance => _instance;

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _passwordsKey = 'user_passwords';

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      
      if (userJson != null) {
        _currentUser = User.fromJson(json.decode(userJson) as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      // print('Error initializing auth: $e');
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (fullName.trim().isEmpty) {
        return {'success': false, 'message': 'Full name is required'};
      }
      if (email.trim().isEmpty || !email.contains('@')) {
        return {'success': false, 'message': 'Please enter a valid email'};
      }
      if (password.length < 6) {
        return {'success': false, 'message': 'Password must be at least 6 characters'};
      }

      final prefs = await SharedPreferences.getInstance();
      
      // Check if email already exists
      final usersJson = prefs.getString(_usersKey);
      List<Map<String, dynamic>> users = [];
      if (usersJson != null) {
        users = List<Map<String, dynamic>>.from(json.decode(usersJson) as List);
      }

      final emailExists = users.any((u) => u['email'] == email.toLowerCase());
      if (emailExists) {
        return {'success': false, 'message': 'Email already registered'};
      }

      // Create new user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: fullName.trim(),
        email: email.toLowerCase().trim(),
        createdAt: DateTime.now(),
      );

      // Save user
      users.add(user.toJson());
      await prefs.setString(_usersKey, json.encode(users));

      // Save password (hashed)
      final passwordsJson = prefs.getString(_passwordsKey);
      Map<String, String> passwords = {};
      if (passwordsJson != null) {
        passwords = Map<String, String>.from(json.decode(passwordsJson) as Map);
      }
      passwords[user.id] = _hashPassword(password);
      await prefs.setString(_passwordsKey, json.encode(passwords));

      // Set as current user
      _currentUser = user;
      await prefs.setString(_currentUserKey, json.encode(user.toJson()));
      notifyListeners();

      return {'success': true, 'message': 'Account created successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to create account: $e'};
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.trim().isEmpty) {
        return {'success': false, 'message': 'Email is required'};
      }
      if (password.isEmpty) {
        return {'success': false, 'message': 'Password is required'};
      }

      final prefs = await SharedPreferences.getInstance();
      
      // Get users
      final usersJson = prefs.getString(_usersKey);
      if (usersJson == null) {
        return {'success': false, 'message': 'No account found with this email'};
      }

      final users = List<Map<String, dynamic>>.from(json.decode(usersJson) as List);
      final userJson = users.firstWhere(
        (u) => u['email'] == email.toLowerCase().trim(),
        orElse: () => {},
      );

      if (userJson.isEmpty) {
        return {'success': false, 'message': 'No account found with this email'};
      }

      // Verify password
      final passwordsJson = prefs.getString(_passwordsKey);
      if (passwordsJson == null) {
        return {'success': false, 'message': 'Authentication error'};
      }

      final passwords = Map<String, String>.from(json.decode(passwordsJson) as Map);
      final storedHash = passwords[userJson['id']];
      final inputHash = _hashPassword(password);

      if (storedHash != inputHash) {
        return {'success': false, 'message': 'Incorrect password'};
      }

      // Sign in successful
      final user = User.fromJson(userJson);
      _currentUser = user;
      await prefs.setString(_currentUserKey, json.encode(user.toJson()));
      notifyListeners();

      return {'success': true, 'message': 'Signed in successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to sign in: $e'};
    }
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      // print('Error signing out: $e');
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return false;

    try {
      if (newPassword.length < 6) return false;

      final prefs = await SharedPreferences.getInstance();
      final passwordsJson = prefs.getString(_passwordsKey);
      if (passwordsJson == null) return false;

      final passwords = Map<String, String>.from(json.decode(passwordsJson) as Map);
      final storedHash = passwords[_currentUser!.id];
      final currentHash = _hashPassword(currentPassword);

      if (storedHash != currentHash) return false;

      // Update password
      passwords[_currentUser!.id] = _hashPassword(newPassword);
      await prefs.setString(_passwordsKey, json.encode(passwords));

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _currentUser!.id;

      // Remove from users list
      final usersJson = prefs.getString(_usersKey);
      if (usersJson != null) {
        final users = List<Map<String, dynamic>>.from(json.decode(usersJson) as List);
        users.removeWhere((u) => u['id'] == userId);
        await prefs.setString(_usersKey, json.encode(users));
      }

      // Remove password
      final passwordsJson = prefs.getString(_passwordsKey);
      if (passwordsJson != null) {
        final passwords = Map<String, String>.from(json.decode(passwordsJson) as Map);
        passwords.remove(userId);
        await prefs.setString(_passwordsKey, json.encode(passwords));
      }

      // Sign out
      await signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
}
