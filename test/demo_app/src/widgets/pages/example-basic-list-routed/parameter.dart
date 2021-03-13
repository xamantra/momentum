import 'package:momentum/momentum.dart';

class BasicListRouteParam extends RouterParam {
  BasicListRouteParam(this.initialList);

  final List<String> initialList;
}

class DummyRouteParam extends RouterParam {}
