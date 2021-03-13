import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

void isControllerValid<T extends MomentumController>(dynamic controller) {
  expect(controller != null, true);
  expect(controller, isInstanceOf<T>());
}

void isModelValid<T extends MomentumModel>(dynamic model) {
  expect(model != null, true);
  expect(model, isInstanceOf<T>());
}
