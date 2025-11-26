import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_state.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static const route = '/signup';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/islan higantes.png',
              height: 280,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 220,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 24, 16, MediaQuery.of(context).padding.bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              const SizedBox(height: 0),
              Text(
                'Welcome to IloJourni!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: TextField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(hintText: 'Full Name'),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: TextField(
                  controller: _pwdCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Password'),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () {
                  if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _pwdCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }
                  // Simulate sign up success
                  AuthState.signIn();
                  Navigator.pushReplacementNamed(context, '/home');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account created successfully!'), backgroundColor: AppTheme.teal),
                  );
                },
                child: const Text('Sign up'),
              ),
              const SizedBox(height: 12),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(color: Colors.black54),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Sign in',
                        style: const TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushReplacementNamed(context, SignInScreen.route),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: Text('OR', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(color: Colors.black38))),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('Continue as a guest'),
              ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
