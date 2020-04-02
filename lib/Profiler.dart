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

  // @override
  // void performResize() {
  //   final textPainter = TextPainter(
  //       text: TextSpan(
  //           text: '999.9 fps',
  //           style: TextStyle(color: Colors.black)
  //       ),
  //       textAlign: TextAlign.left,
  //       textDirection: TextDirection.ltr
  //   );
  //   textPainter.layout();
  //   size = textPainter.size + Offset(2.0 * padding, 2.0 * padding);
  // }

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
    var startTimestamp = timestamp - 1000000;
    _frames.add(timestamp);
    _frames.removeWhere((time) => time <= startTimestamp);

   final fieldPaint = Paint()
     ..color = Colors.orange.withAlpha(32)
     ..style = PaintingStyle.fill;
   context.canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height), fieldPaint);

    final textPainter = TextPainter(
        text: TextSpan(
            text: '${_frames.length} fps',
            style: TextStyle(color: Colors.black)
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr
    );
    textPainter.layout();

    final textSize = textPainter.size;
    final textOffset = Offset(offset.dx + size.width - textSize.width - padding - margin, offset.dy + margin + padding);

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
