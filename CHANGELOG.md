## 1.1.0

- Reformatted the whole readme, reduce number of headings.

## 1.0.9

- New feature: `dontRebuildIf` parameter for `MomentumBuilder`.

  - This method will be called after `model.update(...)` right before the `builder`.
  - `isTimeTravel` is also provided that indicates if the model was updated by time travel methods `.backward()` or `.forward()`, returning it directly means you don't want to rebuild if an update was done with time travel method.
  - Two new properties was also added: `MomentumController.prevModel` and `MomentumController.nextModel` which are properties from model history and their meaning is quite obvious. The `prevModel` is the previous state and `nextModel` is the next state which will only have a value if you use `.backward()` method. If you are on latest snapshot of the model `nextModel` will be null.

    ```Dart
      MomentumBuilder(
        controllers: [ChatController, SessionController],
        dontRebuildIf: (controller, isTimeTravel) {
          var chatController = controller<ChatController>();

          /* You can also get any controller you injected the same way you can get any model in "builder" method. */
          // var sessionController = controller<SessionController>();

          var currentMessage = chatController.model.messageInput; // latest snapshot of the model after a calling "model.update()".
          var prevMessage = chatController.prevModel.messageInput; // model history, previous state of the model.

          var messageInputUpdated = currentMessage != (prevMessage ?? ''); // means the user is inputting a message on textfield.

          return messageInputUpdated; // don't rebuild this widget if user is inputting a message.
        },
        builder: (context, snapshot) {...},
      )
    ```

  - The example code is quite long but you can basically do anything with it. You can access any controllers and their models means you can do any conditions for skipping rebuilds.
  - **WARNING:** This method is the same as any other `builder` of `build` methods, do not call `model.update(...)` or anything that calls `build` method, for example `setState(...)`. You'll get an infinite loop.

## 1.0.8

- Major update:
  - updated `onResetAll` to support widget operation before actually reseting all models.
  - improved README, added lots of new contents.

## 1.0.7

- fixed typos on readme.

## 1.0.6

- updated readme, added MomentumState listener section. and also fix typos.

## 1.0.5

- fix readme not properly displaying in pub.dev

## 1.0.4

- updated example project to link the correct `momentum` version from `pub.dev`.

## 1.0.3

- updated readme, now most parts are covered.

## 1.0.2

- added example app.

## 1.0.1

- updated error message.

## 1.0.0

- Initial version.
