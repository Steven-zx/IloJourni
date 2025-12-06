import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';
import 'sign_in_screen.dart';

class ProfileGuestScreen extends StatefulWidget {
  const ProfileGuestScreen({super.key});
  static const route = '/profile-guest';

  @override
  State<ProfileGuestScreen> createState() => _ProfileGuestScreenState();
}

class _ProfileGuestScreenState extends State<ProfileGuestScreen> {
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFE9E9E9).withValues(alpha: 0.3),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(
              child: Text(
                'Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Guest User', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('No personal details available in guest mode.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pushNamed(context, SignInScreen.route),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.teal, width: 1.5),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: const Text('Sign in'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Appearance', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: SizedBox(
                width: double.infinity,
                child: Row(children: [
                  Icon(Icons.nightlight_round, color: isDark ? AppTheme.darkAccent : null),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Dark mode')),
                  Switch(
                    value: _themeService.isDarkMode,
                    onChanged: (v) {
                      _themeService.toggleTheme();
                      setState(() {});
                    },
                    activeThumbColor: AppTheme.darkAccent,
                  )
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
