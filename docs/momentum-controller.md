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
- Type: `void`

Configure this controller to set some custom behaviors.
  - `maxTimeTravelSteps` - set the maximum number of undo/redo steps that this controller can take. Clamped between `1`(min) and `250`(max).

  - `lazy` - If `false`, this controller will be bootstrapped when the app starts. Defaults to `true`.

  - `enableLogging` - Whether to print detailed verbose logs or not. Defaults to `false`.
```dart
    Momentum(
      // ...
      controllers: [
        ExampleControllerA()..config(
          maxTimeTravelSteps: 30, // maximum of 30 undo/redo steps.
          lazy: false, // bootstrap this controller when the app starts.
          enableLogging: true, // print verbose logs.
        ),
        ExampleControllerB()..config(lazy: false),
      ],
      // ...
    )
```

<hr>

## init()
- Category: `Method`
- Type: `MomentumModel`

Initialize the model of this controller. Required to be implemented. This method will only be called once. Momentum will automatically call this method. The initial values provided here are guaranteed to be usable instantly down the code.
```dart
class ExampleController extends MomentumController<ExampleModel> {

  @override
  void init() {
    return ExampleModel(
      this, // attach this controller to "ExampleModel".
      value: 0, // initial value for a counter app.
    );
  }
}
```
