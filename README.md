<p align="center">
  <img src="https://i.imgur.com/DAFGeAd.png">
</p>

<p align="center">A super powerful flutter state management library that focuses on ease of control inspired with MVC pattern.</p>

**<h3>Features</h3>**
- MVC inspired pattern.
- Inject [_types_ instead of _instance_](#momentumbuilder---widget-class).
- Easily [access and control everything.](#access-and-control-everything)
- Time travel [methods (undo/redo) with 1 line of code.](#backward-time-travel-method)
- Immutable view-model.
- State Reset -> [any controller/model with 1 line of code.](#reset-method)
- State Reset -> [ALL controllers/models with 1 line of code.](#momentumresetallcontext-method)
- Skip rebuilds [`with MomentumBuilder`](https://pub.dev/packages/momentum#109).
- Very short [boilerplate codes.](#boilerplate-codes)
- Very detailed [logs for troubleshooting errors.](#troubleshooting-errors)

PS: If you hate static/singleton this library is for you. :)

#### Table of contents:

- [Concept](#concept)
  - [`Momentum` - setup class](#momentum---setup-class)
  - [`MomentumModel` - view-model class](#momentummodel---view-model-class)
  - [`MomentumController` - logic class](#momentumcontroller---logic-class)
  - [`MomentumBuilder` - widget class](#momentumbuilder---widget-class)
  - [`MomentumState` - listener class](#momentumstate---listener-class)
- [Configuration](#configuration)
  - [`enableLogging` property](#enablelogging-property)
  - [`lazy` property](#lazy-property)
  - [`maxTimeTravelSteps` property](#maxtimetravelsteps-property)
  - [Boilerplate codes](#boilerplate-codes)
  - [Troubleshooting errors.](#troubleshooting-errors)
- [Managing State](#managing-state)
  - [`init()` method](#init-method)
  - [`bootstrap()` method](#bootstrap-method)
  - [`Momentum.of<T>(context)` method](#momentumoftcontext-method)
  - [`model.update(...)` method](#modelupdate-method)
  - [`snapshot<T>()` builder method](#snapshott-builder-method)
  - [`reset()` method](#reset-method)
  - [`Momentum.resetAll(context)` method](#momentumresetallcontext-method)
  - [`backward()` time-travel method.](#backward-time-travel-method)
  - [`forward()` time-travel method.](#forward-time-travel-method)

### Access and Control everything

- The basic idea is that everything can be easily accessed and manipulated. If you are familiar with `BLoC` package the functions are written in the `Bloc` class (ex. _LoginBloc_). In momentum, you write the functions in your `MomentumController` class (ex. _LoginController_). One big difference with BLoC package is that **_there is no "default and easy" way to call another `Bloc` class_**, with momentum it's very easy to call another Controller class, like this:

  ```Dart
  class LoginController extends MomentumController<LoginModel> {
    ...

    void clearSession() {
      // "dependOn" is the magic here. It is a built in method inside MomentumController base class. I can say this is a game changing feature for this library.
      var sessionController = dependOn<SessionController>();
      sessionController.clearSession();

      // that's it, 1 line of code and you are able to access and manipulate other controller (Bloc) class.

      // you can also grab the model value of SessionController:
      var sessionId = sessionController.model.sessionId;
      print(sessionId);
    }

    ...
  }
  ```

  Now, you might be asking where the heck `SessionController` is instantiated. The answer is right below this section.

## Concept

### `Momentum` - setup class

- The `Momentum` class must be your root widget in order to properly implement it. It acts like a config for your momentum implementation like instantiate all controllers, enabling or disabling logging per controllers, enable time travel feature, lazy loading, etc...
- First, this is how your fresh flutter app looks like;
  ```Dart
    void main() {
      runApp(MyApp());
    }
  ```
- Then, implementing momentum state management will make it look like this:

  ```Dart
  void main() {
    runApp(
      Momentum(
        controllers: [
          CounterController(),
          LoginController(),
          SessionController(),
          UserProfileController..config(enableLogging: true), // enable logging and override the global setting.
          RegisterController()..config(maxTimeTravelSteps: 200),
          DashboardController()..config(lazy: true),
        ],
        enableLogging: false, // global setting, all controllers will have logging disabled.
        child: MyApp(),
      ),
    );
  }
  ```

  Note: The controller classes are just examples, you have to make them yourself. They are like `Bloc` class in BLoC package. The `config(...)` method is built in.

### `MomentumModel` - view-model class

- The view model for you controller. It is always linked to a specific type of `MomentumController`. The `update(...)` method you below is like a `copyWith` method with just a slight difference. This method is used to update values (immutable). A pair of controller and model can be use in any widgets, they are NOT tied to a single widget only.

  ```Dart
  class CounterModel extends MomentumModel<CounterController> {
    final int value;

    CounterModel(
      CounterController controller, {
      this.value,
    }) : super(controller);

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

### `MomentumController` - logic class

- This is where your logic comes _(like a "Bloc" class)_. It is always linked to a specific type of `MomentumModel`. The `MomentumController` class is an abstract base class. It requires an implementation of `init()` method which must return the model type linked with this controller. The library automatically calls this method.

  ```Dart
  class CounterController extends MomentumController<CounterModel> {
    @override
    CounterModel init() {
      return CounterModel(
        this,
        value: 0,
      );
    }

    void increment() {
      // let's say model.value is currently = 1
      var value = model.value; // grab the current value.
      model.update(value: value + 1); // calling `model.update(...)` is like calling `setState` so it rebuilds all listeners.
      print('$this -> {value: ${model.value}'); // updated value. model.value is now = 2
    }
  }
  ```

### `MomentumBuilder` - widget class

- Now this is one of the game changer feature of this state management. With the `controllers` parameter, instead of injecting an instance, you inject a type. It is multiple too which makes it easy to refactor instead of having separate class for single and multiple controller builder class.

  ```Dart
  MomentumBuilder(
    controllers: [CounterController], // a type not an instance :)
    builder: (context, snapshot) {
      var counter = snapshot<CounterModel>(); // simply grab a model using generic.
      return Text(
        '${counter.value}',
        style: Theme.of(context).textTheme.display1,
      );
    },
  )
  ```

### `MomentumState` - listener class

- A replacement for `State` class if you want to add a listener for your model state and react to it (showing dialogs, snackbars, toast, navigation and many more...)

  ```Dart
  class Login extends StatefulWidget {
    ...
  }

  class _LoginState extends MomentumState<Login> {

    LoginController loginController;

    @override
    void initMomentumState() {
      loginController = Momentum.of<LoginController>(context);
      // "addListener" is a built-in method from MomentumController.
      loginController.addListener(
        state: this,
        invoke: (model, isTimeTravel) {
          // do anything here...show dialogs, snackbars, toast, navigation and or just print data.
          // "isTimeTravel" tells if this model change is made from time travel method (backward/forward) or not.
        }
      );
    }
  }
  ```

- `initMomentumState` is part of `MomentumState`.

## Configuration

### `enableLogging` property

- This setting is nothing really important. It only shows logs of a specific controller (number of listeners, if the model is update etc...). Uncaught exceptions are not affected by this setting.
- Both the `Momentum` root widget and `MomentumController` has this config property. Defaults to true.
- `MomentumController` overrides `Momentum`'s setting.
- If this is `false` from `Momentum` class but `true` in `MomentumController` class, the accepted value will be `true`.
  ```Dart
    Momentum(
      controller: [
        LoginController()..config(enableLogging: true),
      ]
      enableLogging: false,
      ...
    );
  ```

### `lazy` property

- Sets when the `bootstrap()` method will be called. No matter this setting's value, `init()` method always get called first though.
- Both the `Momentum` root widget and `MomentumController` has this config property. Defaults to `true`.
- If this is `true`, the `bootstrap()` method will be called when the very first `MomentumBuilder` that listens to a specific controller will be loaded.

  ```Dart
    Momentum(
      controller: [
        LoginController()..config(lazy: true),
      ]
      ...
    );

    MomentumBuilder(
      ...
      controllers: [LoginController], // "bootstrap()" method will be called.
      ...
    );
  ```

- If this is `false`, the `bootstrap()` method will be called right when the app starts.

### `maxTimeTravelSteps` property

- If the value is greater than `1`, time travel methods will be enabled.
- Both the `Momentum` root widget and `MomentumController` has this config property. Defaults to `1`, means time travel methods are disabled by default.
- The value is clamped between `1` and `250`.

### Boilerplate codes
- The recommended convention for this is having 1 folder for each pair of `controller and model`. The name of the parent folder where you put all of them depends on you, but for this time I'm gonna call it *"components"*. 
- Example `LoginController`, file: `lib/src/components/login/login.controller.dart`.
  ```Dart
    import 'package:momentum/momentum.dart';

    import 'index.dart';

    class LoginController extends MomentumController<LoginModel> {
      @override
      LoginModel init() {
        // TODO: implement init
        return null;
      }
    }
  ```
- Example `LoginModel`, file: `lib/src/components/login/login.model.dart`.
  ```Dart
    import 'package:momentum/momentum.dart';

    import 'index.dart';

    class LoginModel extends MomentumModel<LoginController> {
      LoginModel(LoginController controller) : super(controller);

      @override
      void update() {
        // TODO: implement update
      }
    }
  ```
- And the optional `lib/src/components/login/index.dart` file.
  ```Dart
    export 'login.controller.dart';
    export 'login.model.dart';
  ```

### Troubleshooting errors.
- This library gives you very detailed logs for errors, like  for [misconfigured Momentum root widget](https://prnt.sc/sd0p3o), [misconfigured MomentumBuilder widget](https://prnt.sc/sd0qmr), referring to types that doesn't exists on the tree, etc. You can easily fix those errors as a result. *(The links are screenshot.)*

## Managing State

### `init()` method

- `MomentumController` requires this method to be implemented, but the library will call it for you. This will only be called once. Also, you should NOT put any logic in here, use <a href="#bootstrap-method">`bootstrap()`</a> method instead.

  ```Dart
    class LoginController extends MomentumController<LoginModel> {

      @override
      LoginModel init() {
        return LoginModel(
          this, // inject this controller itself (required by the library).
          username: '',
          password: '',
        );
      }
    }
  ```

### `bootstrap()` method

- A `MomentumController` method. Called after `init()`. This is an optional virtual method. If you override this, the library will call it for you. This is where you put initialization logic instead of `init()`.
- This is only called once too.

  ```Dart
    class LoginController extends MomentumController<LoginModel> {

      @override
      void bootstrap() async {
        model.update(loadingData: true); // you can use "loadingData" property to display loading indicator in your widget.
        var myProfile = await apiService.getMyProfile(model.userId);
        var friendsList = await apiService.getFriendsList(model.userId); // assuming you actually have friends.
        model.update(
          loadingData: false, // the loading widget will now be hidden :)
          myProfile: myProfile,
          friendsList: friendsList,
        );
      }
    }
  ```

### `Momentum.of<T>(context)` method

- Get a specific controller to call needed functions.

  ```Dart
    class Login extends StatefulWidget {
      ...
    }

    class _LoginState extends State<Login> {

      LoginController loginController;

      @override
      didChangeDependencies() {
        loginController = Momentum.of<LoginController>(context); // you can also call this on build but that's dirty, it's up to you.
        super.didChangeDependencies();
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: Container(
            child: FlatButton(
              child: Text('Submit'),
              onPressed: () {
                loginController.login(); // call any function you defined in your controller.
              }
            ),
          ),
        );
      }
    }
  ```

### `model.update(...)` method

- This is the method which is use to rebuild widgets. When this method is called, all `MomentumBuilder`s that listens to a certain controller will rebuild, for example to `LoginController`. This method is also similar to `copyWith`. This method must be inside your model class and all properties must be final.

  ```Dart
  // declaration
  @override
  void update({
    String username,
    String password,
  }) {
    LoginModel(
      controller,
      username: username ?? this.username,
      password: password ?? this.password,
    ).updateMomentum();
  }

  // usage
  model.update(username: 'momentum', password: '12341234');
  print('${model.username}, ${model.password}');
  // => "momentum, 12341234"

  model.update(password: 'secret'); // only update the password, the username will be retained just like how copyWith works.
  print('${model.username}, ${model.password}');
  // => "momentum, secret"
  ```

  Also, if you are familiar with `copyWith` method, this method does not accept **null** values. If it's string just set it as `''`, if it's integer set it to `0`, and you get the idea...

### `snapshot<T>()` builder method

- This method is use inside `MomentumBuilder`'s _builder_ method.

  ```Dart
  controllers: [LoginController],
  builder: (context, snapshot) {
    var loginModel = snapshot<LoginModel>();
    return Text(loginModel.username);
  }
  ```

- Multiple controller support:

  ```Dart
  controllers: [LoginController, SessionController],
  builder: (context, snapshot) {
    var loginModel = snapshot<LoginModel>();
    var sessionModel = snapshot<SessionModel>();
    var username = loginModel.username;
    var sessionId = sessionModel.sessionId;
    return Text('[$sessionId] - $username');
  }
  ```

- Of course you can rename the `snapshot<T>()` method here to even something shorter like `use<T>` or `consume<T>`.

### `reset()` method

- Reset the model to its initial state. This re-calls `init()` method. You can also call this anywhere.
- Call inside the controller itself:

  ```Dart
    class LoginController ... {
      ...

      /// clears the user input for username and password.
      void clearInput() {
        reset();
      }

      ...
    }
  ```

- Call inside a widget:
  ```Dart
    loginController = Momentum.of<LoginController>(context);
    ...
    loginController.reset();
  ```
- Call inside another controller

  ```Dart
    class HomeController ... {
      ...

      /// clears the user session.
      void clearSession() {
        var sessionController = dependOn<SessionController>();
        sessionController.reset();
      }

      ...
    }
  ```

### `Momentum.resetAll(context)` method
- Reset all controllers and their models. This method requires `BuildContext` because internally it calls `inheritFromWidgetOfExactType` method. Good thing is that you can do something before this method gets actually executed like showing confirmation dialog.
  - You can easily call this method: `Momentum.resetAll(context);`
  - The `onResetAll` parameter. Take a look at this example, assuming we have a logout function that resets everything.
    ```Dart
      void main() {
        runApp(
          Momentum(
            child: MyApp(),
            controllers: [... ],
            onResetAll: (context, resetAll) {
              showDialog(
                context: context,
                builder: (context) {
                  return Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Dialog(
                      child: Container(
                        height: 200,
                        width: 300,
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Are you are you want to logout?',
                              style: TextStyle(fontSize: 24),
                              textAlign: TextAlign.center,
                            ),
                            RaisedButton(
                              onPressed: () {
                                Navigator.pop(context); // exits the dialog
                              },
                              child: Text('No'),
                            ),
                            RaisedButton(
                              onPressed: () {
                                resetAll(context); // call the provided resetAll method.
                                Navigator.pop(context); // exits the dialog
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      }
    ```
  - Now to explain the code. Because `onResetAll` provides `BuildContext` and the actual `resetAll` method, you can do anything widget related (showing dialog, snackbars, navigation, etc...) and whenever you are satisfied with your widget flow, you can then call the provided `resetAll(context);` method. Not just that... because it provides `BuildContext`, you can also call `Momentum.of<T>(context)` method which means you can manipulate any controllers and models "before and/or after" executing `resetAll` method (that's super cool).

### `backward()` time-travel method.

- A `MomentumController` method. Sets the state one step behind from the current model state. Example:
  ```Dart
  loginController.backward();
  ```
- If you are currently in the very first model state (init), this method will do nothing.
- You can also call this anywhere like `reset()` method.

### `forward()` time-travel method.

- A `MomentumController` method. Sets the state one step ahead from the current model state. Example:
  ```Dart
  loginController.forward();
  ```
- If you are currently in the latest model state, this method will do nothing.
- You can also call this anywhere like `reset()` method.

<h4>TODOs and Coming Soon features</h4>

  - Coming soon: `services` parameter for `Momentum` root widget
    - You can inject any type of non-widget objects here like service class that can be use globally in your app like api wrappers for example.
    - You can grab a specific service inside your controller only using: `getService<TypeHere>();` (this is the same way you call `dependOn<T>()` method.)
  - I also created a vs code extension for [generating boilerplate code](#boilerplate-codes) but currently it's on my local environment only. I'm gonna upload it soon on the marketplace :)
  - I'm planning to add a feature for persisting the state using database or shared preference. Like `hydrated_bloc`. Another thing is that aside from state, I also want to persist the navigation state/history. For this, I think I need to create my own navigation/routing system that saves navigation history...*shruugs*. I'm not sure if I will/~~can~~ actually do it or not :)
<br>
<br>
> Additional note: The library doesn't have any dependencies, except flutter sdk. And it only uses `setState` behind the scenes.

**<center><h2>THE END</h2></center>**
