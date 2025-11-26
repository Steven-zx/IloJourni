import 'package:flutter/material.dart';
import '../services/auth_state.dart';
import 'dashboard_screen.dart';
import 'budget_tracker_screen.dart';
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
  bool _showBottomNav = true;

  void _handleScroll(bool isScrolling) {
    if (isScrolling && _showBottomNav) {
      setState(() => _showBottomNav = false);
    } else if (!isScrolling && !_showBottomNav) {
      setState(() => _showBottomNav = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const DashboardScreen(),
      const BudgetTrackerScreen(),
      const SavedTripsScreen(),
      Builder(
        builder: (context) => AuthState.isSignedIn ? const ProfileSignedScreen() : const ProfileGuestScreen(),
      ),
    ];

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          _handleScroll(true);
        } else if (notification is ScrollEndNotification) {
          _handleScroll(false);
        }
        return true;
      },
      child: Scaffold(
        body: pages[_index],
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _showBottomNav ? null : 0,
          child: _showBottomNav
              ? NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  backgroundColor: Colors.white,
                  shadowColor: Colors.black12,
                  elevation: 3,
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                    NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Budget'),
                    NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Trips'),
                    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
