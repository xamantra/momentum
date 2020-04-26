import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../src/momentum/counter-advance/counter-advance.model.dart';
import '../../../../src/momentum/counter-insane/counter-insane.model.dart';

import 'counter-insane.edit-name.dart';

class CounterInsaneItem extends StatelessWidget {
  final CounterItem item;
  final void Function() onAction;
  final void Function() onToggle;
  final bool Function(String) onRename;
  final void Function() onRemove;

  CounterInsaneItem({
    Key key,
    @required this.item,
    @required this.onAction,
    @required this.onToggle,
    @required this.onRename,
    @required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var color = item.action == CounterAdvanceAction.Increment ? Colors.blue : Colors.red;
    var iconData = item.action == CounterAdvanceAction.Increment ? Icons.add : Icons.remove;

    return Card(
      child: InkWell(
        onTap: () {},
        child: Container(
          height: 72,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${item.value}', style: TextStyle(fontSize: 32, color: color)),
              SizedBox(width: 8),
              Text('${item.name}', style: TextStyle(fontSize: 24, color: Colors.black.withOpacity(0.7))),
              Spacer(),
              FloatingActionButton(
                mini: true,
                tooltip: 'Perform Action',
                child: Icon(iconData, size: 24, color: Colors.white),
                backgroundColor: color,
                onPressed: onAction,
                heroTag: '$this#${next(0, 100000)}',
              ),
              FloatingActionButton(
                mini: true,
                tooltip: 'Toggle Action',
                child: Icon(Icons.autorenew, size: 24),
                onPressed: onToggle,
                backgroundColor: Colors.teal,
                heroTag: '$this#${next(100001, 200000)}',
              ),
              FloatingActionButton(
                mini: true,
                tooltip: 'Rename',
                child: Icon(Icons.edit, size: 24, color: Colors.white),
                backgroundColor: Colors.pink,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CounterInsaneEditName(item: item, onSubmit: onRename),
                  );
                },
                heroTag: '$this#${next(200001, 300000)}',
              ),
              FloatingActionButton(
                mini: true,
                tooltip: 'Remove',
                child: Icon(Icons.close, size: 24),
                onPressed: onRemove,
                backgroundColor: Colors.purpleAccent,
                heroTag: '$this#${next(300000, 400001)}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* playing dirty with FloatingActionButton's heroTag :) */
  final _random = new Random();
  int next(int min, int max) => min + _random.nextInt(max - min);
}
