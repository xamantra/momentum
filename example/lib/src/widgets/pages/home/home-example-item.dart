import 'package:flutter/material.dart';
import 'package:relative_scale/relative_scale.dart';

class ExampleItem extends StatelessWidget {
  const ExampleItem({
    Key key,
    @required this.name,
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
      builder: (context, height, width, sy, sx) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: sy(8), vertical: sy(4)),
          height: sy(42),
          width: width,
          decoration: BoxDecoration(
            color: Color(0xff333333),
            borderRadius: BorderRadius.circular(5),
          ),
          child: FlatButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
            onPressed: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: sy(8), vertical: sy(4)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: sy(12),
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(width: sy(8)),
                  Icon(
                    Icons.chevron_right,
                    size: sy(18),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
