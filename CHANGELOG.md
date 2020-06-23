## 1.2.6
- improve Momentum.restart function.

## 1.2.5
- fixed image links in docs

## 1.2.4
- The `pub.dev` package now excluded `docs/` and `test/` folders to speed up `flutter pub get` for environment with limited internet access.

## 1.2.3
- Added `testMode` parameter on `Momentum` for easier testing on project level.
- Fixed bugs related to testing asynchronous code.
- Added more internal tests. 

<hr>

## 1.2.2
- Fixed `Router` error that happens when `persistSave` is not specified.
- Fixed `MomentumError` doesn't override `toString()` so detailed error logs are not printed on the console.

<hr>

## 1.2.1
- [Issue #7](https://github.com/xamantra/momentum/issues/7) - Added new capability to globally disable persistent state for all models. Docs [here](https://xamdev.gq/momentum/#/momentum?id=disabledpersistentstate).
- `skipPersist()`, by default now returns null. Not a breaking change because this method is only meant to be used by momentum internally.

<hr>

## 1.2.0
- critical: fix `snapshot<T>()` where it throws a compile-time type error in older versions of flutter.
- added and refactored test methods.
- added new internal tests.

<hr>

## 1.1.9 - Critical
- Fixed [#5](https://github.com/xamantra/momentum/issues/5)
- Improve types system for dependency injection
- Fix extending controllers that cause bug for `snapshot<T>()`. Click [here](https://xamdev.gq/momentum/#/extending-controllers) for the docs.
- Added internal tests.

<hr>

## 1.1.8 - Important
<a href="https://github.com/xamantra/momentum/actions?query=workflow%3ACI" target="_blank"><img src="https://github.com/xamantra/momentum/workflows/CI/badge.svg?event=push" alt="CI" /></a>
<a href="https://codecov.io/gh/xamantra/momentum"><img src="https://codecov.io/gh/xamantra/momentum/branch/master/graph/badge.svg" /></a>

- Changed license to [BSD-3](https://opensource.org/licenses/BSD-3-Clause)
- critical fix: reset() bug.
- fix config check bug in the "persistSave" parameter.
- (test) fixed dependOn<T>() test to cover more exceptions.
- added public methods for testability.
- Added internal tests.

#### TODO
- Add more internal tests.
- Find a workaround for issue [#5](https://github.com/xamantra/momentum/issues/5)
- Write docs for project-level testing.
- Refactor tests description/names.

<hr>

## 1.1.7 - Major Update
Major changes:
- Persistent state.
- Persistent navigation/routing.
- Equatable support.
- `sendEvent<T>(...)` and `.listen<T>(...)`.
- Official Documentation: https://xamdev.gq/momentum/#/

Minor changes:
  - `Momentum.controller<T>` is now the recommended way of getting a controller using context instead of `Momentum.of<T>`.
  - `Momentum.service<T>` is now the recommended way of getting a service using context instead of `Momentum.getService<T>`.
  - `enableLogging` now defaults to `false`.

✔ No breaking changes.

<hr>

## 1.1.6
- New function added: `Momentum.restart(...)`
  - Restart the app with a new momentum instance.
  - To easily implement, in you `main.dart` create a method that returns `Momentum` instance.
    ```dart
    void main() {
      runApp(momentum()); // call the method here instead of instantiating the Momentum.
    }

    Momentum momentum() {
      return Momentum(
        child: MyApp(),
        controllers: [
          LoginController(),
          SessionController()..config(lazy: false, enableLogging: true),
          TimerController()..config(maxTimeTravelSteps: 5),
          TimeclockController(),
          AppController()..config(lazy: false, enableLogging: true),
          SettingsController()..config(lazy: false),
        ],
        services: [
          Router([
            Login(),
            Home(),
            Settings(),
            LanguageSelection(),
            FontScale(),
          ]),
        ],
        enableLogging: false,
        onResetAll: (context, resetAll) async {
          await Momentum.of<SessionController>(context).clearSession();
          resetAll(context);
          Router.goto(context, Login);
        },
      );
    }
    ```
  - You can then call `Momentum.restart(...)` down the tree:
    ```dart
    Momentum.restart(context, momentum()); // call momentum() which is a top level function.
    ```

<hr>

## 1.1.5

- New feature added: **Services**.
- Inject anything into momentum and use them down the tree inside _widgets_ or _controllers_.
- Example code:

  ```dart
  // main.dart
  Momentum(
    controllers: [...],
    services: [
      ApiService(),
    ],
    child: MyApp(),
    ...
  )

  // *.controller.dart
  void loadUser() async {
    model.update(loadingUser: true);
    var apiService = getService<ApiService>();
    var user = await apiService.getUser(); // load data from server. asynchronous
    model.update(loadingUser: false, user: user);
  }
  ```

## 1.1.4

- exposed MomentumModel.controller property.

<hr>

## 1.1.3 - Breaking Changes

- `bootstrap()` method is now synchronous only.
- added `bootstrapAsync()` for separate asynchronous support.
- For the execution order, `bootstrap()` gets called first then `bootstrapAsync()`.
- added detailed logging for both `bootstrap()` and `bootstrapAsync()` so you can see what gets executed first and the time it took.

<hr>

## 1.1.2

- Fixed health check: `Fix lib/src/momentum_base.dart. (-1 points)`

<hr>

## 1.1.1

- New feature: Asynchronous `bootstrap()` method now supports loading widget using `appLoader` parameter on `Momentum` root widget. If `appLoader` is not specified a default loading widget will be shown.
  - You have to turn lazy loading off to enable this feature.
  - Lets say one of your controllers implements `bootstrap()` method asynchronously and it loads a data that takes seconds to finish:
    ```Dart
      @override
      void bootstrap() async {
        // assuming we are loading some complex and big data here.
        var appSettings = await apiService.getAppSettings();
        model.update(appSettings: appSettings);
      }
    ```
  - Now, imagine `apiService.getAppSettings()` takes 3-5 seconds to load. Before your `MyApp()` gets loaded, _momentum_ will await this bootstrap method and show a loading widget until it finishes. Means, you can now do anything you want with the `bootstrap()` method synchronous or asynchronous. It is safe to call `model.update(...)` in this method.

<hr>

## 1.1.0

- Reformatted the whole readme, reduce the number of headings.

<hr>

## 1.0.9

- New feature: `dontRebuildIf` parameter for `MomentumBuilder`.

  - This method will be called after `model.update(...)` right before the `builder`.
  - `isTimeTravel` is also provided that indicates if the model was updated by time travel methods `.backward()` or `.forward()`, returning it directly means you don't want to rebuild if an update was done with the time travel method.
  - Two new properties were also added: `MomentumController.prevModel` and `MomentumController.nextModel` which are properties from model history and their meaning is quite obvious. The `prevModel` is the previous state and `nextModel` is the next state which will only have a value if you use `.backward()` method. If you are on the latest snapshot of the model `nextModel` will be null.
  - Take a look at this example, The widget is displaying a time format `HH: mm` and `TimerController` ticks every `500ms` for accuracy. We only need to rebuild if _minute_ property is changed, that's where the `dontRebuildIf` parameter comes.

    ```Dart
      MomentumBuilder(
        controllers: [TimerController],
        dontRebuildIf: (controller, isTimeTravel) {
          var timer = controller<TimerController>();
          var prevMinute = timer.prevModel.dateTime.minute;
          var currentMinute = timer.model.dateTime.minute;
          var minuteUnchanged = currentMinute == prevMinute;
          return minuteUnchanged; // don't rebuild the widget if "minute" is unchanged.
        },
        builder: (context, snapshot) {...},
      )
    ```

  - **WARNING:** This method is the same as any other `builder` or `build` methods, do not call `model.update(...)` or anything that calls `build` method, for example, `setState(...)`. You'll get an infinite loop.

<hr>

## 1.0.8

- Major update:
  - updated `onResetAll` to support widget operation before actually resetting all models.
  - improved README added lots of new content.

<hr>

## 1.0.7

- fixed typos on the readme.

<hr>

## 1.0.6

- updated readme added MomentumState listener section. and also fix typos.

<hr>

## 1.0.5

- fix readme not properly displaying in pub.dev

<hr>

## 1.0.4

- updated example project to link the correct `momentum` version from `pub.dev`.

<hr>

## 1.0.3

- updated readme, now most parts are covered.

<hr>

## 1.0.2

- added example app.

<hr>

## 1.0.1

- updated error message.

<hr>

## 1.0.0

- Initial version.
