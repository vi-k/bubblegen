import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

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

class ScaledCustomPaint extends StatefulWidget {
  final CustomPainter painter;
  final double scale;
  final Widget child;
  final EdgeInsets padding;

  const ScaledCustomPaint({Key key, this.painter, this.scale = 1.0, this.child, this.padding}) : super(key: key);

  @override
  _ScaledCustomPaintState createState() => _ScaledCustomPaintState();
}

class _ScaledCustomPaintState extends State<ScaledCustomPaint> {
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
        painter: ScaledCustomPaintPainter(
            painter: widget.painter,
            image: this._image,
            update: update,
            ratio: ratio,
            scale: this.widget.scale,
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

class ScaledCustomPaintPainter extends CustomPainter {
  ScaledCustomPaintPainter({
    this.image,
    this.update,
    this.ratio,
    this.scale,
    this.painter,
    this.onUpdate,
  }) : super();

  final ui.Image image;
  final bool update;
  final double ratio;
  final double scale;
  final CustomPainter painter;
  final void Function(ui.Image) onUpdate;

  @override
  void paint(Canvas canvas, Size size) {
    print('paint $image $size $this');
    if (this.image != null) {
      var paint = Paint();
      paint.isAntiAlias = true;
      canvas.scale(this.scale / this.ratio, this.scale / this.ratio);
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
  NipPosType _posType = NipPosType.angle;
  var _lineAngle = 0.0;
  var _sidePos = 0.0;
  var _cornerPos = -90.0;
  var _h = 0.0; // arc's height (or finish line's radius?)
  var _curve1Enabled = true;
  var _a1 = 0.0; // curve's α₁
  var _sz1 = 2.0 / 3.0; // curve's sz₁
  var _curve2Enabled = true;
  var _a2 = 90.0; // curve's α₂
  var _sz2 = 2.0 / 3.0; // curve's sz₂

  @override
  void initState() {
    _posType = widget.nipLine.posType;
    if (_posType == NipPosType.angle) {
      _lineAngle = widget.nipLine.pos;
    } else if (_posType == NipPosType.side) {
      _sidePos = widget.nipLine.pos;
    } else if (_posType == NipPosType.corner) {
      _cornerPos = widget.nipLine.pos;
    }

    _h = widget.nipLine.h;
    if (_h != 0.0) _lineTypeIndex = 1;

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

  void doChange() {
    if (widget.onChange != null) {
      NipLine nipLine;

      switch (_lineTypeIndex) {
        case 0:
          switch (_posType) {
            case NipPosType.angle:
              nipLine = NipLine.line(_lineAngle);
              break;
            case NipPosType.side:
              nipLine = NipLine.lineTo(_sidePos);
              break;
            case NipPosType.corner:
              nipLine = NipLine.lineToCorner(_cornerPos);
              break;
          }
          break;

        case 1:
          switch (_posType) {
            case NipPosType.angle:
              nipLine = NipLine.arc(_lineAngle, _h);
              break;
            case NipPosType.side:
              nipLine = NipLine.arcTo(_sidePos, _h);
              break;
            case NipPosType.corner:
              nipLine = NipLine.arcToCorner(_cornerPos, _h);
              break;
          }
          break;

        case 2:
          switch (_posType) {
            case NipPosType.angle:
              nipLine = NipLine.curve(_lineAngle,
                  angle1: _curve1Enabled ? _a1 : null,
                  size1: _curve1Enabled ? _sz1 : null,
                  angle2: _curve2Enabled ? _a2 : null,
                  size2: _curve2Enabled ? _sz2 : null);
              break;
            case NipPosType.side:
              nipLine = NipLine.curveTo(_sidePos,
                  angle1: _curve1Enabled ? _a1 : null,
                  size1: _curve1Enabled ? _sz1 : null,
                  angle2: _curve2Enabled ? _a2 : null,
                  size2: _curve2Enabled ? _sz2 : null);
              break;
            case NipPosType.corner:
              nipLine = NipLine.curveToCorner(_cornerPos,
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
        Align(alignment: Alignment.topLeft, child: Text('Position:')),
        Row(
          children: <Widget>[
            Radio(
              value: NipPosType.angle,
              groupValue: _posType,
              onChanged: (value) {
                _posType = value;
                doChange();
              },
            ),
            Text('by line\'s angle'),
            Expanded(
              child: Slider(
                value: _lineAngle,
                min: -80,
                max: 80,
                divisions: 160,
                onChanged: _posType != NipPosType.angle
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
              value: NipPosType.side,
              groupValue: _posType,
              onChanged: (value) {
                _posType = value;
                doChange();
              },
            ),
            Text('y offset on the side'),
            Expanded(
              child: Slider(
                value: _sidePos,
                min: -50,
                max: 50,
                divisions: 100,
                onChanged: _posType != NipPosType.side
                    ? null
                    : (value) {
                        _sidePos = value;
                        doChange();
                      },
              ),
            ),
            Text('${_sidePos.toStringAsFixed(1)}'),
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              value: NipPosType.corner,
              groupValue: _posType,
              onChanged: (value) {
                _posType = value;
                doChange();
              },
            ),
            Text('angle of corners'),
            Expanded(
              child: Slider(
                value: _cornerPos <= -90 ? -(_cornerPos + 180) : _cornerPos >= 90 ? (180 - _cornerPos) : 0,
                min: -90,
                max: 90,
                divisions: 180,
                onChanged: _posType != NipPosType.corner
                    ? null
                    : (value) {
                        _cornerPos = value <= 0 ? -(value + 180) : (180 - value);
                        doChange();
                      },
              ),
            ),
            Text('${_cornerPos.toStringAsFixed(1)}'),
          ],
        ),
        Visibility(
          visible: _lineTypeIndex == 1,
          child: Row(
            children: <Widget>[
              Text('arc\'s height'),
              Expanded(
                child: Slider(
                  value: _h,
                  min: -100,
                  max: 100,
                  divisions: 200,
                  onChanged: (value) {
                    _h = value;
                    doChange();
                  },
                ),
              ),
              Text('${_h.toStringAsFixed(1)}'),
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
  var _scaleLevel = 0.0;
  var _drawDraft = false;
  static String _text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit,' +
      ' sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
  TextEditingController _controller;

  void initState() {
    super.initState();
    this._controller = TextEditingController(text: _text);
  }

  void dispose() {
    this._controller.dispose();
    super.dispose();
  }

  // Whatsapp
  var _boxRadius = 20.0;
  var _nipWidth = 40.0;
  var _nipRadius = 10.0;
  var _nipYOffset = 20.0;
  var _startTopAngle = 0.0;
  var _finishTopPos = 0.0;
  var _finishTopAngle = 180.0;
  var _startBottomAngle = -53.0;
  var _finishBottomPos = 14.0;
  var _finishBottomAngle = 127.0;

  // Whatsapp
//  var _boxRadius = 8.0;
//  var _nipWidth = 10.0;
//  var _nipRadius = 1.0;
//  var _nipYOffset = 0.0;
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

  var _topLine = NipLine.line(-29);
  var _bottomLine = NipLine.line(-45);

  @override
  Widget build(BuildContext context) {
    final painter = MyPainter(
      topLine: _topLine,
      bottomLine: _bottomLine,
      boxRadius: _boxRadius,
      nipWidth: _nipWidth,
      nipRadius: _nipRadius,
      nipYOffset: _nipYOffset,
      startTopAngle: _startTopAngle,
      finishTopPos: _finishTopPos,
      finishTopAngle: _finishTopAngle,
      startBottomAngle: _startBottomAngle,
      finishBottomPos: _finishBottomPos,
      finishBottomAngle: _finishBottomAngle,
      drawDraft: _drawDraft,
    );

    final padding = EdgeInsets.only(left: _nipWidth + 10, top: 10.0 + (_nipYOffset < 0 ? -_nipYOffset : 0), right: 10, bottom: 10);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bubble demo'),
      ),
      body: Column(
        children: <Widget>[
          LimitedBox(
            maxHeight: 200,
            child: Container(
//                width: double.infinity,
//                height: 120.0,
              color: Colors.yellow.withAlpha(64),
              padding: EdgeInsets.all(10),
              child: Builder(
                builder: (BuildContext context) {
                  return _scaleLevel == 0
                      ? CustomPaint(
                          painter: painter, child: Container(padding: padding, child: Text(this._controller.text)))
                      : ScaledCustomPaint(
                          painter: painter,
                          padding: padding,
                          child: Opacity(opacity: 0.0, child: Text(this._controller.text)),
                          scale: pow(2, _scaleLevel));
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
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      minLines: 1,
                      maxLines: 3,
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Text',
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('scale', textAlign: TextAlign.right),
                            Slider(
                              value: _scaleLevel,
                              //label: '${_scale.round()}',
                              min: 0.0,
                              max: 5.0,
                              divisions: 5,
                              onChanged: (double value) {
                                setState(() {
                                  _scaleLevel = value;
                                });
                              },
                            ),
                            Text('${pow(2, _scaleLevel).toStringAsFixed(0)}x'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('boxRadius', textAlign: TextAlign.right),
                            Slider(
                              value: _boxRadius,
                              min: 0.0,
                              max: 40.0,
                              divisions: 40,
                              onChanged: (double value) {
                                setState(() {
                                  _boxRadius = value;
                                });
                              },
                            ),
                            Text('${_boxRadius.toStringAsFixed(1)}'),
                          ],
                        ),
                        Divider(),
                        Text(
                          'Nip',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: <Widget>[
                            Text('nipRadius', textAlign: TextAlign.right),
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
                            Text('nipWidth', textAlign: TextAlign.right),
                            Slider(
                              value: _nipWidth,
                              min: 0.0,
                              max: 40.0,
                              divisions: 40,
                              onChanged: (double value) {
                                setState(() {
                                  _nipWidth = value;
                                });
                              },
                            ),
                            Text('${_nipWidth.toStringAsFixed(1)}'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('nipYOffset', textAlign: TextAlign.right),
                            Slider(
                              value: _nipYOffset,
                              min: -40.0,
                              max: 40.0,
                              divisions: 80,
                              onChanged: (double value) {
                                setState(() {
                                  _nipYOffset = value;
                                });
                              },
                            ),
                            Text('${_nipYOffset.toStringAsFixed(1)}'),
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
                        Row(
                          children: <Widget>[
                            Text('startTopAngle', textAlign: TextAlign.right),
                            Slider(
                              value: _startTopAngle,
                              min: -90.0,
                              max: 90.0,
                              divisions: 180,
                              onChanged: (double value) {
                                setState(() {
                                  _startTopAngle = value;
                                });
                              },
                            ),
                            Text('${_startTopAngle.toStringAsFixed(1)}'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('finishTopPos', textAlign: TextAlign.right),
                            Slider(
                              value: _finishTopPos,
                              min: -90.0,
                              max: 40.0,
                              divisions: 130,
                              onChanged: (double value) {
                                setState(() {
                                  _finishTopPos = value;
                                });
                              },
                            ),
                            Text('${_finishTopPos.toStringAsFixed(1)}'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('finishTopAngle', textAlign: TextAlign.right),
                            Slider(
                              value: _finishTopAngle,
                              min: 90.0,
                              max: 270.0,
                              divisions: 180,
                              onChanged: (double value) {
                                setState(() {
                                  _finishTopAngle = value;
                                });
                              },
                            ),
                            Text('${_finishTopAngle.toStringAsFixed(1)}'),
                          ],
                        ),
                        Divider(),
                        Text(
                          'Bottom line',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: <Widget>[
                            Text('startBottomAngle', textAlign: TextAlign.right),
                            Slider(
                              value: _startBottomAngle,
                              min: -90.0,
                              max: 90.0,
                              divisions: 180,
                              onChanged: (double value) {
                                setState(() {
                                  _startBottomAngle = value;
                                });
                              },
                            ),
                            Text('${_startBottomAngle.toStringAsFixed(1)}'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('finishBottomPos', textAlign: TextAlign.right),
                            Slider(
                              value: _finishBottomPos,
                              min: -90.0,
                              max: 40,
                              divisions: 130,
                              onChanged: (double value) {
                                setState(() {
                                  _finishBottomPos = value;
                                });
                              },
                            ),
                            Text('${_finishBottomPos.toStringAsFixed(1)}'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('finishBottomAngle', textAlign: TextAlign.right),
                            Slider(
                              value: _finishBottomAngle,
                              min: 90.0,
                              max: 270.0,
                              divisions: 180,
                              onChanged: (double value) {
                                setState(() {
                                  _finishBottomAngle = value;
                                });
                              },
                            ),
                            Text('${_finishBottomAngle.toStringAsFixed(1)}'),
                          ],
                        ),
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
                            Radio<int>(
                              groupValue: 1,
                              value: 1,
                              onChanged: (int value) {},
                            ),
                            Text('1'),
                            Radio<int>(
                              groupValue: 1,
                              value: 1,
                              onChanged: (int value) {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(''),
                  Text(''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
