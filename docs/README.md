<p align="center">
  <img src="https://i.imgur.com/DAFGeAd.png">
</p>

<p align="center">A super powerful flutter state management library inspired with MVC pattern with a very flexible dependency injection.</p>

## Features
  - Very flexible `Dependency Injection` to easily instantiate any dependencies once and reuse multiple times across the app.
  - `Persistence` support for states and routing. Use any storage provider.
  - Time travel (`undo/redo`) support in one line of code out of the box.
  - Optional `Equatable` support. (*Improves time travel*).
  - `Immutable` states/models. There's only one way to rebuild widget.
  - You can `reset a state` or all of the states.
  - `Skip rebuilds`. Widget specific.
  - Easy to use `Event System` for sending events to the widgets. *For showing dialogs/snackbars/alerts/navigation/etc.*
  - Everything is in the widget tree.
  - Momentum doesn't have any dependencies so it increases compatibility in other platforms.
  - Supports older versions of flutter.

## Preview
In this image the process were like this:
- Open app (Home Page).
- Go to *Add New List* page.
- Input some data.
- Close and Terminate on multitask view.
- Reopen the app again.

And magic happens! All the inputs were retained and not just that but also including the page where you left off. Navigation history is also persisted which means pressing system back button will navigate you to the correct previous page.

![persistent preview](./images/gallery/001.png)

#### Dark Mode
This theming is done manually using momentum.

![dark mode](./images/gallery/002.png)

#### [Source Code for this Example App](https://github.com/xamantra/listify)
This example app shows how powerful momentum is.