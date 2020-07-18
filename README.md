<p align="center">
  <img src="https://i.imgur.com/DAFGeAd.png">
</p>

<p align="center">A super-powerful flutter state management library inspired with MVC pattern with very flexible dependency injection.</p>

<p align="center">
<a href="https://pub.dev/packages/momentum" target="_blank"><img src="https://img.shields.io/pub/v/momentum" alt="Pub Version" /></a>
<a href="https://github.com/xamantra/momentum/actions?query=workflow%3ACI" target="_blank"><img src="https://github.com/xamantra/momentum/workflows/CI/badge.svg?event=push" alt="CI" /></a>
<a href="https://codecov.io/gh/xamantra/momentum"><img src="https://codecov.io/gh/xamantra/momentum/branch/master/graph/badge.svg" /></a>
<a href="https://pub.dev/packages/momentum/score" target="_blank"><img src="https://img.shields.io/badge/dynamic/json?color=blue&label=likes&query=likes&url=http://www.pubscore.gq/likes?package=momentum" alt="likes" /></a>
<a href="https://pub.dev/packages/momentum/score" target="_blank"><img src="https://img.shields.io/badge/dynamic/json?color=green&label=health&query=pub_points&url=http://www.pubscore.gq/pub-points?package=momentum" alt="health" /></a>
<a href="https://pub.dev/packages/momentum/score" target="_blank"><img src="https://img.shields.io/badge/dynamic/json?color=teal&label=popularity&query=popularity&url=http://www.pubscore.gq/popularity?package=momentum" alt="popularity" /></a>
<a href="https://github.com/xamantra/momentum/stargazers" target="_blank"><img src="https://img.shields.io/github/stars/xamantra/momentum" alt="GitHub stars" /></a>
<a href="https://github.com/tenhobi/effective_dart" target="_blank"><img src="https://img.shields.io/badge/style-effective_dart-54C5F8.svg" alt="style: effective dart" /></a>
<a href="https://github.com/xamantra/momentum/blob/master/LICENSE" target="_blank"><img src="https://img.shields.io/github/license/xamantra/momentum" alt="GitHub license" /></a>
<a href="https://github.com/xamantra/momentum/commits/master" target="_blank"><img src="https://img.shields.io/github/last-commit/xamantra/momentum" alt="GitHub last commit" /></a>
</p>

---

- **MAJOR UPDATE**: **v1.1.7** and up.
- FULL DOCUMENTATION: https://xamdev.gq/momentum/#/
- Testing Guide: https://xamdev.gq/momentum/#/testing
- Recommended Advance <a href="https://github.com/xamantra/listify" target="_blank">Example App</a>
- Old README can be <a href="https://xamdev.gq/momentum/#/README.old" target="_blank">found here</a>

---


## Features
  - Very flexible `Dependency Injection` to easily instantiate any dependencies once and reuse multiple times across the app.
  - `Persistence` support for states and routing. Use any storage provider.
  - Time travel (`undo/redo`) support in one line of code out of the box.
  - Optional `Equatable` support. (*Improves time travel*).
  - `Immutable` states/models. There's only one way to rebuild a widget.
  - You can `reset a state` or all of the states.
  - `Skip rebuilds`. Widget specific.
  - Easy to use `Event System` for sending events to the widgets. *For showing dialogs/snackbars/alerts/navigation/etc.*
  - Momentum doesn't have any dependencies so it increases compatibility in other platforms.
  - Supports older versions of flutter.

## Core Concepts

  - Momentum only uses `setState(...)` under the hood.
  - The method `model.update(...)` is the setState of momentum.
  - Modular project structure because of the component system (`MomentumController` + `MomentumModel`).
  - Everything can be reusable from widgets, services, data, state to logic.
  - Everything is in the widget tree.

## Preview
In this image the process was like this:
- Open the app (Home Page).
- Go to *Add New List* page.
- Input some data.
- Close and Terminate on task view.
- Reopen the app again.

And magic happens! All the inputs were retained and not just that but also including the page where you left off. Navigation history is also persisted which means pressing the system back button will navigate you to the correct previous page.

![persistent preview](https://i.imgur.com/9CrFNRG.png)

#### Dark Mode
This theming is done manually using momentum.

![dark mode](https://i.imgur.com/WurrjR1.png)

#### [Source Code for this Example App](https://github.com/xamantra/listify)
This example app shows how powerful momentum is.

# Quick Start
You only have to install one package and momentum doesn't have any peer dependencies.

## Create
To get started, `flutter create` an app. Name it however you want.

## Installing
1. Add this to your package's `pubspec.yaml` file:
    ```yaml
    dependencies:
      momentum: ^1.3.1
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

## Counter App Example
Copy this example counter app code and run it:

```dart
import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

void main() {
  runApp(
    Momentum(
      controllers: [CounterController()],
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

---

## Please Note

- **MAJOR UPDATE**: **v1.1.7** and up.
- FULL DOCUMENTATION: https://xamdev.gq/momentum/#/
- Testing Guide: https://xamdev.gq/momentum/#/testing
- Recommended Advance <a href="https://github.com/xamantra/listify" target="_blank">Example App</a>
- Old README can be <a href="https://xamdev.gq/momentum/#/README.old" target="_blank">found here</a>
