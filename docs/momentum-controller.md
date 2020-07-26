# MomentumController
The class which holds the logic for your app. This is tied with `MomentumModel`. This is abstract and needs to be implemented.

This is the boilerplate code:
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

## ..config({...})
- Category: `Method`
- Return Type: `void`

Configure this controller to set some custom behaviors.
  - `maxTimeTravelSteps` - set the maximum number of undo/redo steps that this controller can take. Clamped between `1`(min) and `250`(max).

  - `lazy` - If `false`, this controller will be bootstrapped when the app starts. Defaults to `true`.

  - `strategy` - Set the bootstrap behavior for this controller if lazy mode is `true`.

  - `enableLogging` - Whether to print detailed verbose logs or not. Defaults to `false`.
```dart
    Momentum(
      // ...
      controllers: [
        ExampleControllerA()..config(
          maxTimeTravelSteps: 30, // maximum of 30 undo/redo steps.
          lazy: false, // bootstrap this controller when the app starts.
          strategy: BootstrapStrategy.lazyFirstCall, // This controller will bootstrap on first "Momentum.controller<ExampleControllerA>(context)" call.
          enableLogging: true, // print verbose logs.
        ),
        ExampleControllerB()..config(lazy: false),
      ],
      // ...
    )
```

<hr>

## init()
- Category: `Abstract Method`
- Return Type: `MomentumModel`
- Required: `YES`

Initialize the model of this controller. Required to be implemented. This method will only be called once. Momentum will automatically call this method. The initial values provided here are guaranteed to be used instantly down the code.
```dart
class ExampleController extends MomentumController<ExampleModel> {

  @override
  void init() {
    return ExampleModel(
      this, // attach this controller to "ExampleModel".
      value: 0, // initial value for a counter app.
    );
  }

  // ...
}
```

<hr>

## bootstrap()
- Category: `Virtual Method`
- Return Type: `void`
- Required: `NO`

This is where you do logic initialization. `init()` is just for initial constant values. Momentum will call this when the app starts if `lazy` is `false`. If it is true, this will only be called when the very first `MomentumBuilder` that depends on this controller gets rendered on the screen.
```dart
class ExampleController extends MomentumController<ExampleModel> {

  // ...

  @override
  void bootstrap() {
    var isDarkMode = sharedPreference.getBool('isDarkMode');
    model.update(isDarkMode: isDarkMode);
  }

  // ...
}
```

<hr>

## bootstrapAsync()
- Category: `Virtual Method`
- Return Type: `void`
- Required: `NO`

The asynchronous version of `bootstrap()`. You'll probably want to use this more. If `lazy` is `false`, momentum will await this method when the app starts and display a loading widget before your actual `MyApp()` widget gets loaded. If `lazy` is `true`, it has the same behavior with `bootstrap()`.
```dart
class ExampleController extends MomentumController<ExampleModel> {

  // ...

  @override
  Future<void> bootstrapAsync() async {
    var someBigData = await apiService.getSomeBigData();
    model.update(someBigData: someBigData);
  }

  // ...
}
```

<hr>

## skipPersist()
- Category: `Virtual Method`
- Return Type: `Future<bool>`
- Required: `NO`

If you want to disable persistence for this controller's model, you can override this method and return `true`.
```dart
class ExampleController extends MomentumController<ExampleModel> {

  // ...

  @override
  Future<bool> skipPersist() async => true;

  // ...
}
```

<hr>

## .getService\<T\>()
- Category: `Method`
- Return Type: `T` *where T extends MomentumService*

A dependency injection method. Get a specific service of type `T`. Services can be anything.
```dart
class ExampleController extends MomentumController<ExampleModel> {

  // ...

  @override
  Future<void> loadProfile() async {
    var apiService = getService<ApiService>(); // or this.getService<T>()
    var profile = await apiService.getProfile();
    model.update(profile: profile);
  }

  // ...
}
```
If you are using the new `InjectService` to add your services. You can also use the `alias` parameter to get a specific service with matching alias.
```dart
var apiService = getService<ApiService>(alias: ApiAlias.logsEnabled);
```
`alias` is dynamic type which means you can use any values here as long as it matches with the one you want to grab. It is highly recommended to use an `enum`.

Refer to the full documentation for `InjectService` [here](https://xamdev.gq/momentum/#/inject_service).

<hr>

## .dependOn\<T\>()
- Category: `Method`
- Return Type: `T` *where T extends MomentumController*

A dependency injection method. Get a specific controller of type `T`. With this, you can easily access other controllers and manipulate them.
```dart
class ExampleController extends MomentumController<ExampleModel> {

  // ...

  @override
  void logout() {
    var sessionController = dependOn<SessionController>(); // or this.dependOn<T>();
    sessionController.destroySession();
    model.updated(loggedOut: true);
  }

  // ...
}
```

<hr>

## .addListener(...)
- Category: `Method`
- Return Type: `void`

Should be called inside stateful widgets. Used for listening to model updates and react to it. This requires `MomentumState` so that momentum can automatically dispose of the listeners for you. When `model.update(...)` is called, the `invoke` function parameter will be executed.
```dart
class _ExampleState extends MomentumState<ExampleWidget> {

  // ...

  @override
  void initMomentumState() {
    exampleController.addListener(
      state: this, // requires "MomentumState".
      invoke: (model, isTimeTravel) {
        // "model" is of type ExampleModel.
        // do something with the "model" or "isTimeTravel" here.
      },
    );
  }

  // ...
}
```

<hr>

## .sendEvent\<T\>(...)
- Category: `Method`
- Return Type: `void`

It can be used to send events to the widgets. It is highly recommended to use this for doing context actions like dialogs, alerts, snackbars/toast, or page navigation, etc. `T` is the event data and it can be anything.
```dart
/// you can put this class in a separate file along with other event types.
class LoginEvent {
  final bool success;
  final String message;

  LoginEvent({this.success, this.message});
}

class AuthController extends MomentumController<AuthModel> {

  // ...

  @override
  Future<void> login() async {
    var response = await apiService.auth(
      username: model.username,
      password: model.password,
    );
    if (response.success) {
      // or this.sendEvent<T>(...)
      sendEvent(LoginEvent(success: true));
    } else {
      sendEvent(LoginEvent(success: false, message: 'Login failed.'));
    }
  }

  // ...
}
```

<hr>

## .listen\<T\>(...)
- Category: `Method`
- Return Type: `void`

The partner of `sendEvent<T>(...)`. This method will react to every call of `sendEvent<T>()`. Similar to `addListener`, this requires `MomentumState` so that momentum can automatically dispose of the listeners for you.
```dart
class _ExampleState extends MomentumState<ExampleWidget> {

  // ...

  @override
  void initMomentumState() {
    exampleController.listen<LoginEvent>(
      state: this, // requires "MomentumState".
      invoke: (event) {
        // "event" is of type "LoginEvent".
        if (event.success) {
          // go to home page for example.
          Router.goto(context, Home);
        } else {
          showSnackbar(message: event.message, error: true);
        }
      },
    );
  }

  // ...
}
```

<hr>

## .backward()
- Category: `Method`
- Return Type: `void`

Time travel method. `Undo` state update. Useful for input pages or reverting dangerous actions like delete. This will rebuild the widgets.
```dart
FlatButton(
  // ...
  onPressed: () {
    // undo edit on textfields.
    loginController.backward();
  },
  // ...
)
```

<hr>

## .forward()
- Category: `Method`
- Return Type: `void`

Time travel method. `Redo` state update. This will rebuild the widgets.
```dart
FlatButton(
  // ...
  onPressed: () {
    // redo edit on textfields.
    loginController.forward();
  },
  // ...
)
```

<hr>

## .reset()
- Category: `Method`
- Return Type: `void`

Reset the state, the `init()` implementation will be used. Example usage might be for clearing all textfield inputs.
```dart
FlatButton(
  child: Text('Clear All Inputs'),
  onPressed: () {
    loginController.reset();
    
    // remove the ability to undo/redo with "clearHistory" parameter
    loginController.reset(clearHistory: true);
  },
  // ...
)
```

<hr>

## .model
- Category: `Readonly Property`
- Type: `MomentumModel`

The latest snapshot of `model.update(...)` call. This is also what `snapshot<T>()` inside `MomentumBuilder` returns.
```dart
class CounterController extends MomentumController<CounterModel> {

  // ...

  @override
  void increment() {
    print(model.value); // 1
    model.update(value: model.value + 1);
    print(model.value); // 2
  }

  // ...
}
```

<hr>

## .prevModel
- Category: `Readonly Property`
- Type: `MomentumModel`

The previous snapshot of `.model` property.
```dart
class CounterController extends MomentumController<CounterModel> {

  // ...

  @override
  void increment() {
    print(model.value); // 1
    model.update(value: model.value + 1);
    // or this.prevModel
    print(prevModel.value); // 1
    print(model.value); // 2
  }

  // ...
}
```
!> `prevModel` will always be null if time travel is not enabled.

<hr>

## .nextModel
- Category: `Readonly Property`
- Type: `MomentumModel`

The next snapshot of `.model` property. This will only have a value after calling `.backward()`.
```dart
class CounterController extends MomentumController<CounterModel> {

  // ...

  @override
  void increment() {
    print(model.value); // 1
    model.update(value: model.value + 1);
    print(model.value); // 2

    backward();
    print(model.value); // 1
    print(nextModel.value); // 2
    // or this.nextModel
  }

  // ...
}
```
!> `nextModel` will always be null if time travel is not enabled.

<hr>

## .persistenceKey
- Category: `Readonly Property`
- Type: `String`

The key used internally by momentum for persistence. Exposed publicly so that you can optionally override this to create your unique key.
```dart
class ExampleController extends MomentumController<ExampleModel> {
  
  // ...

  @override
  String get persistenceKey => 'YouOwnUniqueKeyHere';

  // ...
}
```

<hr>

## .isLazy
- Category: `Readonly Property`
- Type: `bool`

Indicates whether this controller is lazy loaded or not. This was exposed publicly for no reason at all. I was too lazy thinking for some use cases :)
```dart
class ExampleController extends MomentumController<ExampleModel> {
  
  // ...

  void someMethod() {
    // or this.isLazy
    if (isLazy) {
      print('This controller was lazy loaded');
    } else {
      print('This controller was not lazy loaded');
    }
  }

  // ...
}
```