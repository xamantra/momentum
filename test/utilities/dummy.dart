import 'package:momentum/momentum.dart';

class DummyService extends MomentumService {
  double sum(double a, double b) {
    return a + b;
  }

  double difference(double a, double b) {
    return getService<DummyService2>().difference(a, b);
  }
}

class DummyService2 extends MomentumService {
  double difference(double a, double b) {
    return a - b;
  }

  double sum(double a, double b) {
    return getService<DummyService>().sum(a, b);
  }
}

class DummyObject {
  final int value;

  DummyObject(
    this.value,
  );
}
