# Equatable Support
Momentum has an optional support for equatable. The app will still work fine without it. But it will improve the behavior of time travel feature. Because of value equality comparison instead of instance, we can avoid updating the model which has the same values from previous model/state. It also optimizes the app by not rebuilding the widgets of nothing actually changes.

#### MomentumModel
Implementing equatable in `MomentumModel` needs the mixin `EquatableMixin` not the traditional equatable abstract base class.
```dart
import 'package:equatable/equatable.dart';
import 'package:momentum/momentum.dart';

class ExampleModel extends MomentumModel<ExampleController> with EquatableMixin {
  // ...

  final int firstProperty;
  final String secondProperty;

  // ...

  @override
  List<Object> get props => [
        firstProperty,
        secondProperty,
      ];

  // ...
}
```

That's it! You only need equatable inside `MomentumModel`, that's where the state lives.

Read more about Equatable [here](https://pub.dev/packages/equatable#-readme-tab-).