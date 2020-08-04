import 'package:momentum/momentum.dart';

class DummyService extends MomentumService {
  double sum(double a, double b) {
    return a + b;
  }
}

class DummyObject {
  final int value;

  DummyObject(
    this.value,
  );
}
