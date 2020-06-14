# Extending Controllers
Sometimes you want to update and add functionalities to a certain controller without modifying that controller, instead you are just going to extend it.

- With dart, this is how you extend a class:

```dart
class AuthController extends MomentumController<AuthModel> {
  
  @override
  AuthModel init() {
    return AuthModel(
      this,
    );
  }

  void verifySSL() {
    // ... logic here
  }
}

class LoginController extends AuthController {
  
  @override
  AuthModel init() {
    return AuthModel(
      this,
    );
  }

  void login() {
    // ... logic here
  }
}
```

The problem with this is the `model`. Take a look at this `MomentumBuilder`:

```dart
MomentumBuilder(
  controllers: [
    AuthController,
    LoginController,
  ],
  builder: (context, snapshot) {
    var authModel = snapshot<AuthModel>();
  }
);
```

- The thing is that `AuthModel` has two controllers, which are `AuthController` and `LoginController` because login controller extends the auth controller.
- The second thing is, what `AuthModel` are we specifically getting? Is it the one from Auth or Login controller?
- This is a bug and we need to fix this. Below is the sample code on how to do it.

```dart
MomentumBuilder(
  controllers: [
    AuthController,
    LoginController,
  ],
  builder: (context, snapshot) {
    var authModelBase = snapshot<AuthModel>(AuthController);
    var authModelLogin = snapshot<AuthModel>(LoginController);
  }
);
```

That's it! As you can see we specified another type again which is a controller. No instances.

- `authModelBase` - is a model which is tied in `AuthController`.
- `authModelLogin` - is a model which is tied in `LoginController`.
- You only need to do this if you have controllers that extends other controllers and they are both injected in the same `MomentumBuilder`.

This functionality was added on version `1.1.9`. No breaking changes.