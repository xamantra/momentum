import 'dart:math';

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
class ATypeTestController extends TypeTestController with TypeTestMixinController {
  @override
  TypeTestModel init() {
    return TypeTestModel(this, value: 0);
  }

  void multiplyBy(int multiplier) {
    model.update(value: (model.value * multiplier).toInt());
  }
}

// ignore: lines_longer_than_80_chars
class BTypeTestController extends TypeTestController with TypeTestMixinController {
  @override
  TypeTestModel init() {
    return TypeTestModel(
      this,
      value: 0,
    );
  }

  void divideBy(int divisor) {
    model.update(value: model.value ~/ divisor);
  }
}

class CTypeTestController extends BTypeTestController {
  @override
  TypeTestModel init() {
    return TypeTestModel(
      this,
      value: 0,
      squareRoot: 0,
    );
  }

  void square() {
    model.update(squareRoot: (sqrt(model.value)).round());
  }
}

mixin TypeTestMixinController on TypeTestController {
  bool isOdd() {
    var rem = model.value % 2;
    return model.value == 1 || rem != 0;
  }
}

// ignore: lines_longer_than_80_chars
class ImplementsABTypeController extends TypeTestController implements ATypeTestController, BTypeTestController {
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
