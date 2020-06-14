import 'dart:math';

import 'package:momentum/momentum.dart';

import 'index.dart';

abstract class TypesTestCtrl extends MomentumController<ATypesTestModel> {
  void increment() {
    model.update(value: model.value + 1);
  }

  void decrement() {
    model.update(value: model.value - 1);
  }
}

class ATypesTestCtrl extends TypesTestCtrl with TypesTestMixinCtrl {
  @override
  ATypesTestModel init() {
    return ATypesTestModel(
      this,
      value: 0,
    );
  }

  void multiplyBy(int multiplier) {
    model.update(value: (model.value * multiplier).toInt());
  }
}

class BTypesTestCtrl extends TypesTestCtrl with TypesTestMixinCtrl {
  @override
  ATypesTestModel init() {
    return ATypesTestModel(
      this,
      value: 0,
    );
  }

  void divideBy(int divisor) {
    model.update(value: model.value ~/ divisor);
  }
}

class CTypesTestCtrl extends BTypesTestCtrl {
  @override
  ATypesTestModel init() {
    return ATypesTestModel(
      this,
      value: 0,
      square: 0,
    );
  }

  void add(int value) {
    model.update(value: model.value + value);
  }

  void square() {
    model.update(square: (sqrt(model.value)).round());
  }
}

mixin TypesTestMixinCtrl on TypesTestCtrl {
  bool isOdd() {
    var rem = model.value % 2;
    return model.value == 1 || rem != 0;
  }
}

// ignore: lines_longer_than_80_chars
class ImplementsABCTypesCtrl extends TypesTestCtrl with TypesTestMixinCtrl implements ATypesTestCtrl, BTypesTestCtrl, CTypesTestCtrl {
  @override
  ATypesTestModel init() {
    return ATypesTestModel(
      this,
      value: 10,
      square: 4,
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

  @override
  void square() {
    model.update(square: (sqrt(model.value)).round());
  }

  @override
  void add(int value) {
    model.update(value: model.value + value);
  }
}
