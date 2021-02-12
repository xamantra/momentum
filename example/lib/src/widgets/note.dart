import 'package:flutter/material.dart';
import 'package:relative_scale/relative_scale.dart';

class Note extends StatelessWidget {
  const Note({
    Key key,
    @required this.note,
  }) : super(key: key);

  final String note;

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
      builder: (context, height, width, sy, sx) {
        return Container(
          margin: EdgeInsets.all(sy(8)),
          padding: EdgeInsets.all(sy(6)),
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            note,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: sy(9),
            ),
          ),
        );
      },
    );
  }
}
