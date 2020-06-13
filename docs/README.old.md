<p align="center">
  <img src="https://i.imgur.com/K7BNfKI.png">
</p>

<p align="center">A super powerful flutter state management library inspired with MVC pattern with a very flexible dependency injection.</p>

<p align="center">
<a href="https://pub.dev/packages/momentum" target="_blank"><img src="https://img.shields.io/pub/v/momentum" alt="Pub Version" /></a>
<a href="https://github.com/xamantra/momentum/actions?query=workflow%3ACI" target="_blank"><img src="https://github.com/xamantra/momentum/workflows/CI/badge.svg?event=push" alt="CI" /></a>
<a href="https://codecov.io/gh/xamantra/momentum"><img src="https://codecov.io/gh/xamantra/momentum/branch/master/graph/badge.svg" /></a>
<a href="https://xamdev.gq/momentum/#/" target="_blank"><img src="https://img.shields.io/badge/documentation-100%25-blueviolet" alt="documentation" /></a>
<a href="https://pub.dev/packages/momentum#-analysis-tab-" target="_blank"><img src="https://img.shields.io/badge/dynamic/json?color=orange&label=popularity&query=popularity&url=http://www.pubscore.gq/all?package=momentum" alt="popularity" /></a>
<a href="https://pub.dev/packages/momentum#-analysis-tab-" target="_blank"><img src="https://img.shields.io/badge/dynamic/json?color=blue&label=score&query=overall&url=http://www.pubscore.gq/all?package=momentum" alt="score" /></a>
<a href="https://pub.dev/packages/momentum#-analysis-tab-" target="_blank"><img src="https://img.shields.io/badge/dynamic/json?color=blue&label=maintenance&query=maintenance&url=http://www.pubscore.gq/all?package=momentum" alt="maintenance" /></a>
<a href="https://pub.dev/packages/momentum#-analysis-tab-" target="_blank"><img src="https://img.shields.io/badge/dynamic/json?color=green&label=health&query=health&url=http://www.pubscore.gq/all?package=momentum" alt="health" /></a>
<a href="https://github.com/xamantra/momentum/stargazers" target="_blank"><img src="https://img.shields.io/github/stars/xamantra/momentum" alt="GitHub stars" /></a>
<a href="https://github.com/tenhobi/effective_dart" target="_blank"><img src="https://img.shields.io/badge/style-effective_dart-54C5F8.svg" alt="style: effective dart" /></a>
<a href="https://github.com/xamantra/momentum/blob/master/LICENSE" target="_blank"><img src="https://img.shields.io/github/license/xamantra/momentum" alt="GitHub license" /></a>
<a href="https://github.com/xamantra/momentum/commits/master" target="_blank"><img src="https://img.shields.io/github/last-commit/xamantra/momentum" alt="GitHub last commit" /></a>
</p>

---

**<h3>Features</h3>**

- MVC inspired pattern.
- Inject [_types_ instead of _instance_](#momentumbuilder---widget-class).
- Easily [access and control everything.](#access-and-control-everything)
- Time travel [methods (undo/redo) with 1 line of code.](#backward-time-travel-method)
- Immutable view-model.
- State Reset -> [any controller/model with 1 line of code.](#reset-method)
- State Reset -> [ALL controllers/models with 1 line of code.](#momentumresetallcontext-method)
- Skip rebuilds [with MomentumBuilder](https://pub.dev/packages/momentum#109).
- Very short [boilerplate codes.](#boilerplate-codes)
- Very detailed [logs for troubleshooting errors.](#troubleshooting-errors)

PS: If you hate static/singleton this library is for you. :)

#### Table of contents:

 <hr>
 
- [Concept](#concept)
  - [`Momentum` - setup class](#momentum---setup-class)
  - [`MomentumModel` - view-model class](#momentummodel---view-model-class)
  - [`MomentumController` - logic class](#momentumcontroller---logic-class)
  - [`MomentumBuilder` - widget class](#momentumbuilder---widget-class)
  - [`MomentumState` - listener class](#momentumstate---listener-class)
  <hr>
- [Configuration](#configuration)
  - [`enableLogging` property](#enablelogging-property)
  - [`lazy` property](#lazy-property)
  - [`maxTimeTravelSteps` property](#maxtimetravelsteps-property)
  - [Boilerplate codes](#boilerplate-codes)
  - [Troubleshooting errors.](#troubleshooting-errors)
  <hr>
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

 <hr>
<b id="access-and-control-everything">Access and Control everything</b> - The basic idea is that everything can be easily accessed and manipulated. If you are familiar with `BLoC` package the functions are written in the `Bloc` class (ex. _LoginBloc_). In momentum, you write the functions in your `MomentumController` class (ex. _LoginController_). One big difference with BLoC package is that **_there is no "default and easy" way to call another `Bloc` class_**, with momentum it's very easy to call another Controller class, like this:

```dart
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

 <hr>

## Concept

- <b id="momentum---setup-class">**Momentum**</b> class must be your root widget in order to properly implement it. It acts like a config for your momentum implementation like instantiate all controllers, enabling or disabling logging per controllers, enable time travel feature, lazy loading, etc...

  First, this is how your fresh flutter app looks like;

  ```dart
    void main() {
      runApp(MyApp());
    }
  ```

  Then, implementing momentum state management will make it look like this:

  ```dart
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
  <hr>

- <b id="momentummodel---view-model-class">MomentumModel</b> is the `view model` for you controller. It is always linked to a specific type of `MomentumController`. The `update(...)` method you below is like a `copyWith` method with just a slight difference. This method is used to update values (immutable). A pair of controller and model can be use in any widgets, they are NOT tied to a single widget only.

  ```dart
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

  <hr>

- <b id="momentumcontroller---logic-class">MomentumController</b> class - This is where your logic comes _(like a "Bloc" class)_. It is always linked to a specific type of `MomentumModel`. The `MomentumController` class is an abstract base class. It requires an implementation of `init()` method which must return the model type linked with this controller. The library automatically calls this method.

  ```dart
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

  <hr>

- <b id="momentumbuilder---widget-class">MomentumBuilder</b> is the widget class. With the `controllers` parameter, instead of injecting an instance, you inject a type. It is multiple too which makes it easy to refactor instead of having separate class for single and multiple controller builder class.

  ```dart
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

  <hr>

- <b id="momentumstate---listener-class">MomentumState</b> class - A replacement for `State` class if you want to add a listener for your model state and react to it (showing dialogs, snackbars, toast, navigation and many more...). `initMomentumState` is part of `MomentumState` and will only be called once.

  ```dart
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

  <hr>

## Configuration

- <b id="enablelogging-property">enableLogging</b> property - This setting is nothing really important. It only shows logs of a specific controller (number of listeners, if the model is update etc...). Uncaught exceptions are not affected by this setting.

  - Both the `Momentum` root widget and `MomentumController` has this config property. Defaults to true.
  - `MomentumController` overrides `Momentum`'s setting.
  - If this is `false` from `Momentum` class but `true` in `MomentumController` class, the accepted value will be `true`.

    ```dart
      Momentum(
        controller: [
          LoginController()..config(enableLogging: true),
        ]
        enableLogging: false,
        ...
      );
    ```

  <hr>

- <b id="lazy-property">lazy</b> property - Sets when the `bootstrap()` method will be called. No matter this setting's value, `init()` method always get called first though.

  - Both the `Momentum` root widget and `MomentumController` has this config property. Defaults to `true`.
  - If this is `true`, the `bootstrap()` method will be called when the very first `MomentumBuilder` that listens to a specific controller will be loaded.

    ```dart
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
  <hr>

- <b id="maxtimetravelsteps-property">maxTimeTravelSteps</b> property - If the value is greater than `1`, time travel methods will be enabled.

  - Both the `Momentum` root widget and `MomentumController` has this config property. Defaults to `1`, means time travel methods are disabled by default.
  - The value is clamped between `1` and `250`.
  <hr>

- <b id="boilerplate-codes">Boilerplate codes</b> - The recommended convention for this is having 1 folder for each pair of `controller and model`. The name of the parent folder where you put all of them depends on you, but for this time I'm gonna call it _"components"_.

  - Example `LoginController`, file: `lib/src/components/login/login.controller.dart`.

    ```dart
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

    ```dart
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
    ```dart
      export 'login.controller.dart';
      export 'login.model.dart';
    ```

  <hr>

- <b id="troubleshooting-errors">Troubleshooting errors</b> - This library gives you very detailed logs for errors, like for [misconfigured Momentum root widget](https://prnt.sc/sd0p3o), [misconfigured MomentumBuilder widget](https://prnt.sc/sd0qmr), referring to types that doesn't exists on the tree, etc. You can easily fix those errors as a result. _(The links are screenshot.)_
  <hr>

## Managing State

- <b id="init-method">init()</b> method - `MomentumController` requires this method to be implemented, but the library will call it for you. This will only be called once. Also, you should NOT put any logic in here, use <a href="#bootstrap-method">`bootstrap()`</a> method instead.

  ```dart
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

  <hr>

- <b id="bootstrap-method">bootstrap()</b> - A `MomentumController` method. Called after `init()`. This is an optional virtual method. If you override this, the library will call it for you. This is where you put initialization logic instead of `init()`. This is only called once too. This is also a good place to listen to streams, you don't have to worry about closing/disposing it since `bootstrap()` method is only called once.

  ```dart
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

  <hr>

- <b id="momentumoftcontext-method">Momentum.of<T>(context) method - </b>Get a specific controller to call needed functions.

  ```dart
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

  <hr>

- <b id="modelupdate-method">model.update(...)</b> method - This is the method which is use to rebuild widgets. When this method is called, all `MomentumBuilder`s that listens to a certain controller will rebuild, for example to `LoginController`. This method is also similar to `copyWith`. This method must be inside your model class and all properties must be final.

  ```dart
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
  <hr>

- <b id="snapshott-builder-method">snapshot<T>()</b> method - This method is use inside `MomentumBuilder`'s _builder_ method.

  ```dart
  controllers: [LoginController],
  builder: (context, snapshot) {
    var loginModel = snapshot<LoginModel>();
    return Text(loginModel.username);
  }
  ```

  Multiple controller support:

  ```dart
  controllers: [LoginController, SessionController],
  builder: (context, snapshot) {
    var loginModel = snapshot<LoginModel>();
    var sessionModel = snapshot<SessionModel>();
    var username = loginModel.username;
    var sessionId = sessionModel.sessionId;
    return Text('[$sessionId] - $username');
  }
  ```

  Of course you can rename the `snapshot<T>()` method here to even something shorter like `use<T>` or `consume<T>`.
  <hr>

- <b id="reset-method">reset()</b> method - Reset the model to its initial state. This re-calls `init()` method. You can also call this anywhere.

  Call inside the controller itself:

  ```dart
    class LoginController ... {
      ...

      /// clears the user input for username and password.
      void clearInput() {
        reset();
      }

      ...
    }
  ```

  Call inside a widget:

  ```dart
    loginController = Momentum.of<LoginController>(context);
    ...
    loginController.reset();
  ```

  Call inside another controller

        ```dart
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

    <hr>

- <b id="momentumresetallcontext-method">Momentum.resetAll(context)</b> method - Reset all controllers and their models. This method requires `BuildContext` because internally it calls `inheritFromWidgetOfExactType` method. Good thing is that you can do something before this method gets actually executed like showing confirmation dialog.

  - You can easily call this method: `Momentum.resetAll(context);`
  - The `onResetAll` parameter. Take a look at this example, assuming we have a logout function that resets everything.
    ```dart
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
  <hr>

- <b id="backward-time-travel-method">backward()</b> method - A `MomentumController` method. Sets the state one step _behind_ from the current model state. Example:

  ```dart
  loginController.backward();
  ```

  - If you are currently in the very first model state (init), this method will do nothing.
  - You can also call this anywhere like `reset()` method.

- <b id="backward-time-travel-method">forward()</b> method - A `MomentumController` method. Sets the state one step _ahead_ from the current model state. Example:

  ```dart
  loginController.forward();
  ```

  - If you are currently in the latest model state, this method will do nothing.
  - You can also call this anywhere like `reset()` method.
  <hr>

<h4>TODOs and Coming Soon features</h4>

- ✔ `(added on version 1.1.5)` Coming soon: `services` parameter for `Momentum` root widget
  - You can inject any type of non-widget objects here like service class that can be use globally in your app like api wrappers for example.
  - You can grab a specific service inside your controller only using: `getService<TypeHere>();` (this is the same way you call `dependOn<T>()` method.)
  - ✔ Added on `1.1.5` and some ideas were changed during implementation.
- ✔ I also created a vs code extension for [generating boilerplate code](#boilerplate-codes) but currently it's on my local environment only. I'm gonna upload it soon on the marketplace :)
- ✔ I'm planning to add a feature for persisting the state using database or shared preference. Like `hydrated_bloc`. Another thing is that aside from state, I also want to persist the navigation state/history. For this, I think I need to create my own navigation/routing system that saves navigation history..._shruugs_. I'm not sure if I will/~~can~~ actually do it or not :)

I've completed all my TODOs, yay!
  <hr>
  <br>

> Additional note: The library doesn't have any dependencies, except flutter sdk. And it only uses `setState` behind the scenes.

<center><h2>THE END</h2></center>
