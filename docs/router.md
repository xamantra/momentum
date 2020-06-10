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

The function to navigate to a specific route. You specify the route using a `type` NOT a string route name or a MaterialPageRoute. You can also create a custom transition animation using the `transition` parameter. This is equivalent to `Navigator.push(...)`.
```dart
// go to home page
Router.goto(context, HomePage);

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

Equivalent to `Navigator.pop(...)`. For closing dialogs, do not use this one, use `Navigator.pop(...)` instead.
```dart
// go back to the previous page.
Router.pop(context);

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

## .clearHistory()
- Category: `Method`
- Type: `Future<void>`

Clear the navigation history. Popping will close the app.
```dart
var router = Momentum.getService<Router>(context);
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
var router = Momentum.getService<Router>(context);
// this will not automatically go to the login page.
await router.reset<LoginPage>();
// will be restarted in the login page.
Momentum.restart(context, momentum());
```

<hr>

## .resetWithContext(context)
- Category: `Method`
- Type: `Future<void>`

Shorthand for `.reset<T>()`.
```dart
// this will not automatically go to login page.
await Router.resetWithContext<LoginPage>(context);
// will be restarted in login page.
Momentum.restart(context, momentum());
```