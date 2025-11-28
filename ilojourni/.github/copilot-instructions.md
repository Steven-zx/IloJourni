# AI Coding Agent Instructions for IloJourni

These instructions help AI agents work effectively in this Flutter app. Keep guidance specific to this repo; avoid generic advice.

## Project Overview
- **App type:** Flutter multi-platform app (Android/iOS/Web/Desktop)
- **Domain:** Iloilo travel planner with itinerary generation, maps, saved trips, profiles
- **Entry point:** `lib/main.dart` sets up services, theme, and named routes via `MaterialApp`
- **Screens:** Located in `lib/screens/` and navigated using static `route` strings (e.g., `WelcomeScreen.route`). Use `Navigator.pushNamed` with these.
- **Data:** Destination data is in `lib/data/` (`destinations_database.dart`, `destinations_data.dart`). Models live in `lib/models/` (e.g., `destination.dart`).
- **Services:** Stateful singletons under `lib/services/` (e.g., `SavedTripsStore`, `FavoritesStore`, `ConnectivityService`, `AuthService`, `GeminiService`, `ThemeService`). Most expose `instance` or a factory like `getInstance()`.
- **Theme:** App themes in `lib/theme/` with `AppTheme.light()` and `AppTheme.dark()`. `ThemeService` manages current `themeMode`.

## Architecture & Patterns
- **Initialization order (critical):** In `main()`, call `dotenv.load` then initialize persistent services before `runApp`:
  1. `SavedTripsStore.instance.initialize()`
  2. `FavoritesStore.instance.initialize()`
  3. `ConnectivityService.instance.initialize()`
  4. `AuthService.instance.initialize()`
- **Singleton services:** Prefer `Service.instance` or `Service.getInstance()` over new instances. Do not block UI; perform I/O in `initialize()`.
- **Routing:** `MaterialApp.routes` maps route constants defined in each screen. Add new screens by:
  - Defining `static const route = '/yourRoute'` in the screen.
  - Registering route in `routes:` map in `lib/main.dart`.
  - Navigating via `Navigator.pushNamed(context, YourScreen.route)`.
- **Data flow:** Screens read from stores/services; no global state frameworks detected. Keep state local to screens or via service singletons.
- **AI integration:** `GeminiService` uses `google_generative_ai` with `GEMINI_API_KEY` from `.env`. It builds a strict JSON prompt using `DestinationsDatabase`. Handle retries and JSON extraction via `_extractJson`.
- **Model rules:** `GeneratedItinerary` is expected JSON shape from `GeminiService.generateItinerary(...)` (see service for required fields like `days`, `activities`). Keep activity `type` values to `destination|transport|meal` and ensure realistic costs/times.

## Developer Workflows
- **Install deps:** Run `flutter pub get` at repo root (`ilojourni/`).
- **Run app:**
  - Android/iOS: `flutter run`
  - Web: `flutter run -d chrome`
  - Windows: `flutter run -d windows`
- **Build:** Platform-specific build configs are under `android/`, `ios/`, `windows/`, etc. Use standard `flutter build <platform>`.
- **Tests:** Minimal test at `test/widget_test.dart`. Add widget or service tests under `test/`. Run with `flutter test`.
- **Env vars:** Create `.env` in repo root with `GEMINI_API_KEY=<your_key>`. `flutter_dotenv` loads it in `main()` and within `GeminiService.getInstance()`.

## Conventions
- **Naming:** Screens end with `_screen.dart`; some internal views start with an underscore (e.g., `_trip_map_view.dart`).
- **Routes:** Each screen defines a static `route` string constant used in `main.dart` routes and for navigation.
- **Assets:** Images under `assets/images/`. Add new images to `pubspec.yaml` assets section if needed.
- **Async:** Services often return `Future<void> initialize()`; await these in `main()` during startup.
- **Error handling:** `GeminiService` rethrows parsing/credential errors. Avoid printing logs in production; consider surfacing errors to UI.

## Integration Points
- **Generative AI:** `lib/services/gemini_service.dart` (model `gemini-2.5-flash`, configurable via `.env`). Uses `DestinationsDatabase.allDestinations` to constrain outputs.
- **Auth:** `lib/services/auth_service.dart` and `auth_state.dart` manage signed/guest states reflected in `profile_guest_screen.dart` and `profile_signed_screen.dart`.
- **Connectivity:** `lib/services/connectivity_service.dart` tracks online/offline.
- **Persistence:** `SavedTripsStore` and `FavoritesStore` manage local saved/favorite trips.
- **Maps:** `map_view_screen.dart` and `trip_map_view.dart` display locations; `_trip_map_view.dart` suggests private/internal components.

## Example: Adding a Screen
1. Create `lib/screens/example_screen.dart` with `static const route = '/example'` and a `StatelessWidget`.
2. Register in `MaterialApp.routes` in `lib/main.dart`:
   `ExampleScreen.route: (_) => const ExampleScreen(),`
3. Navigate: `Navigator.pushNamed(context, ExampleScreen.route)`.

## Gotchas
- **Do not instantiate services directly**; use provided singletons to maintain state.
- **Ensure `.env` exists** before any AI calls; missing `GEMINI_API_KEY` throws.
- **Routes must be registered** in `main.dart` or navigation will fail.
- **Respect destination data fields** when generating itineraries; the UI expects consistent keys and image paths.

If any section is unclear or missing patterns (e.g., auth flow details, storage formats), tell us and we’ll refine these instructions.