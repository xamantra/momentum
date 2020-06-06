# The Basics
This covers the basic building blocks of momentum state management. Specifically on setup, rebuilding widgets, write models, write logic, access dependencies.

## Setup
`Momentum` is a widget that should be in the root of the app.
```dart
void main() {
  runApp(
    Momentum(
      child: MyApp(),
      controllers: [
        ExampleController(),
      ],
    ),
  );
}
```
The `controllers` parameter is a list of controller instances that can be reused down the tree multiple times. Let's say in a certain widget you wanted to access `CounterController` but it is not instantiated in controllers parameter of Momentum, you will get an error.

## Rebuilding Widgets
There is only one way to update or rebuild widgets.

Inside controller code:
```dart
void increment() {
  var newValue = model.value + 1;
  model.update(value: newValue); // update widgets
}
```
This is how you display your model/states.
```dart
MomentumBuilder(
  controllers: [CounterController],
  builder: (context, snapshot) {
    var counter = snapshot<CounterModel>();
    return Text('${counter.value}');
  }
)
```
`MomentumBuilder` is a widget means you can use it anywhere.

## Writing Model
Models in momentum must be immutable so all properties are final.
```dart
import 'package:momentum/momentum.dart';

class ExampleModel extends MomentumModel<ExampleController> {
  ExampleModel(
    ExampleController controller, {
    this.value,
    this.name,
  }) : super(controller);

  final int value;
  final String name;

  @override
  void update({
    int value,
    String name,
  }) {
    ExampleModel(
      controller, // re-inject controller to a new model copy.
      value: value ?? this.value,
      name: name ?? this.name,
    ).updateMomentum();
  }
}
```
As you can see, there is `update(...)` method here. It is required to be implemented. This method is similar to `copyWith` function.
The method `updateMomentum()` needs to be explicitly called. A model is always attached to a specific controller so the `controller` parameter should be specified always (*which is very easy to do and is part of the boilerplate*).

!> Refer to [this link](https://developer.school/dart-flutter-what-does-copywith-do/#:~:text=Although%20the%20notion%20of%20copyWith,arguments%20that%20overwrite%20settable%20values.) to understand what is `copyWith` method.

!> Head to boilerplate section if you want to see  [how blank model looks like](/quickstart?id=boilerplate-code)

## Writing Controller
The logic of your momentum app resides in controllers. You write all your functions here. This is also the place where you can call `model.update(...)`.
```dart
import 'package:momentum/momentum.dart';

class ExampleController extends MomentumController<ExampleModel> {
  @override
  ExampleModel init() {
    return ExampleModel(
      this, // specify controller
      value: 0,
    );
  }

  void increment() {
    var newValue = model.value + 1;
    model.update(value: newValue); // update widgets
  }
}
```
The `init()` method is your initial state it is called when the app starts. It's guaranteed that all these initial values will be available inside any functions you define. You can access the model properties you defined using `model.propertyName`. You can do anything inside controllers like calling and awaiting http request while displaying loading widget until the request is done.

!> Always remember to add the controllers you create in `Momentum`'s `controllers` parameter.

!> Head to boilerplate section if you want to see  [how blank controller looks like](/quickstart?id=boilerplate-code)

## Dependency Injection
With momentum you can easily access almost everything. Take a look at these codes:
- Access another controller inside a controller:
  ```dart
  void login() {
    var sessionController = dependOn<SessionController>();
    // do anything with "sessionController" here.
    // you can access "sessionController.model.propertyName".
    // you can also call functions like "sessionController.createSession()".
  }
  ```
- Access a controller inside a widget using `context:
  ```dart
  var loginController = Momentum.controller<LoginController>(context);
  // you can also declare this as class wide variable and
  // call Momentum.controller<T> inside build or didChangeDependencies.
  // in your widgets, for example a button's onPressed parameter
  // you can now call functions like "loginController.login()".
  ```
- You can also access a controller inside `MomentumBuilder`:
  ```dart
  MomentumBuilder(
    controllers: [CounterController],
    builder: (context, snapshot) {
      var counter = snapshot<CounterModel>();
      var counterController = counter.controller;
      return FlatButton(
        onPressed: () {
          counterController.increment();
        },
        child: ...
      );
    }
  )
  ```

!> **NOTE:** If you can access a controller you can access its model and vice-versa. They are in a circular reference.