import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NumericField extends StatefulWidget {
  const NumericField({
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
  _NumericFieldState createState() => _NumericFieldState();
}

enum _ValueButton { no, left, right}

class _NumericFieldState extends State<NumericField> {
  static const _fieldHeight = 48.0; // Высота поля
  static const _buttonWidth = 40.0; // Ширина кнопки
  static const _contentPadding = 4.0; // Отступы от края
  static const _swipeStep = 8.0; // Шаг свайпа, за который происходит измение значения на один шаг

  double _value;
  double _savedValue; // Значение, сохранённое для свайпа
  Offset _savedPos; // Начальная позиция свайпа
  _ValueButton _swipeButton = _ValueButton.no; // Активная кнопка свайпа
  TextEditingController _controller;
  FocusNode _focusNode;
  String _errorText;

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

  void step(int steps, {double value}) {
    if (value == null) value = _value;

    // Если значение не выровнено по границе шага, то выравниваем в соответствующую сторону
    if (_errorText == null) {
      final floorValue = floor(value, widget.fractionDigits);
      if (value == floorValue) {
        value = floor(value + steps * widget.step, widget.fractionDigits);
      } else if (steps < 0) {
        value = floorValue + (steps + 1) * widget.step;
      } else if (steps > 0) {
        value = floor(floorValue + steps * widget.step, widget.fractionDigits);
      }
    }

    setNewValue(value, true);

    if (!_focusNode.hasFocus) _focusNode.requestFocus();
  }

  void setNewValue(double value, bool correctTextField) {
    String errorText;

    var correctedValue = value;

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
    } else if (correctedValue != _value && errorText == null) {
      _value = correctedValue;
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

  Widget getButton(BuildContext context, _ValueButton button) {
    assert(button == _ValueButton.left || button == _ValueButton.right);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: DragStartBehavior.down,
      onLongPress: () {
        _focusNode.requestFocus();
      },
      onVerticalDragStart: !_focusNode.hasFocus ? null : (details) {
//        print('onVerticalDragStart: $this focused=$_focused');
        _savedPos = details.localPosition;
        _savedValue = _value;
        setState(() => _swipeButton = button);
      },
      onVerticalDragUpdate: !_focusNode.hasFocus ? null : (details) {
//        print('onVerticalDragUpdate: $this focused=$_focused');
        print('primaryDelta: ${details.primaryDelta}');
        var offset = details.localPosition - _savedPos;
        var steps = -(offset.dy / _swipeStep).floor();
        if (button == _ValueButton.left && steps > 0 || button == _ValueButton.right && steps < 0) steps = 0;
        step(steps, value: _savedValue);
      },
      onVerticalDragCancel: !_focusNode.hasFocus ? null : () {
//        print('onVerticalDragCancel: $this focused=$_focused');
        setState(() => _swipeButton = _ValueButton.no);
      },
      onVerticalDragEnd: !_focusNode.hasFocus ? null : (details) {
//        print('onVerticalDragEnd: $this');
        setState(() => _swipeButton = _ValueButton.no);
      },
      child: Material(
        color: _errorText != null
            ? Theme.of(context).errorColor.withAlpha(192)
            : _swipeButton == button
            ? Theme.of(context).accentColor
            : _focusNode.hasFocus
            ? Theme.of(context).accentColor.withAlpha(192)
            : Theme.of(context).primaryColor.withAlpha(192),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: button == _ValueButton.left
                ? const BorderRadius.only(topLeft: const Radius.circular(4.0), bottomLeft: const Radius.circular(4.0))
                : const BorderRadius.only(topRight: const Radius.circular(4.0), bottomRight: const Radius.circular(4.0))
        ),
        child: InkWell(
          onTap: () => step(button == _ValueButton.left ? -1 : 1),
          highlightColor: Theme.of(context).accentColor,
          child: Container(
              height: _fieldHeight,
              width: _buttonWidth,
              child: Center(
                  child: Text(
                      widget.onConvertToText == null ? (button == _ValueButton.left ? '–' : '+') : (button == _ValueButton.left ? '<' : '>'),
                      style: TextStyle(fontSize: 20.0,
                          color: Colors.black.withAlpha(_value != (button == _ValueButton.left ? widget.min : widget.max) ? 255 : 48)
                      )
                  )
              )
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print('build $this');

//    if (_value != widget.value) _value = widget.value;

    final input = Focus(
      focusNode: _focusNode,
      onFocusChange: (focused) {
        setState(() {});
      },
      child: Stack(
        children: <Widget>[
          TextField(
            readOnly: widget.onConvertToText != null,
            controller: _controller,
            textAlign: widget.textAlign,
            decoration: InputDecoration(
              fillColor: widget.onConvertToText != null ? Colors.grey[300] : Colors.white,
              filled: true,
              errorText: _errorText,
              contentPadding: EdgeInsets.zero,
              prefix: SizedBox(width: _buttonWidth),
              suffix: Padding(
                padding: EdgeInsets.only(right: _contentPadding + _buttonWidth),
                child: Text(widget.units ?? ''),
              ),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: _errorText != null ? Theme.of(context).errorColor : Theme.of(context).accentColor,
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
          Align(
            alignment: Alignment.topLeft,
            child: getButton(context, _ValueButton.left),
          ),
          Align(
            alignment: Alignment.topRight,
            child: getButton(context, _ValueButton.right),
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
            padding: const EdgeInsets.only(left: _contentPadding, right: _contentPadding, top: 6.0, bottom: 2.0),
            child: Text(widget.caption),
          ),
        ),
        input,
      ],
    );
  }
}
