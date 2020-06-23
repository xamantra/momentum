# Quick Start
You only have to install one package and momentum doesn't have any peer dependencies.

## Create
To get started, `flutter create` an app. Name it however you want.

## Installing
1. Add this to your package's `pubspec.yaml` file:
    ```yaml
    dependencies:
      momentum: ^1.2.7
    ```
    It is not recommended to use the one from GitHub because the changes there are subject to breaking changes on future pushes to the repository.

2. You can install this package from the *command-line*:
    ```bash
    flutter pub get
    ```
    Alternatively, your editor might support `flutter pub get`.

3. Now in your Dart code, you can use:
    ```dart
    import 'package:momentum/momentum.dart';
    ```
    You only have to import this one file alone and you'll be able to use all momentum API.

## Example
Copy this example counter app code and run it:

```dart
import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

void main() {
  runApp(
    Momentum(
      controllers: [
        CounterController(),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum State Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeWidget(),
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
    var value = model.value; // grab the current value
    model.update(value: value + 1); // update state (rebuild widgets)
    print(model.value); // new or updated value
  }
}

class CounterModel extends MomentumModel<CounterController> {
  CounterModel(
    CounterController controller, {
    this.value,
  }) : super(controller);

  final int value;

  @override
  void update({
    int value,
  }) {
    CounterModel(
      controller,
      value: value ?? this.value,
    ).updateMomentum();
  }
}

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Momentum Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            MomentumBuilder(
              controllers: [CounterController],
              builder: (context, snapshot) {
                var counter = snapshot<CounterModel>();
                return Text(
                  '${counter.value}',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
          ],
        ),
      ),
      // we don't need to rebuild the increment button, we can skip the MomentumBuilder
      floatingActionButton: FloatingActionButton(
        onPressed: Momentum.controller<CounterController>(context).increment,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```
- Inside `main()` method `Momentum` is set as the root widget of the app.
- The `CounterController` is instantiated in `controllers` parameter.
- Inside the `CounterController` there is an `increment()` method that updates the value. It calls the method `model.update(...)` which will rebuild the widget.
- The `CounterModel` is where the props are defined and currently has the `value` property.
- The `HomeWidget` uses `MomentumBuilder` which is used for displaying the model properties to the screen. You can call `model.update(...)` to rebuild this widget.

## Boilerplate Code
A pair of `MomentumController` and `MomentumModel` are called components. They both have very short boilerplate codes. The controller is the logic and the Model is the state. A component is not tied to a single widget only, you can use a component in multiple pages/widgets across the app.

- This is the boilerplate code for `controller`:

```dart
import 'package:momentum/momentum.dart';

import 'index.dart';

class ExampleController extends MomentumController<ExampleModel> {
  @override
  ExampleModel init() {
    return ExampleModel(
      this,
      // TODO: specify initial values here...
    );
  }
}
```

- This is the boilerplate code for `model`:

```dart
import 'package:momentum/momentum.dart';

import 'index.dart';

class ExampleModel extends MomentumModel<ExampleController> {
  ExampleModel(ExampleController controller) : super(controller);

  // TODO: add your final properties here...

  @override
  void update() {
    ExampleModel(
      controller,
    ).updateMomentum();
  }
}
```

There is also a [vs code extension](https://marketplace.visualstudio.com/items?itemName=xamantra.momentum-code) for generating these boilerplate codes in few clicks.