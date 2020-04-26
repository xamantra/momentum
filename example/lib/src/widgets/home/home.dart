import 'package:flutter/material.dart';
import '../../../src/widgets/home/widgets/item-card.dart';

import 'modules.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Momentum Demo")),
      body: Container(
        padding: EdgeInsets.all(18),
        color: Colors.white,
        child: _buildRows(modules),
      ),
    );
  }

  Widget _buildRows(List<ItemCard> modules) {
    var columnChildrens = <Widget>[];
    for (var i = 0; i < modules.length; i++) {
      if (i != 0 && (i + 1) % 2 == 0) {
        columnChildrens.add(_buildRow([modules[i - 1], modules[i]]));
      } else if (i == modules.length - 1) {
        columnChildrens.add(_buildRow([modules[i], Spacer()]));
      }
    }
    return Column(children: columnChildrens);
  }

  Widget _buildRow(List<Widget> pair) {
    return Row(children: pair.map((x) => x).toList());
  }
}
