import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/welcome_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_shell.dart';
import 'screens/plan_form_screen.dart';
import 'screens/itinerary_screen.dart';
import 'screens/saved_trips_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/more_info_screen.dart';
import 'screens/profile_guest_screen.dart';
import 'screens/profile_signed_screen.dart';
import 'screens/manual_itinerary_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/trip_budget_tracker_screen.dart';
import 'theme/app_theme.dart';
import 'services/theme_service.dart';
import 'services/saved_trips_store.dart';
import 'services/favorites_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SavedTripsStore.instance.initialize();
  await FavoritesStore.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IloJourni',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeService.themeMode,
      initialRoute: WelcomeScreen.route,
      routes: {
        WelcomeScreen.route: (_) => const WelcomeScreen(),
        SignUpScreen.route: (_) => const SignUpScreen(),
        SignInScreen.route: (_) => const SignInScreen(),
        HomeShell.route: (_) => const HomeShell(),
        PlanFormScreen.route: (_) => const PlanFormScreen(),
        ItineraryScreen.route: (_) => const ItineraryScreen(),
        SavedTripsScreen.route: (_) => const SavedTripsScreen(),
        ExploreScreen.route: (_) => const ExploreScreen(),
        MoreInfoScreen.route: (_) => const MoreInfoScreen(),
        ProfileGuestScreen.route: (_) => const ProfileGuestScreen(),
        ProfileSignedScreen.route: (_) => const ProfileSignedScreen(),
        ManualItineraryScreen.route: (_) => const ManualItineraryScreen(),
        TripDetailScreen.route: (_) => const TripDetailScreen(),
        TripBudgetTrackerScreen.route: (_) => const TripBudgetTrackerScreen(),
      },
    );
  }
}
