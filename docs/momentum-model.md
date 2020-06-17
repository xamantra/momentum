# MomentumModel
The abstract base class which holds the state of your app. This is tied with `MomentumController`. This class is immutable.

This is the boilerplate code:
```dart
class ExampleModel extends MomentumModel<ExampleController> {
  ExampleModel(ExampleController controller) : super(controller);

  // TODO: add your final properties here...

  @override
  void update() {
    ExampleModel(
      controller,
    ).updateMomentum();
  }
}
```

## .update(...)
- Category: `Method`
- Type: `void`

The method for updating this model and rebuilding widgets. Like `setState(...)` but immutable. This is abstract and required to be implemented.
- Example implementation:
```dart
  // ...

  final int value;

  @override
  void update({
    int value,
  }) {
    ExampleModel(
      controller,
      value: value ?? this.value,
    ).updateMomentum();
  }

  // ...
```
  - `updateMomentum()` needs to be explicitly called to rebuild widgets. It is part of the boilerplate.
  - `controller` is also required in the constructor because models are always attached to controllers and vice-versa.
  - Implementing this method follows the convention for `copyWith(...)` method. Refer to [this link](https://developer.school/dart-flutter-what-does-copywith-do/#:~:text=Although%20the%20notion%20of%20copyWith,arguments%20that%20overwrite%20settable%20values.) to learn more about it.

- Example usage inside a controller:
```dart
  // ...

  void increment() {
    var newValue = model.value + 1;
    model.update(value: newValue);
  }

  // ...
```

<hr>

## .controller
- Category: `Readonly Property`
- Type: `MomentumController`

The reference to the controller instance that this model is attached to.
- Example usage inside a widget:
```dart
  MomentumBuilder(
    controllers: [ExampleController],
    builder: (context, snapshot) {
      var exampleModel = snapshot<ExampleModel>();
      
      return FlatButton(
        // ...
        onPressed: () {
          // access the controller property.
          exampleModel.controller.increment();
        },
        // ...
      );
    },
  )
```
!> If you can access the model, you can access its controller.

<hr>

## .controllerName
- Category: `Readonly Property`
- Type: `String`

The name of the controller that this model is attached to. This is used internally by momentum for detailed logs. But it is also accessible publicly for your debugging purposes.
```dart
print(model.controllerName);
```

<hr>

## .toMap()
- Category: `Method`
- Type: `Map<String, dynamic>`

Method to generate a map from this model. Momentum will automatically call this method. This is required for implementing persistence. If you don't need persistence you can ignore this method.
```dart
class ExampleModel extends MomentumModel<ExampleController> {
  // ...

  final int value;

  // ...

  Map<String, dynamic> toMap() {
    return {
      'value': value,
    };
  }

  // ...
}
```

<hr>

## .fromMap(...)
- Category: `Method`
- Type: `MomentumModel`

The method to create an instance of this model from a JSON/map. This is different from the usual factory fromMap method. It's an instance member because you wouldn't be able to access the controller property otherwise. Momentum will automatically call this method. This is required for implementing persistence. If you don't need persistence you can ignore this method.
```dart
class ExampleModel extends MomentumModel<ExampleController> {
  // ...

  final int value;

  // ...

  ExampleModel fromMap(Map<String, dynamic> json) {
    return ExampleModel(
      controller,
      value: json['value'],
    );
  }

  // ...
}
```