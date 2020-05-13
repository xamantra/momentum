import 'package:flutter/material.dart';
import '../../../src/widgets/asynchronous/asynchronous.dart';
import '../../../src/widgets/counter-advance/counter-advance.dart';
import '../../../src/widgets/counter-extreme/counter-extreme.dart';
import '../../../src/widgets/counter-insane/counter-insane.dart';
import '../../../src/widgets/counter/counter.dart';
import '../../../src/widgets/timer/timer.dart';
import '../../../src/widgets/undo-redo/undo-redo.dart';

import 'widgets/item-card.dart';

final modules = [
  ItemCard(text: 'Counter', icon: Icons.add, expand: true, module: CounterPage()),
  ItemCard(text: 'Counter Advance', icon: Icons.add_box, expand: true, module: CounterAdvance()),
  ItemCard(text: 'Counter Extreme', icon: Icons.add_circle, expand: true, module: CounterExtreme()),
  ItemCard(text: 'Counter Insane', icon: Icons.add_to_photos, expand: true, module: CounterInsane()),
  ItemCard(text: 'Undo / Redo', icon: Icons.refresh, expand: true, module: UndoRedo()),
  ItemCard(text: 'Timer', icon: Icons.timer, expand: true, module: Timer()),
  ItemCard(text: 'Asynchronous', icon: Icons.sync, expand: true, module: Asynchronous()),
];
