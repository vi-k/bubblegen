import 'dart:math';
import 'dart:ui' as ui;

import 'package:bubble_demo/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'MyPainter.dart';

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

//enum LineType { line, arc, curve }
enum PosType { angle, pos, offset, corner }

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
  NipLineType _type = NipLineType.line;
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
    _type = widget.nipLine.type;
    if (_type == NipLineType.line || _type == NipLineType.arc || _type == NipLineType.curve) {
      _lineAngle = widget.nipLine.pos;
    } else if (_type == NipLineType.lineTo || _type == NipLineType.arcTo || _type == NipLineType.curveTo) {
      _pos = widget.nipLine.pos;
    } else if (_type == NipLineType.relativeLineTo ||
        _type == NipLineType.relativeArcTo ||
        _type == NipLineType.relativeCurveTo) {
      _offset = widget.nipLine.pos;
    } else if (_type == NipLineType.lineToCorner ||
        _type == NipLineType.arcToCorner ||
        _type == NipLineType.curveToCorner) {
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

  PosType getPosType(NipLineType lineType) {
    PosType posType;

    switch (lineType) {
      case NipLineType.line:
      case NipLineType.arc:
      case NipLineType.curve:
        posType = PosType.angle;
        break;

      case NipLineType.lineTo:
      case NipLineType.arcTo:
      case NipLineType.curveTo:
        posType = PosType.pos;
        break;

      case NipLineType.relativeLineTo:
      case NipLineType.relativeArcTo:
      case NipLineType.relativeCurveTo:
        posType = PosType.offset;
        break;

      case NipLineType.lineToCorner:
      case NipLineType.arcToCorner:
      case NipLineType.curveToCorner:
        posType = PosType.corner;
        break;
    }

    return posType;
  }

  NipLineType setType(int lineTypeIndex, PosType posType) {
    NipLineType type;

    switch (posType) {
      case PosType.angle:
        type = lineTypeIndex == 0 ? NipLineType.line : lineTypeIndex == 1 ? NipLineType.arc : NipLineType.curve;
        break;

      case PosType.pos:
        type = lineTypeIndex == 0 ? NipLineType.lineTo : lineTypeIndex == 1 ? NipLineType.arcTo : NipLineType.curveTo;
        break;

      case PosType.offset:
        type = lineTypeIndex == 0
            ? NipLineType.relativeLineTo
            : lineTypeIndex == 1 ? NipLineType.relativeArcTo : NipLineType.relativeCurveTo;
        break;

      case PosType.corner:
        type = lineTypeIndex == 0
            ? NipLineType.lineToCorner
            : lineTypeIndex == 1 ? NipLineType.arcToCorner : NipLineType.curveToCorner;
        break;
    }

    return type;
  }

  void doChange() {
    if (widget.onChange != null) {
      NipLine nipLine;

      switch (_type) {
        case NipLineType.line:
          nipLine = NipLine.line(_lineAngle);
          break;
        case NipLineType.lineTo:
          nipLine = NipLine.lineTo(_pos);
          break;
        case NipLineType.relativeLineTo:
          nipLine = NipLine.relativeLineTo(_offset);
          break;
        case NipLineType.lineToCorner:
          nipLine = NipLine.lineToCorner(_cornerAngle);
          break;

        case NipLineType.arc:
          nipLine = NipLine.arc(_lineAngle, _a1);
          break;
        case NipLineType.arcTo:
          nipLine = NipLine.arcTo(_pos, _a1);
          break;
        case NipLineType.relativeArcTo:
          nipLine = NipLine.relativeArcTo(_offset, _a1);
          break;
        case NipLineType.arcToCorner:
          nipLine = NipLine.arcToCorner(_cornerAngle, _a1);
          break;

        case NipLineType.curve:
          nipLine = NipLine.curve(_lineAngle,
              angle1: _curve1Enabled ? _a1 : null,
              size1: _curve1Enabled ? _sz1 : null,
              angle2: _curve2Enabled ? _a2 : null,
              size2: _curve2Enabled ? _sz2 : null);
          break;
        case NipLineType.curveTo:
          nipLine = NipLine.curveTo(_pos,
              angle1: _curve1Enabled ? _a1 : null,
              size1: _curve1Enabled ? _sz1 : null,
              angle2: _curve2Enabled ? _a2 : null,
              size2: _curve2Enabled ? _sz2 : null);
          break;
        case NipLineType.relativeCurveTo:
          nipLine = NipLine.relativeCurveTo(_offset,
              angle1: _curve1Enabled ? _a1 : null,
              size1: _curve1Enabled ? _sz1 : null,
              angle2: _curve2Enabled ? _a2 : null,
              size2: _curve2Enabled ? _sz2 : null);
          break;
        case NipLineType.curveToCorner:
          nipLine = NipLine.curveToCorner(_cornerAngle,
              angle1: _curve1Enabled ? _a1 : null,
              size1: _curve1Enabled ? _sz1 : null,
              angle2: _curve2Enabled ? _a2 : null,
              size2: _curve2Enabled ? _sz2 : null);
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
        ToggleButtons(
          isSelected: List.generate(3, (_) => false)..[_lineTypeIndex] = true,
          children: <Widget>[
            Text('line'),
            Text('arc'),
            Text('curve'),
          ],
          borderRadius: BorderRadius.circular(100),
          borderWidth: 5,
          borderColor: Colors.orange,
          selectedBorderColor: Colors.deepOrange,
          fillColor: Colors.orange.shade200,
          onPressed: (index) {
            _lineTypeIndex = index;
            doChange();
          },
        ),
        Row(
          children: <Widget>[
            Radio(
              value: PosType.angle,
              groupValue: getPosType(_type),
              onChanged: (value) {
                _type = setType(_lineTypeIndex, value);
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
                onChanged: getPosType(_type) != PosType.angle
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
              value: PosType.pos,
              groupValue: getPosType(_type),
              onChanged: (value) {
                _type = setType(_lineTypeIndex, value);
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
                onChanged: getPosType(_type) != PosType.pos
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
              value: PosType.offset,
              groupValue: getPosType(_type),
              onChanged: (value) {
                _type = setType(_lineTypeIndex, value);
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
                onChanged: getPosType(_type) != PosType.offset
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
              value: PosType.corner,
              groupValue: getPosType(_type),
              onChanged: (value) {
                _type = setType(_lineTypeIndex, value);
                doChange();
              },
            ),
            Text('corner\'s angle'),
            Expanded(
              child: Slider(
                value: _cornerAngle,
                min: -270,
                max: 270,
                divisions: 560,
                onChanged: getPosType(_type) != PosType.corner
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  var _height = 50.0;
  var _scale = 1.0;
  var _zoomLevel = 0.0;
  var _drawDraft = false;

  var _radius = 20.0;
  var _nipSize = 40.0;
  var _nipOffset = NipOffset(absolute: 10.0);
  var _nipRadius = 10.0;
  var _nipSide = NipSide.left;
  var _topLine = NipLine.line(0);
  var _bottomLine = NipLine.line(30);

  // Whatsapp
//  var _boxRadius = 8.0;
//  var _nipWidth = 10.0;
//  var _nipRadius = 1.0;
//  var _nipYOffset = 0.0;
//  var _topLine = NipLine.line(0);
//  var _bottomLine = NipLine.line(53);
//  var _startTopAngle = 0.0;
//  var _finishTopPos = 0.0;
//  var _finishTopAngle = 180.0;
//  var _startBottomAngle = -53.0;
//  var _finishBottomPos = 14.0;
//  var _finishBottomAngle = 127.0;

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
//  var _boxRadius = 20.0;
//  var _nipWidth = 0.0;
//  var _nipRadius = 1.0;
//  var _nipYOffset = 0.0;
//  var _startTopAngle = 0.0;
//  var _finishTopPos = 0.0;
//  var _finishTopAngle = 180.0;
//  var _startBottomAngle = -90.0;
//  var _finishBottomPos = -90.0;
//  var _finishBottomAngle = 90.0;

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
    final painter = MyPainter(
      topLine: _topLine,
      bottomLine: _bottomLine,
      boxRadius: _radius,
      nipWidth: _nipSize,
      nipRadius: _nipRadius,
      nipYOffset: _nipOffset.absolute,
      height: _height,
      drawDraft: _drawDraft,
    );

    final padding = EdgeInsets.only(
        left: _nipSize + 10,
        top: 10.0 + (_nipOffset.absolute < 0 ? -_nipOffset.absolute : 0),
        right: 10,
        bottom: 10.0 + (_nipOffset.absolute + 2 * _nipRadius > _height ? _nipOffset.absolute + 2 * _nipRadius - _height : 0));

    return Scaffold(
      appBar: AppBar(
        title: Text('Bubble demo'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            child: Bubble(
                scale: _scale.toDouble(),
                radius: BubbleRadius(
                    topLeft: _radius, topRight: _radius, bottomLeft: _radius, bottomRight: _radius),
                nipSide: _nipSide,
                nipRadius: _nipRadius,
                nipSize: _nipSize,
                nipOffset: _nipOffset,
                topLine: _topLine,
                bottomLine: _bottomLine,
                color: Colors.lightBlue,
                elevation: 2.0,
                drawDraft: _drawDraft,
                child: Container(
                    height: _height,
//                    padding: EdgeInsets.all(10),
//                    child: Text('a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a a'),
                    )),
          ),
          LimitedBox(
            maxHeight: 200,
            child: Container(
//                width: double.infinity,
//                height: 400.0,
              color: Colors.yellow.withAlpha(64),
              padding: EdgeInsets.all(20),
              child: Builder(
                builder: (BuildContext context) {
                  return _zoomLevel == 0
                      ? CustomPaint(
                          painter: painter,
                          child: Container(
                              height: _height +
                                  (_nipOffset.absolute < 0
                                      ? -_nipOffset.absolute
                                      : 0 +
                                          (_nipOffset.absolute + 2 * _nipRadius > _height
                                              ? _nipOffset.absolute + 2 * _nipRadius - _height
                                              : 0))))
                      : ZoomCustomPaint(
                          painter: painter,
                          padding: padding,
                          child: Container(height: _height),
                          zoom: pow(2, _zoomLevel));
                },
              ),
            ),
          ),
//            Text('$_size'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('scale', textAlign: TextAlign.right),
                            Slider(
                              value: _scale,// scaleLevel(_scale),
                              min: 1.0,
                              max: 4.0,
                              divisions: 30,
                              onChanged: (double value) {
                                setState(() {
                                  _scale = value;//scaleFromLevel(value);
                                });
                              },
                            ),
                            Text('${_scale.toStringAsFixed(1)}x'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('zoom', textAlign: TextAlign.right),
                            Slider(
                              value: _zoomLevel,
                              //label: '${_zoom.round()}',
                              min: 0.0,
                              max: 5.0,
                              divisions: 5,
                              onChanged: (double value) {
                                setState(() {
                                  _zoomLevel = value;
                                });
                              },
                            ),
                            Text('${pow(2, _zoomLevel).toStringAsFixed(0)}x'),
                          ],
                        ),
                        Divider(),
                        Text(
                          'Box',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: <Widget>[
                            Text('height', textAlign: TextAlign.right),
                            Slider(
                              value: _height,
                              min: 10.0,
                              max: 200.0,
                              divisions: 190,
                              onChanged: (double value) {
                                setState(() {
                                  _height = value;
                                });
                              },
                            ),
                            Text('${_height.toStringAsFixed(0)}'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('corner\'s radius', textAlign: TextAlign.right),
                            Slider(
                              value: _radius,
                              min: 0.0,
                              max: 40.0,
                              divisions: 40,
                              onChanged: (double value) {
                                setState(() {
                                  _radius = value;
                                });
                              },
                            ),
                            Text('${_radius.toStringAsFixed(1)}'),
                          ],
                        ),
                        Divider(),
                        Text(
                          'Nip',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: <Widget>[
                            Text('side', textAlign: TextAlign.right),
                            Slider(
                              value: _nipSide.index.toDouble(),
                              min: NipSide.left.index.toDouble(),
                              max: NipSide.bottom.index.toDouble(),
                              divisions: 3,
                              onChanged: (double value) {
                                setState(() {
                                  _nipSide = NipSide.values[value.floor()];
                                });
                              },
                            ),
                            Text(_nipSide.toString().replaceFirst(RegExp(r'NipSide\.'), '')),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('radius', textAlign: TextAlign.right),
                            Slider(
                              value: _nipRadius,
                              min: 0.0,
                              max: 10.0,
                              divisions: 40,
                              onChanged: (double value) {
                                setState(() {
                                  _nipRadius = value;
                                });
                              },
                            ),
                            Text('${_nipRadius.toStringAsFixed(2)}'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('size', textAlign: TextAlign.right),
                            Slider(
                              value: _nipSize,
                              min: 0.0,
                              max: 40.0,
                              divisions: 40,
                              onChanged: (double value) {
                                setState(() {
                                  _nipSize = value;
                                });
                              },
                            ),
                            Text('${_nipSize.toStringAsFixed(1)}'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('offset.rel', textAlign: TextAlign.right),
                            Slider(
                              value: _nipOffset.relative,
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              onChanged: (double value) {
                                setState(() {
                                  _nipOffset = NipOffset(relative: value, absolute: _nipOffset.absolute);
                                });
                              },
                            ),
                            Text('${_nipOffset.relative.toStringAsFixed(1)}'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('offset.abs', textAlign: TextAlign.right),
                            Slider(
                              value: _nipOffset.absolute,
                              min: -40.0,
                              max: 120.0,
                              divisions: 160,
                              onChanged: (double value) {
                                setState(() {
                                  _nipOffset = NipOffset(relative: _nipOffset.relative, absolute: value);
                                });
                              },
                            ),
                            Text('${_nipOffset.absolute.toStringAsFixed(1)}'),
                          ],
                        ),
                        Divider(),
                        NipLineSelect(
                          caption: 'Top line',
                          nipLine: _topLine,
                          onChange: (nipLine) => setState(() {
                            _topLine = nipLine;
                          }),
                        ),
                        Divider(),
                        NipLineSelect(
                          caption: 'Bottom line',
                          nipLine: _bottomLine,
                          onChange: (nipLine) => setState(() {
                            _bottomLine = nipLine;
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          Row(
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
        ],
      ),
    );
  }
}

double scaleLevel(int scale) {
  int s = scale;
  int l = -1;
  while (s != 0) {
    l++;
    s >>= 1;
  }
  return l.toDouble();
}

int scaleFromLevel(double level) {
  return (1 << level.round());
}