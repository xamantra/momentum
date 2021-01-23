import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:relative_scale/relative_scale.dart';

import '../../../components/timer-example/index.dart';

class TimerExamplePage extends StatelessWidget {
  const TimerExamplePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
      builder: (context, height, width, sy, sx) {
        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              'Momentum - Simple Timer Example',
              style: TextStyle(
                fontSize: sy(11.5),
              ),
            ),
          ),
          body: Center(
            child: MomentumBuilder(
              controllers: [TimerExampleController],
              builder: (context, snapshot) {
                var timerModel = snapshot<TimerExampleModel>();

                if (timerModel.started) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Time Elapsed: ${timerModel.seconds} seconds',
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: sy(15),
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          timerModel.controller.stopTimer();
                        },
                        child: Text(
                          'Stop Timer',
                          style: TextStyle(
                            fontSize: sy(12),
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return FlatButton(
                    onPressed: () {
                      // You can access the `controller` from the `model`. And vice-versa.
                      timerModel.controller.startTimer();
                    },
                    child: Text(
                      'Start Timer',
                      style: TextStyle(
                        fontSize: sy(12),
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
