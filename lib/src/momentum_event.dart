import 'dart:async';

import 'package:flutter/material.dart';

/// Used internally for sending and receiving events.
class MomentumEvent<E> {
  /// The state that this event is binded to.
  final State state;

  /// Used internally for sending and receiving events.
  MomentumEvent(this.state);

  final StreamController<E> _streamController = StreamController<E>.broadcast();

  /// The controller for the event of type `E`.
  StreamController<E> get streamController => _streamController;

  ///
  Stream<E> on() {
    return streamController.stream.where((event) => event is E).cast<E>();
  }

  /// Fires a new event on the event bus with the specified [event].
  void trigger(E event) {
    streamController.add(event);
  }

  /// Destroy this [MomentumEvent]. This is generally only in a testing context.
  void destroy() {
    _streamController.close();
  }
}
