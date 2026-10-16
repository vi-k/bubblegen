//import 'dart:math' as math;
//import 'dart:ui' as ui;

import 'package:bubblegen/bubble_demo.dart';
import 'package:flutter/material.dart';

import 'generator.dart';

GeneratorBubbleStyle gBubbleStyle = GeneratorBubbleStyle();

void main() => runApp(const MyApp());

final primarySwatch = createSwatch(const Color.fromARGB(255, 132, 151, 176));
//final primarySwatch = Colors.blue;
late MaterialColor cursorSwatch;

MaterialColor createSwatch(Color color) {
  // toARGB32() replaces value from Flutter 3.29; the floor is 3.27.
  // ignore: deprecated_member_use
  return MaterialColor(color.value, {
    // Почти совпадают с Colors.blue
    50: Color.alphaBlend(
      color.withAlpha(Color.getAlphaFromOpacity(0.12)),
      Colors.white,
    ),
    100: Color.alphaBlend(
      color.withAlpha(Color.getAlphaFromOpacity(0.30)),
      Colors.white,
    ),
    200: Color.alphaBlend(
      color.withAlpha(Color.getAlphaFromOpacity(0.50)),
      Colors.white,
    ),
    300: Color.alphaBlend(
      color.withAlpha(Color.getAlphaFromOpacity(0.70)),
      Colors.white,
    ),
    400: Color.alphaBlend(
      color.withAlpha(Color.getAlphaFromOpacity(0.85)),
      Colors.white,
    ),
    500: color,
    // Дальше синяя составляющая расходится с Colors.blue, равняюсь по зелёному
    // Тогда они расходятся по цвету, но совпадают по яркости
    600: Color.alphaBlend(
      color.withAlpha(Color.getAlphaFromOpacity(0.91)),
      Colors.black,
    ),
    700: Color.alphaBlend(
      color.withAlpha(Color.getAlphaFromOpacity(0.79)),
      Colors.black,
    ),
    800: Color.alphaBlend(
      color.withAlpha(Color.getAlphaFromOpacity(0.68)),
      Colors.black,
    ),
    900: Color.alphaBlend(
      color.withAlpha(Color.getAlphaFromOpacity(0.48)),
      Colors.black,
    ),
  });
}

// TODO: пунктирные линии в Draft'е не выводятся наверху

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
//    cursorSwatch = createSwatch(Theme.of(context).cursorColor);
    cursorSwatch = createSwatch(Colors.blue);

    return MaterialApp(
      title: 'Bubble generator',
      theme: ThemeData(
        // Drawn by the Material 2 rules it was written for: Material 3 ignores
        // primarySwatch and would repaint the app in its own palette.
        useMaterial3: false,
        primarySwatch: primarySwatch,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: primarySwatch,
          accentColor: Colors.blue,
        ),
        textSelectionTheme:
            TextSelectionThemeData(cursorColor: cursorSwatch[500]),
//        textSelectionColor: cursorSwatch[200],
//        textSelectionHandleColor: cursorSwatch[400],
      ),
      home: const MyHomePage(title: 'Bubble generator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//class NipLineSelect extends StatefulWidget {
//  final String caption;
//  final NipLine nipLine;
//  final void Function(NipLine) onChange;
//
//  const NipLineSelect({Key key, this.caption, @required this.nipLine, @required this.onChange})
//      : assert(nipLine != null),
//        super(key: key);
//
//  @override
//  _NipLineSelectState createState() => _NipLineSelectState();
//}
//
//class _NipLineSelectState extends State<NipLineSelect> {
//  var _lineTypeIndex = 0;
//  NipLineType _lineType = NipLineType.line;
//  NipLinePosType _posType = NipLinePosType.angle;
//  var _lineAngle = 0.0;
//  var _pos = 0.0;
//  var _offset = 0.0;
//  var _cornerAngle = -90.0;
//  //var _h = 0.0; // arc's angle
//  var _curve1Enabled = true;
//  var _a1 = 0.0; // curve's α₁
//  var _sz1 = 2.0 / 3.0; // curve's sz₁
//  var _curve2Enabled = true;
//  var _a2 = 90.0; // curve's α₂
//  var _sz2 = 2.0 / 3.0; // curve's sz₂
//
//  @override
//  void initState() {
//    _posType = widget.nipLine.posType;
//    if (_posType == NipLinePosType.angle) {
//      _lineAngle = widget.nipLine.pos;
//    } else if (_posType == NipLinePosType.pos) {
//      _pos = widget.nipLine.pos;
//    } else if (_posType == NipLinePosType.offset) {
//      _offset = widget.nipLine.pos;
//    } else if (_posType == NipLinePosType.corner) {
//      _cornerAngle = widget.nipLine.pos;
//    }
//
////    _h = widget.nipLine.h;
////    if (_h != 0.0) _typeIndex = 1;
//
//    if (widget.nipLine.a1 != null) {
//      _a1 = widget.nipLine.a1;
//      _sz1 = widget.nipLine.sz1;
//      _curve1Enabled = true;
//    }
//
//    if (widget.nipLine.a2 != null) {
//      _a2 = widget.nipLine.a2;
//      _sz2 = widget.nipLine.sz2;
//      _curve2Enabled = true;
//    }
//
//    super.initState();
//  }
//
//  NipLineType setType(int lineTypeIndex) {
//    return lineTypeIndex == 0 ? NipLineType.line : lineTypeIndex == 1 ? NipLineType.arc : NipLineType.curve;
//  }
//
//  void doChange() {
//    NipLine nipLine;
//
//    if (widget.onChange != null) {
//      switch (_lineType) {
//        case NipLineType.line:
//          switch (_posType) {
//            case NipLinePosType.angle:
//              nipLine = NipLine.line(_lineAngle);
//              break;
//            case NipLinePosType.pos:
//              nipLine = NipLine.lineTo(_pos);
//              break;
//            case NipLinePosType.offset:
//              nipLine = NipLine.relativeLineTo(_offset);
//              break;
//            case NipLinePosType.corner:
//              nipLine = NipLine.lineToCorner(_cornerAngle);
//              break;
//          }
//          break;
//
//        case NipLineType.arc:
//          switch (_posType) {
//            case NipLinePosType.angle:
//              nipLine = NipLine.arc(_lineAngle, _a1);
//              break;
//            case NipLinePosType.pos:
//              nipLine = NipLine.arcTo(_pos, _a1);
//              break;
//            case NipLinePosType.offset:
//              nipLine = NipLine.relativeArcTo(_offset, _a1);
//              break;
//            case NipLinePosType.corner:
//              nipLine = NipLine.arcToCorner(_cornerAngle, _a1);
//              break;
//          }
//          break;
//
//        case NipLineType.curve:
//          switch (_posType) {
//            case NipLinePosType.angle:
//              nipLine = NipLine.curve(_lineAngle,
//                  angle1: _curve1Enabled ? _a1 : null,
//                  size1: _curve1Enabled ? _sz1 : null,
//                  angle2: _curve2Enabled ? _a2 : null,
//                  size2: _curve2Enabled ? _sz2 : null);
//              break;
//            case NipLinePosType.pos:
//              nipLine = NipLine.curveTo(_pos,
//                  angle1: _curve1Enabled ? _a1 : null,
//                  size1: _curve1Enabled ? _sz1 : null,
//                  angle2: _curve2Enabled ? _a2 : null,
//                  size2: _curve2Enabled ? _sz2 : null);
//              break;
//            case NipLinePosType.offset:
//              nipLine = NipLine.relativeCurveTo(_offset,
//                  angle1: _curve1Enabled ? _a1 : null,
//                  size1: _curve1Enabled ? _sz1 : null,
//                  angle2: _curve2Enabled ? _a2 : null,
//                  size2: _curve2Enabled ? _sz2 : null);
//              break;
//            case NipLinePosType.corner:
//              nipLine = NipLine.curveToCorner(_cornerAngle,
//                  angle1: _curve1Enabled ? _a1 : null,
//                  size1: _curve1Enabled ? _sz1 : null,
//                  angle2: _curve2Enabled ? _a2 : null,
//                  size2: _curve2Enabled ? _sz2 : null);
//              break;
//          }
//          break;
//      }
//
//      widget.onChange(nipLine);
//    }
//
//    setState(() => null);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Column(
//      children: <Widget>[
//        Text(
//          widget.caption,
//          style: TextStyle(fontWeight: FontWeight.bold),
//        ),
////        ToggleButtons(
////          isSelected: List.generate(3, (_) => false)..[_lineTypeIndex] = true,
////          children: <Widget>[
////            Text('line'),
////            Text('arc'),
////            Text('curve'),
////          ],
////          borderRadius: BorderRadius.circular(100),
////          borderWidth: 5,
////          borderColor: Colors.orange,
////          selectedBorderColor: Colors.deepOrange,
////          fillColor: Colors.orange.shade200,
////          onPressed: (index) {
////            _lineTypeIndex = index;
////            doChange();
////          },
////        ),
//        Column(
//          children: <Widget>[
//            Table(
//              children: <TableRow>[
//                TableRow(children: [
//                  DropdownButton(
//                    value: _posType,
//                    items: <DropdownMenuItem<NipLinePosType>>[
//                      DropdownMenuItem(child: Text('line(a)'), value: NipLinePosType.angle),
//                      DropdownMenuItem(child: Text('lineTo(pos)'), value: NipLinePosType.pos),
//                      DropdownMenuItem(child: Text('relativeLineTo(pos)'), value: NipLinePosType.offset),
//                      DropdownMenuItem(child: Text('lineToCorner(a)'), value: NipLinePosType.corner),
//                    ],
//                    onChanged: (value) {
//                      _lineType = setType(_lineTypeIndex);
//                      doChange();
//                    },
//                  ),
//                  TextFormField(
//                    controller: TextEditingController(),
//                    decoration: new InputDecoration(labelText: "Enter your number"),
//                    keyboardType: TextInputType.number,
//                    inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
//                  ),
//                ])
//              ],
//            ),
//            Slider(
//              value: _lineAngle,
//              min: -90,
//              max: 90,
//              divisions: 180,
//              onChanged: (value) {
//                _lineAngle = value;
//                doChange();
//              },
//            ),
//            Text('${_lineAngle.toStringAsFixed(1)}'),
//          ],
//        ),
//        Row(
//          children: <Widget>[
//            Radio(
//              value: NipLinePosType.angle,
//              groupValue: _posType,
//              onChanged: (value) {
//                _lineType = setType(_lineTypeIndex);
//                doChange();
//              },
//            ),
//            Text('line\'s angle'),
//            Expanded(
//              child: Slider(
//                value: _lineAngle,
//                min: -90,
//                max: 90,
//                divisions: 180,
//                onChanged: _posType != NipLinePosType.angle
//                    ? null
//                    : (value) {
//                        _lineAngle = value;
//                        doChange();
//                      },
//              ),
//            ),
//            Text('${_lineAngle.toStringAsFixed(1)}'),
//          ],
//        ),
//        Row(
//          children: <Widget>[
//            Radio(
//              value: NipLinePosType.pos,
//              groupValue: _posType,
//              onChanged: (value) {
//                _lineType = setType(_lineTypeIndex);
//                doChange();
//              },
//            ),
//            Text('side\'s position'),
//            Expanded(
//              child: Slider(
//                value: _pos,
//                min: -100,
//                max: 100,
//                divisions: 200,
//                onChanged: _posType != NipLinePosType.pos
//                    ? null
//                    : (value) {
//                        _pos = value;
//                        doChange();
//                      },
//              ),
//            ),
//            Text('${_pos.toStringAsFixed(1)}'),
//          ],
//        ),
//        Row(
//          children: <Widget>[
//            Radio(
//              value: NipLinePosType.offset,
//              groupValue: _posType,
//              onChanged: (value) {
//                _lineType = setType(_lineTypeIndex);
//                doChange();
//              },
//            ),
//            Text('side\'s offset'),
//            Expanded(
//              child: Slider(
//                value: _offset,
//                min: -100,
//                max: 100,
//                divisions: 200,
//                onChanged: _posType != NipLinePosType.offset
//                    ? null
//                    : (value) {
//                        _offset = value;
//                        doChange();
//                      },
//              ),
//            ),
//            Text('${_offset.toStringAsFixed(1)}'),
//          ],
//        ),
//        Row(
//          children: <Widget>[
//            Radio(
//              value: NipLinePosType.corner,
//              groupValue: _posType,
//              onChanged: (value) {
//                _lineType = setType(_lineTypeIndex);
//                doChange();
//              },
//            ),
//            Text('corner\'s angle'),
//            Expanded(
//              child: Slider(
//                value: _cornerAngle,
//                min: -180,
//                max: 180,
//                divisions: 360,
//                onChanged: _posType != NipLinePosType.corner
//                    ? null
//                    : (value) {
//                        _cornerAngle = value;
//                        doChange();
//                      },
//              ),
//            ),
//            Text('${_cornerAngle.toStringAsFixed(1)}'),
//          ],
//        ),
//        Visibility(
//          visible: _lineTypeIndex == 1,
//          child: Row(
//            children: <Widget>[
//              Text('arc\'s angle'),
//              Expanded(
//                child: Slider(
//                  value: _a1,
//                  min: -100,
//                  max: 100,
//                  divisions: 200,
//                  onChanged: (value) {
//                    _a1 = value;
//                    doChange();
//                  },
//                ),
//              ),
//              Text('${_a1.toStringAsFixed(1)}'),
//            ],
//          ),
//        ),
//        Visibility(
//          visible: _lineTypeIndex == 2,
//          child: Column(
//            children: <Widget>[
//              Align(alignment: Alignment.topLeft, child: Text('Curve\'s guideline 1:')),
//              Row(
//                children: <Widget>[
//                  Checkbox(
//                    value: _curve1Enabled,
//                    onChanged: (value) {
//                      _curve1Enabled = value;
//                      doChange();
//                    },
//                  ),
//                  Expanded(
//                    child: Column(
//                      children: <Widget>[
//                        Row(
//                          children: <Widget>[
//                            Text('curves\'s α₁'),
//                            Expanded(
//                              child: Slider(
//                                value: _a1,
//                                min: -90,
//                                max: 90,
//                                divisions: 180,
//                                onChanged: !_curve1Enabled
//                                    ? null
//                                    : (value) {
//                                        _a1 = value;
//                                        doChange();
//                                      },
//                              ),
//                            ),
//                            Text('${_a1.toStringAsFixed(1)}'),
//                          ],
//                        ),
//                        Row(
//                          children: <Widget>[
//                            Text('curves\'s sz₁'),
//                            Expanded(
//                              child: Slider(
//                                value: _sz1,
//                                min: 0,
//                                max: 2,
//                                divisions: 12,
//                                onChanged: !_curve1Enabled
//                                    ? null
//                                    : (value) {
//                                        _sz1 = value;
//                                        doChange();
//                                      },
//                              ),
//                            ),
//                            Text('${_sz1.toStringAsFixed(2)}'),
//                          ],
//                        ),
//                      ],
//                    ),
//                  ),
//                ],
//              ),
//              Align(alignment: Alignment.topLeft, child: Text('Curve\'s guideline 2:')),
//              Row(
//                children: <Widget>[
//                  Checkbox(
//                    value: _curve2Enabled,
//                    onChanged: (value) {
//                      _curve2Enabled = value;
//                      doChange();
//                    },
//                  ),
//                  Expanded(
//                    child: Column(
//                      children: <Widget>[
//                        Row(
//                          children: <Widget>[
//                            Text('curves\'s α₂'),
//                            Expanded(
//                              child: Slider(
//                                value: _a2,
//                                min: -90,
//                                max: 90,
//                                divisions: 180,
//                                onChanged: !_curve2Enabled
//                                    ? null
//                                    : (value) {
//                                        _a2 = value;
//                                        doChange();
//                                      },
//                              ),
//                            ),
//                            Text('${_a2.toStringAsFixed(1)}'),
//                          ],
//                        ),
//                        Row(
//                          children: <Widget>[
//                            Text('curves\'s sz₂'),
//                            Expanded(
//                              child: Slider(
//                                value: _sz2,
//                                min: 0,
//                                max: 2,
//                                divisions: 12,
//                                onChanged: !_curve2Enabled
//                                    ? null
//                                    : (value) {
//                                        _sz2 = value;
//                                        doChange();
//                                      },
//                              ),
//                            ),
//                            Text('${_sz2.toStringAsFixed(2)}'),
//                          ],
//                        ),
//                      ],
//                    ),
//                  ),
//                ],
//              ),
//            ],
//          ),
//        ),
//      ],
//    );
//  }
//}

//class NipLinePos extends StatelessWidget {
//  NipLinePos({
//    this.caption,
//    @required this.nipLine,
//    this.onChanged,
//  });
//
//  final String caption;
//  final NipLine nipLine;
//  final ValueChanged<NipLine> onChanged;
//
//  NipLineType setType(int lineTypeIndex) {
//    return lineTypeIndex == 0 ? NipLineType.line : lineTypeIndex == 1 ? NipLineType.arc : NipLineType.curve;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    var value = nipLine.pos;
//    double min;
//    double max;
//    var step = 1.0;
//    var fractionDigits = 1;
//    String units;
//
//    switch (nipLine.posType) {
//      case NipLinePosType.angle:
//        min = -90;
//        max = 90;
//        units = '°';
//        break;
//
//      case NipLinePosType.pos:
//        min = -100;
//        max = 100;
//        units = ' px';
//        break;
//
//      case NipLinePosType.offset:
//        min = -100;
//        max = 100;
//        units = ' px';
//        break;
//
//      case NipLinePosType.corners:
//        min = -180;
//        max = 180;
//        units = '°';
//        break;
//    }
//
//    var divisions = ((max - min) / step).round();
//    var num = ((value - min) / step).round();
//
//    return Padding(
//      padding: EdgeInsets.symmetric(horizontal: 5),
//      child: Column(
//        children: <Widget>[
//          Text(caption),
//          Table(
//              columnWidths: {
//                0: FlexColumnWidth(),
//                1: FixedColumnWidth(60),
//              },
//              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//              children: [
//                TableRow(
//                  children: <Widget>[
//                    DropdownButton(
//                      value: nipLine.posType,
//                      items: <DropdownMenuItem<NipLinePosType>>[
//                        DropdownMenuItem(
//                            child: Text('line\'s angle', textScaleFactor: 0.9), value: NipLinePosType.angle),
//                        DropdownMenuItem(child: Text('pos', textScaleFactor: 0.9), value: NipLinePosType.pos),
//                        DropdownMenuItem(child: Text('offset', textScaleFactor: 0.9), value: NipLinePosType.offset),
//                        DropdownMenuItem(
//                            child: Text('corners angle', textScaleFactor: 0.9), value: NipLinePosType.corners),
//                      ],
//                      onChanged: (value) {
//                        onChanged(NipLine(nipLine.lineType, value, nipLine.pos));
//                      },
//                    ),
//                    Text('${value.toStringAsFixed(fractionDigits)}${units ?? ""}', textAlign: TextAlign.end)
//                    //                Text('0.0', textAlign: TextAlign.end)
//                  ],
//                ),
//              ]),
//          Table(
//            columnWidths: {
//              0: FixedColumnWidth(40),
//              1: FlexColumnWidth(40),
//              2: FixedColumnWidth(40),
//            },
//            children: [
//              TableRow(
//                children: <Widget>[
//                  RaisedButton(
//                    child: Text('–'),
//                    color: Colors.blue,
//                    onPressed: () =>
//                        onChanged(NipLine(nipLine.lineType, nipLine.posType, num > 0 ? min + (num - 1) * step : min)),
//                  ),
//                  Slider(
//                    value: value,
//                    min: min,
//                    max: max,
//                    divisions: divisions,
//                    onChanged: (value) => onChanged(NipLine(nipLine.lineType, nipLine.posType, value)),
//                  ),
//                  RaisedButton(
//                    child: Text('+'),
//                    color: Colors.blue,
//                    onPressed: () =>
//                        onChanged(NipLine(nipLine.lineType, nipLine.posType, num < divisions ? min + (num + 1) * step : max)),
//                  ),
//                ],
//              ),
//            ],
//          ),
//        ],
//      ),
//    );
//  }
//}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 4,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  child: Text('1'),
                ),
                const PopupMenuItem(
                  child: Text('2'),
                ),
                const PopupMenuItem(
                  child: Text('3'),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Generator'),
              Tab(text: 'Bubble\ndemo'),
              Tab(text: 'CustomBubble\ndemo'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: const <Widget>[
              Generator(),
              BubbleDemo(),
              Text('Test #2'),
            ],
          ),
        ),
      );
}
