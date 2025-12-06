import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../services/saved_trips_store.dart';
import '../widgets/placeholder_image.dart';
import 'itinerary_screen.dart';
import 'welcome_screen.dart';

class ProfileSignedScreen extends StatelessWidget {
  const ProfileSignedScreen({super.key});
  static const route = '/profile-signed';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = AuthService.instance.currentUser;
    
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
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTeal : AppTheme.navy,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                user?.fullName ?? 'User',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                user?.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Travel Stats', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 12),
          _StatsCard(),
          const SizedBox(height: 20),
          Text('My Journeys', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: SavedTripsStore.instance,
            builder: (context, _) {
              final trips = SavedTripsStore.instance.trips;
              
              if (trips.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.explore_outlined, size: 48, color: isDark ? Colors.white38 : Colors.black38),
                      const SizedBox(height: 12),
                      Text(
                        'No Journeys Yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Start planning your first adventure!',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return Column(
                children: trips.map((trip) {
                  final colors = [
                    const Color(0xFF4A90E2),
                    const Color(0xFFCD9A5B),
                    const Color(0xFF9B59B6),
                    const Color(0xFFE74C3C),
                    const Color(0xFF2ECC71),
                  ];
                  final colorIndex = trips.indexOf(trip) % colors.length;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(
                        context,
                        ItineraryScreen.route,
                        arguments: {
                          'itinerary': trip.itinerary,
                          'days': trip.itinerary.days.length,
                        },
                      ),
                      child: _JourneyItem(
                        image: trip.image,
                        imageColor: colors[colorIndex],
                        title: trip.title,
                        subtitle: trip.dateRange,
                        budget: '₱${trip.budget.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} • ${trip.itinerary.days.length} days',
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          Text('Appearance', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),
          _AppearanceRow(),
          const SizedBox(height: 20),
          Text('Account', style: (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: InkWell(
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await AuthService.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      WelcomeScreen.route,
                      (route) => false,
                    );
                  }
                }
              },
              child: Row(
                children: [
                  Icon(Icons.logout, size: 24, color: Colors.red),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 15, color: Colors.red),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.black38),
                ],
              ),
            ),
          ),
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
    return AnimatedBuilder(
      animation: SavedTripsStore.instance,
      builder: (context, _) {
        final trips = SavedTripsStore.instance.trips;
        final totalExpenses = trips.fold<int>(0, (sum, trip) => sum + trip.budget);
        final totalPlaces = trips.fold<int>(0, (sum, trip) => sum + trip.itinerary.days.fold<int>(0, (daySum, day) => daySum + day.activities.where((a) => a.type == 'destination').length));
        
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              item(Icons.map_outlined, 'Trips', '${trips.length}'),
              Container(width: 1, height: 40, color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)),
              item(Icons.place_outlined, 'Places', '$totalPlaces'),
              Container(width: 1, height: 40, color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)),
              item(Icons.account_balance_wallet_outlined, 'Expenses', totalExpenses > 0 ? '₱ ${totalExpenses.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}' : '₱ 0'),
            ],
          ),
        );
      },
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
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
