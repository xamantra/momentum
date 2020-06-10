# MomentumState
Abstract `State` class required in `.addListener(...)` and `.listen<T>(...)`. Also contains `initMomentumState()` callback which is like `initState()`.
```dart
class _ExampleState extends MomentumState<ExampleWidget> {

  // ...

  @override
  void initMomentumState() {
    // initialize here.
    // you can access "context".
  }

  // ...
}
```

<hr>

## initMomentumState()
- Category: `Virtual Method`
- Type: `void`
- Required: `NO`

A callback similar to `initState()` but you can access the context variable safely.
```dart

  ExampleController exampleController;

  @override
  void initMomentumState() {
    exampleController = Momentum.of<ExampleController>(context);
  }
```

<hr>