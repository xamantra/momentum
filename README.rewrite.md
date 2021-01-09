# Momentum
Closest `MVC` implementation for flutter state management.

### Features
- Model View Controller pattern.
- Immutable. *(only one way to update values)*
- Service locator.
- Dependency injection.
- Routing.
- Event system. *(alerts, dialogs, navigations, etc.)*
- Modular code.
- Highly testable.

This library has a lot of features but it actually only uses `setState(...)` *under the hood* except for `Event System` which uses Stream.

<br>
<hr>
<br>

## Model View Controller
Here's a *diagram* describing the flow between the data (`m`), widget (`v`) and the logic (`c`):
<img src="https://i.imgur.com/O17iMbR.png">

Both `MomentumController` and `MomentumModel` are abstract classes that needs to be implemented.
And `MomentumBuilder` is simply a widget. This is used to listen to controllers for rebuilds and accessing models to display their values. It is similar to *StreamBuilder* but accepts `controllers` type array instead of *stream*.