import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import '../../../src/momentum/undo-redo/undo-redo.controller.dart';
import '../../../src/momentum/undo-redo/undo-redo.model.dart';
import '../../../src/plugins/auto_size_text/auto_size_text.dart';

class UndoRedo extends StatefulWidget {
  @override
  _UndoRedoState createState() => _UndoRedoState();
}

class _UndoRedoState extends MomentumState<UndoRedo> {
  UndoRedoController undoRedoController;

  final CustomTextController firstNameInputController = CustomTextController();
  final FocusNode firstNameFocusNode = FocusNode();
  final CustomTextController lastNameInputController = CustomTextController();
  final FocusNode lastNameFocusNode = FocusNode();

  @override
  void initMomentumState() {
    undoRedoController = Momentum.of<UndoRedoController>(context);

    // optional, do only if you want to retain your input values even after disposing this screen, if you come back to this screen, latest values you typed will be restored.
    firstNameInputController.text = undoRedoController.model.firstName;
    lastNameInputController.text = undoRedoController.model.lastName;

    undoRedoController.addListener(
      state: this,
      invoke: (model, isTimeTravel) {
        if (!isTimeTravel) return; // do nothing if this update is not triggered by time travel methods.

        // yeah this looks too much setup just for an undo/redo feature with only 2 textfields.
        // the reason is I want to unfocus all textfields when I'm manipulating the textfield controllers.

        firstNameInputController.text = model.firstName;
        lastNameInputController.text = model.lastName;
        firstNameFocusNode.unfocus();
        lastNameFocusNode.unfocus();
      },
    );
  }

  var textStyle = TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Undo / Redo")),
      body: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildTextField(
              controller: firstNameInputController,
              hint: 'Firstname',
              onChanged: undoRedoController.setFirstname,
              focusNode: firstNameFocusNode,
            ),
            _buildTextField(
              controller: lastNameInputController,
              hint: 'Lastname',
              onChanged: undoRedoController.setLastname,
              focusNode: lastNameFocusNode,
            ),
            MomentumBuilder(
              controllers: [UndoRedoController],
              builder: (context, snapshot) {
                return DropdownButton<Gender>(
                  isExpanded: true,
                  value: snapshot<UndoRedoModel>().gender,
                  items: Gender.values
                      .map(
                        (gender) => DropdownMenuItem(
                          value: gender,
                          child: AutoSizeText(
                            gender.toString().replaceAll('Gender.', ''),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: undoRedoController.setGender,
                );
              },
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 24),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 52,
                      child: RaisedButton(
                        onPressed: undoRedoController.backward,
                        child: AutoSizeText('Undo', style: textStyle),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 52,
                      child: RaisedButton(
                        onPressed: undoRedoController.forward,
                        child: AutoSizeText('Redo', style: textStyle),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController controller,
    String hint,
    Function(String) onChanged,
    FocusNode focusNode,
  }) {
    return TextField(
      controller: controller,
      style: textStyle,
      decoration: InputDecoration(hintText: hint, hintStyle: textStyle),
      onChanged: onChanged,
      focusNode: focusNode,
    );
  }
}

/// A replacement for flutter's default TextEditingController, which is better
/// because when setting the text value using this controller, the cursor will be positioned
/// in the end of the text not start.
class CustomTextController extends TextEditingController {
  @override
  set text(String newText) {
    if (this.text == newText) return;
    value = value.copyWith(
      text: newText,
      selection: TextSelection(baseOffset: newText.length, extentOffset: newText.length),
      composing: TextRange.empty,
    );
  }
}
