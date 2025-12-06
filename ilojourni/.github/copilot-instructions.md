# AI Coding Agent Instructions for IloJourni

These instructions help AI agents work effectively in this Flutter app. Keep guidance specific to this repo; avoid generic advice.

## Project Overview
- **App type:** Flutter multi-platform app (Android/iOS/Web/Desktop)
- **Domain:** Iloilo travel planner with AI-powered itinerary generation, offline maps, saved trips, user authentication
- **Entry point:** `lib/main.dart` sets up services, theme, and named routes via `MaterialApp`
- **Navigation:** 4-tab bottom nav in `HomeShell` (Dashboard, Explore, Saved, Profile). Auth state switches between `ProfileGuestScreen` and `ProfileSignedScreen`.
- **Data:** 15+ real Iloilo destinations in `lib/data/destinations_database.dart` with GPS, pricing, hours, tags. Models in `lib/models/destination.dart`.
- **Services:** `ChangeNotifier` singletons under `lib/services/` handle state:
  - `SavedTripsStore` / `FavoritesStore` → local persistence via `SharedPreferences`
  - `AuthService` → local user registry with SHA-256 password hashing
  - `GeminiService` → async factory `getInstance()` for AI itinerary generation
  - `ThemeService` → factory singleton managing light/dark mode
  - `ConnectivityService` → network state tracking

## Architecture & Patterns
### Initialization (Critical Boot Sequence)
In `main()`, **must** initialize in this order before `runApp()`:
```dart
await dotenv.load(fileName: ".env");
await SavedTripsStore.instance.initialize();
await FavoritesStore.instance.initialize();
await ConnectivityService.instance.initialize();
await AuthService.instance.initialize();
```
**Why:** Persistent services load from `SharedPreferences` synchronously at boot to avoid race conditions.

### Service Access Patterns
- **Static instance:** `SavedTripsStore.instance`, `AuthService.instance`, `ConnectivityService.instance` (already instantiated)
- **Async factory:** `GeminiService.getInstance()` (lazy-loads `.env` on first call)
- **Factory singleton:** `ThemeService()` (returns same instance via `factory`)
- **Never** call service constructors directly; always use provided accessors

### Routing System
- Each screen defines `static const route = '/path'` (e.g., `WelcomeScreen.route = '/welcome'`)
- All routes registered in `lib/main.dart` `MaterialApp.routes` map
- Navigate: `Navigator.pushNamed(context, ScreenName.route)` or `pushNamedAndRemoveUntil` for auth flows
- **HomeShell route arguments:** Pass `{'tab': int, 'search': String?}` to set initial tab/search query

### State Management
- No global state frameworks (no Provider, Riverpod, Bloc)
- Services extend `ChangeNotifier`; widgets rebuild on `addListener()` or via `setState()`
- `AuthService` updates `notifyListeners()` on sign-in/out; screens check `AuthState.isSignedIn` (computed property)
- Local state for forms, animations, scroll controllers

### AI Integration (GeminiService)
- **Model:** `gemini-2.5-flash` with temperature 0.7, maxTokens 16384
- **Retry logic:** 3 attempts with exponential backoff (2s, 4s, 6s)
- **Network detection:** Throws `NETWORK_ERROR:` prefix for socket/DNS failures
- **Prompt structure:** Strict JSON output with `DestinationsDatabase.allDestinations` embedded, transportation costs (₱12-15 jeepney, ₱40+ taxi), meal budgets (₱80-600)
- **Activity types:** `destination`, `transport`, `meal` only; UI renders differently per type
- **Image paths:** Must use exact `image` field from destination JSON; meals use `assets/images/breakfast.jpg`, `dinner.jpg`, `coffee.jpg`

## Developer Workflows
- **Setup:** `flutter pub get` (run in `ilojourni/` directory)
- **Run:** `flutter run` (Android/iOS), `flutter run -d chrome` (Web), `flutter run -d windows` (Windows)
- **Analyze:** `flutter analyze` (uses `package:flutter_lints/flutter.yaml`)
- **Format:** `dart format lib/` (enforces Dart style guide)
- **Tests:** `flutter test` (minimal coverage, add tests under `test/`)
- **Env setup:** Create `.env` with `GEMINI_API_KEY=<key>` (never commit; in `.gitignore`)

## Conventions
### File Naming
- Screens: `*_screen.dart` (e.g., `plan_form_screen.dart`)
- Services: `*_service.dart` or `*_store.dart`
- Private/internal widgets: `_widget_name.dart` (e.g., `_trip_map_view.dart`)
- Models: singular nouns (e.g., `destination.dart`)

### Code Style
- Static route constants: `static const route = '/path';`
- Prefer `const` constructors where possible
- Theme-aware UI: Check `Theme.of(context).brightness` for dark mode adjustments
- Use `AppTheme.navy`, `AppTheme.teal`, `AppTheme.darkTeal` for brand colors
- Google Fonts: Josefin Sans via `google_fonts` package

### Asset Management
- Images: `assets/images/*.jpg` (referenced as `'assets/images/fileName.jpg'`)
- Add new assets to `pubspec.yaml` under `flutter: assets:`
- `.env` file also listed in assets for runtime access

## Integration Points
### Generative AI (GeminiService)
- **Location:** `lib/services/gemini_service.dart`
- **Usage:** 
  ```dart
  final service = await GeminiService.getInstance();
  final itinerary = await service.generateItinerary(
    budget: 5000,
    days: 3,
    travelStyles: ['Foodie', 'Culture'],
  );
  ```
- **Error handling:** Catch `Exception` with messages like `'NETWORK_ERROR: ...'`, `'API Error: ...'`, or JSON parsing failures
- **Testing:** See `PHASE1_PROGRESS.md` for manual testing flow; no automated tests yet

### Authentication (AuthService)
- **Local-only:** No backend; users stored in `SharedPreferences` under `'registered_users'` key
- **Password storage:** SHA-256 hashed, stored separately under `'user_passwords'` key
- **Sign-in flow:** Validates email/password, sets `_currentUser`, calls `notifyListeners()`
- **Sign-out:** Clears `_currentUser` and `'current_user'` from storage
- **Guest mode:** Default state when `_currentUser == null`; UI shows `ProfileGuestScreen`

### Offline Support
- **OfflineBanner:** Shown at top of `HomeShell` when offline (via `ConnectivityService`)
- **Saved trips:** Persisted locally with `isOfflineAvailable: true` flag; viewable offline
- **Maps:** Uses `flutter_map` with cached tiles (not fully implemented)

### Persistence (SharedPreferences)
- **Keys:** `'saved_trips'`, `'favorite_trips'`, `'registered_users'`, `'current_user'`, `'user_passwords'`
- **Format:** JSON-encoded strings; decode with `json.decode()` and model factories (`fromJson`)
- **Initialize before access:** Services call `_isInitialized` guard to prevent duplicate loads

## Common Tasks
### Adding a Screen
1. Create `lib/screens/new_screen.dart`:
   ```dart
   class NewScreen extends StatelessWidget {
     const NewScreen({super.key});
     static const route = '/new';
     @override
     Widget build(BuildContext context) => Scaffold(...);
   }
   ```
2. Register in `lib/main.dart`:
   ```dart
   NewScreen.route: (_) => const NewScreen(),
   ```
3. Navigate: `Navigator.pushNamed(context, NewScreen.route)`

### Modifying Destinations
- Edit `lib/data/destinations_database.dart` to add/update entries
- Ensure fields: `id`, `name`, `description`, `district`, `category`, `latitude`, `longitude`, `image`, `entranceFee`, `estimatedTime`, `tags`, `openingHours`, `isPopular`
- Image path must exist in `assets/images/`

### Tweaking AI Prompts
- Modify `_buildPrompt()` in `lib/services/gemini_service.dart`
- Adjust `GenerationConfig` (temperature, topK, topP) for output variation
- Test with `maxRetries: 1` during development to avoid quota burn

## Known Gotchas
1. **Service instantiation:** Don't call `GeminiService()` or `AuthService._()` directly; use provided accessors
2. **`.env` missing:** App throws on AI generation if `GEMINI_API_KEY` not found; handle gracefully in UI
3. **Route not registered:** Navigator fails silently if route missing from `main.dart` map
4. **Image paths:** AI must return **exact** image paths from destination JSON; typos break UI
5. **Theme switching:** `ThemeService` uses `notifyListeners()`; widgets must call `addListener()` in `initState()` or wrap in builder
6. **Async initialization:** Never access `SavedTripsStore.trips` before `initialize()` completes

## Architecture Decisions (Why Things Are This Way)
- **No backend:** Phase 1 focuses on AI integration; local storage simulates backend for prototyping
- **Singleton services:** Ensures single source of truth for app state without state management libraries
- **ChangeNotifier over setState:** Services need to notify multiple widgets; manual listeners avoid setState boilerplate
- **Strict JSON from AI:** Gemini's unstructured output requires defensive parsing; `_extractJson()` strips markdown fences
- **Retry logic in AI service:** Free-tier API can be flaky; exponential backoff improves success rate

## Future Enhancements (Not Yet Implemented)
- Backend integration (Firebase/Supabase) for user accounts
- Real-time collaborative trip planning
- Offline map caching strategy
- Unit/widget tests for services and screens
- CI/CD pipeline for multi-platform builds

---

**Questions or unclear patterns?** Check `PHASE1_PROGRESS.md` for project context or ask for clarification on specific flows (e.g., auth state transitions, AI error handling).
