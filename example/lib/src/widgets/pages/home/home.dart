import 'package:flutter/material.dart';
import 'package:relative_scale/relative_scale.dart';

import 'index.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
      builder: (context, height, width, sy, sx) {
        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              'Momentum Flutter Demo',
            ),
          ),
          body: Container(
            height: height,
            width: width,
            padding: EdgeInsets.all(sy(8)),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  ExampleItem(
                    name: 'Simple Timer Example',
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
