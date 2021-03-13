import 'package:momentum/src/momentum_base.dart';

class BasicListService extends MomentumService {
  String addFrom(String name, String age) {
    return '$name - $age';
  }
}
