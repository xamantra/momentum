# Working with Streams
You don't need `StreamBuilder`. With `MomentumBuilder` you can do any synchronous, asynchronous, and `reactive` state management. The most common area where you'll be required to work with streams is the firebase library.

This will guide you on how to rebuild your widgets with firebase snapshots, how to dispose of the listener when the user logs out and handling stream errors.

## Setup the Model

```dart
class ChatModel extends MomentumModel<ChatController> {
  ChatModel(
    ChatController controller, {
    // ...
    this.roomsSubscription,
    this.roomsSnapshot,
    // ...
  }) : super(controller);

  // ...
  final StreamSubscription<QuerySnapshot> roomsSubscription;
  final QuerySnapshot roomsSnapshot;
  // ...

  @override
  void update({
    // ...
    StreamSubscription<QuerySnapshot> roomsSubscription,
    QuerySnapshot roomsSnapshot,
    // ...
  }) {
    ChatModel(
      controller,
      // ...
      roomsSubscription: roomsSubscription ?? this.roomsSubscription,
      roomsSnapshot: roomsSnapshot ?? this.roomsSnapshot,
      // ...
    ).updateMomentum();
  }

  // ...
}
```

- `QuerySnapshot` - the actual data we need to display on our widget. It is a room list snapshot in this case.

- `StreamSubscription<QuerySnapshot>` - we need a reference to the stream subscription so we can dispose of it later.

<hr>

## Setup the Controller

```dart
class ChatController extends MomentumController<ChatModel> {

  // ...

  @override
  void bootstrap() {
    var roomsSubscription = Firestore.instance.collection('rooms').snapshots().listen((querySnapshot) {
      // whenever "rooms" is modified in firestore server, the model will be updated
      // and "MomentumBuilder" will react to it.
      model.update(roomsSnapshot: querySnapshot);
    });
    // save the reference into the model so we can dispose it later.
    model.update(roomsSubscription: roomsSubscription);
  } 

  // ...
}
```

- `bootstrap()` - this is the best place to initialize listeners not just for streams. This callback method is guaranteed to run only once. There is an asynchronous version for this but we don't need any async code right now.

- `.snapshots()` is of type `Stream<QuerySnapshot>`. We need to listen to this stream.

- `.listen(...)` will return a `StreamSubscription<QuerySnapshot>` and in this code we are storing it in the variable `roomsSubscription`.

- Inside `.listen(...)` callback, we are updating the `roomsSnapshot` with the provided `querySnapshot`. This is realtime so whenever firestore updates this collection, `MomentumBuilder` will also rebuild.

- Finally, we are saving the `roomsSubscription` into the model so we can dispose of it later.

<hr>

## Error Handling

```dart
class ChatController extends MomentumController<ChatModel> {

  // ...

  @override
  void bootstrap() {
    // ...
    model.roomsSubscription.onError((error, stackTrace) {
      print(error);
      print(stackTrace);
    });
    // ...
  } 

  // ...
}
```

- `.onError` is the callback that will be called by firestore when an error occurred in the stream.
- Aside from printing errors on the console, you might want to show alerts or snackbars with the argument `error`. 

<hr>

## Setup the Widget
```dart
MomentumBuilder(
  controllers: [ChatController],
  builder: (context, snapshot) {
    var chatModel = snapshot<ChatModel>();
    var rooms = chatModel.roomsSnapshot.documents;
    // do something "rooms"
    // it is of type "List<DocumentSnapshot>"
    // one "DocumentSnapshot" is one room.
    return ListView.builder(
      itemCount: rooms.length,
      builder: (context, index) {
        var room = rooms[index];
        return RoomWidget(
          // ...
          room: room.data,
          // ...
        );
      },
    );
  },
)
```

- In this momentum builder, we injected `ChatController` so that we can use the `roomsSnapshot` property from `ChatModel`.

- With `roomsSnapshot.documents`, we can access the list of rooms from the firestore and do anything with it.

- `room.data` is the JSON representation of your firestore room.

- `RoomWidget` is just an example, you can display any widget here.

- It is highly recommended to parse the JSON data into a typed object.

<hr>

## Dispose of the Stream

```dart
class ChatController extends MomentumController<ChatModel> {

  // ...

  Future<void> disposeStream() async {
    await model.roomsSubscription.cancel();
  } 

  // ...
}
```

- The `.cancel()` method is asynchronous, the stream needs to clean up after canceling a subscription.
- Now, we can call `disposeStream()` anywhere in our code.

Let's close the stream subscription when the user logout:

```dart
/// ...
TextButton(
  // ...
  child: Text('Logout'),
  onPressed: () async {
    var chatController = Momentum.controller<ChatController>(context);
    await chatController.disposeStream();
    // set the router to clear history and assign login page as initial page in the route.
    await MomentumRouter.resetWithContext<LoginPage>(context);
    // restart the app (this will show login page).
    Momentum.restart(context, momentum());
  },
  // ...
),
```

<hr>

## Long Boilerplate?
You might be thinking right now that just for one stream data, the code is very long. Well, that is very true. But you are seeing it wrong. The biggest advantage with this enough you can overlook the long boilerplate is the `reusability`.

Imagine this scenario:

- You decided that, on the home page, you want to display the number of rooms that the current user belongs to.
- Then, are you going to create another `QuerySnapshot` for it? **NO**.
- Instead of creating another one, you can just reuse the `QuerySnapshot` we created above.

Here's an example:

```dart
AppBar(
  title: MomentumBuilder(
    controllers: [ProfileController, ChatController],
    builder: (context, snapshot) {
      var profileModel = snapshot<ProfileModel>();
      var chatModel = snapshot<ChatModel>();
      var roomCount = chatModel.roomsSnapshot.documents.length;
      return Text('${profileModel.username} - ($roomCount)');
    }
  ),
),
```

- In the appbar, we displayed the room count along with the username.
- We also injected multiple controllers here. (*another good thing about momentum*)
- And this is realtime so whenever the room list gets updated on firestore the appbar title will automatically rebuild too.