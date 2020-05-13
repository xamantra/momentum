## Install momentum

Add `momentum: LATEST_VERSION` on your `pubspec.yaml` file.

```yaml
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^0.1.2
  momentum: ^1.1.5
```

Run `flutter pub get` to fetch the library.

## Setup <u>main()</u> function

Add the root widget class `Momentum` in your `runApp(...)` method call inside `main.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart'; // import momentum

void main() {
  runApp(
    Momentum(
      /* empty for now, we're gonna add some stuff here later... */
      controllers: [],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum State Management', // Add you own title here.
      theme: ThemeData(
        /* replace the theme if you want */
        primarySwatch: Colors.blue
      ),
      home: HomeWidget(), // we're gonna create this later...
    );
  }
}
```

You can now test this setup. See if the app runs fine. Enter `flutter run` or your IDE's run function.

#### Now, lets make a counter app!

Create the folder `lib/src/components/counter` on you project directory.

## CounterModel

Inside the `counter` folder, create `counter.model.dart` file.

```dart
import 'package:momentum/momentum.dart'; // import momentum

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
```

`MomentumModel<CounterController>` means we are tying this model into `CounterController`.

This code will give an error about `CounterController` being an undefined type. So let's make it!

## CounterController

Inside the `counter` folder, create `counter.controller.dart` file.

**NOTE: Don't forget to import the controller and model file on each other.**

```dart
import 'package:momentum/momentum.dart'; // import momentum

class CounterController extends MomentumController<CounterModel> {
  @override
  CounterModel init() {
    return CounterModel(
      this,
      value: 0, // counter starts at 0.
    );
  }

  void increment() {
    var value = model.value; // grab the current value
    model.update(value: value + 1); // update state (rebuild widgets)
    print(model.value); // new or updated value
  }
}
```

`MomentumController<CounterModel>` means we are tying this controller into `CounterModel`.

## HomeWidget

Now, this widget file will not be included inside `components/counter` folder because controllers and models are not tied to any widget. You can create this widget file anywhere in your project like `lib/src/widgets/home.widget.dart` for example.

**NOTE: Don't forget to import the controller and model file.**

```dart
import 'package:momentum/momentum.dart'; // import momentum

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
                  '${counter.value}', // display the counter value
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: MomentumBuilder(
        controllers: [CounterController],
        builder: (context, snapshot) {
          var controller = snapshot<CounterModel>().controller; // circular reference.
          return FloatingActionButton(
            onPressed: controller.increment, // reference the `increment` method we defined above ^
            tooltip: 'Increment',
            child: Icon(Icons.add),
          );
        },
      ),
    );
  }
}
```

Now try to run it. See how amazing your very first flutter momentum app ever!
