# AI Coding Agent Guide for IloJourni

IloJourni is a Flutter travel planning app for Iloilo, Philippines with Gemini AI-powered itinerary generation. Focus on maintaining the established architecture patterns and offline-first capabilities.

## Core Architecture

**Entry & Navigation**
- `lib/main.dart`: App entry with Firebase/dotenv initialization. Named routes defined in `MaterialApp.routes`
- Navigation: Named routes (`Navigator.pushNamed(context, ScreenName.route)`). No complex router—keep it simple
- Shell: `HomeShell` (bottom nav with 4 tabs: Dashboard, Explore, SavedTrips, Profile)
- Auth flow: Welcome → SignUp/SignIn → HomeShell. Use `pushNamedAndRemoveUntil` for auth transitions

**State Management Strategy**
- **Singleton services with ChangeNotifier**: `ThemeService`, `AuthService`, `SavedTripsStore`, `FavoritesStore`, `ConnectivityService`
- Access via `.instance` (e.g., `AuthService.instance.currentUser`)
- Local widget state: `StatefulWidget` + `setState` for UI-only concerns
- Persistence: `SharedPreferences` for local data (trips, favorites, auth tokens)
- **No Provider/Riverpod/Bloc** — extending this pattern requires justification

**Data Layer**
- Models: `lib/models/destination.dart` (Destination, GeneratedItinerary, DayPlan, Activity)
- Static data: `lib/data/destinations_database.dart` (15+ real Iloilo destinations with GPS, prices, hours)
- AI Service: `lib/services/gemini_service.dart` generates itineraries via Gemini 2.0 Flash
- Firebase: Integrated but minimal usage (commented example in main.dart). Firestore for future cloud sync

**Theme System**
- Custom theme: `lib/theme/app_theme.dart` with light/dark modes
- Colors: Navy (#0B2239), Teal (#5AB8A9) for light; dark variants defined
- Typography: Google Fonts Josefin Sans throughout
- Toggle theme via `ThemeService.instance.toggleTheme()` — updates all listeners

## Critical Conventions

**Service Pattern**
```dart
// Singleton with ChangeNotifier for reactive updates
class MyService extends ChangeNotifier {
  static final MyService _instance = MyService._();
  MyService._();
  static MyService get instance => _instance;
  
  Future<void> initialize() async { /* load from SharedPreferences */ }
  // Call notifyListeners() when state changes
}
```
Initialize in `main()` before `runApp()`. Widgets listen via `instance.addListener()` or manual `setState()`

**JSON Serialization**
All models have `toJson()`/`fromJson()` for SharedPreferences storage. No code generation—manual serialization only

**AI Itinerary Generation Flow**
1. User fills `PlanFormScreen` (budget, days, travel styles)
2. `GeminiService.generateItinerary()` sends prompt with destinations JSON
3. Response parsed into `GeneratedItinerary` → displayed in `ItineraryScreen`
4. User saves to `SavedTripsStore` for offline access
5. **Retry logic**: 3 attempts with exponential backoff for API flakiness

**Offline-First Design**
- `ConnectivityService` monitors network status via `connectivity_plus`
- `OfflineBanner` widget shows at top when offline
- SavedTrips/Favorites persist locally—always accessible offline
- Check `ConnectivityService.instance.isOnline` before API calls

## Key Files & Responsibilities

| Path | Purpose |
|------|---------|
| `lib/screens/plan_form_screen.dart` | User inputs for AI itinerary generation |
| `lib/screens/itinerary_screen.dart` | Display AI-generated itinerary with day/activity breakdown |
| `lib/screens/saved_trips_screen.dart` | Offline-accessible saved trips list |
| `lib/services/gemini_service.dart` | Gemini AI integration with retry logic & JSON parsing |
| `lib/services/auth_service.dart` | Local auth (no backend—SHA-256 hashed passwords in SharedPreferences) |
| `lib/data/destinations_database.dart` | Curated list of real Iloilo destinations with metadata |
| `lib/theme/app_theme.dart` | Light/dark theme definitions with custom colors |

## Development Workflow

**Setup**
```powershell
flutter pub get                    # Install dependencies
# Add GEMINI_API_KEY to .env file (get from https://aistudio.google.com/app/apikey)
flutter run                        # Hot reload enabled
```

**Quality Checks**
```powershell
flutter analyze                    # Lints (flutter_lints package)
flutter test                       # Run tests (currently minimal coverage)
```

**Adding Dependencies**
Edit `pubspec.yaml` → run `flutter pub get`. Current stack:
- `google_generative_ai`: Gemini AI
- `flutter_dotenv`: Secrets management
- `shared_preferences`: Local storage
- `connectivity_plus`: Network monitoring
- `firebase_core`, `cloud_firestore`: Future cloud sync
- `flutter_map`, `latlong2`: Map integration
- `google_fonts`: Josefin Sans typography

## Common Patterns

**Navigation with Arguments**
```dart
Navigator.pushNamed(context, ItineraryScreen.route, arguments: generatedItinerary);
// In destination screen:
final itinerary = ModalRoute.of(context)!.settings.arguments as GeneratedItinerary;
```

**Dark Mode Aware UI**
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final color = isDark ? AppTheme.darkTeal : AppTheme.navy;
```

**Saving Data Persistently**
```dart
await SavedTripsStore.add(SavedTrip(...));  // Auto-persists to SharedPreferences
// Access: SavedTripsStore.instance.trips
```

**Handling Async Errors**
Use try-catch with user-friendly messages. Show SnackBar for errors:
```dart
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error message')));
```

## Testing Approach
- Test file structure: `test/` mirrors `lib/` structure
- Widget tests for UI components; integration tests for flows
- Currently minimal—expand coverage for new features

## Security Notes
- **API Keys**: Store in `.env` (gitignored). Never commit secrets
- **Auth**: Local-only with SHA-256 hashing. No backend validation—suitable for MVP only
- Future: Migrate to Firebase Auth for production

## Before Committing
1. Run `flutter analyze` (must pass)
2. Test on emulator/device (hot reload during dev)
3. Verify `.env` not in git (`git status`)
4. Check for commented debug prints—remove before PR

## Common Pitfalls
- **Gemini response truncation**: Keep AI prompts concise. Current limit: 16384 max tokens
- **JSON parsing failures**: `_extractJson()` handles markdown wrapping; validate required fields
- **Navigator context**: Use `Builder` widget for correct context in bottom nav
- **Hot reload state**: Services initialized in `main()` persist across reloads—use hot restart for fresh state

## Adding New Screens
1. Create in `lib/screens/<name>_screen.dart` with `static const route = '/name'`
2. Add route to `main.dart` routes map
3. Follow existing AppBar/SafeArea patterns for consistency
4. Use theme colors via `Theme.of(context)` or `AppTheme` constants

## Extending AI Features
- Modify prompt in `GeminiService._buildPrompt()`
- Add/update destinations in `destinations_database.dart`
- Update `Destination` model if new fields needed (remember toJson/fromJson)
- Test with various budget/day combinations to catch edge cases