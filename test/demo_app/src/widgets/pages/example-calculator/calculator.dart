import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:relative_scale/relative_scale.dart';

import '../../../components/calculator-example/index.dart';
import 'index.dart';

class CalculatorExamplePage extends StatelessWidget {
  const CalculatorExamplePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
      builder: (context, height, width, sy, sx) {
        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              'Calculator Example',
              style: TextStyle(
                fontSize: sy(11.5),
              ),
            ),
          ),
          body: Container(
            height: height,
            width: width,
            child: Column(
              children: [
                Expanded(
                  flex: 20,
                  child: MomentumBuilder(
                    controllers: [CalculatorExampleController],
                    builder: (context, snapshot) {
                      var calculatorModel = snapshot<CalculatorExampleModel>();
                      return Container(
                        height: height,
                        width: width,
                        color: Color(0xff282C34),
                        padding: EdgeInsets.all(sy(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  calculatorModel.expression,
                                  style: TextStyle(
                                    fontSize: sy(16),
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  calculatorModel.result,
                                  style: TextStyle(
                                    fontSize: sy(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 80,
                  child: Container(
                    color: Color(0xff21252B),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: CalculatorButton(
                                  exp: '<',
                                  callback: (controller) {
                                    controller.backspace();
                                  },
                                ),
                              ),
                              Expanded(
                                child: CalculatorButton(
                                  exp: 'Clear',
                                  callback: (controller) {
                                    controller.clear();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: CalculatorButtonRow(exps: ['7', '8', '9'])),
                        Expanded(child: CalculatorButtonRow(exps: ['4', '5', '6'])),
                        Expanded(child: CalculatorButtonRow(exps: ['1', '2', '3'])),
                        Expanded(child: CalculatorButtonRow(exps: ['0', '.'])),
                        Expanded(child: CalculatorButtonRow(exps: ['+', '-', '*', '/'])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
