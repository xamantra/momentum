import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import '../../../src/momentum/timer/timer.controller.dart';
import '../../../src/momentum/timer/timer.model.dart';
import '../../../src/plugins/auto_size_text/auto_size_text.dart';

class Timer extends StatelessWidget {
  const Timer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var timerController = Momentum.of<TimerController>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Timer")),
      body: Container(
        padding: EdgeInsets.all(18),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(24),
                child: AutoSizeText(
                  timerController.getLabel(),
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black.withOpacity(0.85),
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  minFontSize: 1,
                ),
              ),
              MomentumBuilder(
                controllers: [TimerController],
                builder: (context, snapshot) {
                  var timer = snapshot<TimerModel>();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Spacer(),
                      Expanded(
                        child: AutoSizeText(
                          timer.hours.toString(),
                          style: TextStyle(
                            fontSize: 75,
                            color: Colors.black.withOpacity(0.85),
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          timer.minutes.toString(),
                          style: TextStyle(
                            fontSize: 60,
                            color: Colors.black.withOpacity(0.70),
                            height: 1.25,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          timer.seconds.toString(),
                          style: TextStyle(
                            fontSize: 45,
                            color: Colors.black.withOpacity(0.55),
                            height: 1.666666666666667,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          timer.microseconds.toString(),
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black.withOpacity(0.40),
                            height: 2.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Spacer(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
