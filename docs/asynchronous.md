# Asynchronous
You want to call some HTTP requests and show a loading widget? Well, it can be anything. Asynchronous code exists in every app and the UI should properly display an appropriate indicator that the app is doing something.

You might **NOT** need `FutureBuilder`. It is very easy to do that in momentum.

#### Example Code
The logic inside controller:
```dart
 class ExampleController extends MomentumController<ExampleModel> {

   // ...

  @override
  void bootstrap() {
    loadSomeData(); // only loaded once in the app's lifecycle.
    // you can also call "loadSomeData()" from "initState()" if you
    // want to reload the data whenever the widget gets reloaded too.
  }

  Future<void> loadSomeData() async {
    model.update(loadingData: true);
    var result = await apiService.loadSomeBigData();
    model.update(loadingData: false, someData: result);
  }

   // ...
 }
```
The UI code to display loading and data/result's widget:
```dart
MomentumBuilder(
  controllers: [ExampleController],
  builder: (context, snapshot) {
    var exampleModel = snapshot<ExampleModel>();

    if (exampleModel.loadingData) {
      return CircularProgressIndicator();
    }

    return YourWidgetsHere(
      someData: exampleModel.someData,
      // ...
    );
  }
)
```

#### The Process

Always remember that `model.update(...)` will rebuild widgets.

- Inside `Future<void> loadSomeData()`:
  - The first line is simply setting the property `loadingData` to `true`:
    ```dart
      model.update(loadingData: true);
    ```
  - In the widget code, if `loadingData` is `true`, we are displaying a loading indicator:
    ```dart
      if (exampleModel.loadingData) {
        return CircularProgressIndicator();
      }
    ```
  - Now, the next line inside `loadSomeData()` is an asynchronous code. Imagine this code will take seconds to finish:
    ```dart
    var result = await apiService.loadSomeBigData();
    ```
  - The last line, we set the `loadingData` to `false` after the async code finishes. And also store the result in `someData` property:
    ```dart
      model.update(loadingData: false, someData: result);
    ```
  - The widget is now rebuilt with new model values and `loadingData` to `false`. We can now display the widget we want:
    ```dart
      // now false and will not return loading indicator.
      if (exampleModel.loadingData) {
        return CircularProgressIndicator();
      }

      return YourWidgetsHere(
        someData: exampleModel.someData,
        // ...
      );
    ```