# Momentum
Closest `MVC` implementation for flutter state management.

### Features
- Model View Controller pattern.
- Immutable. *(only one way to update values)*
- Service locator.
- Dependency injection.
- Routing.
- Event system. *(alerts, dialogs, navigations, etc.)*
- Persistence state. *(configurable)*
- Modular code.
- Highly testable.

This library has a lot of features but it actually only uses `setState(...)` *under the hood* except for `Event System` which uses Stream.

<br>
<hr>
<br>

# Model View Controller
Here's a *diagram* describing the flow between the data (`m`), widget (`v`) and the logic (`c`):
<img src="https://i.imgur.com/O17iMbR.png">

Both `MomentumController` and `MomentumModel` are abstract classes that needs to be implemented.
And `MomentumBuilder` is simply a widget. This is used to listen to controllers for rebuilds and accessing models to display their values. It is similar to *StreamBuilder* but accepts `controllers` type array instead of *stream*.

<br>
<hr>
<br>

# Example Code
This section we are going to take a look at Momentum's MVC pattern with actual flutter codes. This example is a simple *Timer Widget* that starts after a button is clicked.

The example codes below produces this [following result](#example-output).
<br>
<br>

## MomentumModel - `TimerModel`
A model is basically just a list of *final* properties. In this figure we have `seconds (int)` and `started (bool)` properties.

<img height=400px src="https://i.imgur.com/VMdfbuM.png">

Pay close attention to the *dimmed* part. The dimmed parts are the boilerplate codes for momentum models. The highlighted codes are the actual codes you'll write when developing momentum apps.

Also notice the `TimerController` at the first line of the code. You are going to see the contents of that in a few sections below.

<br>

## MomentumBuilder
Now for rendering the model properties into widgets. If you read the code below, you see `timerModel.started` and `timerModel.seconds` being used. We are now using the properties earlier in this widget. If `started (bool)` is `true`, the text widget is displayed. If it is false a button is displayed which calls a function from the controller when it is clicked.

<img height=350px src="https://i.imgur.com/SBChTKn.png">

`controllers: [TimerController]` - injects the *TimerController* into the widget to listen for value updates and rebuilds. Can also inject multiple controllers, hence it's an array.

`timerModel.started` - the property to check to display or hide the `Start Timer` button widget.

`timerModel.seconds` - the value which gets incremented every second when the timer has started. Displayed in a text widget.

`timerModel.controller.startTimer()` - the `Start Timer` button widget calls this function to start the timer and hides itself after (`started` = `true`).

<br>

## MomentumController - `TimerController`
Finally, the last part of our example. The code below shows the logic of the timer. It basically just updates the `model.seconds` value by incrementing it every second.


<img height=350px src="https://i.imgur.com/2cNeLGa.png">

`init()` - initial state of the model.

`model.update(...)` - *update* the values and *rebuild* the widgets. Also the *only* way to update the values (immutable). 

`startTimer()` - timer logic. Starts the timer when called and hides the start button.

`MomentumController` has a very short boilerplate code as you can see from the dimmed parts.

## Example Output
The 3 part example codes above produces the following results:

<img height=420px src="https://i.imgur.com/NxzcF9z.gif">

<br>
<br>

That wraps the example for Momentum. Pretty simple timer widget but it doesn't mean this library can't do advance types of apps. Momentum can do pretty much anything like asynchronous state management, realtime firebase state, local database (persistence) and much more.

// TODO: http rest (async) example project. (soon)

// TODO: firebase example project. (soon)


<br>
<br>

// TODO: Modular Code documentation