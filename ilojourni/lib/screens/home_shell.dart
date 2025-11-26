import 'package:flutter/material.dart';
import '../services/auth_state.dart';
import 'dashboard_screen.dart';
import 'explore_screen.dart';
import 'saved_trips_screen.dart';
import 'profile_guest_screen.dart';
import 'profile_signed_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  static const route = '/home';

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pages = <Widget>[
      const DashboardScreen(),
      const ExploreScreen(),
      const SavedTripsScreen(),
      Builder(
        builder: (context) => AuthState.isSignedIn ? const ProfileSignedScreen() : const ProfileGuestScreen(),
      ),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shadowColor: isDark ? Colors.black26 : Colors.black12,
        elevation: 3,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
