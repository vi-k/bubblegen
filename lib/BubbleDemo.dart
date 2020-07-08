import 'package:flutter/cupertino.dart';
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

  AnimationController _animationController;

  @override
  bool get wantKeepAlive => true;

  var _frames = <int>[];
  var _fps = 0;
  var _animate = false;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 2000),
        animationBehavior: AnimationBehavior.normal,
    );
    _animationController.repeat();
    _animationController.addListener(() {
      var timestamp = DateTime.now().microsecondsSinceEpoch;
      var startTimestamp = timestamp - 2000000; // 1 сек
      _frames.removeWhere((time) => time < startTimestamp);
      final count = _frames.length;
      final duration = _frames.length > 0 ? timestamp - _frames[0] : 0;
      _frames.add(timestamp);
      _fps = duration == 0 ? 0 : count * 1000000.0 ~/ duration;
    });
    super.initState();
  }

  Widget _getBubble({@required int index, double animationValue, @required String suffix}) {
    var text = StringBuffer();
    for (var i = 0; i < index % (_words.length - 1) + 1; i++) {
      text.write(_words[i]);
    }

    return Bubble(
      style: Generator.settings.style.copyWith(
//        nipSide: index % 2 == 0 ? NipSide.left : NipSide.right,
//        nipPlaceholderSize: Generator.settings.style.nipSize,
//        nipSize: Generator.settings.style.nipSize - (animationValue != null ? animationValue * Generator.settings.style.nipSize : 0),
//        strokeWidth: animationValue != null ? animationValue * 2.0 : Generator.settings.style.strokeWidth,
//        elevation: Generator.settings.style.elevation + (animationValue != null ? animationValue * 4.0 : 0.0),
        color: index % 2 == 0 ? Colors.white : Colors.lightGreen[100],
      ),
      nip: Generator.settings.nip.copyWith(
          size: Generator.settings.nip.size - (animationValue != null ? animationValue * Generator.settings.nip.size : 0)
      ),
      topLine: Generator.settings.topLine,
      bottomLine: Generator.settings.bottomLine,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${text.toString()}$suffix',
              textWidthBasis: TextWidthBasis.longestLine,
            ),
//                      child: RichText(
//                        textWidthBasis: TextWidthBasis.longestLine,
//                        text: TextSpan(
//                          text: text.toString(),
//                          style: DefaultTextStyle.of(context).style,
//                          children: [
//                            TextSpan(
//                              text: '   #${index + 1}',
//                              style: DefaultTextStyle.of(context).style.copyWith(
//                                color: Colors.black.withAlpha(64),
//                                fontSize: 10.0,
//                                fontStyle: FontStyle.italic,
//                              )
//                            ),
////                        WidgetSpan(
////                          alignment: PlaceholderAlignment.bottom,
////                          baseline: TextBaseline.alphabetic,
////                          style: DefaultTextStyle.of(context).style.copyWith(
////                            fontSize: 10.0,
////                            fontStyle: FontStyle.italic,
////                            height: 1,
////                          ),
////                          child: Text(
////                            '   #${index + 1}',
//////                            style: DefaultTextStyle.of(context).style.copyWith(
//////                              fontSize: 10.0,
//////                              fontStyle: FontStyle.italic,
//////                              height: 1,
//////                            )
////                          )
////                        )
//                          ]
//                        ),
//                      ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                  TimeOfDay(hour: index ~/ 60, minute: index % 60).format(context),
                  style: DefaultTextStyle.of(context).style.copyWith(
                    color: Colors.black.withAlpha(64),
                    fontSize: 10.0,
                    fontStyle: FontStyle.italic,
                  )
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    print('build $this');
//    final animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    final animation = TweenSequence([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 1.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 1.0,
      ),
    ]).animate(_animationController);

    final suffix = ' ' * (5 + TimeOfDay(hour: 23, minute: 59).format(context).length);

    return Container(
      color: Colors.grey[300],
      child: Stack(
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
//              print('itemBuilder: #$index');
              return Padding(
                padding: EdgeInsets.only(
                  top: 6.0 + (Generator.settings.hFlip ? 0.0 : Generator.settings.additionalPadding),
                  bottom: 6.0 + (Generator.settings.hFlip ? Generator.settings.additionalPadding : 0.0),
                  left: index % 2 == 0 ? 8.0 : 64.0,
                  right: index % 2 == 0 ? 64.0 : 8.0,
                ),
                child: Align(
                  alignment: index % 2 == 0 ? Alignment.topLeft : Alignment.topRight,
                  child: _animate
                      ? AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return _getBubble(index: index, animationValue: animation.value, suffix: suffix);
                          }
                        )
                      : _getBubble(index: index, suffix: suffix),
                ),
              );
            },
          ),
//          Profiler(),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return RaisedButton.icon(
                    onPressed: () {
                      setState(() {
                        _animate = !_animate;
                      });
                    },
                    color: _animate ? Colors.orange : Colors.lightGreen,
                    icon: _animate ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
                    label: Text('$_fps fps')
                  );
                }
              ),
            )
          ),
        ],
      ),
    );
  }
}
