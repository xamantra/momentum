import 'package:momentum/momentum.dart';

class BasicListService extends MomentumService {
  String addFrom(String name, String age) {
    return '$name - $age';
  }
}
