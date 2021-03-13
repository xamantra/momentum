import 'package:flutter/material.dart';

import 'index.dart';

class CalculatorButtonRow extends StatelessWidget {
  const CalculatorButtonRow({
    Key key,
    @required this.exps,
  }) : super(key: key);

  final List<String> exps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: exps
          .map(
            (exp) => Expanded(
              child: CalculatorButton(exp: exp),
            ),
          )
          .toList(),
    );
  }
}
