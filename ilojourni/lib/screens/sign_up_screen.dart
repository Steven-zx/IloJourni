import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';
import 'home_shell.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _pwdCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.instance.signUp(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _pwdCtrl.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      await AuthService.instance.initialize();
      Navigator.pushNamedAndRemoveUntil(context, HomeShell.route, (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                onPressed: _isLoading ? null : _handleSignUp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Sign up'),
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
                onPressed: () async {
                  await AuthService.instance.signOut();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(context, HomeShell.route, (route) => false);
                },
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
