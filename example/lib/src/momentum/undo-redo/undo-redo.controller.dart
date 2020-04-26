import 'package:momentum/momentum.dart';

import 'undo-redo.model.dart';

class UndoRedoController extends MomentumController<UndoRedoModel> {
  @override
  UndoRedoModel init() {
    return UndoRedoModel(
      this,
      firstName: '',
      lastName: '',
      gender: Gender.Male,
    );
  }

  void setFirstname(String firstName) {
    model.update(firstName: firstName ?? '');
  }

  void setLastname(String lastName) {
    model.update(lastName: lastName ?? '');
  }

  void setGender(Gender gender) {
    model.update(gender: gender);
  }
}
