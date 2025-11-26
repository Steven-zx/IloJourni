import 'package:flutter/material.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  static const route = '/welcome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen image
          Positioned.fill(
            child: Image.asset(
              'assets/images/islan higantes.png',
              fit: BoxFit.cover,
            ),
          ),
          // App name overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'IloJourni',
                style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle()).copyWith(
                      fontSize: 24,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                      shadows: [const Shadow(color: Colors.black38, blurRadius: 8)],
                    ),
              ),
            ),
          ),
          // Bottom white card overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -4)),
                ],
              ),
              padding: EdgeInsets.fromLTRB(24, 28, 24, MediaQuery.of(context).padding.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Journeys Made\nEffortless',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'With IloJourni, exploring Iloilo is simple. Find routes, track your budget, and enjoy the journey—one ride at a time.',
                    textAlign: TextAlign.center,
                    style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, SignUpScreen.route),
                      child: const Text('Get Started'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
