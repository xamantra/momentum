<h1 id="readme"></h1>
<p align="center">
  <img src="https://i.imgur.com/DAFGeAd.png">
</p>

<p align="center"><strong>MVC</strong> pattern for flutter. Works as <i>state management</i>, <i>dependency injection</i> and <i>service locator</i>.</p>

<p align="center">
<a href="https://pub.dev/packages/momentum" target="_blank"><img src="https://img.shields.io/pub/v/momentum" alt="Pub Version" /></a>
<a href="https://github.com/xamantra/momentum/actions" target="_blank"><img src="https://github.com/xamantra/momentum/workflows/CI/badge.svg" alt="Test" /></a>
<a href="https://codecov.io/gh/xamantra/momentum"><img src="https://codecov.io/gh/xamantra/momentum/branch/master/graph/badge.svg" /></a>
<a href="https://github.com/xamantra/momentum/stargazers" target="_blank"><img src="https://img.shields.io/github/stars/xamantra/momentum" alt="GitHub stars" /></a>
<a href="https://github.com/xamantra/momentum/blob/master/LICENSE" target="_blank"><img src="https://img.shields.io/github/license/xamantra/momentum" alt="GitHub license" /></a>
<a href="https://github.com/xamantra/momentum/commits/master" target="_blank"><img src="https://img.shields.io/github/last-commit/xamantra/momentum" alt="GitHub last commit" /></a>
</p>

> **Project revival** — Maintenance on *momentum* has resumed after a long pause. **3.0.0** brings the package up to date with current Dart and Flutter toolchains, CI, and dependencies so it can be used and contributed to again. See [CHANGELOG.md](CHANGELOG.md) for the full release history.
>
> **Breaking changes (3.0.0)** — Requires **Dart 3** (`sdk: '>=3.0.0 <4.0.0'`) and **Flutter 3.50+** (`flutter: '>=3.50.0'`). Removed v1 deprecated aliases (`Momentum.of`, `Momentum.getService`, `dependOn`, and `getService` — use `Momentum.controller`, `Momentum.service`, `controller`, and `service` instead), and updated internal usage for removed or deprecated Flutter APIs (for example `WillPopScope`, `ThemeData.backgroundColor` / `accentColor`, and `@required`). Upgrade your app’s SDK constraints before bumping to 3.0.0. If you are still on 2.x, review [CHANGELOG.md](CHANGELOG.md) for earlier breaking changes (notably the `Router` → `MomentumRouter` rename in 2.0.0).

---



<h1 align="center">Model View Controller</h1>
<p align="center">
Here's a <i>diagram</i> describing the flow between the <u>state</u> (<code>model</code>), <u>widget</u> (<code>view</code>) and the <u>logic</u> (<code>controller</code>):
</p>

<p align="center">
  <img src="https://i.imgur.com/O17iMbR.png">
</p>


<p align="center">
Both <code>MomentumController</code> and <code>MomentumModel</code> are abstract classes that needs to be implemented. A pair of model and controller is called a <strong>component</strong>. <code>MomentumBuilder</code> is simply a widget. This is used to listen to controllers for rebuilds and accessing models to display their values.
</p>


# Example
If you want to see a full runnable code example for **Momentum 3.0.0** (Dart 3 / Flutter 3.50+), check out [`example/lib/main.dart`](https://github.com/xamantra/momentum/blob/master/example/lib/main.dart) (CI-checked), [`example/README.md`](https://github.com/xamantra/momentum/blob/master/example/README.md), the [Quick Start](quick-start.md) guide, or the [pub.dev example](https://pub.dev/packages/momentum/example) tab. Otherwise, if you only want to see a glimpse of how momentum works, read the [Overview](#overview) and [FAQs](#faqs) below.

**Legacy Advanced Example:** [Listify](https://github.com/xamantra/listify) (written for Flutter 2.0.0; kept for historical reference)


# Overview
**MomentumModel** - the data or state. Must be *Immutable*.
```dart
class ProfileModel extends MomentumModel<ProfileController> {
  const ProfileModel(
    super.controller, {
    required this.userId,
    required this.username,
  });

  final int userId;
  final String username;

  @override
  void update({int? userId, String? username}) {
    ProfileModel(
      controller,
      userId: userId ?? this.userId,
      username: username ?? this.username,
    ).updateMomentum();
  }
}
```



**MomentumBuilder** - the view or widget to display the state.
```dart
MomentumBuilder(
  controllers: const [ProfileController], // injects both `ProfileController` and `ProfileModel`.
  builder: (context, snapshot) {
    final profileState = snapshot<ProfileModel>(); // grab the `ProfileModel` using snapshot.
    final username = profileState.username;
    return Text(username);
  },
)
```



**MomentumController** - the logic to manipulate the model or state.
```dart
class ProfileController extends MomentumController<ProfileModel> {
  // ...

  Future<void> loadProfile() async {
    final profile = await http.get(...);
    // update the model's properties.
    model.update(
      userId: profile.userId,
      username: profile.username,
    );
  }

  // ...
}
```



# FAQs
## How to *rebuild* the widget?
Calling `model.update(...)` from inside the controller rebuilds all the `MomentumBuilder`s that are listening to it.

<hr>

## How to access the *model* object?
It is automatically provided by `MomentumController` for you to use. Inside a controller class, you can access it directly. It's never null.


<hr>

## How to *initialize* the model or state?
By implementing the `T init()` method which is required by *MomentumController*. Like this:
```dart
class ShopController extends MomentumController<ShopModel> {

  @override
  ShopModel init() {
    return ShopModel(
      this, // required
      shopList: [],
      productList: [],
    );
  }
}
```

<hr>

## Can I access the model properties inside my controller?
Of course. The **model** object is already provided by *MomentumController* meaning you can also directly access its properties like this:
```dart
class ShopController extends MomentumController<ShopModel> {

  bool hasProducts() {
    return model.productList.isNotEmpty;
  }
}
```

<hr>

## Is there a special *setup* required for Momentum to run?
Yes, definitely. This is the required setup for *Momentum* in a flutter app:
```dart
void main() {
  runApp(momentum());
}

Momentum momentum() {
  return Momentum(
    child: const MyApp(),
    controllers: [
      ProfileController(),
      ShopController(),
    ],
    // and more optional parameters here.
  );
}
```

# Testing
Momentum is highly testable. This is how a basic **widget testing** for momentum would look like:
```dart
void main() {
  testWidgets('should display username', (tester) async {
    final profileCtrl = ProfileController();

    await tester.pumpWidget(
      Momentum(
        child: const MyApp(),
        controllers: [profileCtrl],
      ),
    );
    await tester.pumpAndSettle();

    profileCtrl.updateUsername('johndoe');
    await tester.pumpAndSettle(); // ensure rebuilds

    expect(profileCtrl.model.username, 'johndoe'); // unit check
    expect(find.text('johndoe'), findsOneWidget); // widget check
  });
}
```

Or you might not be a fan of widget testing and only want to test your components:
```dart
void main() {
  test('should display username', () async {
    final profileCtrl = ProfileController();

    final tester = MomentumTester(
      Momentum(
        controllers: [profileCtrl],
      ),
    );
    await tester.init();

    profileCtrl.updateUsername('johndoe');
    expect(profileCtrl.model.username, 'johndoe'); // unit check
  });
}
```



# Other optional features
- **Routing** - Navigation system that supports persistence. The app will open the page where the user left off.
- **Event System** - For showing dialogs, prompts, navigation, alerts.
- **Persistence State** - Restore state when the app opens again.
- **Testing** - Tests your widgets and logic. Built-in helper class for unit testing.

Momentum leverages the power of `setState(..)` and *StatefulWidget* behind the scenes. The feature `Event System` uses *Stream*.

## Router issues
- The router doesn't support named routes yet.
- The parameter handling for router is slightly verbose. And might be complicated for some. But it works magically.
- Needs to explicitly wrap screens with the `RouterPage` widget (which uses `PopScope`) in order to handle the system's back button.
- (**FIXED** ✅) The router breaks after hot reload. Only a problem during development but it should work in normal execution.


# API Reference & Agent Docs
- **Canonical 3.0.0 API Quick-Reference (LLMs & Developers):** [`llms.txt`](https://github.com/xamantra/momentum/blob/master/llms.txt)
- **Repository & Contributor Guide for AI Coding Agents:** [`AGENTS.md`](https://github.com/xamantra/momentum/blob/master/AGENTS.md)
- **Docs Website:** Browse the sidebar to explore the full *api reference*, *guides*, and *examples*.

<hr>

Thanks for checking out *momentum*. I hope you try it soon and don't hesitate to file an [issue on github](https://github.com/xamantra/momentum/issues). I always check them everyday.
