# Time Travel
People love time machine. So time travel function was one of the first features added in momentum. It is for undoing or redoing state changes.

- Configure in one line of code.
- `Disabled` by default.
- Supports up to `250` steps.
- Call time travel methods in one line of code.

## Configure
You can enable time travel per controller or enable all controllers. To enable this, you need to specify the parameter `maxTimeTravelSteps`, if the value is greater than 1, it will be `enabled`, otherwise, it will be `disabled`,

- Enable per controller:
  ```dart
  Momentum(
    // ...
      controllers: [
        // ...
        ExampleControllerA()..config(maxTimeTravelSteps: 200),
        ExampleControllerB(), // time travel disabled.
        // ...
      ],
    // ...
  )
  ```

- Enable in all controllers:
  ```dart
  Momentum(
    // ...
      controllers: [
        // ...
        ExampleControllerA(),
        ExampleControllerB(),
        ExampleControllerC(maxTimeTravelSteps: 1), // disable in this controller.
        // ...
      ],
      maxTimeTravelSteps: 100,
    // ...
  )
  ```

## Undo & Redo
The method `.backward()` is for undo while `.forward()` is for redo states.

```dart
class ExampleController extends MomentumController<ExampleModel> {
  
  // ...

  void undoEdit() {
    backward();
    // or
    this.backward();
    // choose your preference :)
  }

  void redoEdit() {
    forward();
  }

  // ...
}
```

## TextFormField
This will guide you on how to implement undo/redo with text fields. There are two options to do this.

- First, using `MomentumBuilder`, `dontRebuildIf` parameter and flutter's `Key`.
```dart
  MomentumBuilder(
    controllers: [ExampleController],
    // skip rebuild if state update was not done
    // with time travel methods. This is very IMPORTANT.
    dontRebuildIf: (controller, isTimeTravel) => !isTimeTravel,
    builder: (context, snapshot) {
      var example = snapshot<ExampleModel>();
      return TextFormField(
        key: Key(example.username),
        initialValue: example.username,
        // ...
      );
    }
  )
```
  - Whenever you type into this textbox, the widget will not rebuild.
  - We don't need to rebuild the textbox widget because what we type here is automatically rendered.
  - We only want to rebuild when `.backward()` or `.forward()` method is called.
  - Only `TextFormField` has *initialValue* property.

<hr>

- Second, using `MomentumState`, `TextEditingController` and `.addListener(...)` method. This is the long way :)
```dart
  class _ExampleState extends MomentumState<ExampleWidget> {
    ExampleController exampleController;
    TextEditingController usernameController = TextEditingController();

    @override
    void initMomentumState() {
      exampleController = Momentum.controller<ExampleController>(context);
      exampleController.addListener(
        state: this,
        invoke: (model, isTimeTravel) {
          if (isTimeTravel) {
            usernameController.text = model.username;
            // for this selection code, refer to this link: https://stackoverflow.com/a/58307018
            usernameController.selection = TextSelection.fromPosition(
              TextPosition(offset: usernameController.text.length),
            );
          }
        }
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        // ...
          child: TextFormField(
            controller: usernameController,
            onChanged: (value) {
              // update value in the model as the user types.
              exampleController.setUsernameInput(username: value);
            },
            // ...
          ),
        // ...
      );
    }
  }
```
#### Notes
  - When you call `backward()` or `forward()`, both these options will react to it and rebuild the text fields appropriately.
  - The second option is kinda long and it's not easy to handle for multiple text fields. So you can forget about it :)
  - These long setup above is for text fields only really, with the other widget types they can work out of the box with `MomentumBuilder` alone without those special parameters.
  - If a certain widget doesn't work, try using flutter's `Key`.