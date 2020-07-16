# Router
A built-in `MomentumService` for persistent navigation system.
```dart
void main() {
  runApp(
    Momentum(
      // child: ...,
      services: [
        Router([
          LoginPage(),
          HomePage(),
          SettingsPage(),
        ]),
      ],
      // ...,
    ),
  );
}
```

<hr>

## .getActivePage(context)
- Category: `Static Method`
- Type: `Widget`

Get the active widget from the router. You may want this to be your initial widget when your app starts.
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: // ...,
      theme: // ...,
      home: Router.getActivePage(context),
      // ...
    );
  }
}
```

<hr>

## .goto(...)
- Category: `Static Method`
- Type: `void`

The function to navigate to a specific route. You specify the route using a `type` NOT a string route name or a MaterialPageRoute. You can also create a custom transition animation using the `transition` parameter. This is equivalent to `Navigator.push(...)`. You can also optionally pass in a route param and access it anywhere.
```dart
// go to home page
Router.goto(context, HomePage);

// with parameters
Router.goto(context, HomePage, params: HomeParam(title: 'Hello World'));

// access the parameters using context
var param = Router.getParam<HomeParam>(context);
print(param.title); // or display it in a widget ...

// access the parameters inside the controller
var param = getParam<HomeParam>();
print(param.title); // or bind this in your model ...

// with custom animation
Router.goto(
  context,
  HomePage,
  transition: (context, page) {
    // MaterialPageRoute is not the one you need here :)
    // use any route animation from flutter or from pub.dev
    return MaterialPageRoute(builder: (context) => page);
  },
);
```

<hr>

## .pop(context)
- Category: `Static Method`
- Type: `void`

Equivalent to `Navigator.pop(...)`. For closing dialogs, do not use this one, use `Navigator.pop(...)` instead. Similar to `Router.goto`, you can also pass in parameters optionally but the name is `result`. The reason why it's named `result` is to follow flutter's original convention for `Navigator.pop` which also has `result` parameter.
```dart
// go back to the previous page.
Router.pop(context);

// with parameters, assuming you are from HomePage.
Router.pop(context, result: LoginParam(action: 'User had logged out.'));

// access the parameters using context
var param = Router.getParam<LoginParam>(context);
print(param.action); // or display it in a widget ...

// access the parameters inside the controller
var param = getParam<LoginParam>();
print(param.action); // or bind this in your model ...

// with custom animation
Router.goto(
  context,
  transition: (context, page) {
    // MaterialPageRoute is not the one you need here :)
    // use any route animation from flutter or from pub.dev
    return MaterialPageRoute(builder: (context) => page);
  },
);
```

<hr>

## RouterParam
- Category: `Abstract Class`

An abstract class required for marking a certain data class as a router param model. This class is immutable.

```dart
class ExampleParam extends RouterParam {
  final String value1;
  final String value2;

  ExampleParam(this.value1, this.value2);
}

// usage

Router.goto(context, HomePage, params: ExampleParam('Hello', 'World'));
```

<hr>

## .getParam\<T\>(context)
- Category: `Static Method`
- Type: `T` extends `RouterParam`

Get the current route parameters specified using the params parameter in Router.goto(...) method.

```dart
class ExamplePage extends StatelessWidget {
  const ExamplePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var param = Router.getParam<ExampleParam>(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Text(param.title),
        ],
      ),
    );
  }
}

```

<hr>

## .clearHistory()
- Category: `Method`
- Type: `Future<void>`

Clear the navigation history. Popping will close the app.
```dart
var router = Momentum.service<Router>(context);
await router.clearHistory();
```

<hr>

## .clearHistoryWithContext(context)
- Category: `Method`
- Type: `Future<void>`

Shorthand for `.clearHistory()`.
```dart
await Router.clearHistoryWithContext(context);
```

<hr>

## .reset<T>()
- Category: `Method`
- Type: `Future<void>`

Clear navigation history and set an initial page. The recommended use case for this is when you want to restart your app.
```dart
var router = Momentum.service<Router>(context);
// this will not automatically go to the login page.
await router.reset<LoginPage>();
// will be restarted in the login page.
Momentum.restart(context, momentum());
```

<hr>

## .resetWithContext\<T\>(context)
- Category: `Method`
- Type: `Future<void>`

Shorthand for `.reset<T>()`.
```dart
// this will not automatically go to login page.
await Router.resetWithContext<LoginPage>(context);
// will be restarted in login page.
Momentum.restart(context, momentum());
```