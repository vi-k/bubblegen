import 'package:flutter/material.dart';

import 'Generator.dart';
import 'bubble.dart';

class BubbleDemo extends StatefulWidget {
  BubbleDemo({Key key}) : super(key: key);

  @override
  _BubbleDemoState createState() => _BubbleDemoState();
}

class _BubbleDemoState extends State<BubbleDemo> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  static const _words = ['Lorem', ' ipsum', ' dolor', ' sit', ' amet', ', consectetur', ' adipiscing', ' elit', ', sed', ' do eiusmod', ' tempor', ' incididunt', ' ut', ' labore', ' et', ' dolore', ' magna', ' aliqua.'];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    print('build $this');

    return Container(
      color: Colors.grey[300],
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          var text = StringBuffer();

          for (var i = 0; i < index % (_words.length - 1) + 1; i++) {
            text.write(_words[i]);
          }

          return Padding(
            padding: EdgeInsets.only(top: 6.0, bottom: 6.0, left: index % 2 == 0 ? 8.0 : 64.0, right: index % 2 == 0 ? 64.0 : 8.0),
            child: Padding(
              padding: Generator.style.inverse ? EdgeInsets.only(bottom: Generator.style.additionalPadding) : EdgeInsets.only(top: Generator.style.additionalPadding),
              child: Align(
                alignment: index % 2 == 0 ? Alignment.topLeft : Alignment.topRight,
                child: Bubble(
                  style: Generator.style.style.copyWith(
                    nipSide: index % 2 == 0 ? NipSide.left : NipSide.right,
                    color: index % 2 == 0 ? Colors.white : Colors.lightGreen[100],
                  ),
                  topLine: Generator.style.topLine,
                  bottomLine: Generator.style.bottomLine,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
//                      child: Text('${text.toString()} (#${index + 1})'),
                    child: RichText(
                      text: TextSpan(
                        text: text.toString(),
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                            text: '   #${index + 1}',
                            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 10.0, fontStyle: FontStyle.italic)
                          )
                        ]
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
