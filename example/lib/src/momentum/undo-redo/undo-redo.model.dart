import 'package:momentum/momentum.dart';

import 'undo-redo.controller.dart';

class UndoRedoModel extends MomentumModel<UndoRedoController> {
  UndoRedoModel(
    UndoRedoController controller, {
    this.firstName,
    this.lastName,
    this.gender,
  }) : super(controller);

  final String firstName;
  final String lastName;
  final Gender gender;

  @override
  void update({
    String firstName,
    String lastName,
    Gender gender,
  }) {
    UndoRedoModel(
      controller,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
    ).updateMomentum();
  }
}

enum Gender { Male, Female }
