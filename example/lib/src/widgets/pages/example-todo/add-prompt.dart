import 'package:flutter/material.dart';
import 'package:relative_scale/relative_scale.dart';

Future<String> showTodoPrompt(BuildContext context) async {
  var result = await showDialog<String>(
    context: context,
    builder: (_) => _AddTodoPrompt(),
  );
  return result;
}

class _AddTodoPrompt extends StatelessWidget {
  _AddTodoPrompt({Key key}) : super(key: key);

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: RelativeBuilder(
        builder: (context, height, width, sy, sx) {
          return Container(
            width: width,
            padding: EdgeInsets.all(sy(4)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controller,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Todo title here...',
                  ),
                  onFieldSubmitted: (value) {
                    Navigator.pop(context, value);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
