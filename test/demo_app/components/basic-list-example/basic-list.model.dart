import 'package:momentum/momentum.dart';

import 'index.dart';

class BasicListExampleModel extends MomentumModel<BasicListExampleController> {
  BasicListExampleModel(
    BasicListExampleController controller, {
    this.list,
  }) : super(controller);

  final List<String>? list;

  @override
  void update({List<String>? list}) {
    BasicListExampleModel(
      controller,
      list: list ?? this.list,
    ).updateMomentum();
  }
}
