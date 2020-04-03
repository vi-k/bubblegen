import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Profiler extends SingleChildRenderObjectWidget {
  const Profiler();

  @override
  RenderObject createRenderObject(BuildContext context) {
//    print('createRenderObject');
    return RenderProfiler(this);
  }

  @override
  void updateRenderObject(BuildContext context, RenderProfiler renderObject) {
//    print('updateRenderObject');
    renderObject.profiler = this;
  }
}

class RenderProfiler extends RenderProxyBox {
  RenderProfiler(
      Profiler profiler, {
        RenderBox child,
      })  : assert(profiler != null),
        _profiler = profiler,
        super(child);

  static const margin = 8.0;
  static const padding = 8.0;
  static const radius = 4.0;

  var _frames = <int>[];

  Profiler _profiler;
  Profiler get profiler => _profiler;
  set profiler(Profiler profiler) {
    assert(profiler != null);
    markNeedsPaint();
    _profiler = profiler;
  }

  @override
  void performLayout() {
    // print('performLayout');
    // Забираем всё пространство родителя
    //performResize();
    size = Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var timestamp = DateTime.now().microsecondsSinceEpoch;
    var startTimestamp = timestamp - 1000000; // 1 сек
    _frames.removeWhere((time) => time < startTimestamp);
    final count = _frames.length;
    final duration = _frames.length > 0 ? timestamp - _frames[0] : 0;
    final fps = duration == 0 ? 0 : count * 1000000 ~/ duration;
    _frames.add(timestamp);

    final fieldPaint = Paint()
      ..color = Colors.white.withAlpha(1)
      ..style = PaintingStyle.fill;
    context.canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height), fieldPaint);

    if (fps >= 10) {
      final textPainter = TextPainter(
          text: TextSpan(
              text: '$fps fps',
              style: TextStyle(color: Colors.black)
          ),
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr
      );
      textPainter.layout();

      final textSize = textPainter.size;
      final textOffset = Offset(
          offset.dx + size.width - textSize.width - padding - margin, offset.dy + margin + padding);

      final path = Path();
      path.addRRect(RRect.fromLTRBR(
          textOffset.dx - padding,
          textOffset.dy - padding,
          textOffset.dx + textSize.width + padding,
          textOffset.dy + textSize.height + padding,
          const Radius.circular(radius)
      ));

      context.canvas.drawShadow(path, Colors.black, 4.0, true);

      final paint = Paint()
        ..color = Colors.orange.withAlpha(192)
        ..style = PaintingStyle.fill;
      context.canvas.drawPath(path, paint);

//    paint
//      ..color = Colors.orange[700]
//      ..strokeWidth = 1.0
//      ..style = PaintingStyle.stroke;
//    context.canvas.drawPath(path, paint);

      textPainter.paint(context.canvas, textOffset);
    }
  }
}
