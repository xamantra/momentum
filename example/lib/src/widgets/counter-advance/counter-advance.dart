import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import '../../../src/momentum/counter-advance/counter-advance.controller.dart';
import '../../../src/momentum/counter-advance/counter-advance.model.dart';

/* Lets take counter to the next level. Now with action switch between increment and decrement plus time travel feature (undo/redo). */

class CounterAdvance extends StatefulWidget {
  @override
  _CounterAdvanceState createState() => _CounterAdvanceState();
}

class _CounterAdvanceState extends State<CounterAdvance> {
  CounterAdvanceController counterAdvanceController;
  @override
  Widget build(BuildContext context) {
    counterAdvanceController ??= Momentum.of<CounterAdvanceController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Counter Advance"),
        actions: [
          IconButton(icon: Icon(Icons.autorenew), onPressed: counterAdvanceController.toggleAction),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'A lucky number:',
            ),
            MomentumBuilder(
              controllers: [CounterAdvanceController],
              builder: (context, snapshot) {
                var counterAdvance = snapshot<CounterAdvanceModel>();
                return Text(
                  '${counterAdvance.value}',
                  style: Theme.of(context).textTheme.display1,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: MomentumBuilder(
        controllers: [CounterAdvanceController],
        builder: (context, snapshot) {
          var counterAdvance = snapshot<CounterAdvanceModel>();
          var iconData = counterAdvance.action == CounterAdvanceAction.Increment ? Icons.add : Icons.remove;
          var color = counterAdvance.action == CounterAdvanceAction.Increment ? Colors.blue : Colors.red;
          return FloatingActionButton(
            onPressed: counterAdvanceController.dispatchAction,
            tooltip: counterAdvance.action.toString(),
            child: Icon(iconData),
            backgroundColor: color,
          );
        },
      ),
    );
  }
}
