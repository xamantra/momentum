<p align="center">
  <img src="https://i.imgur.com/DAFGeAd.png">
</p>

<p align="center">A flutter state management library that focuses on ease of control.</p>

Jump to sections:

- [Classes](#classes)
  - [`Momentum` - setup class](#momentum---setup-class)
  - [`MomentumModel` - view-model class](#momentummodel---view-model-class)
  - [`MomentumController` - logic class](#momentumcontroller---logic-class)
  - [`MomentumBuilder` - widget class](#momentumbuilder---widget-class)
- [Managing State](#managing-state)
  - [`init()` method](#init-method)
  - [`Momentum.of<T>(context)` method](#momentumoftcontext-method)
  - [`model.update(...)` method](#modelupdate-method)
  - [`snapshot<T>()` method](#snapshott-method)

The basic idea is that everything can be easily accessed and manipulated. If you are familiar with `BLoC` package the functions are written in the `Bloc` class (ex. _LoginBloc_). In momentum, you write the functions in your `MomentumController` class (ex. _LoginController_). One big difference with BLoC package is that **_there is no "default and easy" way to call another `Bloc` class_**, with momentum it's very easy to call another Controller class, like this:

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

## Classes

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
          UserProfileController..config(enableLogging: true),
          RegisterController()..config(maxTimeTravelSteps: 200),
          DashboardController()..config(lazy: true),
        ],
        enableLogging: false,
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

## Managing State

### `init()` method
- `MomentumController` requires this method to be implemented, but the library will call it for you. This will only be called once.
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

### `snapshot<T>()` method

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

Additional note: The library doesn't have any dependencies, except flutter sdk of course.

**THE END**

I am still writing additional content for this readme like explaning about the `config(...)` method, mentioning methods like `bootstrap()` etc...
