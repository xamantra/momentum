import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:relative_scale/relative_scale.dart';

import '../../../components/calculator-example/index.dart';

class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    Key key,
    @required this.exp,
    this.callback,
  }) : super(key: key);

  final String exp;
  final void Function(CalculatorExampleController) callback;

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
      builder: (context, height, width, sy, sx) {
        return Container(
          height: height,
          width: width,
          child: TextButton(
            onPressed: () {
              var controller = Momentum.controller<CalculatorExampleController>(context);
              if (callback != null) {
                callback(controller);
              } else {
                controller.appendExpression(exp);
                controller.calculateResult();
              }
            },
            child: Center(
              child: Text(
                exp,
                style: TextStyle(
                  fontSize: sy(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
