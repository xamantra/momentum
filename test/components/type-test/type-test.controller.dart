import 'package:momentum/momentum.dart';

import 'index.dart';

abstract class TypeTestController extends MomentumController<TypeTestModel> {
  void increment() {
    model.update(value: model.value + 1);
  }

  void decrement() {
    model.update(value: model.value - 1);
  }
}

// ignore: lines_longer_than_80_chars
class TypeTestAController extends TypeTestController with TypeTestMixinController {
  @override
  TypeTestModel init() {
    return TypeTestModel(this, value: 0);
  }

  void multiplyBy(int multiplier) {
    model.update(value: (model.value * multiplier).toInt());
  }
}

// ignore: lines_longer_than_80_chars
class TypeTestBController extends TypeTestController with TypeTestMixinController {
  @override
  TypeTestModel init() {
    return TypeTestModel(this, value: 0);
  }

  void divideBy(int divisor) {
    model.update(value: model.value ~/ divisor);
  }
}

mixin TypeTestMixinController on TypeTestController {
  bool isOdd() {
    var rem = model.value % 2;
    return model.value == 1 || rem != 0;
  }
}

// ignore: lines_longer_than_80_chars
class ImplementsTypeController extends TypeTestController implements TypeTestAController, TypeTestBController {
  @override
  TypeTestModel init() {
    return TypeTestModel(
      this,
      value: 0,
    );
  }

  @override
  bool isOdd() {
    return (model.value % 2) == 0;
  }

  void multiplyBy(int multiplier) {
    model.update(value: model.value * multiplier);
  }

  @override
  void divideBy(int divisor) {
    model.update(value: model.value ~/ divisor);
  }
}
