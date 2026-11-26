# AGENTS.md

Guide for AI coding agents and developers working with **momentum** (`v3.0.0`).

This document is organized into two parts:
- **[Part 1: Usage](#part-1-usage)** — For building Flutter apps with `momentum` (recommended feature-based architecture, best practices, core MVC patterns, and testing).
- **[Part 2: Contributing](#part-2-contributing)** — For modifying this repository directly to improve, fix, or maintain the `momentum` library itself (repository layout, commands, architectural invariants, and verification checklist).

For a concise API quick-reference (classes, constructors, methods, and typedefs), see [`llms.txt`](llms.txt).

---

## Part 1: Usage

Follow this section when using `momentum` (`^3.0.0`) in a Flutter application.

### Requirements & Imports

- **SDK constraints:** Dart `>=3.0.0 <4.0.0`, Flutter `>=3.50.0`.
- **Single public import:** `import 'package:momentum/momentum.dart';`
- **Material UI import (Flutter 3.47+):** Use `import 'package:material_ui/material_ui.dart';` instead of the deprecated `package:flutter/material.dart`.

### Recommended Architecture: Feature-Based Folder System

Organize your application by feature under `lib/features/<feature>/` (for example, `lib/features/login/` and `lib/features/dashboard/`). Each feature encapsulates its own model, controller, service, main view, and sub-widgets:

```text
lib/
  main.dart                              # App entrypoint & Momentum root wiring
  app.dart                               # MaterialApp, theme, and root routing
  core/                                  # Optional shared cross-feature services, models, widgets, utilities
    services/
    widgets/
  features/
    login/
      login_model.dart                   # Extends MomentumModel<LoginController>
      login_controller.dart              # Extends MomentumController<LoginModel>
      login_service.dart                 # Extends MomentumService
      login_view.dart                    # Main page or screen for the login feature
      widgets/                           # Feature-scoped widget parts
        login_form.dart
        login_submit_button.dart
    dashboard/
      dashboard_model.dart               # Extends MomentumModel<DashboardController>
      dashboard_controller.dart          # Extends MomentumController<DashboardModel>
      dashboard_service.dart             # Extends MomentumService
      dashboard_view.dart                # Main page or screen for the dashboard feature
      widgets/                           # Feature-scoped widget parts
        dashboard_header.dart
        dashboard_stats_card.dart
        dashboard_activity_list.dart
```

#### File Responsibilities per Feature

| File | Inherits / Type | Responsibility |
| --- | --- | --- |
| `<feature>_model.dart` | `extends MomentumModel<FeatureController>` | Holds **immutable** feature state (`const` constructor, `final` fields). Implements `update(...)` to instantiate a new copy and call `.updateMomentum()`. Optionally overrides `toJson()` / `fromJson()` for persistence and `==` / `hashCode` (or `Equatable`) to skip redundant rebuilds. |
| `<feature>_controller.dart` | `extends MomentumController<FeatureModel>` | Holds feature business logic and state orchestration. Implements `init()` for initial state, uses `bootstrap()` / `bootstrapAsync()` for initial loading, resolves dependencies via `service<T>()` and `controller<T>()`, updates state via `model.update(...)`, and sends one-off UI events via `sendEvent<T>(...)`. |
| `<feature>_service.dart` | `extends MomentumService` | Handles I/O, API calls, storage, parsing, or platform integrations for the feature. Keeps controllers lean and easy to test with mocks. Can resolve sibling services via `service<OtherService>()`. |
| `<feature>_view.dart` | `StatelessWidget` or `StatefulWidget` (`MomentumState`) | Main page/screen for the feature (wrapped in `RouterPage` when using `MomentumRouter`). Composes widgets from `widgets/` and registers one-off event listeners inside `MomentumState.initMomentumState()`. |
| `widgets/**.dart` | `StatelessWidget` / `StatefulWidget` | Composable widget parts for the feature. Scope `MomentumBuilder` narrowly to only the widgets that need reactive state updates. |

### Reference Feature Implementation (`features/dashboard/`)

#### `dashboard_service.dart`

```dart
import 'package:momentum/momentum.dart';

class DashboardService extends MomentumService {
  Future<List<String>> fetchSummaryItems() async {
    // Perform API/repository work here. Resolve shared services via service<ApiClient>().
    return const ['Active users: 128', 'Tasks completed: 42'];
  }
}
```

#### `dashboard_model.dart`

```dart
import 'package:momentum/momentum.dart';
import 'dashboard_controller.dart';

class DashboardModel extends MomentumModel<DashboardController> {
  const DashboardModel(
    super.controller, {
    required this.isLoading,
    required this.items,
  });

  final bool isLoading;
  final List<String> items;

  @override
  void update({
    bool? isLoading,
    List<String>? items,
  }) {
    DashboardModel(
      controller,
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
    ).updateMomentum();
  }
}
```

#### `dashboard_controller.dart`

```dart
import 'package:momentum/momentum.dart';
import 'dashboard_model.dart';
import 'dashboard_service.dart';

class DashboardErrorEvent {
  const DashboardErrorEvent(this.message);
  final String message;
}

class DashboardController extends MomentumController<DashboardModel> {
  @override
  DashboardModel init() {
    return DashboardModel(
      this,
      isLoading: false,
      items: const [],
    );
  }

  @override
  Future<void> bootstrapAsync() async {
    await refresh();
  }

  Future<void> refresh() async {
    model.update(isLoading: true);
    try {
      final items = await service<DashboardService>().fetchSummaryItems();
      model.update(isLoading: false, items: List.unmodifiable(items));
    } catch (e) {
      model.update(isLoading: false);
      sendEvent(DashboardErrorEvent('Failed to load dashboard: $e'));
    }
  }
}
```

#### `widgets/dashboard_stats_card.dart`

```dart
import 'package:material_ui/material_ui.dart';
import 'package:momentum/momentum.dart';
import '../dashboard_controller.dart';
import '../dashboard_model.dart';

class DashboardStatsCard extends StatelessWidget {
  const DashboardStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return MomentumBuilder(
      controllers: const [DashboardController],
      builder: (context, snapshot) {
        final state = snapshot<DashboardModel>();
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: state.items.length,
          itemBuilder: (context, index) => ListTile(title: Text(state.items[index])),
        );
      },
    );
  }
}
```

#### `dashboard_view.dart`

```dart
import 'package:material_ui/material_ui.dart';
import 'package:momentum/momentum.dart';
import 'dashboard_controller.dart';
import 'widgets/dashboard_stats_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends MomentumState<DashboardView> {
  @override
  void initMomentumState() {
    Momentum.controller<DashboardController>(context).listen<DashboardErrorEvent>(
      state: this,
      invoke: (event) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(event.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const DashboardStatsCard(),
      // Outside MomentumBuilder: calling controller methods does not subscribe to rebuilds.
      floatingActionButton: FloatingActionButton(
        onPressed: Momentum.controller<DashboardController>(context).refresh,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

#### Root Wiring (`main.dart`)

```dart
import 'package:material_ui/material_ui.dart';
import 'package:momentum/momentum.dart';
import 'app.dart';
import 'features/dashboard/dashboard_controller.dart';
import 'features/dashboard/dashboard_service.dart';
import 'features/login/login_controller.dart';
import 'features/login/login_service.dart';

void main() => runApp(momentum());

Momentum momentum() {
  return Momentum(
    controllers: [
      LoginController(),
      DashboardController(),
    ],
    services: [
      LoginService(),
      DashboardService(),
    ],
    child: const MyApp(),
  );
}
```

### Best Practices

1. **Keep Models strictly immutable:**
   - Never mutate lists, maps, or fields in place on `model`; always pass new copies (e.g., `List.unmodifiable(...)`) to `model.update(...)`.
   - Implement value equality (`==` and `hashCode`, or `equatable`) when a model may receive repeated identical updates so Momentum skips unnecessary rebuilds.
2. **Keep `MomentumBuilder` narrow and intentional:**
   - Wrap only the specific sub-widgets (usually inside `widgets/*.dart`) that read state from `snapshot<MyModel>()`, rather than wrapping an entire `Scaffold`.
   - Use `dontRebuildIf` on `MomentumBuilder` to skip rebuilds when unrelated fields on a shared model change.
   - Invoke actions directly with `Momentum.controller<T>(context)` outside `MomentumBuilder` (it does not create an inherited subscription and is safe inside both `initState()` and `build()`).
3. **Isolate I/O and external dependencies in Services:**
   - Put HTTP clients, database queries, and platform plugins in `<feature>_service.dart` or `lib/core/services/` rather than inside controllers or views.
   - Bind against abstract service interfaces by registering a concrete subclass in `Momentum(services: [...])` and resolving it with `service<MyRepository>(runtimeType: false)`.
   - Register multiple instances of the same service type with `InjectService<ApiService>(alias, instance)` and retrieve them via `service<ApiService>(alias: alias)`.
4. **Use `sendEvent` + `MomentumState` for transient UI side effects:**
   - Do not pollute `MomentumModel` with one-off flags for snackbars, dialogs, or navigation triggers. Emit typed events from the controller using `sendEvent<T>(event)` and handle them in `MomentumState.initMomentumState()` with `listen<T>(state: this, invoke: ...)`. Subscriptions are automatically cleaned up in `dispose()`.
5. **Leverage lazy bootstrapping deliberately:**
   - Controllers default to `lazy: true` (`BootstrapStrategy.lazyFirstBuild`), running `bootstrap()` / `bootstrapAsync()` only when their first `MomentumBuilder` mounts.
   - Opt into eager startup only for app-critical controllers (such as auth or session restoration) via `LoginController()..config(lazy: false)`, and supply an `appLoader` widget on `Momentum` for async initialization.
6. **Minimize cross-feature coupling:**
   - Avoid importing another feature's `widgets/` or internal helpers. Coordinate across features through `controller<OtherController>()` or shared services in `lib/core/services/`.
   - Never call `controller<Self>()` inside a controller (throws `MomentumError`).
7. **Configure optional built-in features cleanly:**
   - **Persistence:** Provide both `persistSave` and `persistGet` on `Momentum`, override `toJson()` and `fromJson()` on models that should persist, and override `skipPersist()` on controllers that need per-controller control.
   - **Time travel (undo/redo):** Set `..config(maxTimeTravelSteps: 20)` (`> 1`, clamped `1..250`) on controllers that need `backward()`, `forward()`, `prevModel`, and `nextModel`.
   - **Routing:** Register `MomentumRouter([...])` in `services`, set `MaterialApp(home: MomentumRouter.getActivePage(context))`, wrap feature views in `RouterPage`, pass typed `RouterParam` payloads, and add `with RouterMixin` to controllers that react to route changes.
8. **Test controllers headlessly with `MomentumTester`:**
   - Unit-test `<feature>_controller.dart` with fake/mock `MomentumService` implementations without pumping a widget tree:
     ```dart
     final tester = MomentumTester(
       Momentum(
         controllers: [DashboardController()],
         services: [FakeDashboardService()],
       ),
     );
     await tester.init();
     await tester.mockLazyBootstrap<DashboardController>();
     final ctrl = tester.controller<DashboardController>()!;
     expect(ctrl.model.items, isNotEmpty);
     ```
   - Use `testWidgets` with your `momentum()` helper (or a feature-scoped `Momentum` wrapper) for `<feature>_view.dart` and `widgets/**.dart` tests.

### Removed / Deprecated APIs (Do Not Use in 3.0.0)

| Removed / Legacy | 3.0.0 Replacement |
| --- | --- |
| `Momentum.of<T>(context)` | `Momentum.controller<T>(context)` |
| `Momentum.getService<T>(context)` | `Momentum.service<T>(context)` |
| `dependOn<T>()` (in controller) | `controller<T>()` |
| `getService<T>()` (in controller/service) | `service<T>()` |
| `Router` (removed in 2.0.0) | `MomentumRouter` |
| `package:flutter/material.dart` | `package:material_ui/material_ui.dart` |
| `WillPopScope` | `PopScope` (`onPopInvokedWithResult`) / `RouterPage` |
| `TextTheme.headline4` | `TextTheme.headlineMedium` |
| `ThemeData.backgroundColor` / `accentColor` | `ColorScheme` / `scaffoldBackgroundColor` |
| `@required` | Dart `required` keyword |

---

## Part 2: Contributing

Follow this section when directly modifying the **momentum** package repository to fix bugs, add features, or maintain documentation and tests.

### Project Overview

- **Package:** `momentum` `3.0.0` — MVC state management, dependency injection, service locator, persistence, time-travel (undo/redo), event bus, and persistent routing for Flutter.
- **SDK constraints:** Dart `>=3.0.0 <4.0.0`, Flutter `>=3.50.0` (CI runs Flutter `3.50.1`).
- **Material UI import (Flutter 3.50+):** `package:flutter/material.dart` was deprecated after Flutter `3.47.0-0.0.pre` in favor of `package:material_ui/material_ui.dart`. All code in `lib/`, `test/`, and `example/` imports `package:material_ui/material_ui.dart`.

### Repository Layout

```text
lib/
  momentum.dart              # Single public barrel export (explicit `show` lists)
  src/
    momentum_base.dart       # Core: Momentum, MomentumModel, MomentumController,
                             # BootstrapStrategy, MomentumBuilder, MomentumState,
                             # MomentumService, InjectService, MomentumTester, RouterMixin
    momentum_router.dart     # Routing: MomentumRouter, RouterPage, RouterParam, RouterSignal
    momentum_event.dart      # Internal broadcast StreamController wrapper for events
    momentum_error.dart      # MomentumError exception
    momentum_types.dart      # Public typedefs (MomentumSnapshot, BuildSkipper, etc.)
example/
  lib/main.dart              # Runnable Flutter 3.50+ counter app (analyzed & tested in CI)
  README.md                  # Example docs synced with example/lib/main.dart
test/
  demo_app/                  # Fixture app (controllers, models, services, pages) used by tests
  test_files/                # Unit & widget test suite (including bug_fixes_test.dart, example_test.dart)
docs/                        # Docsify documentation site (quick-start.md, API reference, README.md)
AGENTS.md                    # This file (Usage & Contributing guide for AI agents and developers)
llms.txt                     # Canonical Momentum 3.0.0 API quick-reference for LLMs/agents
```

### Commands

```bash
# Fetch dependencies
flutter pub get

# Static analysis (entire package and/or example)
flutter analyze
flutter analyze example/lib/main.dart

# Full test suite with coverage (matches CI)
flutter test --no-pub --coverage

# Run a targeted test file
flutter test test/test_files/bug_fixes_test.dart
flutter test test/test_files/example_test.dart
```

Formatting settings in `analysis_options.yaml` currently preserve trailing commas (`trailing_commas: preserve`) and use `page_width: 99999`.

### Architectural Invariants

Preserve these invariants when modifying library internals:

1. **Public API surface (`lib/momentum.dart`):**
   - Always use explicit `export ... show ...` clauses.
   - Public exports: `Momentum`, `MomentumModel`, `MomentumController`, `BootstrapStrategy`, `MomentumBuilder`, `MomentumState`, `MomentumService`, `InjectService`, `MomentumTester`, `RouterMixin`, `MomentumError`, `MomentumRouter`, `RouterPage`, `RouterParam`, and typedefs `MomentumSnapshot`, `MomentumBuilderFunction`, `ResetAll`, `BuildSkipper`, `PersistSaver`, `PersistGet`.
2. **Initialization order (keep `_MomentumRootState._init` and `MomentumTester.init` identical):**
   1. `await Momentum.initializer()` (if provided)
   2. Wire services (`_context` / `_tester`), bind `MomentumRouter` persistence + event bus, and `await router.init()`
   3. Initialize every controller: apply `_configInternal(...)`, call `init()`, and restore persisted state via `persistGet` + `model.fromJson(...)`
   4. Call `bootstrap()` on all non-lazy controllers (`lazy == false`)
   5. `await Future.wait(...)` on `bootstrapAsync()` for all non-lazy controllers, honoring `minimumBootstrapTime`
   6. Call `onReady()` on **all** controllers
3. **InheritedWidget lookup without subscriptions:**
   - `Momentum` extends `InheritedWidget` with `updateShouldNotify => false`.
   - `_getMomentumInstance(context)` uses `context.getInheritedWidgetOfExactType<Momentum>()` (NOT `dependOnInheritedWidgetOfExactType`), so `Momentum.controller<T>(context)` and `Momentum.service<T>(context)` are safe inside `initState()` and never cause spurious rebuilds. Throw `MomentumError` if no `Momentum` ancestor exists.
4. **Parent rebuild safety:**
   - `_MomentumRootState` caches `_initFuture`, `_momentumEvent`, and `_routerSubscription` so parent widget rebuilds never re-run `initializer()`, `bootstrap()`, or duplicate router subscriptions. Clean up subscriptions/events in `dispose()`.
5. **Listener & event cleanup:**
   - `MomentumState` tracks `deactivated` (`deactivate`/`activate`/`didUpdateWidget`) and runs all registered `_disposeCallbacks` in `dispose()`.
   - `MomentumBuilder` detaches old listeners and re-subscribes when `widget.controllers` changes in `didUpdateWidget`.
   - `MomentumController.sendEvent<T>` prunes closed/unmounted handlers before dispatching.
6. **Immutability, equality & time travel:**
   - `MomentumModel` is `@immutable`. `_setMomentum` skips updates when `_currentActiveModel == model` (supports `equatable` or custom `==`/`hashCode`).
   - `maxTimeTravelSteps` is clamped to `1..250`; values `> 1` enable `backward()` / `forward()` and populate `prevModel` / `nextModel`.
7. **Persistence safety:**
   - Active only when **both** `persistSave` and `persistGet` are provided on `Momentum`.
   - Per-controller `skipPersist()` (`Future<bool?>`) overrides global `disabledPersistentState` when non-null.
   - Never persist when `toJson()` returns `null` or throws; never invoke `fromJson()` when stored JSON is `null`, empty, or not a `Map<String, dynamic>`.
8. **Service & controller lookup rules:**
   - Duplicate controller types in `Momentum(controllers: [...])` and duplicate `InjectService` aliases throw `MomentumError`.
   - `controller<T>()` throws `MomentumError` when called with its own type or an unregistered type.
   - `service<T>({bool runtimeType = true, dynamic alias})` matches exact `runtimeType` by default; `runtimeType: false` matches subtypes/abstract interfaces (`s is T`). Requesting bare `InjectService` throws `MomentumError`.
9. **Routing (`MomentumRouter` / `RouterPage`):**
   - `MomentumRouter` is a `MomentumService` navigating by widget `Type` (not named route strings).
   - `RouterPage` wraps Flutter's `PopScope` (`onPopInvokedWithResult`) to route system back gestures to `MomentumRouter.pop(context)`.

### Contribution & Verification Checklist

- Throw `MomentumError` for misconfiguration and lookup errors (with actionable messages referencing the 3.0.0 method names).
- Do not reintroduce any removed v1/v2 aliases or deprecated Flutter APIs listed in [Removed / Deprecated APIs](#removed--deprecated-apis-do-not-use-in-300).
- Whenever changing initialization, config, persistence, or service wiring, update **both** `_MomentumRootState` and `MomentumTester`.
- Keep `example/lib/main.dart`, `example/README.md`, `docs/quick-start.md`, and `llms.txt` in sync when public APIs change.
- Add or update unit tests (`MomentumTester`) and/or widget tests (`testWidgets`) under `test/test_files/` and verify `flutter analyze` and `flutter test --no-pub --coverage` pass (CI enforces coverage checks via `lcov-cop`).
