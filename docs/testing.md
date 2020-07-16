# Testing
Momentum is very testable. This section will guide you on how to do unit tests and widget tests.

!> **NOTE:** If you have asynchronous code in your app like HTTP requests, it is very hard to do widget tests for those codes. You can use `flutter_driver` instead.

## Setup
The only thing you need to do to make your momentum app testable is to extract the `Momentum(...)` instance inside `runApp(...)` into a method.

#### Before:
```dart
void main() {
  runApp(Momentum(
    // ...
    child: MyApp(),
    controllers: [
      CounterController(),
    ],
    // ...
  ));
}
```

#### After:
```dart
void main() {
  runApp(momentum());
}

Momentum momentum() {
  return Momentum(
    // ...
    child: MyApp(),
    controllers: [
      CounterController(),
    ],
    // ...
  );
}
```

Now, you can call the `momentum()` method which returns a `Momentum` instance inside your test files. No need to mock widgets in momentum.

## Unit Test
Although this is called "unit" tests, you need to use the method `testWidgets(...)` NOT `test(...)`. We are going to unit test both the controller and the model here.

#### Testing Initialization
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Testing Initialization', (tester) async {
    var widget = counter();
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    var counterController = widget.getController<CounterController>();
    expect(counterController, isInstanceOf<CounterController>());
    expect(counterController.model.value, 0);
  });
}
```
- `.getController<T>()` is a momentum method for testing that grabs a specific type of controller.
- We are expecting that `counterController` is not null and is of type `CounterController`.
- The next line checks if the model is initialized properly.
- `pumpAndSettle()` is optional, you can try to remove it and see if the test still works.

#### Testing Functions
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Testing Functions', (tester) async {
    var widget = counter();
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    var counterController = widget.getController<CounterController>();
    counterController.increment();
    expect(counterController.model.value, 1);
    counterController.increment();
    expect(counterController.model.value, 2);
  });
}
```
- Call the `increment()` function from counter controller.
- Check if the value was incremented properly.

## Widget Test
Now we are done with unit testing and confident with our controllers working properly. It's time to test the widgets.

#### Testing Widget Initialization
```dart
testWidgets('Testing Widget Initialization', (tester) async {
  var widget = counter();
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();

  var valueFinder = find.byKey(keyCounterValue);
  var incrementFinder = find.byKey(keyIncrementButton);
  expect(valueFinder, findsOneWidget);
  expect(incrementFinder, findsOneWidget);
  expect(find.text('0'), findsOneWidget);
});
```
- The only thing that is related to momentum here is the `counter()` method which returns an instance of `Momentum`.
- The remaining code lines below are all from the `flutter_test` library. Refer to the official [flutter testing guide](https://flutter.dev/docs/cookbook/testing/widget/introduction#6-verify-the-widget-using-a-matcher).
- We are only testing if the momentum root widget properly initializes the `child` parameter.

#### Testing Widget Functions
```dart
testWidgets('Testing Widget Functions', (tester) async {
  var widget = counter();
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(keyIncrementButton));
  await tester.pump();
  expect(find.text('1'), findsOneWidget);
  await tester.tap(find.byKey(keyIncrementButton));
  await tester.pump();
  expect(find.text('1'), findsNothing);
  expect(find.text('2'), findsOneWidget);
});
```
- We are calling the `.tap()` the method from flutter_test here to test the increment button which calls `increment()` function from the controller.
- After calling `.tap()`, we also called `.pump()`. It is very important because, during testing, widgets don't rebuild automatically.
