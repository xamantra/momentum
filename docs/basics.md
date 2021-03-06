# The Basics
This covers the basic building blocks of momentum state management. Specifically, on setup, rebuilding widgets, write models, write logic, access dependencies.

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
There is only one way to update or rebuild widgets. That is using `model.update(...)`.
- `model.update(...)` is like `setState(...)` but immutable and called inside logic class not inside the widgets.
- It's not just for rebuilding widgets but also syncing values when something changes in the UI like user inputs.

#### The logic inside controller code:
```dart
class CounterController extends MomentumController<CounterModel> {

  // ...

  void increment() {
    var newValue = model.value + 1;
    model.update(value: newValue); // update widgets
  }

  // ...
}
```
- You can access property values using `model.propertyName`.
- Models are immutable so you can't do `model.propertyName = value;` to update the state.

#### This is how you display the model/state:
```dart
MomentumBuilder(
  controllers: [CounterController],
  builder: (context, snapshot) {
    var counter = snapshot<CounterModel>();
    return Text('${counter.value}');
  }
)
```
- `MomentumBuilder` is a widget that means you can use it anywhere.
- `snapshot<T>` is a method used to grab a certain model that the controller is injected into the `controllers` parameter.

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
- As you can see, there is an `update(...)` method here. It is required to be implemented. This method is similar to the `copyWith` function.
- The method `updateMomentum()` needs to be explicitly called. 
- A model is always attached to a specific controller so the `controller` parameter should be specified always (*which is very easy to do and is part of the boilerplate*).

!> Refer to [this link](https://developer.school/dart-flutter-what-does-copywith-do/#:~:text=Although%20the%20notion%20of%20copyWith,arguments%20that%20overwrite%20settable%20values.) to understand what is `copyWith` method.

!> Head to boilerplate section if you want to see  [how the blank model looks like](/quick-start?id=boilerplate-code)

## Writing Controller
The logic of the momentum app resides in controllers. You write all the functions here. This is also the place where you can call `model.update(...)`.
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
- The `init()` method is the initial state, it is called when the app starts.
- It's guaranteed that all these initial values will be available inside any functions you define.
- You can access the model properties you defined using `model.propertyName`.
- You can do anything inside controllers like calling and awaiting an HTTP request while displaying a loading widget until the request is done.

!> Always remember to add the controllers you create in `Momentum`'s `controllers` parameter.

!> Head to boilerplate section if you want to see  [how blank controller looks like](/quick-start?id=boilerplate-code)

## Dependency Injection
With momentum, you can easily access almost everything. Take a look at these codes:
- Access another controller inside a controller using `controller<T>()` method:
  ```dart
  class AuthController extends MomentumController<AuthModel> {

    // ...

    void login() {
      var sessionController = controller<SessionController>();
      // do anything with "sessionController" here.
      // you can access "sessionController.model.propertyName".
      // you can also call functions like "sessionController.createSession()".
    }

    // ...

  }
  ```
- Access a controller inside a widget using `Momentum.controller<T>(context)`:
  ```dart
  @override
  Widget build(BuildContext context) {
    var loginController = Momentum.controller<LoginController>(context);
    // you can also declare this as class wide variable and
    // call Momentum.controller<T> inside build or didChangeDependencies.
    // in the widgets, for example a button's onPressed parameter
    // you can now call functions like "loginController.login()".
  }
  ```
- You can also access a controller inside `MomentumBuilder`:
  ```dart
  MomentumBuilder(
    controllers: [CounterController],
    builder: (context, snapshot) {
      var counterModel = snapshot<CounterModel>();
      var counterController = counterModel.controller;
      return TextButton(
        onPressed: () {
          counterController.increment();
        },
        child: ...
      );
    }
  )
  ```
- Access a service inside a controller using `service<T>()` method:
  ```dart
  class AuthController extends MomentumController<AuthModel> {

    // ...

    void login() async {
      var apiService = service<ApiService>();
      var result = await apiService.auth(
        username: model.username,
        password: model.password,
      );
    }

    // ...

  }
  ```
- Access a service inside a widget using `Momentum.service<T>(context)`:
  ```dart
  Widget build(BuildContext context) {
    var someService = Momentum.service<SomeService>(context);
    // you can also declare this as class wide variable and
    // call Momentum.someService<T> inside build or didChangeDependencies.
    // in the widgets.
  }
  ```
