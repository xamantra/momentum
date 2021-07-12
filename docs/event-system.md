# Event System
`MomentumController` can send event data to the widgets. Widgets can receive these events with the `.listen<T>` method where `T` can be of any type.

- This can be useful for showing dialogs/alerts/snackbars.
- Navigating to a different page if certain logic in the controller meets all the conditions.
- Or just print the event data on the debug console.

## Defining Events

```dart
enum LoginEventAction {
  None,
  LoginSuccess,
  UsernameDoesntExists,
  IncorrectPassword,
  UnknownError,
}

class LoginEvent {
  final LoginEventAction action;
  final String message;

  LoginEvent({this.action, this.message});
}
```

- You can put this code in a separate file like: `login.events.dart`.

<hr>

## Sending Events

```dart
class LoginController extends Momentum<LoginModel> {

  // ...

  void login() async {
    final apiService = service<ApiService>();
    final response = await apiService.auth(
      username: model.username,
      password: model.password,
    );
    if (response != null) {
      if (response.success) {
        sendEvent(LoginEvent(action: LoginEventAction.LoginSuccess));
      } else {
        if (response.errorUsername) {
          sendEvent(LoginEvent(action: LoginEventAction.UsernameDoesntExists, message: 'The username "${model.username}" doesn\'t exists.'));
        }

        if (response.wrongPassword) {
          sendEvent(LoginEvent(action: LoginEventAction.IncorrectPassword, message: 'The password is wrong.'));
        }
      }
    } else {
      sendEvent(LoginEvent(action: LoginEventAction.UnknownError, message: 'Unknown error occurred.'));
    }
  }

  // ...
}
```

- Don't pay too much attention to the other codes.
- Only focus on `sendEvent(...)` and `LoginEvent(...)`.
- In the next section, you're going to see how the widgets can receive these events.

<hr>

## Listening to Events

```dart
class _LoginWidgetState extends MomentumState<LoginWidget> {
  LoginController loginController;

  @override
  void initMomentumState() {
    loginController = Momentum.controller<LoginController>(context);
    loginController.listen<LoginEvent>(
      state: this,
      invoke: (event) {
        switch (event.action) {
          case LoginEventAction.LoginSuccess:
            MomentumRouter.goto(context, Home);
            break;
          case LoginEventAction.UsernameDoesntExists:
            showSnackbar(message: event.message);
            break;
          case LoginEventAction.IncorrectPassword:
            showToast(message: event.message);
            break;
          case LoginEventAction.UnknownError:
            print(event.message);
            break;
          default:
        }
      },
    );
  }

  // ...
}
```

- We made this widget listen to `LoginEvent` using `.listen<LoginEvent>`.
- Any call to `sendEvent(LoginEvent(...))` will invoke the parameter `invoke`.
- The argument `event` is of type `LoginEvent`.
- You can then use this argument to display snackbars or toast.
- If the login was successful, navigate to the home page.