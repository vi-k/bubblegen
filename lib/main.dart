//import 'dart:math' as math;
//import 'dart:ui' as ui;

import 'package:bubble_demo/bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(MyApp());

//final primarySwatch = createSwatch(Color.fromARGB(255, 132, 151, 176));
//final primarySwatch = createSwatch(Color.fromARGB(255, 132, 151, 176));
final primarySwatch = Colors.blue;
MaterialColor cursorSwatch;

MaterialColor createSwatch(Color color) {
  return MaterialColor(color.value, {
    50: Color.alphaBlend(color.withOpacity(0.12), Colors.white), // Почти совпадают с Colors.blue
    100: Color.alphaBlend(color.withOpacity(0.30), Colors.white),
    200: Color.alphaBlend(color.withOpacity(0.50), Colors.white),
    300: Color.alphaBlend(color.withOpacity(0.70), Colors.white),
    400: Color.alphaBlend(color.withOpacity(0.85), Colors.white),
    500: color,
    600: Color.alphaBlend(
        color.withOpacity(0.91), Colors.black), // Синяя составляющая расходится с Colors.blue, равнялся по зелёному
    700: Color.alphaBlend(
        color.withOpacity(0.79), Colors.black), // Тогда они расходятся по цвету, но совпдают по яркости
    800: Color.alphaBlend(color.withOpacity(0.68), Colors.black),
    900: Color.alphaBlend(color.withOpacity(0.48), Colors.black),
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    cursorSwatch = createSwatch(Theme.of(context).cursorColor);
    cursorSwatch = createSwatch(Colors.blue);

    return MaterialApp(
      title: 'Bubble Demo',
      theme: ThemeData(
        primarySwatch: primarySwatch,
        cursorColor: cursorSwatch[500],
        textSelectionColor: cursorSwatch[200],
        textSelectionHandleColor: cursorSwatch[400],
      ),
      home: MyHomePage(title: 'Bubble Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//class ZoomCustomPaint extends StatefulWidget {
//  final CustomPainter painter;
//  final double zoom;
//  final Widget child;
//  final EdgeInsets padding;
//
//  const ZoomCustomPaint({Key key, this.painter, this.zoom = 1.0, this.child, this.padding}) : super(key: key);
//
//  @override
//  _ZoomCustomPaintState createState() => _ZoomCustomPaintState();
//}
//
//class _ZoomCustomPaintState extends State<ZoomCustomPaint> {
//  ui.Image _image;
//  bool _update = true;
//
//  @override
//  Widget build(BuildContext context) {
//    var ratio = MediaQuery.of(context).devicePixelRatio;
//    var update = this._update;
//    this._update = true;
////    print('build $this');
//
//    return Container(
//      child: CustomPaint(
//        child: Container(padding: widget.padding, child: widget.child),
////      painter: widget.painter,
//        painter: ZoomCustomPaintPainter(
//            painter: widget.painter,
//            image: this._image,
//            update: update,
//            ratio: ratio,
//            zoom: this.widget.zoom,
//            onUpdate: (image) {
//              setState(() {
//                this._image = image;
//                this._update = false;
////                print('repaint without updating');
//              });
//            }),
//      ),
//    );
//  }
//}
//
//class ZoomCustomPaintPainter extends CustomPainter {
//  ZoomCustomPaintPainter({
//    this.image,
//    this.update,
//    this.ratio,
//    this.zoom,
//    this.painter,
//    this.onUpdate,
//  }) : super();
//
//  final ui.Image image;
//  final bool update;
//  final double ratio;
//  final double zoom;
//  final CustomPainter painter;
//  final void Function(ui.Image) onUpdate;
//
//  @override
//  void paint(Canvas canvas, Size size) {
////    print('paint $image $size $this');
//    if (this.image != null) {
//      var paint = Paint();
//      paint.isAntiAlias = true;
//      canvas.scale(this.zoom / this.ratio, this.zoom / this.ratio);
//      canvas.drawImage(this.image, Offset.zero, paint);
//    }
//
//    if (this.update) {
//      var imageSize = Size(size.width * this.ratio, size.height * this.ratio);
////      print('update $ratio $imageSize');
//      var pictureRecorder = ui.PictureRecorder();
//      var canvas = Canvas(pictureRecorder);
//      canvas.scale(this.ratio);
//      painter.paint(canvas, size);
//      var pic = pictureRecorder.endRecording();
//      pic.toImage(imageSize.width.ceil(), imageSize.height.ceil()).then((image) {
////        print('onUpdate');
//        this.onUpdate?.call(image);
//      });
//    }
//  }
//
//  @override
//  bool shouldRepaint(CustomPainter oldDelegate) {
//    return true;
//  }
//}

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

class Value extends StatefulWidget {
  const Value({
    this.caption,
    this.horizontal = false,
    this.inputWidth,
    this.units,
    @required this.value,
    this.min = double.negativeInfinity,
    this.max = double.infinity,
    @required this.step,
    this.fractionDigits = 0,
    this.textAlign = TextAlign.end,
    this.onBeforeChanging,
    @required this.onChanged,
    this.onConvertToText,
  })  : assert(!horizontal || inputWidth != null),
        assert(step != 0),
        assert(min < max),
        assert(onChanged != null);

  final String caption;
  final bool horizontal;
  final double inputWidth;
  final String units;
  final double value;
  final double min;
  final double max;
  final double step;
  final int fractionDigits;
  final TextAlign textAlign;
  final double Function(double) onBeforeChanging;
  final Function(double) onChanged;
  final String Function(double) onConvertToText;

  @override
  _ValueState createState() => _ValueState();
}

class _ValueState extends State<Value> {
  double _value;
  TextEditingController _controller;
  FocusNode _focusNode;
  String _errorText;
  String _debugText;
  static const _buttonWidth = 36.0;
  static const _buttonPadding = 4.0;

  @override
  void initState() {
    super.initState();

    _value = widget.value;
    _controller = TextEditingController();
    _controller.text = convertToText(_value);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  static double floor(double value, int fractionDigits) {
    return double.parse(value.toStringAsFixed(fractionDigits));
  }

  void change(double diff) {
    final floorValue = floor(_value, widget.fractionDigits);

    // Если значение не выровнено по границе шага, то выравниваем в соответствующую сторону
    var value = _value;
    if (floorValue == value)
      value = floor(value + diff, widget.fractionDigits);
    else if (diff < 0)
      value = floorValue;
    else if (diff > 0) value = floor(floorValue + diff, widget.fractionDigits);

    setNewValue(value, true);

    _focusNode.requestFocus();
    _focusNode.unfocus();
  }

  void setNewValue(double value, bool correctTextField) {
    String errorText;

    var correctedValue = value;
    var setValue = true;

    if (correctedValue == null) {
      correctedValue = _value;
      errorText = 'value incorrect';
    } else if (correctedValue < widget.min) {
      correctedValue = widget.min;
      errorText = 'value must be ≥ ${widget.min}';
    } else if (correctedValue > widget.max) {
      correctedValue = widget.max;
      errorText = 'value must be ≤ ${widget.max}';
    } else if (widget.onBeforeChanging != null) {
      final correctedValue2 = widget.onBeforeChanging(correctedValue);
      if (correctedValue2 != correctedValue) {
        correctedValue = correctedValue2;
        errorText = 'value incorrect';
        setValue = false;
      }
    }

    // Вносим изменения в TextField
    if (correctTextField) {
      final str = convertToText(correctedValue);
      _controller.text = str;
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: str.length));
      // Во время преобразования могло произойти округление, учитываем это
      _value = widget.onConvertToText == null ? convertToValue(str) : correctedValue;
      widget.onChanged(_value);
      errorText = null;
    } else if (correctedValue != _value && setValue) {
      _value = value;
      widget.onChanged(_value);
    }

    if (errorText != _errorText)
      setState(() {
        _errorText = errorText;
      });
  }

  String convertToText(double value) {
    return widget.onConvertToText?.call(value) ?? value.toStringAsFixed(widget.fractionDigits);
  }

  double convertToValue(String value) {
    return double.tryParse(value);
  }

  @override
  Widget build(BuildContext context) {
    // print('build $this');

    if (_value != widget.value) {
      _value = widget.value;
      _controller.text = convertToText(_value);
    }

    final input = FocusableActionDetector(
      onFocusChange: (focused) {
        if (!focused) setNewValue(convertToValue(_controller.text), false);
      },
      child: Stack(
        children: <Widget>[
          TextField(
            readOnly: widget.onConvertToText != null,
            controller: _controller,
            focusNode: _focusNode,
            textAlign: widget.textAlign,
            decoration: InputDecoration(
              fillColor: widget.onConvertToText != null ? Colors.yellow[100] : Colors.white,
              filled: true,
              errorText: _errorText,
              helperText: _debugText,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
              prefix: SizedBox(width: _buttonWidth + _buttonPadding,),
              suffix: Padding(
                padding: EdgeInsets.only(right: _buttonPadding +_buttonWidth + _buttonPadding),
                child: Text(widget.units ?? ''),
              ),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: _errorText == null ? Theme.of(context).cursorColor : Theme.of(context).errorColor,
                      width: 2.0
                  )
              ),
            ),
            keyboardType: TextInputType.numberWithOptions(signed: widget.min < 0.0, decimal: true),
            onChanged: (str) {
              setNewValue(convertToValue(str), false);
            },
            onSubmitted: (str) {
              setNewValue(convertToValue(str), false);
            },
          ),
          Positioned(
            left: _buttonPadding,
            child: SizedBox(
              width: _buttonWidth,
              child: FlatButton(
                padding: EdgeInsets.zero,
                color: primarySwatch[200],
                child: Text(widget.onConvertToText == null ? '–' : '<', style: TextStyle(fontSize: 20.0)),
                onPressed: () => change(-widget.step),
              ),
            ),
          ),
          Positioned(
            right: _buttonPadding,
            child: SizedBox(
              width: _buttonWidth,
              child: GestureDetector(
                //behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _debugText = 'tap';                    
                  });
                },
                onVerticalDragStart: (details) {
                  _errorText = 'dragStart';
                },
                onVerticalDragEnd: (details) {
                  _errorText = 'dragEnd';
                },
                onVerticalDragUpdate: (details) {
                  _errorText = 'dragUpdate';
                },
                child: FlatButton(
                  padding: EdgeInsets.zero,
                  color: primarySwatch[200],
                  child: Text(widget.onConvertToText == null ? '+' : '>', style: TextStyle(fontSize: 20.0)),
                  onPressed: () => change(widget.step),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return widget.horizontal
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Visibility(
                visible: widget.caption != null,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(widget.caption),
                ),
              ),
              SizedBox(
                width: widget.inputWidth,
                child: input
              )
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                visible: widget.caption != null,
                child: Padding(
                  padding: const EdgeInsets.only(left: _buttonPadding, right: _buttonPadding, top: 6.0, bottom: 2.0),
                  child: Text(widget.caption),
                ),
              ),
              input,
            ],
          );
  }
}

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
  static final _staticPadding = 20.0;
  var _additionalPadding = 0.0;
//  Widget _settings;
  var _showSettings = false;
  static final _settingsWidth = 180.0;
  AnimationController _settingsController;

  var _height = 50.0;
  var _width = 50.0;
  var _elevation = 0.5;
  var _scale = 6.0;
//  var _zoomLevel = 0.0;
  var _drawDraft = true;

  // Whatsapp
  var _radius = 6.0;
  var _nipSide = NipSide.left;
  var _inverse = false;
  var _nipRadius = 1.5;
  var _nipSize = 7.0;
  var _nipOffset = NipOffset(absolute: 0.0);
  var _topLine = NipLine.line(0.0);
  var _topLineValues = [0.0, 0.0, 0.0, -90.0];
  var _bottomLine = NipLine.line(53.0);
  var _bottomLineValues = [53.0, 6.0, 3.0, -180.0];

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
    _settingsController = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 100),
      animationBehavior: AnimationBehavior.normal,
      vsync: this,
    );

    super.initState();
  }

  void toggleSettings() {
    _showSettings = !_showSettings;
    (_showSettings ? _settingsController.forward : _settingsController.reverse)();
  }

  @override
  Widget build(BuildContext context) {
    print('build');

    final animation = Tween(begin: _settingsWidth, end: 0.0).animate(_settingsController);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 4.0,
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('1'),
                ),
                PopupMenuItem(
                  child: Text('2'),
                ),
                PopupMenuItem(
                  child: Text('3'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            PhysicalModel(
              color: primarySwatch[200],
              elevation: 4.0,
              child: Container(
                padding: EdgeInsets.all(_staticPadding / 2.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: getAddingPadding(1.0),
                      child: Align(
                        alignment:
                            _nipSide.isLeft || _nipSide.isVertical && !_inverse ? Alignment.topLeft : Alignment.topRight,
//                    child: const Text('test'),
                        child: Bubble(
                          radius: BubbleRadius(
                              topLeft: _radius, topRight: _radius, bottomLeft: _radius, bottomRight: _radius),
                          nipSide: _nipSide,
                          inverse: _inverse,
                          nipRadius: _nipRadius,
                          nipSize: _nipSize,
                          nipOffset: _nipOffset,
                          topLine: _topLine,
                          bottomLine: _bottomLine,
                          color: Colors.white,
                          elevation: _elevation,
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Lorem ipsum dolor sit amet'),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: _staticPadding / 2.0) + getAddingPadding(1.0),
                      child: Align(
                        alignment:
                            _nipSide.isLeft || _nipSide.isVertical && !_inverse ? Alignment.topLeft : Alignment.topRight,
//                    child: const Text('test'),
                        child: Bubble(
                          radius: BubbleRadius(
                              topLeft: _radius, topRight: _radius, bottomLeft: _radius, bottomRight: _radius),
                          nipSide: _nipSide,
                          inverse: _inverse,
                          nipRadius: _nipRadius,
                          nipSize: _nipSize,
                          nipOffset: _nipOffset,
                          topLine: _topLine,
                          bottomLine: _bottomLine,
                          color: Colors.white,
                          elevation: _elevation,
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),
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
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => toggleSettings(),
                          child: Padding(
                            padding: EdgeInsets.all(_staticPadding) + getAddingPadding(_scale),
                            // child: const Text('TEST'),
                            child: Bubble(
                              scale: _scale,
                              radius: BubbleRadius(
                                  topLeft: _radius, topRight: _radius, bottomLeft: _radius, bottomRight: _radius),
                              nipSide: _nipSide,
                              inverse: _inverse,
                              nipRadius: _nipRadius,
                              nipSize: _nipSize,
                              nipOffset: _nipOffset,
                              topLine: _topLine,
                              bottomLine: _bottomLine,
                              color: Colors.lightBlue,
                              elevation: _elevation,
                              drawDraft: _drawDraft,
                              child: SizedBox(
                                height: _height,
                                width: _width,
                                //                          child: Text('a a a a a')
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            height: double.infinity,
                            width: _settingsWidth,
                            child: AnimatedBuilder(
                              animation: animation,
                              child: getSettings(),
                              builder: (BuildContext context, Widget child) {
                                return Transform.translate(
                                  offset: Offset(animation.value, 0.0),
                                  child: child,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
              color: primarySwatch[200],
              elevation: 8.0,
              child: Container(
                padding: EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Text('Draft'),
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
                    Value(
                      caption: 'Scale:',
                      horizontal: true,
                      inputWidth: _settingsWidth - 8.0,
                      value: _scale,
                      units: 'x',
                      min: 1.0,
                      max: 16.0,
                      step: 1.0,
                      onChanged: (double value) {
                        setState(() {
                          _scale = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getSettings() {
    return Material(
      elevation: 2.0,
//        color: Colors.lime.shade100.withAlpha(224),
      color: Colors.white.withAlpha(160),
      child: ListView(
        children: <Widget>[
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
          const Text(
            'View',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Value(
              caption: 'Additional padding:',
              value: _additionalPadding,
              units: 'dp',
              min: 0.0,
              step: 1.0,
              onChanged: (double value) {
                setState(() {
                  _additionalPadding = value;
                });
              },
            ),
          ),
          const Divider(),
          const Text(
            'Box',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
//          Padding(
//            padding: const EdgeInsets.all(4.0),
//            child: Value(
//              caption: 'Height:',
//              value: _height,
//              units: 'dp',
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
//              units: 'dp',
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
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Value(
              caption: 'Corner\'s radius:',
              value: _radius,
              units: 'dp',
              min: 0.0,
              step: 1.0,
              onChanged: (double value) {
                setState(() {
                  _radius = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Value(
              caption: 'Elevation:',
              value: _elevation,
              units: 'dp',
              min: 0.0,
              step: 0.1,
              fractionDigits: 1,
              onChanged: (double value) {
                setState(() {
                  _elevation = value;
                });
              },
            ),
          ),
          const Divider(),
          const Text(
            'Nip',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Value(
                caption: 'Side:',
                value: _nipSide.index.toDouble() * 2.0 + (_inverse ? 1.0 : 0.0),
                min: NipSide.minIndex.toDouble(),
                max: NipSide.maxIndex.toDouble() * 2.0 + 1.0,
                step: 1,
                textAlign: TextAlign.center,
                onChanged: (double value) {
                  setState(() {
                    final index = value.round();
                    _nipSide = NipSide.byIndex(index >> 1);
                    _inverse = index % 2 == 1;
                  });
                },
                onConvertToText: (value) {
                  final index = value.round();
                  var nipSide = NipSide.byIndex(index >> 1);
                  return nipSide.toString(onlyValue: true) + (index % 2 == 0 ? '' : nipSide.isHorizontal ? '↑' : '←');
                }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Value(
              caption: 'Radius:',
              value: _nipRadius,
              units: 'dp',
              min: 0.0,
              step: 0.1,
              fractionDigits: 1,
              onChanged: (double value) {
                setState(() {
                  _nipRadius = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Value(
              caption: 'Size:',
              value: _nipSize,
              units: 'dp',
              min: 0.0,
              step: 1.0,
              onChanged: (double value) {
                setState(() {
                  _nipSize = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Value(
              caption: 'Relative offset:',
              value: _nipOffset.relative * 100.0,
              units: '%',
              min: 0.0,
              max: 100.0,
              step: 10.0,
              onChanged: (double value) {
                setState(() {
                  _nipOffset = NipOffset(relative: value / 100.0, absolute: _nipOffset.absolute);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Value(
              caption: 'Absolute offset:',
              value: _nipOffset.absolute,
              units: 'dp',
              step: 1.0,
              onChanged: (double value) {
                setState(() {
                  _nipOffset = NipOffset(relative: _nipOffset.relative, absolute: value);
                });
              },
            ),
          ),
          const Divider(),
          const Text(
            'Top line',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Value(
                caption: 'Type of position:',
                value: _topLine.posType.index.toDouble(),
                min: 0.0,
                max: (NipLinePosType.values.length - 1).toDouble(),
                step: 1,
                textAlign: TextAlign.center,
                onChanged: (double value) {
                  setState(() {
                    final index = value.round();
                    _topLine = NipLine(_topLine.lineType, NipLinePosType.values[index], _topLineValues[index]);
                  });
                },
                onConvertToText: (value) {
                  final index = value.floor();
                  return NipLinePosType.values[index].toString().replaceFirst(RegExp(r'.*\.'), '');
                }),
          ),
          Visibility(
            visible: _topLine.posType == NipLinePosType.angle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Value(
                caption: 'Angle of line:',
                value: _topLineValues[NipLinePosType.angle.index],
                units: '°',
                min: -90.0,
                max: 90.0,
                step: 1.0,
                onChanged: (double value) {
                  setState(() {
                    _topLineValues[NipLinePosType.angle.index] = value;
                    _topLine = NipLine(_topLine.lineType, NipLinePosType.angle, value);
                  });
                },
              ),
            ),
          ),
          Visibility(
            visible: _topLine.posType == NipLinePosType.pos,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Value(
                caption: 'Position on the side:',
                value: _topLineValues[NipLinePosType.pos.index],
                units: 'dp',
                step: 1.0,
                onChanged: (double value) {
                  setState(() {
                    _topLineValues[NipLinePosType.pos.index] = value;
                    _topLine = NipLine(_topLine.lineType, NipLinePosType.pos, value);
                  });
                },
              ),
            ),
          ),
          Visibility(
            visible: _topLine.posType == NipLinePosType.offset,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Value(
                caption: 'Offset from the nip:',
                value: _topLineValues[NipLinePosType.offset.index],
                units: 'dp',
                step: 1.0,
                onChanged: (double value) {
                  setState(() {
                    _topLineValues[NipLinePosType.offset.index] = value;
                    _topLine = NipLine(_topLine.lineType, NipLinePosType.offset, value);
                  });
                },
              ),
            ),
          ),
          Visibility(
            visible: _topLine.posType == NipLinePosType.corners,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Value(
                caption: 'Position on the corners:',
                value: _topLineValues[NipLinePosType.corners.index],
                units: '°',
                step: 1.0,
                onBeforeChanging: (double value) {
                  if (value < -180.0) value = 180.0;
                  else if (value > 180.0) value = -180.0;
                  else if (value > -90.0 && value <= 0.0) value = -90.0;
                  else if (value > 0.0 && value < 90.0) value = 90.0;
                  return value;
                },
                onChanged: (double value) {
                  setState(() {
                    _topLineValues[NipLinePosType.corners.index] = value;
                    _topLine = NipLine(_topLine.lineType, NipLinePosType.corners, value);
                  });
                },
              ),
            ),
          ),

          const Divider(),
          const Text(
            'Bottom line',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Value(
                caption: 'Type of position:',
                value: _bottomLine.posType.index.toDouble(),
                min: 0.0,
                max: (NipLinePosType.values.length - 1).toDouble(),
                step: 1,
                textAlign: TextAlign.center,
                onChanged: (double value) {
                  setState(() {
                    final index = value.round();
                    _bottomLine = NipLine(_bottomLine.lineType, NipLinePosType.values[index], _bottomLineValues[index]);
                  });
                },
                onConvertToText: (value) {
                  final index = value.floor();
                  return NipLinePosType.values[index].toString().replaceFirst(RegExp(r'.*\.'), '');
                }),
          ),
          Visibility(
            visible: _bottomLine.posType == NipLinePosType.angle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Value(
                caption: 'Angle of line:',
                value: _bottomLineValues[NipLinePosType.angle.index],
                units: '°',
                min: -90.0,
                max: 90.0,
                step: 1.0,
                onChanged: (double value) {
                  setState(() {
                    _bottomLineValues[NipLinePosType.angle.index] = value;
                    _bottomLine = NipLine(_bottomLine.lineType, NipLinePosType.angle, value);
                  });
                },
              ),
            ),
          ),
          Visibility(
            visible: _bottomLine.posType == NipLinePosType.pos,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Value(
                caption: 'Position on the side:',
                value: _bottomLineValues[NipLinePosType.pos.index],
                units: 'dp',
                step: 1.0,
                onChanged: (double value) {
                  setState(() {
                    _bottomLineValues[NipLinePosType.pos.index] = value;
                    _bottomLine = NipLine(_bottomLine.lineType, NipLinePosType.pos, value);
                  });
                },
              ),
            ),
          ),
          Visibility(
            visible: _bottomLine.posType == NipLinePosType.offset,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Value(
                caption: 'Offset from the nip:',
                value: _bottomLineValues[NipLinePosType.offset.index],
                units: 'dp',
                step: 1.0,
                onChanged: (double value) {
                  setState(() {
                    _bottomLineValues[NipLinePosType.offset.index] = value;
                    _bottomLine = NipLine(_bottomLine.lineType, NipLinePosType.offset, value);
                  });
                },
              ),
            ),
          ),
          Visibility(
            visible: _bottomLine.posType == NipLinePosType.corners,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Value(
                caption: 'Position on the corners:',
                value: _bottomLineValues[NipLinePosType.corners.index],
                units: '°',
                step: 1.0,
                onBeforeChanging: (double value) {
                  if (value < -180.0) value = 180.0;
                  else if (value > 180.0) value = -180.0;
                  else if (value > -90.0 && value <= 0.0) value = -90.0;
                  else if (value > 0.0 && value < 90.0) value = 90.0;
                  return value;
                },
                onChanged: (double value) {
                  setState(() {
                    _bottomLineValues[NipLinePosType.corners.index] = value;
                    _bottomLine = NipLine(_bottomLine.lineType, NipLinePosType.corners, value);
                  });
                },
              ),
            ),
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
  }

  EdgeInsets getAddingPadding(double scale) {
    var padding = _additionalPadding * scale;
    return _nipSide.isHorizontal
        ? _inverse ? EdgeInsets.only(bottom: padding) : EdgeInsets.only(top: padding)
        : _inverse ? EdgeInsets.only(right: padding) : EdgeInsets.only(left: padding);
  }
}
