# Restarting App
Restarting a momentum app can be done in 2 lines of code. Everything will be reloaded the same way as you open the app normally.

## Configure main.dart

This is the typical `main.dart` you usually see in this documentation:

- `Momentum` is inside the `runApp(...)` method.

```dart
void main() {
  runApp(
    Momentum(
      child: MyApp(),
      controllers: [
        // ...
      ]
      // ...
    ),
  );
}
```

To easily implement restart, we need a new instance of momentum every time. And it can be done using a top-level method.

```dart
void main() {
  runApp(momentum());
}

Momentum momentum() {
  return Momentum(
    key: UniqueKey(),
    restartCallback: main,
    child: MyApp(),
    controllers: [
      // ...
    ],
    // ...
  );
}
```

- `key` - Uses `UniqueKey()` to force rebuild the entire widget tree from scratch.
- `restartCallback` - Uses the `main()` method which calls `runApp(...)` to restart the widget from scratch.
- Now, down the tree, we can call the `momentum()` method which returns a fresh copy of `Momentum` instance with the same dependencies.

<hr>

## Call Momentum.restart(...)
Here's the two line code you're waiting for:

```dart
await Router.resetWithContext<Home>(context);
Momentum.restart(context, momentum());
```

- If you are using persistent navigation, we need to call `Router.resetWithContext<Home>` to set the initial page when the app restarts.
- `Momentum.restart(...)` called the method `momentum()`.
- Requires context so you need to call this inside a widget like a button click.