import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Generator.dart';
import 'Profiler.dart';
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
      child: Stack(
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              // print('itemBuilder: #$index');
              var text = StringBuffer();

              for (var i = 0; i < index % (_words.length - 1) + 1; i++) {
                text.write(_words[i]);
              }

              return Padding(
                padding: EdgeInsets.only(
                  top: 6.0 + (Generator.settings.inverse ? 0.0 : Generator.settings.additionalPadding),
                  bottom: 6.0 + (Generator.settings.inverse ? Generator.settings.additionalPadding : 0.0),
                  left: index % 2 == 0 ? 8.0 : 64.0,
                  right: index % 2 == 0 ? 64.0 : 8.0,
                ),
                child: Align(
                  alignment: index % 2 == 0 ? Alignment.topLeft : Alignment.topRight,
                  child: Bubble(
                    style: Generator.settings.style.copyWith(
                      nipSide: index % 2 == 0 ? NipSide.left : NipSide.right,
                      color: index % 2 == 0 ? Colors.white : Colors.lightGreen[100],
                    ),
                    topLine: Generator.settings.topLine,
                    bottomLine: Generator.settings.bottomLine,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
//                      child: Text('${text.toString()} (#${index + 1})'),
                      child: RichText(
                        textWidthBasis: TextWidthBasis.longestLine,
                        text: TextSpan(
                          text: text.toString(),
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: '   #${index + 1}',
                              style: DefaultTextStyle.of(context).style.copyWith(
                                color: Colors.black.withAlpha(64),
                                fontSize: 10.0,
                                fontStyle: FontStyle.italic,
                              )
                            ),
//                        WidgetSpan(
//                          alignment: PlaceholderAlignment.bottom,
//                          baseline: TextBaseline.alphabetic,
//                          style: DefaultTextStyle.of(context).style.copyWith(
//                            fontSize: 10.0,
//                            fontStyle: FontStyle.italic,
//                            height: 1,
//                          ),
//                          child: Text(
//                            '   #${index + 1}',
////                            style: DefaultTextStyle.of(context).style.copyWith(
////                              fontSize: 10.0,
////                              fontStyle: FontStyle.italic,
////                              height: 1,
////                            )
//                          )
//                        )
                          ]
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Profiler(),
        ],
      ),
    );
  }
}
