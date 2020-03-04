import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:bubble_demo/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class ZoomCustomPaint extends StatefulWidget {
  final CustomPainter painter;
  final double zoom;
  final Widget child;
  final EdgeInsets padding;

  const ZoomCustomPaint({Key key, this.painter, this.zoom = 1.0, this.child, this.padding}) : super(key: key);

  @override
  _ZoomCustomPaintState createState() => _ZoomCustomPaintState();
}

class _ZoomCustomPaintState extends State<ZoomCustomPaint> {
  ui.Image _image;
  bool _update = true;

  @override
  Widget build(BuildContext context) {
    var ratio = MediaQuery.of(context).devicePixelRatio;
    var update = this._update;
    this._update = true;
    print('build $this');

    return Container(
      child: CustomPaint(
        child: Container(padding: widget.padding, child: widget.child),
//      painter: widget.painter,
        painter: ZoomCustomPaintPainter(
            painter: widget.painter,
            image: this._image,
            update: update,
            ratio: ratio,
            zoom: this.widget.zoom,
            onUpdate: (image) {
              setState(() {
                this._image = image;
                this._update = false;
                print('repaint without updating');
              });
            }),
      ),
    );
  }
}

class ZoomCustomPaintPainter extends CustomPainter {
  ZoomCustomPaintPainter({
    this.image,
    this.update,
    this.ratio,
    this.zoom,
    this.painter,
    this.onUpdate,
  }) : super();

  final ui.Image image;
  final bool update;
  final double ratio;
  final double zoom;
  final CustomPainter painter;
  final void Function(ui.Image) onUpdate;

  @override
  void paint(Canvas canvas, Size size) {
    print('paint $image $size $this');
    if (this.image != null) {
      var paint = Paint();
      paint.isAntiAlias = true;
      canvas.scale(this.zoom / this.ratio, this.zoom / this.ratio);
      canvas.drawImage(this.image, Offset.zero, paint);
    }

    if (this.update) {
      var imageSize = Size(size.width * this.ratio, size.height * this.ratio);
      print('update $ratio $imageSize');
      var pictureRecorder = ui.PictureRecorder();
      var canvas = Canvas(pictureRecorder);
      canvas.scale(this.ratio);
      painter.paint(canvas, size);
      var pic = pictureRecorder.endRecording();
      pic.toImage(imageSize.width.ceil(), imageSize.height.ceil()).then((image) {
        print('onUpdate');
        this.onUpdate?.call(image);
      });
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class NipLineSelect extends StatefulWidget {
  final String caption;
  final NipLine nipLine;
  final void Function(NipLine) onChange;

  const NipLineSelect({Key key, this.caption, @required this.nipLine, @required this.onChange})
      : assert(nipLine != null),
        super(key: key);

  @override
  _NipLineSelectState createState() => _NipLineSelectState();
}

class _NipLineSelectState extends State<NipLineSelect> {
  var _lineTypeIndex = 0;
  NipLineType _lineType = NipLineType.line;
  NipLinePosType _posType = NipLinePosType.angle;
  var _lineAngle = 0.0;
  var _pos = 0.0;
  var _offset = 0.0;
  var _cornerAngle = -90.0;
  //var _h = 0.0; // arc's angle
  var _curve1Enabled = true;
  var _a1 = 0.0; // curve's α₁
  var _sz1 = 2.0 / 3.0; // curve's sz₁
  var _curve2Enabled = true;
  var _a2 = 90.0; // curve's α₂
  var _sz2 = 2.0 / 3.0; // curve's sz₂

  @override
  void initState() {
    _posType = widget.nipLine.posType;
    if (_posType == NipLinePosType.angle) {
      _lineAngle = widget.nipLine.pos;
    } else if (_posType == NipLinePosType.pos) {
      _pos = widget.nipLine.pos;
    } else if (_posType == NipLinePosType.offset) {
      _offset = widget.nipLine.pos;
    } else if (_posType == NipLinePosType.corner) {
      _cornerAngle = widget.nipLine.pos;
    }

//    _h = widget.nipLine.h;
//    if (_h != 0.0) _typeIndex = 1;

    if (widget.nipLine.a1 != null) {
      _a1 = widget.nipLine.a1;
      _sz1 = widget.nipLine.sz1;
      _curve1Enabled = true;
    }

    if (widget.nipLine.a2 != null) {
      _a2 = widget.nipLine.a2;
      _sz2 = widget.nipLine.sz2;
      _curve2Enabled = true;
    }

    super.initState();
  }

  NipLineType setType(int lineTypeIndex) {
    return lineTypeIndex == 0 ? NipLineType.line : lineTypeIndex == 1 ? NipLineType.arc : NipLineType.curve;
  }

  void doChange() {
    NipLine nipLine;

    if (widget.onChange != null) {
      switch (_lineType) {
        case NipLineType.line:
          switch (_posType) {
            case NipLinePosType.angle:
              nipLine = NipLine.line(_lineAngle);
              break;
            case NipLinePosType.pos:
              nipLine = NipLine.lineTo(_pos);
              break;
            case NipLinePosType.offset:
              nipLine = NipLine.relativeLineTo(_offset);
              break;
            case NipLinePosType.corner:
              nipLine = NipLine.lineToCorner(_cornerAngle);
              break;
          }
          break;

        case NipLineType.arc:
          switch (_posType) {
            case NipLinePosType.angle:
              nipLine = NipLine.arc(_lineAngle, _a1);
              break;
            case NipLinePosType.pos:
              nipLine = NipLine.arcTo(_pos, _a1);
              break;
            case NipLinePosType.offset:
              nipLine = NipLine.relativeArcTo(_offset, _a1);
              break;
            case NipLinePosType.corner:
              nipLine = NipLine.arcToCorner(_cornerAngle, _a1);
              break;
          }
          break;

        case NipLineType.curve:
          switch (_posType) {
            case NipLinePosType.angle:
              nipLine = NipLine.curve(_lineAngle,
                  angle1: _curve1Enabled ? _a1 : null,
                  size1: _curve1Enabled ? _sz1 : null,
                  angle2: _curve2Enabled ? _a2 : null,
                  size2: _curve2Enabled ? _sz2 : null);
              break;
            case NipLinePosType.pos:
              nipLine = NipLine.curveTo(_pos,
                  angle1: _curve1Enabled ? _a1 : null,
                  size1: _curve1Enabled ? _sz1 : null,
                  angle2: _curve2Enabled ? _a2 : null,
                  size2: _curve2Enabled ? _sz2 : null);
              break;
            case NipLinePosType.offset:
              nipLine = NipLine.relativeCurveTo(_offset,
                  angle1: _curve1Enabled ? _a1 : null,
                  size1: _curve1Enabled ? _sz1 : null,
                  angle2: _curve2Enabled ? _a2 : null,
                  size2: _curve2Enabled ? _sz2 : null);
              break;
            case NipLinePosType.corner:
              nipLine = NipLine.curveToCorner(_cornerAngle,
                  angle1: _curve1Enabled ? _a1 : null,
                  size1: _curve1Enabled ? _sz1 : null,
                  angle2: _curve2Enabled ? _a2 : null,
                  size2: _curve2Enabled ? _sz2 : null);
              break;
          }
          break;
      }

      widget.onChange(nipLine);
    }

    setState(() => null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          widget.caption,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
//        ToggleButtons(
//          isSelected: List.generate(3, (_) => false)..[_lineTypeIndex] = true,
//          children: <Widget>[
//            Text('line'),
//            Text('arc'),
//            Text('curve'),
//          ],
//          borderRadius: BorderRadius.circular(100),
//          borderWidth: 5,
//          borderColor: Colors.orange,
//          selectedBorderColor: Colors.deepOrange,
//          fillColor: Colors.orange.shade200,
//          onPressed: (index) {
//            _lineTypeIndex = index;
//            doChange();
//          },
//        ),
        Column(
          children: <Widget>[
            Table(
              children: <TableRow>[
                TableRow(children: [
                  DropdownButton(
                    value: _posType,
                    items: <DropdownMenuItem<NipLinePosType>>[
                      DropdownMenuItem(child: Text('line(a)'), value: NipLinePosType.angle),
                      DropdownMenuItem(child: Text('lineTo(pos)'), value: NipLinePosType.pos),
                      DropdownMenuItem(child: Text('relativeLineTo(pos)'), value: NipLinePosType.offset),
                      DropdownMenuItem(child: Text('lineToCorner(a)'), value: NipLinePosType.corner),
                    ],
                    onChanged: (value) {
                      _lineType = setType(_lineTypeIndex);
                      doChange();
                    },
                  ),
                  TextFormField(
                    controller: TextEditingController(),
                    decoration: new InputDecoration(labelText: "Enter your number"),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                  ),
                ])
              ],
            ),
            Slider(
              value: _lineAngle,
              min: -90,
              max: 90,
              divisions: 180,
              onChanged: (value) {
                _lineAngle = value;
                doChange();
              },
            ),
            Text('${_lineAngle.toStringAsFixed(1)}'),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              value: NipLinePosType.angle,
              groupValue: _posType,
              onChanged: (value) {
                _lineType = setType(_lineTypeIndex);
                doChange();
              },
            ),
            Text('line\'s angle'),
            Expanded(
              child: Slider(
                value: _lineAngle,
                min: -90,
                max: 90,
                divisions: 180,
                onChanged: _posType != NipLinePosType.angle
                    ? null
                    : (value) {
                        _lineAngle = value;
                        doChange();
                      },
              ),
            ),
            Text('${_lineAngle.toStringAsFixed(1)}'),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              value: NipLinePosType.pos,
              groupValue: _posType,
              onChanged: (value) {
                _lineType = setType(_lineTypeIndex);
                doChange();
              },
            ),
            Text('side\'s position'),
            Expanded(
              child: Slider(
                value: _pos,
                min: -100,
                max: 100,
                divisions: 200,
                onChanged: _posType != NipLinePosType.pos
                    ? null
                    : (value) {
                        _pos = value;
                        doChange();
                      },
              ),
            ),
            Text('${_pos.toStringAsFixed(1)}'),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              value: NipLinePosType.offset,
              groupValue: _posType,
              onChanged: (value) {
                _lineType = setType(_lineTypeIndex);
                doChange();
              },
            ),
            Text('side\'s offset'),
            Expanded(
              child: Slider(
                value: _offset,
                min: -100,
                max: 100,
                divisions: 200,
                onChanged: _posType != NipLinePosType.offset
                    ? null
                    : (value) {
                        _offset = value;
                        doChange();
                      },
              ),
            ),
            Text('${_offset.toStringAsFixed(1)}'),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              value: NipLinePosType.corner,
              groupValue: _posType,
              onChanged: (value) {
                _lineType = setType(_lineTypeIndex);
                doChange();
              },
            ),
            Text('corner\'s angle'),
            Expanded(
              child: Slider(
                value: _cornerAngle,
                min: -180,
                max: 180,
                divisions: 360,
                onChanged: _posType != NipLinePosType.corner
                    ? null
                    : (value) {
                        _cornerAngle = value;
                        doChange();
                      },
              ),
            ),
            Text('${_cornerAngle.toStringAsFixed(1)}'),
          ],
        ),
        Visibility(
          visible: _lineTypeIndex == 1,
          child: Row(
            children: <Widget>[
              Text('arc\'s angle'),
              Expanded(
                child: Slider(
                  value: _a1,
                  min: -100,
                  max: 100,
                  divisions: 200,
                  onChanged: (value) {
                    _a1 = value;
                    doChange();
                  },
                ),
              ),
              Text('${_a1.toStringAsFixed(1)}'),
            ],
          ),
        ),
        Visibility(
          visible: _lineTypeIndex == 2,
          child: Column(
            children: <Widget>[
              Align(alignment: Alignment.topLeft, child: Text('Curve\'s guideline 1:')),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _curve1Enabled,
                    onChanged: (value) {
                      _curve1Enabled = value;
                      doChange();
                    },
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('curves\'s α₁'),
                            Expanded(
                              child: Slider(
                                value: _a1,
                                min: -90,
                                max: 90,
                                divisions: 180,
                                onChanged: !_curve1Enabled
                                    ? null
                                    : (value) {
                                        _a1 = value;
                                        doChange();
                                      },
                              ),
                            ),
                            Text('${_a1.toStringAsFixed(1)}'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('curves\'s sz₁'),
                            Expanded(
                              child: Slider(
                                value: _sz1,
                                min: 0,
                                max: 2,
                                divisions: 12,
                                onChanged: !_curve1Enabled
                                    ? null
                                    : (value) {
                                        _sz1 = value;
                                        doChange();
                                      },
                              ),
                            ),
                            Text('${_sz1.toStringAsFixed(2)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(alignment: Alignment.topLeft, child: Text('Curve\'s guideline 2:')),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _curve2Enabled,
                    onChanged: (value) {
                      _curve2Enabled = value;
                      doChange();
                    },
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('curves\'s α₂'),
                            Expanded(
                              child: Slider(
                                value: _a2,
                                min: -90,
                                max: 90,
                                divisions: 180,
                                onChanged: !_curve2Enabled
                                    ? null
                                    : (value) {
                                        _a2 = value;
                                        doChange();
                                      },
                              ),
                            ),
                            Text('${_a2.toStringAsFixed(1)}'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('curves\'s sz₂'),
                            Expanded(
                              child: Slider(
                                value: _sz2,
                                min: 0,
                                max: 2,
                                divisions: 12,
                                onChanged: !_curve2Enabled
                                    ? null
                                    : (value) {
                                        _sz2 = value;
                                        doChange();
                                      },
                              ),
                            ),
                            Text('${_sz2.toStringAsFixed(2)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Value extends StatelessWidget {
  Value({
    this.caption,
    this.units,
    @required this.value,
    @required this.min,
    @required this.max,
    @required this.step,
    fractionDigits,
    this.onChanged,
  })  : divisions = ((max - min) / step).round(),
        num = ((value - min) / step).round(),
        fractionDigits = fractionDigits ?? 1;

  final String caption;
  final String units;
  final double value;
  final double min;
  final double max;
  final double step;
  final int divisions;
  final int num;
  final int fractionDigits;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: <Widget>[
          Table(children: [
            TableRow(
              children: <Widget>[
                Text(caption),
                Text('${value.toStringAsFixed(fractionDigits)}${units ?? ""}', textAlign: TextAlign.end)
//                Text('$num $divisions $value', textAlign: TextAlign.end)
              ],
            ),
          ]),
          Table(
            columnWidths: {
              0: FixedColumnWidth(40),
              1: FlexColumnWidth(40),
              2: FixedColumnWidth(40),
            },
            children: [
              TableRow(
                children: <Widget>[
                  RaisedButton(
                    child: Text('–'),
                    onPressed: () {
                      onChanged(num > 0 ? min + (num - 1) * step : min);
                    },
                  ),
                  Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: divisions,
                    onChanged: onChanged,
                  ),
                  RaisedButton(
                    child: Text('+'),
                    onPressed: () {
                      onChanged(num < divisions ? min + (num + 1) * step : max);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NipLinePos extends StatelessWidget {
  NipLinePos({
    this.caption,
    @required this.nipLine,
    this.onChanged,
  });

  final String caption;
  final NipLine nipLine;
  final ValueChanged<NipLine> onChanged;

  NipLineType setType(int lineTypeIndex) {
    return lineTypeIndex == 0 ? NipLineType.line : lineTypeIndex == 1 ? NipLineType.arc : NipLineType.curve;
  }

  @override
  Widget build(BuildContext context) {
    var value = nipLine.pos;
    double min;
    double max;
    var step = 1.0;
    var fractionDigits = 1;
    String units;

    switch (nipLine.posType) {
      case NipLinePosType.angle:
        min = -90;
        max = 90;
        units = '°';
        break;

      case NipLinePosType.pos:
        min = -100;
        max = 100;
        units = ' px';
        break;

      case NipLinePosType.offset:
        min = -100;
        max = 100;
        units = ' px';
        break;

      case NipLinePosType.corner:
        min = -180;
        max = 180;
        units = '°';
        break;
    }

    var divisions = ((max - min) / step).round();
    var num = ((value - min) / step).round();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: <Widget>[
          Text(caption),
          Table(
            columnWidths: {
              0: FlexColumnWidth(),
              1: FixedColumnWidth(60),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: <Widget>[
                  DropdownButton(
                    value: nipLine.posType,
                    items: <DropdownMenuItem<NipLinePosType>>[
                      DropdownMenuItem(child: Text('line\'s angle', textScaleFactor: 0.9), value: NipLinePosType.angle),
                      DropdownMenuItem(child: Text('pos', textScaleFactor: 0.9), value: NipLinePosType.pos),
                      DropdownMenuItem(child: Text('offset', textScaleFactor: 0.9), value: NipLinePosType.offset),
                      DropdownMenuItem(child: Text('corners angle', textScaleFactor: 0.9), value: NipLinePosType.corner),
                    ],
                    onChanged: (value) {
                      onChanged(NipLine(nipLine.lineType, value, nipLine.pos));
                    },
                  ),
                  Text('${value.toStringAsFixed(fractionDigits)}${units ?? ""}', textAlign: TextAlign.end)
  //                Text('0.0', textAlign: TextAlign.end)
                ],
              ),
            ]
          ),
          Table(
            columnWidths: {
              0: FixedColumnWidth(40),
              1: FlexColumnWidth(40),
              2: FixedColumnWidth(40),
            },
            children: [
              TableRow(
                children: <Widget>[
                  RaisedButton(
                    child: Text('–'),
                    onPressed: () =>
                        onChanged(NipLine(nipLine.lineType, nipLine.posType, num > 0 ? min + (num - 1) * step : min)),
                  ),
                  Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: divisions,
                    onChanged: (value) => onChanged(NipLine(nipLine.lineType, nipLine.posType, value)),
                  ),
                  RaisedButton(
                    child: Text('+'),
                    onPressed: () =>
                        onChanged(NipLine(nipLine.lineType, nipLine.posType, num > 0 ? min + (num + 1) * step : min)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  var _height = 50.0;
  var _width = 100.0;
  var _scale = 8.0;
//  var _zoomLevel = 0.0;
  var _drawDraft = true;

  // Whatsapp
  var _radius = 8.0;
  var _nipSide = NipSide.left;
  var _nipRadius = 1.0;
  var _nipSize = 10.0;
  var _nipOffset = NipOffset(absolute: 0.0);
  var _topLine = NipLine.line(0);
  var _bottomLine = NipLine.line(53);

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
  Widget build(BuildContext context) {
//  print('topLine.pos: ${_topLine.pos}');
//  print('bottomLine.pos: ${_bottomLine.pos}');

    var size = MediaQuery.of(context).size;
    print('screen: $size');

    var _drawer = Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: MaterialLocalizations.of(context)?.drawerLabel,
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(width: math.min(MediaQuery.of(context).size.width / 2, 320)),
        child: Material(
          elevation: 1.0,
          child: ListView(
            children: <Widget>[
              Value(
                caption: 'scale',
                value: _scale,
                units: 'x',
                min: 1.0,
                max: 16.0,
                step: 1.0,
                fractionDigits: 0,
                onChanged: (double value) {
                  setState(() {
                    _scale = value;
                  });
                },
              ),
//              Row(
//                children: <Widget>[
//                  Text('zoom', textAlign: TextAlign.right),
//                  Slider(
//                    value: _zoomLevel,
//                    //label: '${_zoom.round()}',
//                    min: 0.0,
//                    max: 5.0,
//                    divisions: 5,
//                    onChanged: (double value) {
//                      setState(() {
//                        _zoomLevel = value;
//                      });
//                    },
//                  ),
//                  Text('${math.pow(2, _zoomLevel).toStringAsFixed(0)}x'),
//                ],
//              ),
              Divider(),
              Text(
                'Box',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Value(
                caption: 'height',
                value: _height,
                units: ' dp',
                min: 10,
                max: 200,
                step: 1,
                fractionDigits: 0,
                onChanged: (double value) {
                  setState(() {
                    _height = value;
                  });
                },
              ),
              Value(
                caption: 'width',
                value: _width,
                units: ' dp',
                min: 10,
                max: 400,
                step: 1,
                fractionDigits: 0,
                onChanged: (double value) {
                  setState(() {
                    _width = value;
                  });
                },
              ),
              Value(
                caption: 'corner\'s radius',
                value: _radius,
                units: ' dp',
                min: 0,
                max: 40,
                step: 1,
                fractionDigits: 0,
                onChanged: (double value) {
                  setState(() {
                    _radius = value;
                  });
                },
              ),
              Divider(),
              Text(
                'Nip',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Value(
                caption: 'side',
                value: _nipSide.index.toDouble(),
                min: NipSide.left.index.toDouble(),
                max: NipSide.bottom.index.toDouble(),
                step: 1,
                fractionDigits: 0,
                onChanged: (double value) {
                  setState(() {
                    _nipSide = NipSide.values[value.floor()];
                  });
                },
              ),
              Value(
                caption: 'radius',
                value: _nipRadius,
                units: ' dp',
                min: 0,
                max: 10,
                step: 0.25,
                fractionDigits: 2,
                onChanged: (double value) {
                  setState(() {
                    _nipRadius = value;
                  });
                },
              ),
              Value(
                caption: 'size',
                value: _nipSize,
                units: ' dp',
                min: 0,
                max: 40,
                step: 1,
                fractionDigits: 0,
                onChanged: (double value) {
                  setState(() {
                    _nipSize = value;
                  });
                },
              ),
              Value(
                caption: 'offset.rel',
                value: _nipOffset.relative,
                min: 0,
                max: 1,
                step: 0.1,
                fractionDigits: 1,
                onChanged: (double value) {
                  setState(() {
                    _nipOffset = NipOffset(relative: value, absolute: _nipOffset.absolute);
                  });
                },
              ),
              Value(
                caption: 'offset.abs',
                value: _nipOffset.absolute,
                units: ' dp',
                min: -40,
                max: 120,
                step: 1,
                fractionDigits: 0,
                onChanged: (double value) {
                  setState(() {
                    _nipOffset = NipOffset(relative: _nipOffset.relative, absolute: value);
                  });
                },
              ),
              Divider(),
              NipLinePos(
                caption: 'Top line',
                nipLine: _topLine,
                onChanged: (nipLine) => setState(() {
                  _topLine = nipLine;
                }),
              ),
//              NipLineSelect(
//                caption: 'Top line',
//                nipLine: _topLine,
//                onChange: (nipLine) => setState(() {
//                  _topLine = nipLine;
//                }),
//              ),
              Divider(),
              NipLinePos(
                caption: 'Bottom line',
                nipLine: _bottomLine,
                onChanged: (nipLine) => setState(() {
                  _bottomLine = nipLine;
                }),
              ),
//              NipLineSelect(
//                caption: 'Bottom line',
//                nipLine: _bottomLine,
//                onChange: (nipLine) => setState(() {
//                  _bottomLine = nipLine;
//                }),
//              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Bubble demo'),
      ),
      body: Column(
        children: <Widget>[
          PhysicalModel(
            color: Colors.grey.shade300,
            elevation: 2.0,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Bubble(
                  radius: BubbleRadius(topLeft: _radius, topRight: _radius, bottomLeft: _radius, bottomRight: _radius),
                  nipSide: _nipSide,
                  nipRadius: _nipRadius,
                  nipSize: _nipSize,
                  nipOffset: _nipOffset,
                  topLine: _topLine,
                  bottomLine: _bottomLine,
                  color: Colors.lightBlue,
                  elevation: 1.0,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text('Lorem ipsum dolor sit amet'),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(40),
                child: Bubble(
                  scale: _scale,
                  radius: BubbleRadius(topLeft: _radius, topRight: _radius, bottomLeft: _radius, bottomRight: _radius),
                  nipSide: _nipSide,
                  nipRadius: _nipRadius,
                  nipSize: _nipSize,
                  nipOffset: _nipOffset,
                  topLine: _topLine,
                  bottomLine: _bottomLine,
                  color: Colors.lightBlue,
                  elevation: 1.0,
                  drawDraft: _drawDraft,
                  child: SizedBox(
                    height: _height,
                    width: _width,
//                          child: Text('a a a a a')
                  ),
                ),
              ),
            ),
          ),
//          Bubble(
//              scale: _scale,
//              radius: BubbleRadius(
//                  topLeft: _radius, topRight: _radius, bottomLeft: _radius, bottomRight: _radius),
//              nipSide: _nipSide,
//              nipRadius: _nipRadius,
//              nipSize: _nipSize,
//              nipOffset: _nipOffset,
//              topLine: _topLine,
//              bottomLine: _bottomLine,
//              color: Colors.lightBlue,
//              elevation: 1.0,
//              drawDraft: _drawDraft,
//              child: Container(
//                height: _height,
////                    padding: EdgeInsets.all(10),
////                    child: Text('a a a a a'),
////                    child: Text('a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a'),
//              )),
//          LimitedBox(
//            maxHeight: 200,
//            child: Container(
////                width: double.infinity,
////                height: 400.0,
//              color: Colors.yellow.withAlpha(64),
//              padding: EdgeInsets.all(20),
//              child: Builder(
//                builder: (BuildContext context) {
//                  return _zoomLevel == 0
//                      ? CustomPaint(
//                          painter: painter,
//                          child: Container(
//                              height: _height +
//                                  (_nipOffset.absolute < 0
//                                      ? -_nipOffset.absolute
//                                      : 0 +
//                                          (_nipOffset.absolute + 2 * _nipRadius > _height
//                                              ? _nipOffset.absolute + 2 * _nipRadius - _height
//                                              : 0))))
//                      : ZoomCustomPaint(
//                          painter: painter,
//                          padding: padding,
//                          child: Container(height: _height),
//                          zoom: pow(2, _zoomLevel));
//                },
//              ),
//            ),
//          ),
          PhysicalModel(
            color: Colors.grey.shade300,
            elevation: 2.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  Text('Draft'),
                  Switch(
                    value: _drawDraft,
                    onChanged: (bool value) {
                      setState(() {
                        _drawDraft = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: _drawer,
      endDrawer: _drawer,
    );
  }
}
