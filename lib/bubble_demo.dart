import 'package:flutter/material.dart';

import 'bubble.dart';
import 'generator.dart';

class BubbleDemo extends StatefulWidget {
  const BubbleDemo({super.key});

  @override
  State<BubbleDemo> createState() => _BubbleDemoState();
}

class _BubbleDemoState extends State<BubbleDemo>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  static const _words = [
    'Lorem',
    ' ipsum',
    ' dolor',
    ' sit',
    ' amet',
    ', consectetur',
    ' adipiscing',
    ' elit',
    ', sed',
    ' do eiusmod',
    ' tempor',
    ' incididunt',
    ' ut',
    ' labore',
    ' et',
    ' dolore',
    ' magna',
    ' aliqua.',
  ];

  late AnimationController _animationController;

  @override
  bool get wantKeepAlive => true;

  final _frames = <int>[];
  var _fps = 0;
  var _animate = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animationController
      ..repeat()
      ..addListener(() {
        final timestamp = DateTime.now().microsecondsSinceEpoch;
        final startTimestamp = timestamp - 2000000; // 1 сек
        _frames.removeWhere((time) => time < startTimestamp);
        final count = _frames.length;
        final duration = _frames.isNotEmpty ? timestamp - _frames[0] : 0;
        _frames.add(timestamp);
        _fps = duration == 0 ? 0 : count * 1000000.0 ~/ duration;
      });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _getBubble({
    required int index,
    double? animationValue,
    required String suffix,
  }) {
    final text = StringBuffer();
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
        color: index.isEven ? Colors.white : Colors.lightGreen[100],
      ),
      nip: Generator.settings.nip.copyWith(
        size: Generator.settings.nip.size -
            (animationValue != null
                ? animationValue * Generator.settings.nip.size
                : 0),
      ),
      topLine: Generator.settings.topLine,
      bottomLine: Generator.settings.bottomLine,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '$text$suffix',
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
              padding: const EdgeInsets.all(4),
              child: Text(
                TimeOfDay(hour: index ~/ 60, minute: index % 60)
                    .format(context),
                style: DefaultTextStyle.of(context).style.copyWith(
                      color: Colors.black.withAlpha(64),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

//    final animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    final animation = TweenSequence([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0, end: 1)
            .chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 1,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1, end: 0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 1,
      ),
    ]).animate(_animationController);

    final suffix = ' ' *
        (5 + const TimeOfDay(hour: 23, minute: 59).format(context).length);

    return Container(
      color: Colors.grey[300],
      child: Stack(
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) =>
//              print('itemBuilder: #$index');
                Padding(
              padding: EdgeInsets.only(
                top: 6.0 +
                    (Generator.settings.hFlip
                        ? 0.0
                        : Generator.settings.additionalPadding),
                bottom: 6.0 +
                    (Generator.settings.hFlip
                        ? Generator.settings.additionalPadding
                        : 0.0),
                left: index.isEven ? 8.0 : 64.0,
                right: index.isEven ? 64.0 : 8.0,
              ),
              child: Align(
                alignment:
                    index.isEven ? Alignment.topLeft : Alignment.topRight,
                child: _animate
                    ? AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) => _getBubble(
                          index: index,
                          animationValue: animation.value,
                          suffix: suffix,
                        ),
                      )
                    : _getBubble(index: index, suffix: suffix),
              ),
            ),
          ),
//          Profiler(),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) => ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _animate = !_animate;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _animate ? Colors.orange : Colors.lightGreen,
                    foregroundColor: Colors.black87,
                  ),
                  icon: _animate
                      ? const Icon(Icons.stop)
                      : const Icon(Icons.play_arrow),
                  label: Text('$_fps fps'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
