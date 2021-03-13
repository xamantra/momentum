import 'package:momentum/momentum.dart';

import '../services/index.dart';
import 'index.dart';

List<MomentumService> services() {
  return [
    ApiService(),
    MomentumRouter(routes),
  ];
}
