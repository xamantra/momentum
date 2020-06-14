import 'package:momentum/momentum.dart';

import 'index.dart';

class DropdownModel extends MomentumModel<DropdownController> {
  DropdownModel(
    DropdownController controller, {
    this.gender,
  }) : super(controller);

  final Gender gender;

  @override
  void update({
    Gender gender,
  }) {
    DropdownModel(
      controller,
      gender: gender ?? this.gender,
    ).updateMomentum();
  }
}

enum Gender { male, female, other }
