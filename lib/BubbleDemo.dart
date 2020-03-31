import 'package:flutter/material.dart';

import 'bubble.dart';

class BubbleDemo extends StatefulWidget {
  BubbleDemo({Key key}) : super(key: key);

  @override
  _BubbleDemoState createState() => _BubbleDemoState();
}

class _BubbleDemoState extends State<BubbleDemo> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  // Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
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
        itemBuilder: (BuildContext context, int index) {
          var text = StringBuffer();

          for (var i = 0; i < index % (_words.length - 1) + 1; i++) {
            text.write(_words[i]);
          }

          return Padding(
            padding: EdgeInsets.only(top: 12.0, left: index % 2 == 0 ? 8.0 : 64.0, right: index % 2 == 0 ? 64.0 : 8.0),
            child: Align(
              alignment: index % 2 == 0 ? Alignment.topLeft : Alignment.topRight,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 96.0),
                child: Bubble(
                  radius: BubbleRadius.all(8.0),
                  nipSide: index % 2 == 0 ? NipSide.left : NipSide.right,
                  nipRadius: 0.5,
                  nipSize: 7.0,
//            nipOffset: NipOffset,
                  color: index % 2 == 0 ? Colors.white : Colors.lightGreen[100],
                  elevation: 0.5,
                  topLine: NipLine.line(0.0),
                  bottomLine: NipLine.line(53.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${text.toString()} (#${index + 1})'),
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
