# MomentumTester
A feature for unit testing. This helps to test controllers, models, and services without relying on any widget. Which means any asynchronous code works fine in this tool.

### Example
```dart
  test('Momentum Tester Tool: Counter', () async {
    // create tester instance.
    var tester = MomentumTester(momentum());

    await tester.init(); // initialize the tester (calls bootstrap methods)

    var counter = tester.controller<CounterController>();
    expect(counter != null, true);
    expect(counter, isInstanceOf<CounterController>());
    expect(counter.model.value, 0);
    counter.increment();
    expect(counter.model.value, 1);
  });
```

<hr>

## .init()
- Category: `Method`
- Type: `Future<void>`

Initialize a momentum instance with `Momentum Tester` to make all the dependencies testable.

```dart
  test('Momentum Tester Tool: Counter', () async {
    // create tester from a momentum instance.
    var tester = MomentumTester(momentum());

    await tester.init(); // mock initialization without relying on widgets.

    // ...
  });
```

<hr>

## .controller\<T\>()
- Category: `Method`
- Type: `T` *extends* `MomentumController`

Get a controller from a tester instance to test its functions.

```dart
  test('Counter', () async {
    var tester = MomentumTester(momentum());
    await tester.init();

    var counter = tester.controller<CounterController>(); // get the controller
    expect(counter.model.value, 0); // testing initial value if correct.

    // ...
  });
```

<hr>

## .service\<T\>()
- Category: `Method`
- Type: `T` *extends* `MomentumService`

Get service from a tester instance to test its functions.

```dart
  test('ApiService', () async {
    var tester = MomentumTester(momentum());
    await tester.init();

    var api = tester.service<ApiService>(); // get the service
    var response = await api.login('username', 'password');
    expect(response.success, true);

    // ...
  });
```

<hr>

## .mockLazyBootstrap\<T\>()
- Category: `Method`
- Type: `Future<void>`

The bootstrap function of `MomentumController`s depend on the widget. Calling `mockLazyBootstrap<T>()` manually mock its behavior for testing.

```dart
  test('ProfileController', () async {
    var tester = MomentumTester(momentum());
    await tester.init();

    // 1. calls `bootstrap()`
    // 2. calls `bootstrapAsync()`
    await tester.mockLazyBootstrap<ProfileController>(); // mock bootstrap for `ProfileController`
    var profile = tester.controller<ProfileController>();
    expect(profile.username, 'hello_world'); // assuming the bootstrap function loads the user's profile.

    // ...
  });
```

<hr>

## .mockRouterParam(...)
- Category: `Method`
- Type: `void`

In momentum, controllers can also access router params if present. But navigation relies on widget context. Calling `mockRouterParam(param)` sends a router param data to controllers that are mixed with `RouterMixin`. This way you can test your controller functions that depend on router params.

```dart
  test('RouterController', () async {
    var tester = MomentumTester(momentum());
    await tester.init();

    var routerCtrl = tester.controller<RouterController>();
    var response = await tester.service<ApiService>().getProfile();
    tester.mockRouterParam(ProfileRouteParam(profileData: response.profile)); // mocks router param.
    expect(routerCtrl.model.profileData.username, 'hello_world');

    // ...
  });
```