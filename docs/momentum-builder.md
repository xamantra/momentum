# MomentumBuilder
`MomentumBuilder` widget class is used for displaying your model/state values. It's a very small widget yet powerful which lets you easily inject any controllers and access their models using the provided generic snapshot callback. This widget will rebuild using the method `model.update(...)`.
- Single and multiple controllers have the same syntax so refactoring isn't a problem at all.
- Single controller:
  ```dart
  MomentumBuilder(
    controllers: [ExampleController],
    builder: (context, snapshot) {
      var exampleModel = snapshot<ExampleModel>();
      return Text(exampleModel.propertyName);
    }
  )
  ```
- Multiple controllers:
  ```dart
  MomentumBuilder(
    controllers: [ExampleControllerA, ExampleControllerB],
    builder: (context, snapshot) {
      var exampleModelA = snapshot<ExampleModelA>();
      var exampleModelB = snapshot<ExampleModelB>();
      return Text('${exampleModelA.propertyName} - ${exampleModelB.propertyName}');
    }
  )
  ```

## controllers
- Type: `List<Type>`
- Default: `[]` *// empty list*
- Required: `NO`

List of controllers to inject. You inject them using *type* not an instance. Momentum will automatically look up the instance for the types you provided. Throws an error if one of the controller types provided is not found.
  ```dart
    MomentumBuilder(
      // ...,
      controllers: [ExampleController],
      // ...,
    )
  ```

<hr>

## builder
- Type: `Widget Function(BuildContext, T Function<T>())`
- Default: `null`
- Required: `YES`

The function parameter where you can access your model values and return a widget based on those values.
```dart
  MomentumBuilder(
    // ...,
    builder: (context, snapshot) {
      var exampleModel = snapshot<ExampleModel>();
      return Text(exampleModel.propertyName);
    },
    // ...,
  )
```
  - `context` is provided for the flutter convention. It can be used for grabbing any context related variables like `Theme` or `MediaQuery`, etc..

  - `snapshot<T>` is a function that is used for grabbing a specific type of model using generic type parameter `T`. The controller of the model type `T` should be in the `controllers` parameter.

<hr>

## dontRebuildIf
- Type: `bool Function(T Function<T>(), bool)`
- Default: `null`
- Required: `NO`

An optional callback. If provided, this will be called right before the `builder`. If returns `true`, it will skip rebuilding this `MomentumBuilder`.
```dart
  MomentumBuilder(
    // ...,
    dontRebuildIf: (controller, isTimeTravel) {
      var exampleController = controller<ExampleController>();
      // do something with "exampleController".
      // you can access the model using "exampleController.model".
      return !isTimeTravel; // skip rebuild if update is not undo/redo.
    },
    // ...,
  )
```
  - `controller<T>` is a function that is used for grabbing a specific type of controller using a generic type parameter. It is similar to `snapshot<T>` but for controllers. The controller should be in the `controllers` parameter for this to work.

  - By grabbing a specific type of controllers, you can use them for a complex condition to skip a rebuild for some reason.

  - `isTimeTravel` is a `bool` that indicates whether the model update was done using time travel (undo/redo) methods.

<hr>

## owner
- Type: `Widget`
- Default: `null`
- Required: `NO`

Used for detailed error logs. Simply specify with `owner: this` for `StatelessWidget` and `owner: widget` for `StatefulWidget` to set the current widget as the owner.
  - If you are in a `StatelessWidget`:
    ```dart
      MomentumBuilder(
        // ...,
        owner: this,
        // ...,
      )
    ```
  - If you are in a `StatefulWidget` with `State<T>`:
    ```dart
      MomentumBuilder(
        // ...,
        owner: widget,
        // ...,
      )
    ```

<hr>
