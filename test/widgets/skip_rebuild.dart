import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';

Momentum skipRebuildWidget() {
  return Momentum(
    child: SkipRebuildWidget(),
    controllers: [CounterController()],
  );
}

class SkipRebuildWidget extends StatelessWidget {
  const SkipRebuildWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: Scaffold(
        body: Center(
          child: MomentumBuilder(
            controllers: [CounterController],
            dontRebuildIf: (controller, _) {
              var counter = controller<CounterController>().model;
              return counter.value == 3;
            },
            builder: (context, snapshot) {
              var counter = snapshot<CounterModel>();
              return Text('${counter.value}');
            },
          ),
        ),
      ),
    );
  }
}
