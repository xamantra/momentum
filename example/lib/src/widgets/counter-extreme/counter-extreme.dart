import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import '../../../src/momentum/counter-extreme/counter-extreme.controller.dart';
import '../../../src/momentum/counter-extreme/counter-extreme.model.dart';
import '../../../src/widgets/counter-extreme/widgets/counter-extreme.item.dart';

class CounterExtreme extends StatefulWidget {
  @override
  _CounterExtremeState createState() => _CounterExtremeState();
}

class _CounterExtremeState extends State<CounterExtreme> {
  CounterExtremeController _counterExtremeController;

  @override
  Widget build(BuildContext context) {
    _counterExtremeController = Momentum.of<CounterExtremeController>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Counter Extreme")),
      body: Container(
        padding: EdgeInsets.all(12),
        child: MomentumBuilder(
          controllers: [CounterExtremeController],
          builder: (context, snapshot) {
            var counterExtreme = snapshot<CounterExtremeModel>();
            return ListView.builder(
              itemCount: counterExtreme.items.length,
              itemBuilder: (context, index) {
                return CounterExtremeItem(
                  item: counterExtreme.items[index],
                  onAction: () => _counterExtremeController.dispatchAction(index),
                  onToggle: () => _counterExtremeController.toggleAction(index),
                  onRename: (name) => _counterExtremeController.setName(name, index),
                  onRemove: () => _counterExtremeController.removeItem(index),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _counterExtremeController.addItem,
        heroTag: '$this#1',
      ),
    );
  }
}
