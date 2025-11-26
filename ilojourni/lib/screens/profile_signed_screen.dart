import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';
import '../widgets/placeholder_image.dart';
import 'itinerary_screen.dart';

class ProfileSignedScreen extends StatelessWidget {
  const ProfileSignedScreen({super.key});
  static const route = '/profile-signed';

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
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.teal, width: 3),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: PlaceholderImage(
                          height: 100,
                          width: 100,
                          label: '',
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Philip Hamilton',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            Text('Travel Stats', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 12),
          _StatsCard(),
          const SizedBox(height: 20),
          Text('My Journeys', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.pushNamed(context, ItineraryScreen.route),
            child: _JourneyItem(image: '', imageColor: const Color(0xFF4A90E2), title: 'Island Hopping', subtitle: 'September 13-18, 2025', budget: '30000 • 6 days'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.pushNamed(context, ItineraryScreen.route),
            child: _JourneyItem(image: '', imageColor: const Color(0xFFCD9A5B), title: 'Foodie Adventure', subtitle: 'August 19-20, 2025', budget: '1500 • 2 days'),
          ),
          const SizedBox(height: 20),
          Text('Appearance', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),
          _AppearanceRow(),
        ],
      ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget item(IconData icon, String label, String value) => Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: isDark ? AppTheme.darkAccent : AppTheme.navy),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          item(Icons.map_outlined, 'Trips', '7'),
          Container(width: 1, height: 40, color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)),
          item(Icons.place_outlined, 'Places', '38'),
          Container(width: 1, height: 40, color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)),
          item(Icons.wallet_outlined, 'Budget', '₱ 30000'),
        ],
      ),
    );
  }
}

class _JourneyItem extends StatelessWidget {
  const _JourneyItem({required this.image, this.imageColor, required this.title, required this.subtitle, required this.budget});
  final String image;
  final Color? imageColor;
  final String title;
  final String subtitle;
  final String budget;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image.isEmpty
                ? PlaceholderImage(
                    height: 70,
                    width: 70,
                    label: '',
                    color: imageColor,
                    borderRadius: BorderRadius.circular(12),
                  )
                : Image.asset(
                    image,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: AppTheme.lightGrey),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E9E9).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    budget,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceRow extends StatefulWidget {
  @override
  State<_AppearanceRow> createState() => _AppearanceRowState();
}

class _AppearanceRowState extends State<_AppearanceRow> {
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(Icons.nightlight_round, size: 24, color: isDark ? AppTheme.darkAccent : null),
          const SizedBox(width: 12),
          const Expanded(child: Text('Dark mode', style: TextStyle(fontSize: 15))),
          Switch(
            value: _themeService.isDarkMode,
            onChanged: (v) {
              _themeService.toggleTheme();
              setState(() {});
            },
            activeTrackColor: AppTheme.darkAccent,
            activeColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
