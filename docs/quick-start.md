# Quick Start

Momentum 3.0.0 requires **Dart 3** (`>=3.0.0 <4.0.0`) and **Flutter 3.50+** (`>=3.50.0`).

## Create
To get started, `flutter create` an app and name it however you want.

## Installing
1. Add `momentum` (and `material_ui`, which replaces the deprecated `package:flutter/material.dart` in Flutter 3.47+) to your package's `pubspec.yaml`:
    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      material_ui: ^1.11.1
      momentum: ^3.0.0
    ```
    It is recommended to depend on the published version from pub.dev rather than tracking a git branch directly.

2. Install the package from the *command-line*:
    ```bash
    flutter pub get
    ```
    Alternatively, your editor may run `flutter pub get` automatically.

3. Import the single barrel file in your Dart code:
    ```dart
    import 'package:momentum/momentum.dart';
    ```
    All public Momentum APIs (classes, enums, `MomentumError`, and typedefs) are exported from this single entry point.

## Example
Copy this runnable counter app code (also kept in sync and CI-checked in [`example/lib/main.dart`](https://github.com/xamantra/momentum/blob/master/example/lib/main.dart)):

```dart
import 'package:material_ui/material_ui.dart';
import 'package:momentum/momentum.dart';

void main() {
  runApp(momentum());
}

Momentum momentum() {
  return Momentum(
    controllers: [CounterController()],
    child: const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum State Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomeWidget(),
    );
  }
}

class CounterController extends MomentumController<CounterModel> {
  @override
  CounterModel init() {
    return CounterModel(
      this,
      value: 0,
    );
  }

  void increment() {
    model.update(value: model.value + 1);
  }
}

class CounterModel extends MomentumModel<CounterController> {
  const CounterModel(
    super.controller, {
    required this.value,
  });

  final int value;

  @override
  void update({int? value}) {
    CounterModel(
      controller,
      value: value ?? this.value,
    ).updateMomentum();
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Momentum Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            MomentumBuilder(
              controllers: const [CounterController],
              builder: (context, snapshot) {
                final counter = snapshot<CounterModel>();
                return Text(
                  '${counter.value}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      // We don't need to rebuild the button, so it can live outside MomentumBuilder.
      floatingActionButton: FloatingActionButton(
        onPressed: Momentum.controller<CounterController>(context).increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```
- Inside `main()`, `Momentum` is set as the root widget of the app.
- `CounterController` is registered in the `controllers` list.
- Inside `CounterController`, `increment()` calls `model.update(...)`, creating a new immutable `CounterModel` and rebuilding all `MomentumBuilder` widgets listening to `CounterController`.
- `CounterModel` holds immutable `final` state fields (`value`) and implements `update(...)` using nullable optional named parameters.
- `HomeWidget` uses `MomentumBuilder` to read the latest `CounterModel` snapshot and `Momentum.controller<CounterController>(context)` to invoke controller actions without rebuilding the button.

## Boilerplate Code
A pair of `MomentumController` and `MomentumModel` is called a **component**. The controller holds the logic and the model holds the immutable state. A component is not tied to a single widget—you can reuse it across multiple pages and widgets.

- Boilerplate for a `controller`:

```dart
import 'package:momentum/momentum.dart';

import 'index.dart';

class ExampleController extends MomentumController<ExampleModel> {
  @override
  ExampleModel init() {
    return ExampleModel(
      this,
      value: 0,
    );
  }
}
```

- Boilerplate for a `model`:

```dart
import 'package:momentum/momentum.dart';

import 'index.dart';

class ExampleModel extends MomentumModel<ExampleController> {
  const ExampleModel(
    super.controller, {
    required this.value,
  });

  final int value;

  @override
  void update({int? value}) {
    ExampleModel(
      controller,
      value: value ?? this.value,
    ).updateMomentum();
  }
}
```

There is also a [VS Code extension](https://marketplace.visualstudio.com/items?itemName=xamantra.momentum-code) for generating component boilerplate.
