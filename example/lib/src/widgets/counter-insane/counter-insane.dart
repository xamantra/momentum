import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import '../../../src/momentum/counter-insane/counter-insane.controller.dart';
import '../../../src/momentum/counter-insane/counter-insane.model.dart';
import '../../../src/widgets/counter-insane/widgets/counter-insane.item.dart';

class CounterInsane extends StatefulWidget {
  @override
  _CounterInsaneState createState() => _CounterInsaneState();
}

class _CounterInsaneState extends MomentumState<CounterInsane> {
  CounterInsaneController _counterInsaneController;

  @override
  void initMomentumState() {
    // we can just actually do this on build method, but it's not clean :)
    _counterInsaneController = Momentum.of<CounterInsaneController>(context);
    _counterInsaneController.addListener(
      state: this,
      invoke: (model, isTimeTravel) {
        if (model.counterExceedError) {
          showDialog(context: context, builder: (context) => AlertDialog(title: Text(model.counterExceedMessage)));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Counter Insane"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: _counterInsaneController.backward,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: _counterInsaneController.forward,
            tooltip: 'Redo',
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: MomentumBuilder(
          controllers: [CounterInsaneController],
          builder: (context, snapshot) {
            var counterInsane = snapshot<CounterInsaneModel>();
            return ListView.builder(
              itemCount: counterInsane.items.length,
              itemBuilder: (context, index) {
                return CounterInsaneItem(
                  item: counterInsane.items[index],
                  onAction: () => _counterInsaneController.dispatchAction(index),
                  onToggle: () => _counterInsaneController.toggleAction(index),
                  onRename: (name) => _counterInsaneController.setName(name, index),
                  onRemove: () => _counterInsaneController.removeItem(index),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _counterInsaneController.addItem,
        heroTag: '$this#1',
      ),
    );
  }
}
