import 'package:math_expressions/math_expressions.dart';
import 'package:momentum/momentum.dart';

import '../../_config/index.dart';
import 'index.dart';

class CalculatorExampleController extends MomentumController<CalculatorExampleModel> {
  @override
  CalculatorExampleModel init() {
    return CalculatorExampleModel(
      this,
      expression: '',
      result: '',
    );
  }

  void writeExpression(String exp) {
    model.update(expression: exp);
  }

  void appendExpression(String character) {
    model.update(expression: model.expression + character);
  }

  void backspace() {
    var exp = model.expression;
    model.update(expression: exp.substring(0, exp.length - 1));
    calculateResult();
  }

  void clear() {
    model.update(expression: '', result: '');
  }

  void calculateResult() {
    try {
      var exp = parser.parse(model.expression);
      var result = exp.evaluate(EvaluationType.REAL, ContextModel());
      var simplified = _normalizeDecimal(result.toString());
      if (simplified == model.expression) {
        model.update(result: '');
        return;
      }
      model.update(result: simplified);
    } catch (e) {
      print(e);
      model.update(result: 'invalid');
    }
  }

  String _normalizeDecimal(String result) {
    var d = double.parse(result);
    var i = d.round();
    if (i == d) {
      return i.toString();
    }
    return d.toString();
  }
}
