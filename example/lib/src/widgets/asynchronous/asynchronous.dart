import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../../momentum/asynchronous/index.dart';
import '../../plugins/auto_size_text/auto_size_text.dart';

class Asynchronous extends StatelessWidget {
  const Asynchronous({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Momentum Asynchronous"),
        actions: [],
      ),
      body: MomentumBuilder(
        controllers: [AsynchronousController],
        builder: (context, snapshot) {
          var asynch = snapshot<AsynchronousModel>();
          var hasUser = asynch.user != null;

          if (asynch.loadingUser) {
            return Center(
              child: SizedBox(
                height: 36,
                width: 36,
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                !hasUser
                    ? SizedBox()
                    : AutoSizeText(
                        'Username: "${asynch.user.username}"',
                        style: TextStyle(fontSize: 24, color: Colors.black87),
                        maxLines: 1,
                        minFontSize: 1,
                      ),
                !hasUser
                    ? SizedBox()
                    : AutoSizeText(
                        'Email: "${asynch.user.email}"',
                        style: TextStyle(fontSize: 24, color: Colors.black87),
                        maxLines: 1,
                        minFontSize: 1,
                      ),
                RaisedButton(
                  onPressed: () {
                    asynch.controller.loadUser();
                  },
                  color: Color(0xff54C5F8),
                  child: AutoSizeText(
                    'Load User',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    maxLines: 1,
                    minFontSize: 1,
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    asynch.controller.reset();
                  },
                  color: Colors.red,
                  child: AutoSizeText(
                    'Reset',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    maxLines: 1,
                    minFontSize: 1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
