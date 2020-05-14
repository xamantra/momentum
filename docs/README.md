<p align="center">
  <img src="https://i.imgur.com/DAFGeAd.png">
</p>

<h5 align="center">A super powerful flutter state management library that focuses on ease of control inspired with MVC pattern.</h5>

### Goal

One aim of **momentum** is to make widget classes **parameter-less**. I'm pretty sure you've heard of `BLoC` package. One of the most common situation you can see with it is the widget has the parameter `bloc:`. The purpose of it is passing around the bloc instance to use it in other widgets. But as project grows it will be very hard to debug and maintain anymore. It's called `context hell`. With momentum you can "easily" access any controllers anytime anywhere. You can even access a specific controller inside another controller without using `context` in 1 line of code. It sounds impossible but it's true. Some in demand features like `time travel state` (undo/redo), `state reset`, `asynchronous initializers` exist and most of them are zero config and can be done in 1 line of code. Yes, this library really focus on ease of control. You will never pass around anything.

### Pattern

**Momentum** is inspired with MVC pattern. The difference is that `Controller` and `Model` are not tied to any view (**widget**). Any widget can basically use a pair of **controller** and **model**. Some apis of momentum looks like it's using static/singleton containers but it's actually NOT. It follows **flutter** widget tree system and encapsulation. The model is also immutable. You can update the state by using a method similar to `copyWith`, this will be explained more later.

In momentum a controller is called `MomentumController` and a model is called `MomentumModel`. Both are tied to each other. MomentumController has MomentumModel property and vice-versa. This circular reference will be explained more later in the docs. While this library has those common features of a state management, it also has a lot of features that doesn't exists in other popular state management. You are going to see them later. The class you use to actually display your model is `MomentumBuilder` widget. You can access multiple controllers and models in a single momentum builder widget and can even skip rebuilds with `dontRebuildIf` parameter which is really powerful.

### Code Preview

Take a look at this simple example which is a (as usual) counter app.

**NOTE:** This code won't work out of the box. You need to setup something at your `main()` function. This is only a preview code on how momentum looks like. Please head to **Getting Started**.

> counter.model.dart

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

> counter.controller.dart

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

> home.widget.dart

```dart
import 'package:flutter/material.dart';
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
