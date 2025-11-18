# AI Coding Agent Guide for `ilojourni`

Concise, project-specific instructions to become productive quickly. This is a vanilla Flutter starter; keep changes incremental and idiomatic.

## Core Architecture
- Single entrypoint: `lib/main.dart` launching `MyApp` (a `StatelessWidget`) which sets a `MaterialApp` with a seeded `ColorScheme` and `home: MyHomePage`.
- State management currently uses local `StatefulWidget` + `setState` (`_counter` in `_MyHomePageState`). No global state, routing, DI, or async layers yet.
- Multi-platform scaffold already generated (android/, ios/, web/, windows/, macos/, linux/) — keep logic inside `lib/` to stay portable.

## Conventions & Patterns
- Keep new widgets in `lib/` with clear separation (e.g. `lib/widgets/`, `lib/screens/`) before introducing packages.
- Use `ThemeData`/`ColorScheme.fromSeed` pattern already present for consistent theming; extend rather than replace to avoid regressions.
- Favor composable widgets over inheritance; maintain short build methods.
- Follow lints from `analysis_options.yaml` (inherits `flutter_lints`). Add rule overrides explicitly under `linter.rules` instead of scattering `ignore` comments.

## Adding Functionality Safely
- Introduce new state: prefer lifting state up or migrating to a state management solution (Provider/Riverpod/etc.) only when >2 widgets need the same data. Document rationale in PR description.
- For navigation beyond a single screen, add named routes via `MaterialApp(routes: {...})` or a `RouterConfig`—start with the simplest.
- When adding async operations (e.g. network calls), create a service file (`lib/services/<feature>_service.dart`) and keep UI widgets pure.

## Dependencies
- Declare in `pubspec.yaml` under `dependencies:`; run `flutter pub get` after edits.
- Avoid adding heavy state libraries prematurely; justify each external dependency.

## Build & Test Workflow
- Fetch deps: `flutter pub get`
- Analyze lints: `flutter analyze`
- Run app: `flutter run` (hot reload friendly)
- Run tests: `flutter test` (sample exists in `test/widget_test.dart`; extend with new widget tests when adding UI components)

## Testing Guidance (Project-Specific)
- Mirror widget file paths under `test/` (e.g. `lib/widgets/counter_button.dart` → `test/widgets/counter_button_test.dart`).
- Use `pumpWidget(const MyApp())` for integration-like widget tests; isolate small widgets with minimal harness.

## Performance & UX Considerations
- Keep rebuild surfaces small; extract stateless child widgets if build method exceeds ~40 lines.
- Avoid synchronous heavy work in `build()` or button handlers—offload to async functions/services.

## Extending Theme / Styles
- Modify `ThemeData` in `MyApp`; reuse `Theme.of(context)` instead of hard-coded colors. Add custom text styles via `theme.textTheme.copyWith(...)`.

## Safe Refactors
- Renaming `MyHomePage`: ensure constructor & state class alignment (`State<MyHomePage>`). Run analyze + tests.
- Introducing routing: maintain existing home screen as fallback until new navigation stabilizes.

## Pull Request Expectations (for AI changes)
- Describe purpose, affected widgets, dependency additions, and any new commands.
- Confirm: `flutter analyze` PASS, `flutter test` PASS, app launches.

## When Unsure
- Prefer minimal scaffolding over speculative abstractions.
- Ask for confirmation before introducing a state management library or complex navigation system.

(Provide feedback on unclear sections or missing project-specific practices to iterate.)