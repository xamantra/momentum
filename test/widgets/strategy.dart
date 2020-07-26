import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/src/momentum_base.dart';

import '../components/strategy/index.dart';

Momentum bootstrapStrategy({
  bool inlineConfig = false,
}) {
  return Momentum(
    child: BootstrapStrategyWidget(),
    controllers: inlineConfig
        ? [
            StrategyController()
              ..config(
                strategy: BootstrapStrategy.lazyFirstCall,
              ),
          ]
        : [
            StrategyController(),
          ],
    strategy: inlineConfig ? null : BootstrapStrategy.lazyFirstCall,
  );
}

class BootstrapStrategyWidget extends StatelessWidget {
  const BootstrapStrategyWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Momentum.controller<StrategyController>(context);
    return MaterialApp(
      title: 'Momentum BootstrapStrategy',
      home: Scaffold(
        body: Center(
          child: MomentumBuilder(
            controllers: [StrategyController],
            builder: (context, snapshot) {
              var model = controller.model;
              if (model.loading) {
                return Column(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    FlatButton(
                      onPressed: controller.stopLoading,
                      child: Text("Stop Loading"),
                    ),
                  ],
                );
              } else {
                return Text('Not Loading');
              }
            },
          ),
        ),
      ),
    );
  }
}
