import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Profiler extends SingleChildRenderObjectWidget {
  const Profiler({super.key, this.breath = 0.0});

  final double breath;

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
    RenderBox? child,
  })  : _profiler = profiler,
        super(child);

  static const margin = 8.0;
  static const padding = 8.0;
  static const radius = 4.0;

  final _frames = <int>[];

  Profiler _profiler;
  Profiler get profiler => _profiler;
  set profiler(Profiler profiler) {
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
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final startTimestamp = timestamp - 1000000; // 1 сек
    _frames.removeWhere((time) => time < startTimestamp);
    final count = _frames.length;
    final duration = _frames.isNotEmpty ? timestamp - _frames[0] : 0;
    final fps = duration == 0 ? 0 : count * 1000000 ~/ duration;
    _frames.add(timestamp);

    final fieldPaint = Paint()
      ..color = Colors.white.withAlpha(64)
      ..style = PaintingStyle.fill;
    context.canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      fieldPaint,
    );

//    if (fps >= 10) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$fps fps',
        style: const TextStyle(color: Colors.black),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textSize = textPainter.size;
    final textOffset = Offset(
      offset.dx + size.width - textSize.width - padding - margin,
      offset.dy + margin + padding,
    );

    final path = Path();
    path.addRRect(
      RRect.fromLTRBR(
        textOffset.dx - padding - _profiler.breath,
        textOffset.dy - padding - _profiler.breath,
        textOffset.dx + textSize.width + padding + _profiler.breath,
        textOffset.dy + textSize.height + padding + _profiler.breath,
        const Radius.circular(radius),
      ),
    );

    context.canvas.drawShadow(path, Colors.black, 4, true);

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
//    }
  }
}
