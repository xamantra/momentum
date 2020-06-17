import 'package:momentum/momentum.dart';

import '../../utilities/dummy.dart';
import 'index.dart';

class PersistErrorModel extends MomentumModel<PersistErrorController> {
  PersistErrorModel(
    PersistErrorController controller, {
    this.data,
  }) : super(controller);

  final DummyObject data;

  @override
  void update({
    DummyObject data,
  }) {
    PersistErrorModel(
      controller,
      data: data ?? this.data,
    ).updateMomentum();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'data': data,
    };
  }
}
