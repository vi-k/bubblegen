import 'package:flutter/material.dart';

import 'bubble.dart';
import 'custom_bubble.dart';
import 'main.dart';
import 'numeric_field.dart';

class GeneratorBubbleStyle {
  GeneratorBubbleStyle([BubbleStyle style = const BubbleStyle()]) {
    this.style = style;
  }

  double additionalPadding = 0;
  double? height;
  double? width;

  late bool hasOneRadius;
  late BubbleRadius radius;
//  NipSide nipSide;
  late bool hFlip;
  late bool vFlip;
//  double nipRadius;
//  double nipSize;
//  NipOffset nipOffset;
  late Color color;
  late double elevation;
  late Color shadowColor;
  late Color strokeColor;
  late double strokeWidth;

  late Nip nip;

  late NipLine topLine;
  late NipLine bottomLine;

  set style(BubbleStyle style) {
    hasOneRadius = style.radius.hasOneRadius;
    radius = style.radius;
//    nipSide = style.nipSide;
    hFlip = style.hFlip;
    vFlip = style.vFlip;
//    nipRadius = style.nipRadius;
//    nipSize = style.nipSize;
//    nipOffset = style.nipOffset;
    color = style.color;
    elevation = style.elevation;
    shadowColor = style.shadowColor;
    strokeColor = style.strokeColor;
    strokeWidth = style.strokeWidth;
  }

  BubbleStyle get style => BubbleStyle(
        radius: hasOneRadius ? BubbleRadius(all: radius.topLeft) : radius,
//        nipSide: nipSide,
        hFlip: hFlip,
        vFlip: vFlip,
//        nipRadius: nipRadius,
//        nipSize: nipSize,
//        nipOffset: nipOffset,
        color: color,
        elevation: elevation,
        shadowColor: shadowColor,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
      );
}

class Generator extends StatefulWidget {
  const Generator({super.key});

  static final settings = GeneratorBubbleStyle();

  @override
  State<Generator> createState() => _GeneratorState();
}

class _GeneratorState extends State<Generator>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  static const _staticPadding = 20.0;
//  Widget _settings;
  var _showSettings = false;
  static const _settingsWidth = 180.0;
  late AnimationController _settingsController;

//  var _elevation = 0.5;
  var _scale = 6.0;
  var _drawDraft = true;

  // Whatsapp
//  var _radius = 6.0;
//  var _nipSide = NipSide.left;
//  var _inverse = false;
//  var _nipRadius = 1.5;
//  var _nipSize = 7.0;
//  var _nipOffset = NipOffset(absolute: 0.0);
//  var _topLine = NipLine.line(0.0);
  final _topLineValues = [0.0, 0.0, 0.0, -90.0];
//  var _bottomLine = NipLine.line(53.0);
  final _bottomLineValues = [53.0, 6.0, 3.0, -180.0];

  // Telegram
//  var _boxRadius = 12.0;
//  var _nipWidth = 10.0;
//  var _nipRadius = 1.0;
//  var _nipYOffset = 0.0;
//  var _startTopAngle = 0.0;
//  var _finishTopPos = 0.0;
//  var _finishTopAngle = 180.0;
//  var _startBottomAngle = -10.0;
//  var _finishBottomPos = 20.0;
//  var _finishBottomAngle = 90.0;

  // Viber
//  var _radius = 20.0;
//  var _nipSide = NipSide.left;
//  var _nipRadius = 0.0;
//  var _nipSize = 0.0;
//  var _nipOffset = NipOffset();
//  var _topLine = NipLine.lineToCorner(-90);
//  var _bottomLine = NipLine.lineToCorner(-180);

  // Sid chat
//  var _boxRadius = 40.0;
//  var _nipWidth = 6.0;
//  var _nipRadius = 1.0;
//  var _nipYOffset = 0.0;
//  var _startTopAngle = -65.0;
//  var _finishTopPos = -40.0;
//  var _finishTopAngle = 192.0;
//  var _startBottomAngle = -90.0;
//  var _finishBottomPos = -65.0;
//  var _finishBottomAngle = 140.0;

  @override
  void initState() {
    Generator.settings.width = 50.0;
    Generator.settings.height = 50.0;
    Generator.settings.additionalPadding = 0.0;

    Generator.settings.hasOneRadius = true;
    Generator.settings.radius = const BubbleRadius(all: 6);
//    Generator.settings.nipSide = NipSide.left;
    Generator.settings.hFlip = false;
    Generator.settings.vFlip = false;
//    Generator.settings.nipRadius = 1.5;
//    Generator.settings.nipSize = 7.0;
//    Generator.settings.nipOffset = NipOffset();

    Generator.settings.nip = const Nip(
      inset: Inset(
        InsetPos(InsetPosType.topLeft, Position.zero),
        InsetPos(InsetPosType.topLeft, Position(ratio: 1)),
      ),
      size: 7,
      radius: 1.5,
      anchor: NipAnchor.end,
      cornerOffset: CornerOffset.byHeight,
    );

    Generator.settings.topLine = const NipLine.line(0);
    Generator.settings.bottomLine = const NipLine.line(53);

//    _settings = getSettings();

    _settingsController = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 100),
      vsync: this,
    );

    super.initState();
  }

  @override
  void dispose() {
    _settingsController.dispose();
    super.dispose();
  }

  void toggleSettings() {
    _showSettings = !_showSettings;
    (_showSettings
        ? _settingsController.forward
        : _settingsController.reverse)();
  }

  EdgeInsets getAddingPadding(double scale) =>
//    var padding = Generator.settings.additionalPadding * scale;
//    return Generator.settings.nipSide.isHorizontal
//        ? Generator.settings.inverse ? EdgeInsets.only(bottom: padding) : EdgeInsets.only(top: padding)
//        : Generator.settings.inverse ? EdgeInsets.only(right: padding) : EdgeInsets.only(left: padding);
      EdgeInsets.zero;

  Widget getSettings() => Material(
        elevation: 2,
//        color: Colors.lime.shade100.withAlpha(224),
        color: Colors.white.withAlpha(160),
        child: ListView(
          children: <Widget>[
            ExpansionTile(
              title: const Text(
                'View',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: NumericField(
                    caption: 'Draft:',
                    value: _drawDraft ? 1.0 : 0.0,
                    min: 0,
                    max: 1,
                    step: 1,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      setState(() {
                        _drawDraft = value == 1.0;
                      });
                    },
                    onConvertToText: (value) => value == 1.0 ? 'show' : 'hide',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: NumericField(
                    caption: 'Scale:',
                    value: _scale,
                    units: 'x',
                    min: 1,
                    max: 32,
                    step: 1,
                    onChanged: (value) {
                      setState(() {
                        _scale = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: NumericField(
                    caption: 'Additional padding:',
                    value: Generator.settings.additionalPadding,
                    units: 'px',
                    min: 0,
                    step: 1,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.additionalPadding = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text(
                'style',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: <Widget>[
//          Padding(
//            padding: const EdgeInsets.all(4.0),
//            child: Value(
//              caption: 'Height:',
//              value: _height,
//              units: 'px',
//              min: 10.0,
//              //max: 200,
//              step: 1.0,
//              onChanged: (double value) {
//                setState(() {
//                  _height = value;
//                });
//              },
//            ),
//          ),
//          Padding(
//            padding: const EdgeInsets.symmetric(horizontal: 4.0),
//            child: Value(
//              caption: 'Width:',
//              value: _width,
//              units: 'px',
//              min: 10.0,
//              step: 1.0,
//              onChanged: (double value) {
//                setState(() {
//                  _width = value;
//                });
//              },
//            ),
//          ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'hasOneRadius:',
                    value: Generator.settings.hasOneRadius ? 1.0 : 0.0,
                    units: '',
                    min: 0,
                    max: 1,
                    step: 1,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.hasOneRadius = value == 1.0;
                      });
                    },
                    onConvertToText: (value) => value == 1.0 ? 'true' : 'false',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: Generator.settings.hasOneRadius
                        ? 'radius:'
                        : 'radius.topLeft:',
                    value: Generator.settings.radius.topLeft,
                    units: 'px',
                    min: 0,
                    step: 1,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.radius =
                            Generator.settings.hasOneRadius
                                ? BubbleRadius(all: value)
                                : Generator.settings.radius
                                    .copyWith(topLeft: value);
                      });
                    },
                  ),
                ),
                Visibility(
                  visible: !Generator.settings.hasOneRadius,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: NumericField(
                      caption: 'radius.topRight:',
                      value: Generator.settings.radius.topRight,
                      units: 'px',
                      min: 0,
                      step: 1,
                      onChanged: (value) {
                        setState(() {
                          Generator.settings.radius = Generator.settings.radius
                              .copyWith(topRight: value);
                        });
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: !Generator.settings.hasOneRadius,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: NumericField(
                      caption: 'radius.bottomRight:',
                      value: Generator.settings.radius.bottomRight,
                      units: 'px',
                      min: 0,
                      step: 1,
                      onChanged: (value) {
                        setState(() {
                          Generator.settings.radius = Generator.settings.radius
                              .copyWith(bottomRight: value);
                        });
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: !Generator.settings.hasOneRadius,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: NumericField(
                      caption: 'radius.bottomLeft:',
                      value: Generator.settings.radius.bottomLeft,
                      units: 'px',
                      min: 0,
                      step: 1,
                      onChanged: (value) {
                        setState(() {
                          Generator.settings.radius = Generator.settings.radius
                              .copyWith(bottomLeft: value);
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'elevation:',
                    value: Generator.settings.elevation,
                    units: 'px',
                    min: 0,
                    step: 0.1,
                    fractionDigits: 1,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.elevation = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'strokeWidth:',
                    value: Generator.settings.strokeWidth,
                    units: 'px',
                    min: 0,
                    step: 0.1,
                    fractionDigits: 1,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.strokeWidth = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: NumericField(
                    caption: 'hFlip:',
                    value: Generator.settings.hFlip ? 1.0 : 0.0,
                    min: 0,
                    max: 1,
                    step: 1,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.hFlip = value == 1.0;
                      });
                    },
                    onConvertToText: (value) => value == 1.0 ? 'true' : 'false',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: NumericField(
                    caption: 'vFlip:',
                    value: Generator.settings.vFlip ? 1.0 : 0.0,
                    min: 0,
                    max: 1,
                    step: 1,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.vFlip = value == 1.0;
                      });
                    },
                    onConvertToText: (value) => value == 1.0 ? 'true' : 'false',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text(
                'inset',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'start.type:',
                    value: Generator.settings.nip.inset.start.type.index
                        .toDouble(),
                    min: 0,
                    max: InsetPosType.values.length - 1.0,
                    step: 1,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.nip =
                            Generator.settings.nip.copyWith(
                          inset: Inset(
                            Generator.settings.nip.inset.start.copyWith(
                              type: InsetPosType.values[value.round()],
                            ),
                            Generator.settings.nip.inset.end,
                          ),
                        );
                      });
                    },
                    onConvertToText: (value) {
                      final index = value.round();
                      return InsetPosType.values[index]
                          .toString()
                          .replaceFirst('InsetPosType.', '');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'start.pos.ratio:',
                    value: Generator.settings.nip.inset.start.pos.ratio,
                    units: '',
                    min: 0,
                    max: 1,
                    step: 0.1,
                    fractionDigits: 2,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.nip =
                            Generator.settings.nip.copyWith(
                          inset: Inset(
                            Generator.settings.nip.inset.start.copyWith(
                              pos: Generator.settings.nip.inset.start.pos
                                  .copyWith(ratio: value),
                            ),
                            Generator.settings.nip.inset.end,
                          ),
                        );
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'start.pos.offset:',
                    value: Generator.settings.nip.inset.start.pos.offset,
                    units: 'px',
                    step: 1,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.nip =
                            Generator.settings.nip.copyWith(
                          inset: Inset(
                            Generator.settings.nip.inset.start.copyWith(
                              pos: Generator.settings.nip.inset.start.pos
                                  .copyWith(offset: value),
                            ),
                            Generator.settings.nip.inset.end,
                          ),
                        );
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'start.cornerOffset:',
                    value: Generator.settings.nip.inset.start.cornerOffset.index
                        .toDouble(),
                    min: 0,
                    max: CornerOffset.values.length - 1.0,
                    step: 1,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.nip =
                            Generator.settings.nip.copyWith(
                          inset: Inset(
                            Generator.settings.nip.inset.start.copyWith(
                              cornerOffset: CornerOffset.values[value.round()],
                            ),
                            Generator.settings.nip.inset.end,
                          ),
                        );
                      });
                    },
                    onConvertToText: (value) {
                      final index = value.round();
                      return CornerOffset.values[index]
                          .toString()
                          .replaceFirst('CornerOffset.', '');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'end.type:',
                    value:
                        Generator.settings.nip.inset.end.type.index.toDouble(),
                    min: 0,
                    max: InsetPosType.values.length - 1.0,
                    step: 1,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.nip =
                            Generator.settings.nip.copyWith(
                          inset: Inset(
                            Generator.settings.nip.inset.start,
                            Generator.settings.nip.inset.end.copyWith(
                              type: InsetPosType.values[value.round()],
                            ),
                          ),
                        );
                      });
                    },
                    onConvertToText: (value) {
                      final index = value.round();
                      return InsetPosType.values[index]
                          .toString()
                          .replaceFirst('InsetPosType.', '');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'end.pos.ratio:',
                    value: Generator.settings.nip.inset.end.pos.ratio,
                    units: '',
                    min: 0,
                    max: 1,
                    step: 0.1,
                    fractionDigits: 2,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.nip =
                            Generator.settings.nip.copyWith(
                          inset: Inset(
                            Generator.settings.nip.inset.start,
                            Generator.settings.nip.inset.end.copyWith(
                              pos: Generator.settings.nip.inset.start.pos
                                  .copyWith(ratio: value),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'end.pos.offset:',
                    value: Generator.settings.nip.inset.end.pos.offset,
                    units: 'px',
                    step: 1,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.nip =
                            Generator.settings.nip.copyWith(
                          inset: Inset(
                            Generator.settings.nip.inset.start,
                            Generator.settings.nip.inset.end.copyWith(
                              pos: Generator.settings.nip.inset.end.pos
                                  .copyWith(offset: value),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'end.cornerOffset:',
                    value: Generator.settings.nip.inset.end.cornerOffset.index
                        .toDouble(),
                    min: 0,
                    max: CornerOffset.values.length - 1.0,
                    step: 1,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.nip =
                            Generator.settings.nip.copyWith(
                          inset: Inset(
                            Generator.settings.nip.inset.start,
                            Generator.settings.nip.inset.end.copyWith(
                              cornerOffset: CornerOffset.values[value.round()],
                            ),
                          ),
                        );
                      });
                    },
                    onConvertToText: (value) {
                      final index = value.round();
                      return CornerOffset.values[index]
                          .toString()
                          .replaceFirst('CornerOffset.', '');
                    },
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text(
                'nip',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'size:',
                    value: Generator.settings.nip.size,
                    units: 'px',
                    step: 1,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.nip =
                            Generator.settings.nip.copyWith(size: value);
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'radius:',
                    value: Generator.settings.nip.radius,
                    units: 'px',
                    step: 1,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.nip =
                            Generator.settings.nip.copyWith(radius: value);
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'anchor:',
                    value: Generator.settings.nip.anchor.index.toDouble(),
                    min: 0,
                    max: NipAnchor.values.length - 1.0,
                    step: 1,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.nip =
                            Generator.settings.nip.copyWith(
                          anchor: NipAnchor.values[value.round()],
                        );
                      });
                    },
                    onConvertToText: (value) {
                      final index = value.round();
                      return NipAnchor.values[index]
                          .toString()
                          .replaceFirst('NipAnchor.', '');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'offset:',
                    value: Generator.settings.nip.offset,
                    units: 'px',
                    step: 1,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.nip =
                            Generator.settings.nip.copyWith(offset: value);
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'cornerOffset:',
                    value: Generator.settings.nip.cornerOffset.index.toDouble(),
                    min: 0,
                    max: CornerOffset.values.length - 1.0,
                    step: 1,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      setState(() {
                        Generator.settings.nip =
                            Generator.settings.nip.copyWith(
                          cornerOffset: CornerOffset.values[value.round()],
                        );
                      });
                    },
                    onConvertToText: (value) {
                      final index = value.round();
                      return CornerOffset.values[index]
                          .toString()
                          .replaceFirst('CornerOffset.', '');
                    },
                  ),
                ),
              ],
            ),
//          ExpansionTile(
//            title: const Text(
//              'Nip',
//              textAlign: TextAlign.center,
//              style: TextStyle(fontWeight: FontWeight.bold),
//            ),
//            children: <Widget>[
//              Padding(
//                padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                child: NumericField(
//                  caption: 'Side:',
//                  value: Generator.settings.nipSide.index.toDouble() * 2.0 + (Generator.settings.hFlip ? 1.0 : 0.0),
//                  min: NipSide.minIndex.toDouble(),
//                  max: NipSide.maxIndex.toDouble() * 2.0 + 1.0,
//                  step: 1.0,
//                  textAlign: TextAlign.center,
//                  onChanged: (double value) {
//                    setState(() {
//                      final index = value.round();
//                      Generator.settings.nipSide = NipSide.byIndex(index >> 1);
//                      Generator.settings.hFlip = index % 2 == 1;
//                    });
//                  },
//                  onConvertToText: (value) {
//                    final index = value.round();
//                    var nipSide = NipSide.byIndex(index >> 1);
//                    return nipSide.toString(onlyValue: true) + (index % 2 == 0 ? '' : nipSide.isHorizontal ? '↑' : '←');
//                  },
//                ),
//              ),
//              Padding(
//                padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                child: NumericField(
//                  caption: 'Radius:',
//                  value: Generator.settings.nipRadius,
//                  units: 'px',
//                  min: 0.0,
//                  step: 0.1,
//                  fractionDigits: 1,
//                  onChanged: (double value) {
//                    setState(() {
//                      Generator.settings.nipRadius = value;
//                    });
//                  },
//                ),
//              ),
//              Padding(
//                padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                child: NumericField(
//                  caption: 'Size:',
//                  value: Generator.settings.nipSize,
//                  units: 'px',
//                  //min: 0.0,
//                  step: 1.0,
//                  onChanged: (double value) {
//                    setState(() {
//                      Generator.settings.nipSize = value;
//                    });
//                  },
//                ),
//              ),
//              Padding(
//                padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                child: NumericField(
//                  caption: 'Relative offset:',
//                  value: Generator.settings.nipOffset.relative * 100.0,
//                  units: '%',
//                  min: 0.0,
//                  max: 100.0,
//                  step: 1.0,
//                  onChanged: (double value) {
//                    setState(() {
//                      Generator.settings.nipOffset = NipOffset(relative: value / 100.0, absolute: Generator.settings.nipOffset.absolute);
//                    });
//                  },
//                ),
//              ),
//              Padding(
//                padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                child: NumericField(
//                  caption: 'Absolute offset:',
//                  value: Generator.settings.nipOffset.absolute,
//                  units: 'px',
//                  step: 1.0,
//                  onChanged: (double value) {
//                    setState(() {
//                      Generator.settings.nipOffset = NipOffset(relative: Generator.settings.nipOffset.relative, absolute: value);
//                    });
//                  },
//                ),
//              ),
//            ],
//          ),
            ExpansionTile(
              title: const Text(
                'Top line',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'Type of position:',
                    value: Generator.settings.topLine.posType.index.toDouble(),
                    min: 0,
                    max: (NipLinePosType.values.length - 1).toDouble(),
                    step: 1,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      setState(() {
                        final index = value.round();
                        Generator.settings.topLine = NipLine(
                          Generator.settings.topLine.lineType,
                          NipLinePosType.values[index],
                          _topLineValues[index],
                        );
                      });
                    },
                    onConvertToText: (value) {
                      final index = value.floor();
                      return NipLinePosType.values[index]
                          .toString()
                          .replaceFirst(RegExp(r'.*\.'), '');
                    },
                  ),
                ),
                Visibility(
                  visible: Generator.settings.topLine.posType ==
                      NipLinePosType.angle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: NumericField(
                      caption: 'Angle of line:',
                      value: _topLineValues[NipLinePosType.angle.index],
                      units: '°',
                      min: -90,
                      max: 90,
                      step: 1,
                      onChanged: (value) {
                        setState(() {
                          _topLineValues[NipLinePosType.angle.index] = value;
                          Generator.settings.topLine = NipLine(
                            Generator.settings.topLine.lineType,
                            NipLinePosType.angle,
                            value,
                          );
                        });
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible:
                      Generator.settings.topLine.posType == NipLinePosType.pos,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: NumericField(
                      caption: 'Position on the side:',
                      value: _topLineValues[NipLinePosType.pos.index],
                      units: 'px',
                      step: 1,
                      onChanged: (value) {
                        setState(() {
                          _topLineValues[NipLinePosType.pos.index] = value;
                          Generator.settings.topLine = NipLine(
                            Generator.settings.topLine.lineType,
                            NipLinePosType.pos,
                            value,
                          );
                        });
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: Generator.settings.topLine.posType ==
                      NipLinePosType.offset,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: NumericField(
                      caption: 'Offset from the nip:',
                      value: _topLineValues[NipLinePosType.offset.index],
                      units: 'px',
                      step: 1,
                      onChanged: (value) {
                        setState(() {
                          _topLineValues[NipLinePosType.offset.index] = value;
                          Generator.settings.topLine = NipLine(
                            Generator.settings.topLine.lineType,
                            NipLinePosType.offset,
                            value,
                          );
                        });
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: Generator.settings.topLine.posType ==
                      NipLinePosType.corners,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: NumericField(
                      caption: 'Position on the corners:',
                      value: _topLineValues[NipLinePosType.corners.index],
                      units: '°',
                      step: 1,
                      onBeforeChanging: (value) {
                        if (value < -180.0) {
                          value = 180.0;
                        } else if (value > 180.0) {
                          value = -180.0;
                        } else if (value > -90.0 && value <= 0.0) {
                          value = -90.0;
                        } else if (value > 0.0 && value < 90.0) {
                          value = 90.0;
                        }
                        return value;
                      },
                      onChanged: (value) {
                        setState(() {
                          _topLineValues[NipLinePosType.corners.index] = value;
                          Generator.settings.topLine = NipLine(
                            Generator.settings.topLine.lineType,
                            NipLinePosType.corners,
                            value,
                          );
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text(
                'Bottom line',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: NumericField(
                    caption: 'Type of position:',
                    value:
                        Generator.settings.bottomLine.posType.index.toDouble(),
                    min: 0,
                    max: (NipLinePosType.values.length - 1).toDouble(),
                    step: 1,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      setState(() {
                        final index = value.round();
                        Generator.settings.bottomLine = NipLine(
                          Generator.settings.bottomLine.lineType,
                          NipLinePosType.values[index],
                          _bottomLineValues[index],
                        );
                      });
                    },
                    onConvertToText: (value) {
                      final index = value.floor();
                      return NipLinePosType.values[index]
                          .toString()
                          .replaceFirst(RegExp(r'.*\.'), '');
                    },
                  ),
                ),
                Visibility(
                  visible: Generator.settings.bottomLine.posType ==
                      NipLinePosType.angle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: NumericField(
                      caption: 'Angle of line:',
                      value: _bottomLineValues[NipLinePosType.angle.index],
                      units: '°',
                      min: -90,
                      max: 90,
                      step: 1,
                      onChanged: (value) {
                        setState(() {
                          _bottomLineValues[NipLinePosType.angle.index] = value;
                          Generator.settings.bottomLine = NipLine(
                            Generator.settings.bottomLine.lineType,
                            NipLinePosType.angle,
                            value,
                          );
                        });
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: Generator.settings.bottomLine.posType ==
                      NipLinePosType.pos,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: NumericField(
                      caption: 'Position on the side:',
                      value: _bottomLineValues[NipLinePosType.pos.index],
                      units: 'px',
                      step: 1,
                      onChanged: (value) {
                        setState(() {
                          _bottomLineValues[NipLinePosType.pos.index] = value;
                          Generator.settings.bottomLine = NipLine(
                            Generator.settings.bottomLine.lineType,
                            NipLinePosType.pos,
                            value,
                          );
                        });
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: Generator.settings.bottomLine.posType ==
                      NipLinePosType.offset,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: NumericField(
                      caption: 'Offset from the nip:',
                      value: _bottomLineValues[NipLinePosType.offset.index],
                      units: 'px',
                      step: 1,
                      onChanged: (value) {
                        setState(() {
                          _bottomLineValues[NipLinePosType.offset.index] =
                              value;
                          Generator.settings.bottomLine = NipLine(
                            Generator.settings.bottomLine.lineType,
                            NipLinePosType.offset,
                            value,
                          );
                        });
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: Generator.settings.bottomLine.posType ==
                      NipLinePosType.corners,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: NumericField(
                      caption: 'Position on the corners:',
                      value: _bottomLineValues[NipLinePosType.corners.index],
                      units: '°',
                      step: 1,
                      onBeforeChanging: (value) {
                        if (value < -180.0) {
                          value = 180.0;
                        } else if (value > 180.0) {
                          value = -180.0;
                        } else if (value > -90.0 && value <= 0.0) {
                          value = -90.0;
                        } else if (value > 0.0 && value < 90.0) {
                          value = 90.0;
                        }
                        return value;
                      },
                      onChanged: (value) {
                        setState(() {
                          _bottomLineValues[NipLinePosType.corners.index] =
                              value;
                          Generator.settings.bottomLine = NipLine(
                            Generator.settings.bottomLine.lineType,
                            NipLinePosType.corners,
                            value,
                          );
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
//          const Divider(),
//          NipLinePos(
//            caption: 'Top line',
//            nipLine: _topLine,
//            onChanged: (nipLine) => setState(() {
//              _topLine = nipLine;
//            }),
//          ),
//          const Divider(),
//          NipLinePos(
//            caption: 'Bottom line',
//            nipLine: _bottomLine,
//            onChanged: (nipLine) => setState(() {
//              _bottomLine = nipLine;
//            }),
//          ),
          ],
        ),
      );

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final animation = Tween<double>(begin: _settingsWidth, end: 0)
        .animate(_settingsController);

    return Column(
      children: <Widget>[
        PhysicalModel(
          color: primarySwatch[200]!,
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(_staticPadding / 2.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: getAddingPadding(1),
                  child: Align(
//                    alignment: Generator.settings.nipSide.isLeft || Generator.settings.nipSide.isVertical && !Generator.settings.hFlip ? Alignment.topLeft : Alignment.topRight,
                    alignment: Generator.settings.hFlip
                        ? Alignment.topRight
                        : Alignment.topLeft,
//                    child: const Text('test'),
                    child: Bubble(
                      style: Generator.settings.style,
                      nip: Generator.settings.nip,
                      topLine: Generator.settings.topLine,
                      bottomLine: Generator.settings.bottomLine,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('Lorem ipsum dolor sit amet'),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: _staticPadding / 2.0) +
                      getAddingPadding(1),
                  child: Align(
//                    alignment: Generator.settings.nipSide.isLeft || Generator.settings.nipSide.isVertical && !Generator.settings.hFlip ? Alignment.topLeft : Alignment.topRight,
                    alignment: Generator.settings.hFlip
                        ? Alignment.topRight
                        : Alignment.topLeft,
//                    child: const Text('test'),
                    child: Bubble(
                      style: Generator.settings.style,
                      nip: Generator.settings.nip,
                      topLine: Generator.settings.topLine,
                      bottomLine: Generator.settings.bottomLine,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              SizedBox.expand(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: toggleSettings,
                      child: Padding(
                        padding: const EdgeInsets.all(_staticPadding) +
                            getAddingPadding(_scale),
                        // child: const Text('TEST'),
                        child: Bubble(
                          scale: _scale,
                          style: Generator.settings.style
                              .copyWith(color: Colors.lightBlue),
                          nip: Generator.settings.nip,
                          topLine: Generator.settings.topLine,
                          bottomLine: Generator.settings.bottomLine,
                          drawDraft: _drawDraft,
                          child: SizedBox(
                            height: Generator.settings.height,
                            width: Generator.settings.width,
                            child: const Center(
                              child: Text(
                                'Press me',
                                style: TextStyle(color: Colors.black12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(
                        height: double.infinity,
                        width: _settingsWidth,
                        child: AnimatedBuilder(
                          animation: animation,
                          child: getSettings(),
                          builder: (context, child) => Visibility(
                            maintainInteractivity: true,
                            maintainSemantics: true,
                            maintainState: true,
                            maintainAnimation: true,
                            maintainSize: true,
                            visible: animation.value != _settingsWidth,
                            child: Transform.translate(
                              offset: Offset(animation.value, 0),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
