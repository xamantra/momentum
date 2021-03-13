import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../../../demo_app/components/calculator-example/index.dart';
import '../../utils.dart';

void main() {
  test('<CalculatorExampleController> component test', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [
          CalculatorExampleController(),
        ],
      ),
    );
    await tester.init();

    var controller = tester.controller<CalculatorExampleController>()!;
    isControllerValid<CalculatorExampleController>(controller);
    isModelValid<CalculatorExampleModel>(controller.model);

    controller.writeExpression('1+5');
    expect(controller.model.expression, '1+5');
    controller.calculateResult();
    expect(controller.model.result, '6');

    controller.writeExpression('2+4.1');
    expect(controller.model.expression, '2+4.1');
    controller.calculateResult();
    expect(controller.model.result, '6.1');

    controller.writeExpression('6/2+1-5');
    expect(controller.model.expression, '6/2+1-5');
    controller.calculateResult();
    expect(controller.model.result, '-1');

    controller.writeExpression('42+++323dd');
    expect(controller.model.expression, '42+++323dd');
    controller.calculateResult();
    expect(controller.model.result, 'invalid');

    controller.clear();
    expect(controller.model.result, '');
    expect(controller.model.expression, '');

    controller.appendExpression('7');
    controller.appendExpression('-');
    controller.appendExpression('8');
    expect(controller.model.expression, '7-8');
    controller.calculateResult();
    expect(controller.model.result, '-1');
    controller.backspace();
    controller.backspace();
    controller.backspace();
    expect(controller.model.expression, '');
  });
}
