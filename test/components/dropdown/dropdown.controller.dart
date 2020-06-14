import 'package:momentum/momentum.dart';

import 'index.dart';

class DropdownController extends MomentumController<DropdownModel> {
  @override
  DropdownModel init() {
    return DropdownModel(
      this,
      gender: Gender.other,
    );
  }

  void changeGender(Gender value) {
    model.update(gender: value);
  }
}
