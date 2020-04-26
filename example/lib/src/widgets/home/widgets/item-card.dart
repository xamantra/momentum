import 'package:flutter/material.dart';
import '../../../../src/plugins/auto_size_text/auto_size_text.dart';

class ItemCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool expand;
  final Widget module;

  const ItemCard({Key key, this.expand = false, @required this.text, @required this.icon, @required this.module}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var card = Card(
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => module));
        },
        child: Container(
          margin: EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Colors.blue),
              Expanded(
                child: AutoSizeText(
                  text,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black.withOpacity(0.65),
                  ),
                  maxLines: 1,
                  minFontSize: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return expand ? Expanded(child: card) : card;
  }
}
