# RouterMixin
A mixin for `MomentumController` that adds the capability to handle route changes from momentum's built-in routing system.

You need to add this mixin in your controller to be able to use it.

```dart
class ExampleController extends MomentumController<ExampleModel> with RouterMixin {
  // ...
}
```

<hr>

## getParam\<T\>()
- Category: `Method`
- Type: `T` extends `RouterParam`

Get the current route parameters specified using the `params` parameter in `MomentumRouter.goto(...)` or `MomentumRouter.pop` method. Returns `null` if no parameter is provided.
```dart
// setting the route params.
MomentumRouter.goto(context, DashboardPage, params: ExampleParam(...));

// accessing the route params inside controllers.
final params = getParam<ExampleParam>();
```

<hr>

## onRouteChanged(...)
- Category: `Virtual Method`
- Type: `void`

A callback whenever `MomentumRouter.goto` or `MomentumRouter.pop` is called. The `RouterParam` is also injected here, will be `null` if not provided.

Example:
```dart
class ExampleController extends MomentumController<ExampleModel> with RouterMixin {
  @override
  ExampleModel init() {
    return ExampleModel(
      this,
    );
  }

  @override
  void onRouteChanged(RouterParam param) {
    if (param is ExampleParam) {
      final title = (param as ExampleParam).title;

      // You can also use "getParam<T>()" here.
      // final title = getParam<ExampleParam>().title.

      print(title);
    }
  }
}
```