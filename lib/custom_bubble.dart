import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'geometry.dart';

class CustomBubble extends SingleChildRenderObjectWidget {
  CustomBubble({
    super.key,
    this.scale = 1.0,
    this.drawDraft = false,
    this.style = const CustomBubbleStyle(),
    Inset? inset,
    List<Inset>? insets,
    this.child,
  })  : assert(inset == null || insets == null),
        insets = InsetList(insets ?? (inset != null ? [inset] : []));

  final CustomBubbleStyle style;
  @override
  final Widget? child;
  final double scale;
  final bool drawDraft;
  final InsetList insets;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderBubble(this);

  @override
  void updateRenderObject(BuildContext context, RenderBubble renderObject) {
    renderObject.bubble = this;
  }

  @protected
  bool needsLayout(CustomBubble other) => scale != other.scale;

  void generateInsets() {
//    insets.list.clear();
//    insets.list.add(Inset(
//        InsetPos(InsetPosType.topLeft, Position(ratio: 0.5)),
//        InsetPos(InsetPosType.top, Position(offset: 5.0))
//    ));
//    insets.list.add(Inset(
//        InsetPos(InsetPosType.topRight, Position(ratio: 0.5)),
//        InsetPos(InsetPosType.right, Position(offset: 5.0))
//    ));
//    insets.list.add(Inset(
//        InsetPos(InsetPosType.bottomRight, Position(ratio: 0.5)),
//        InsetPos(InsetPosType.bottom, Position(offset: 5.0))
//    ));
//    insets.list.add(Inset(
//        InsetPos(InsetPosType.bottomLeft, Position(ratio: 0.5)),
//        InsetPos(InsetPosType.left, Position(offset: 5.0))
//    ));
  }

  void createInset(
    int index,
    Path path,
    Box box,
    Point start,
    Point end,
    Inset inset,
    AbsInset absInset,
    DraftInfo? draftInfo,
  ) {}

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'CustomBubble(${scale == 1.0 ? '' : 'scale: $scale, '}${drawDraft == false ? '' : 'drawDraft: $drawDraft, '}style: $style, insets: $insets)';
}

class RenderBubble extends RenderProxyBox {
  RenderBubble(
    CustomBubble bubble, {
    RenderBox? child,
  })  : _bubble = bubble,
        super(child);

  CustomBubble _bubble;

  CustomBubble get bubble => _bubble;

  set bubble(CustomBubble bubble) {
    if (_bubble.needsLayout(bubble)) markNeedsLayout();
    markNeedsPaint();
    _bubble = bubble;
  }

  @override
  void performLayout() {
//    print('performLayout');

    if (child != null) {
      // Вычисляем размер child
      BoxConstraints childConstraints;
//      Offset changes;
//      final nipPlaceholderSize = bubble.style.nipPlaceholderSize ?? bubble.style.nipSize;

//        changes = Offset(nipPlaceholderSize, 0);
      final maxWidth = constraints.maxWidth -
          (bubble.style.margin.left + bubble.style.margin.right) * bubble.scale;
      final maxHeight = constraints.maxHeight -
          (bubble.style.margin.top + bubble.style.margin.bottom) * bubble.scale;
      final minWidth = math.min(constraints.minWidth, maxWidth);
      final minHeight = math.min(constraints.minHeight, maxHeight);

      childConstraints = BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
      );
//      else if (bubble.style.nipSide.isVertical) {
//        changes = Offset(0, nipPlaceholderSize);
//        childConstraints = constraints.copyWith(
//          maxHeight: maxHeight,
//          minHeight: minHeight,
//        );
//      }

      childConstraints = childConstraints / bubble.scale;
//      print('constraints: $constraints');
//      print('childConstraints: $childConstraints');

      child!.layout(childConstraints, parentUsesSize: true);
      size = Size(
            child!.size.width +
                bubble.style.margin.left +
                bubble.style.margin.right,
            child!.size.height +
                bubble.style.margin.top +
                bubble.style.margin.bottom,
          ) *
          bubble.scale;
//      print('child.size: ${child.size}');
//      print('size: $size');
    } else {
      performResize();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // print('paint $this');
    if (child == null) return;

    final pi = BubblePaintInfo();
    pi.scale = bubble.scale;
    var childOffset = offset;

//    final nipPlaceholderSize = bubble.style.nipPlaceholderSize ?? bubble.style.nipSize;

//    print('$bubble');
//    print('size: $size');
//    print('original size: ${size / pi.scale}');

    pi.rect = Rect.fromLTWH(
      0,
      0,
      size.width / bubble.scale,
      size.height / bubble.scale,
    );
    pi.box = Rect.fromLTRB(
      bubble.style.margin.left,
      bubble.style.margin.top,
      pi.rect.right - bubble.style.margin.right,
      pi.rect.bottom - bubble.style.margin.bottom,
    );
    childOffset = offset.translate(
      bubble.style.margin.left * bubble.scale,
      bubble.style.margin.top * bubble.scale,
    );

//    if (bubble.style.nipSide.isHorizontal) {
//      pi.rect = Rect.fromLTWH(0, 0, size.width / bubble.scale, size.height / bubble.scale);
//      pi.box = Rect.fromLTWH(nipPlaceholderSize, 0, size.width / bubble.scale - nipPlaceholderSize, size.height / bubble.scale);
//      if (bubble.style.nipSide.isLeft) childOffset = offset.translate(nipPlaceholderSize * bubble.scale, 0);
//    } else {
//      pi.rect = Rect.fromLTWH(0, 0, size.height / bubble.scale, size.width / bubble.scale);
//      pi.box = Rect.fromLTWH(nipPlaceholderSize, 0, size.height / bubble.scale - nipPlaceholderSize, size.width / bubble.scale);
//      if (bubble.style.nipSide.isTop) childOffset = offset.translate(0, nipPlaceholderSize * bubble.scale);
//    }

//    print('childOffset: $childOffset');
//    print('pi.rect: ${pi.rect}');
//    print('pi.box: ${pi.box}');

    // Если радиусы больше сторон бокса, рассчитываем коэффициент, чтобы равномерно уменьшить все радиусы
    var k = 1.0;

    if (bubble.style.radius.topLeft + bubble.style.radius.topRight >
        pi.box.width) {
      final tK = pi.box.width /
          (bubble.style.radius.topLeft + bubble.style.radius.topRight);
      if (tK < k) k = tK;
    }

    if (bubble.style.radius.bottomLeft + bubble.style.radius.bottomRight >
        pi.box.width) {
      final bK = pi.box.width /
          (bubble.style.radius.bottomLeft + bubble.style.radius.bottomRight);
      if (bK < k) k = bK;
    }

    if (bubble.style.radius.topLeft + bubble.style.radius.bottomLeft >
        pi.box.height) {
      final lK = pi.box.height /
          (bubble.style.radius.topLeft + bubble.style.radius.bottomLeft);
      if (lK < k) k = lK;
    }

    if (bubble.style.radius.topRight + bubble.style.radius.bottomRight >
        pi.box.height) {
      final rK = pi.box.height /
          (bubble.style.radius.topRight + bubble.style.radius.bottomRight);
      if (rK < k) k = rK;
    }

//    pi.nipCircle = Circle(
//        Point(pi.box.left - bubble.style.nipSize + bubble.style.nipRadius,
//            pi.box.top + bubble.style.nipOffset.pos(bubble.style.nipRadius, pi.box.height) + bubble.style.nipRadius),
//        bubble.style.nipRadius);

    var radius = bubble.style.radius.topLeft * k;
    pi.ltCircle =
        Circle(Point(pi.box.left + radius, pi.box.top + radius), radius);

    radius = bubble.style.radius.bottomLeft * k;
    pi.lbCircle =
        Circle(Point(pi.box.left + radius, pi.box.bottom - radius), radius);

    radius = bubble.style.radius.topRight * k;
    pi.rtCircle =
        Circle(Point(pi.box.right - radius, pi.box.top + radius), radius);

    radius = bubble.style.radius.bottomRight * k;
    pi.rbCircle =
        Circle(Point(pi.box.right - radius, pi.box.bottom - radius), radius);

    pi.draft = bubble.drawDraft ? DraftInfo() : null;

    final path = Path();

    final box = Box.fromLTRBAndCorners(
      pi.box.left,
      pi.box.top,
      pi.box.right,
      pi.box.bottom,
      topLeft: pi.ltCircle.radius,
      topRight: pi.rtCircle.radius,
      bottomLeft: pi.lbCircle.radius,
      bottomRight: pi.rbCircle.radius,
    );

    bubble.generateInsets();
    createBox(path, box, pi.draft);

    // path = Path.combine(PathOperation.union, path, Path());

//    var thirdPath = Path()
//      ..addOval(Rect.fromCenter(center: pi.nipCircle.center - Offset(0.0, 0.0), width: pi.nipCircle.diameter, height: pi.nipCircle.diameter));
////    path = Path.combine(PathOperation.union, path, thirdPath);

    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);

//    if (bubble.style.nipSide.isRight) {
//      context.canvas.translate(size.width, 0);
//      context.canvas.scale(-1, 1);
//    } else if (bubble.style.nipSide.isTop) {
//      context.canvas.scale(-1, 1);
//      context.canvas.rotate(math.pi * 90 / 180);
//    } else if (bubble.style.nipSide.isBottom) {
//      context.canvas.translate(0, size.height);
//      context.canvas.scale(-1, -1);
//      context.canvas.rotate(math.pi * 90 / 180);
//    }

    if (bubble.style.hFlip) {
      context.canvas.translate(size.width, 0);
      context.canvas.scale(-1, 1);
    }

    if (bubble.style.vFlip) {
      context.canvas.translate(0, size.height);
      context.canvas.scale(1, -1);
    }

    context.canvas.scale(bubble.scale);

    final paint = Paint();
    paint.color = bubble.style.color;
    paint.style = PaintingStyle.fill;
    if (pi.draft != null) pi.draft!.paintBackground(context.canvas, pi);
    context.canvas.drawShadow(
      path,
      bubble.style.shadowColor,
      bubble.style.elevation * bubble.scale,
      true,
    );
    if (pi.draft != null) context.canvas.drawPath(path, paint);

    // Обводка
    if (bubble.style.strokeWidth != 0.0) {
      paint.style = PaintingStyle.stroke;
      paint.color = bubble.style.strokeColor;
      paint.strokeWidth = bubble.style.strokeWidth;
//      paint.strokeCap = StrokeCap.round;
      paint.strokeJoin = StrokeJoin.round;
      context.canvas.drawPath(path, paint);
    }

    if (pi.draft != null) pi.draft!.paint(context.canvas, pi);

    context.canvas.restore();

    context.canvas.save();
    context.canvas.translate(childOffset.dx, childOffset.dy);
    context.canvas.scale(bubble.scale);
    context.paintChild(child!, Offset.zero);
    context.canvas.restore();
  }

  void createBox(Path path, Box box, DraftInfo? draftInfo) {
//    print('createBox()');

    final absInsets = bubble.insets.apply(box);

//    print('box: $box');

    final start = absInsets.isNotEmpty
        ? absInsets[0].start
        : const AbsInsetPos(InsetPosType.topLeft, 0);
    var lastPoint = start.apply(box);
//    print('moveTo: $start $lastPoint');
    path.moveTo(lastPoint.x, lastPoint.y);

    if (absInsets.isEmpty) {
      pathFromTo(path, box, start, const AbsInsetPos(InsetPosType.left, 0));
    } else {
      for (var index = 0; index < absInsets.length; index++) {
        final inset = bubble.insets.list[index];
        final absInset = absInsets[index];

        // Врезка
        final nextPoint = absInset.end.apply(box);
        if (draftInfo != null) {
          draftInfo.addPoint(lastPoint);
          draftInfo.addPoint(nextPoint, DraftType.Main);
        }
        bubble.createInset(
          index,
          path,
          box,
          lastPoint,
          nextPoint,
          inset,
          absInset,
          draftInfo,
        );
        lastPoint = nextPoint;

        // Устанавливаем в точку возврата самостоятельно
        path.lineTo(nextPoint.x, nextPoint.y);

        // Путь до следующей врезки
        final pos =
            index < absInsets.length - 1 ? absInsets[index + 1].start : start;
        final point = pathFromTo(path, box, absInset.end, pos);
        if (point != null) lastPoint = point;
      }
    }

    path.close();
  }

  Point? pathFromTo(Path path, Box box, AbsInsetPos start, AbsInsetPos end) {
    Point? point;

//    print('$start $end');
//    print('start: ${start.apply(box)}');

    var pos = start;
    while (pos != end) {
      final prevPos = pos;
      if (pos.type == end.type && pos.pos < end.pos) {
        pos = end;
      } else {
        var nextTypeIndex = pos.type.index + 1;
        if (nextTypeIndex == InsetPosType.values.length) nextTypeIndex = 0;
        pos = AbsInsetPos(InsetPosType.values[nextTypeIndex], 0);
      }

      point = pos.apply(box);
      if (prevPos.isOnCorner) {
//        print('arcTo: $pos $point');
        path.arcToPoint(
          point,
          radius: Radius.circular(prevPos.getRadius(box)!),
        );
      } else {
//        print('lineTo: $pos $point');
        path.lineTo(point.x, point.y);
      }
    }

    return point;
  }
}

class BubbleRadius {
  const BubbleRadius({
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomRight,
    double? bottomLeft,
  })  : assert(topLeft != null || all != null),
        assert(topRight != null || all != null),
        assert(bottomRight != null || all != null),
        assert(bottomLeft != null || all != null),
        topLeft = (topLeft ?? all) as double,
        topRight = (topRight ?? all) as double,
        bottomRight = (bottomRight ?? all) as double,
        bottomLeft = (bottomLeft ?? all) as double;

  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  bool get hasOneRadius =>
      topLeft == topRight && bottomLeft == bottomRight && topLeft == bottomLeft;

  BubbleRadius copyWith({
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) =>
      BubbleRadius(
        topLeft: topLeft ?? this.topLeft,
        topRight: topRight ?? this.topRight,
        bottomRight: bottomRight ?? this.bottomRight,
        bottomLeft: bottomLeft ?? this.bottomLeft,
      );

  @override
  String toString() => hasOneRadius
      ? 'BubbleRadius(all: $topLeft)'
      : 'BubbleRadius(topLeft: $topLeft, topRight: $topRight, bottomLeft: $bottomLeft, bottomRight: $bottomRight)';
}

enum DraftType { Draft, Main, Error }

class DraftLine {
  DraftLine(this.line, this.type);
  final DraftType type;
  final Line line;
}

class DraftLineSegment {
  DraftLineSegment(this.lineSegment, this.type);
  final DraftType type;
  final LineSegment lineSegment;
}

class DraftPoint {
  DraftPoint(this.point, this.type);
  final DraftType type;
  final Point point;
}

class DraftInfo {
  DraftInfo();

  bool showNip = true;
  bool showTopSide = false;
  bool showLeftSide = false;
  bool showBottomSide = false;
  bool showTopCorner = false;
  bool showBottomCorner = false;

  static const Color draftColor = Colors.black26;
  static const Color lineColor = Colors.orange;
  static const Color mainColor = Colors.black;
  static const Color errorColor = Colors.red;

  final List<DraftLine> _lines = [];
  final List<DraftLineSegment> _lineSegments = [];
  final List<DraftPoint> _points = [];

  List<DraftLine> get lines => _lines;
  List<DraftLineSegment> get lineSegments => _lineSegments;
  List<DraftPoint> get points => _points;

  void addLine(
    Point start,
    double direct, [
    DraftType type = DraftType.Draft,
  ]) =>
      lines.add(DraftLine(Line(start, direct), type));
  void addLineCopy(Line line, [DraftType type = DraftType.Draft]) =>
      lines.add(DraftLine(Line(line.start, line.direct), type));

  void addLineSegment(
    Point start,
    Point end, [
    DraftType type = DraftType.Draft,
  ]) =>
      lineSegments.add(DraftLineSegment(LineSegment(start, end), type));
  void addLineSegmentCopy(
    LineSegment lineSegment, [
    DraftType type = DraftType.Draft,
  ]) =>
      lineSegments.add(
        DraftLineSegment(
          LineSegment(lineSegment.start, lineSegment.end),
          type,
        ),
      );

  void addPoint(Point point, [DraftType type = DraftType.Draft]) =>
      points.add(DraftPoint(point, type));

  void paintBackground(Canvas canvas, BubblePaintInfo pi) {
    final dp = 1.0 / pi.scale;
    final limitSize = 10.0 * dp;

    final paint = Paint();
    paint.strokeWidth = 1 * dp;
    paint.color = draftColor;
    paint.style = PaintingStyle.stroke;

    final path = Path();

    // Левая граница
    path.moveTo(pi.rect.left, pi.rect.top - limitSize);
    path.lineTo(pi.rect.left, pi.rect.bottom + limitSize);

    // Правая граница
    path.moveTo(pi.rect.right, pi.rect.top - limitSize);
    path.lineTo(pi.rect.right, pi.rect.bottom + limitSize);

    // Верхняя граница
    path.moveTo(pi.rect.left - limitSize, pi.rect.top);
    path.lineTo(pi.rect.right + limitSize, pi.rect.top);

    // Нижняя граница
    path.moveTo(pi.rect.left - limitSize, pi.rect.bottom);
    path.lineTo(pi.rect.right + limitSize, pi.rect.bottom);

    // Границы бокса
    path.moveTo(pi.box.left, pi.box.top - limitSize);
    path.lineTo(pi.box.left, pi.box.bottom + limitSize);

    canvas.drawPath(path, paint);
  }

  void paint(Canvas canvas, BubblePaintInfo pi) {
    final dp = 1 / pi.scale;
    final sideSize = 4 * dp;
    final pointSize = 1.5 * dp;

    final path = Path();
    final paint = Paint()
      ..strokeWidth = 1 * dp
      ..color = draftColor
      ..style = PaintingStyle.fill;

    // Малый круг
//    if (showNip) {
//      canvas.drawCircle(pi.nipCircle.center, pi.nipCircle.radius, paint);
//    }

    // Верхняя сторона
    if (showTopSide) {
      path.reset();
      path.moveTo(pi.ltCircle.center.x, pi.box.top);
      path.lineTo(pi.rtCircle.center.x, pi.box.top);
      path.lineTo(pi.rtCircle.center.x, pi.box.top + sideSize);
      path.lineTo(pi.ltCircle.center.x, pi.box.top + sideSize);
      path.close();

      canvas.drawPath(path, paint);
    }

    // Левая сторона
    if (showLeftSide) {
      path.reset();
      path.moveTo(pi.box.left, pi.ltCircle.center.y);
      path.lineTo(pi.box.left + sideSize, pi.ltCircle.center.y);
      path.lineTo(pi.box.left + sideSize, pi.lbCircle.center.y);
      path.lineTo(pi.box.left, pi.lbCircle.center.y);
      path.close();

      canvas.drawPath(path, paint);
    }

    // Нижняя сторона
    if (showBottomSide) {
      path.reset();
      path.moveTo(pi.lbCircle.center.x, pi.box.bottom);
      path.lineTo(pi.rbCircle.center.x, pi.box.bottom);
      path.lineTo(pi.rbCircle.center.x, pi.box.bottom - sideSize);
      path.lineTo(pi.lbCircle.center.x, pi.box.bottom - sideSize);
      path.close();

      canvas.drawPath(path, paint);
    }

    // Верхний угол
    if (showTopCorner) {
      paint.style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCenter(
          center: pi.ltCircle.center,
          width: pi.ltCircle.diameter,
          height: pi.ltCircle.diameter,
        ),
        -math.pi / 2,
        -math.pi / 2,
        true,
        paint,
      );
    } else {
      path.reset();
      path.moveTo(
        pi.ltCircle.center.dx,
        pi.ltCircle.center.dy - pi.ltCircle.radius,
      );
      path.lineTo(pi.ltCircle.center.dx, pi.ltCircle.center.dy);
      path.lineTo(
        pi.ltCircle.center.dx - pi.ltCircle.radius,
        pi.ltCircle.center.dy,
      );
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }

    // Нижний угол
    if (showBottomCorner) {
      paint.style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCenter(
          center: pi.lbCircle.center,
          width: pi.lbCircle.diameter,
          height: pi.lbCircle.diameter,
        ),
        math.pi / 2,
        math.pi / 2,
        true,
        paint,
      );
    } else {
      path.reset();
      path.moveTo(
        pi.lbCircle.center.dx,
        pi.lbCircle.center.dy + pi.lbCircle.radius,
      );
      path.lineTo(pi.lbCircle.center.dx, pi.lbCircle.center.dy);
      path.lineTo(
        pi.lbCircle.center.dx - pi.lbCircle.radius,
        pi.lbCircle.center.dy,
      );
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }

    // Правый верхний угол
    path.reset();
    path.moveTo(
      pi.rtCircle.center.dx,
      pi.rtCircle.center.dy - pi.rtCircle.radius,
    );
    path.lineTo(pi.rtCircle.center.dx, pi.rtCircle.center.dy);
    path.lineTo(
      pi.rtCircle.center.dx + pi.rtCircle.radius,
      pi.rtCircle.center.dy,
    );
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);

    // Правый нижний угол
    path.reset();
    path.moveTo(
      pi.rbCircle.center.dx,
      pi.rbCircle.center.dy + pi.rbCircle.radius,
    );
    path.lineTo(pi.rbCircle.center.dx, pi.rbCircle.center.dy);
    path.lineTo(
      pi.rbCircle.center.dx + pi.rbCircle.radius,
      pi.rbCircle.center.dy,
    );
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);

    for (final type in DraftType.values) {
      paint.color = type == DraftType.Error
          ? errorColor
          : type == DraftType.Main
              ? mainColor
              : draftColor;

      paint.style = PaintingStyle.stroke;

      // Линии
      for (final item in lines) {
        if (item.type == type) {
          final interval = 6 / pi.scale;
          final padding = 4 * interval;

          // Рассчитываем концы линий - бесконечными они быть не могут, а длинные отрисовываются медленно
//          Point pt;
//          if (item.line.direct < math.pi / 2 && item.line.direct > -math.pi / 2) pt = item.line.pointByX(pi.rect.right + pad);
//          else pt = item.line.pointByX(pi.rect.left - pad);
//          if (pt == null || pt.y < 0 || pt.y > pi.rect.bottom) {
//            if (item.line.direct > 0) pt = item.line.pointByY(pi.rect.bottom + pad);
//            else pt = item.line.pointByX(pi.rect.top - pad);
//          }
//
//          if (pt != null) canvas.drawLine(item.line.start, pt, paint);

          // Пунктирные линии
          var size = 0.0;
          while (true) {
            final start = item.line.point(size);
            if (start.x < pi.rect.left - padding ||
                start.x > pi.rect.right + padding ||
                start.y < pi.rect.top - padding ||
                start.y > pi.rect.bottom + padding) {
              break;
            }
            final end = item.line.point(size + interval);
            size += 2 * interval;
            canvas.drawLine(start, end, paint);
          }
        }
      }

      // Отрезки
      for (final item in lineSegments) {
        if (item.type == type) {
          canvas.drawLine(item.lineSegment.start, item.lineSegment.end, paint);
        }
      }

      paint.style = PaintingStyle.fill;

      // Точки
      for (final item in points) {
        if (item.type == type) {
          canvas.drawCircle(item.point, pointSize, paint);
        }
      }
    }
  }
}

class BubblePaintInfo {
  late double scale;
  late Rect rect;
//  Circle nipCircle;
  late Rect box;
  late Circle ltCircle;
  late Circle lbCircle;
  late Circle rtCircle;
  late Circle rbCircle;
  DraftInfo? draft;
}

class CustomBubbleStyle {
  const CustomBubbleStyle({
    EdgeInsets? margin,
    BubbleRadius? radius,
    bool? hFlip,
    bool? vFlip,
    Color? color,
    double? elevation,
    Color? shadowColor,
    Color? strokeColor,
    double? strokeWidth,
  })  : margin = margin ?? EdgeInsets.zero,
        radius = radius ?? const BubbleRadius(all: 4),
        hFlip = hFlip ?? false,
        vFlip = vFlip ?? false,
        color = color ?? Colors.white,
        elevation = elevation ?? 1.0,
        shadowColor = shadowColor ?? Colors.black,
        strokeColor = strokeColor ?? Colors.orange,
        strokeWidth = strokeWidth ?? 0.0;

  final EdgeInsets margin;
  final BubbleRadius radius;
  final bool hFlip;
  final bool vFlip;
  final Color color;
  final double elevation;
  final Color shadowColor;
  final Color strokeColor;
  final double strokeWidth;

  CustomBubbleStyle copyWith({
    EdgeInsets? margin,
    BubbleRadius? radius,
    bool? hFlip,
    bool? vFlip,
    Color? color,
    double? elevation,
    Color? shadowColor,
    Color? strokeColor,
    double? strokeWidth,
  }) =>
      CustomBubbleStyle(
        margin: margin ?? this.margin,
        radius: radius ?? this.radius,
        hFlip: hFlip ?? this.hFlip,
        vFlip: vFlip ?? this.vFlip,
        color: color ?? this.color,
        elevation: elevation ?? this.elevation,
        shadowColor: shadowColor ?? this.shadowColor,
        strokeColor: strokeColor ?? this.strokeColor,
        strokeWidth: strokeWidth ?? this.strokeWidth,
      );

  @override
  String toString() =>
      'CustomBubbleStyle(margin: $margin, radius: $radius, hFlip: $hFlip, vFlip: $vFlip, color: $color, elevation: $elevation, shadowColor: $shadowColor, strokeColor: $strokeColor, strokeWidth: $strokeWidth)';
}

class Position {
  const Position({this.ratio = 0.0, this.offset = 0.0})
      : assert(ratio >= 0.0 && ratio <= 1.0);

  final double ratio;
  final double offset;

  static const zero = Position();

  double apply(double size) => size * ratio + offset;

  @override
  bool operator ==(Object other) =>
      other is Position && other.ratio == ratio && other.offset == offset;

  @override
  int get hashCode => Object.hash(ratio, offset);

  Position copyWith({
    double? ratio,
    double? offset,
  }) =>
      Position(
        ratio: ratio ?? this.ratio,
        offset: offset ?? this.offset,
      );

  @override
  String toString() => 'Position(ratio: $ratio, offset: $offset)';
}

/// Аналог RRect, но исключительно с круглыми (не овальными) углами
class Box {
  const Box._({
    this.left = 0.0,
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
    this.tlRadius = 0.0,
    this.trRadius = 0.0,
    this.brRadius = 0.0,
    this.blRadius = 0.0,
  });

  Box.fromLTRBR(
    double left,
    double top,
    double right,
    double bottom,
    double radius,
  ) : this._(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
          tlRadius: radius,
          trRadius: radius,
          blRadius: radius,
          brRadius: radius,
        );

  Box.fromLTRBAndCorners(
    double left,
    double top,
    double right,
    double bottom, {
    double topLeft = 0.0,
    double topRight = 0.0,
    double bottomRight = 0.0,
    double bottomLeft = 0.0,
  }) : this._(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
          tlRadius: topLeft,
          trRadius: topRight,
          blRadius: bottomLeft,
          brRadius: bottomRight,
        );

  final double left;
  final double top;
  final double right;
  final double bottom;
  final double tlRadius;
  final double trRadius;
  final double brRadius;
  final double blRadius;

  double get width => right - left;
  double get height => bottom - top;
  double get leftHeight => height - blRadius - tlRadius;
  double get rightHeight => height - trRadius - brRadius;
  double get topWidth => width - tlRadius - trRadius;
  double get bottomWidth => width - brRadius - blRadius;

  @override
  String toString() {
    final radius = tlRadius == trRadius &&
            tlRadius == brRadius &&
            tlRadius == blRadius
        ? 'radius: $tlRadius'
        : 'tlRadius: $tlRadius, trRadius: $trRadius, brRadius: $brRadius, blRadius: $blRadius';
    return 'Box(left: $left, top: $top, right: $right, bottom: $bottom, width: $width, height: $height, $radius)';
  }
}

/// Врезка
class Inset {
  const Inset(this.start, this.end);

  final InsetPos start;
  final InsetPos end;

  @override
  String toString() => 'Inset(start: $start, end: $end)';
}

/// Тип позиции врезки
enum InsetPosType {
  left,
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft
}

/// Тип рассчёта смещения, когда оно попадает на угол
/// byLength - по длине дуги угла
/// byHeight - по высоте угла
/// byWidth - по ширине угла
enum CornerOffset { byLength, byHeight, byWidth }

/// Позиция врезки
class InsetPos {
  const InsetPos(
    this.type,
    this.pos, [
    this.cornerOffset = CornerOffset.byLength,
  ]);

  final InsetPosType type;
  final Position pos;
  final CornerOffset cornerOffset;

  static const halfPi = math.pi / 2.0;

  static bool isSide(InsetPosType type) =>
      type == InsetPosType.left ||
      type == InsetPosType.top ||
      type == InsetPosType.right ||
      type == InsetPosType.bottom;

  static bool isCorner(InsetPosType type) =>
      type == InsetPosType.topLeft ||
      type == InsetPosType.topRight ||
      type == InsetPosType.bottomRight ||
      type == InsetPosType.bottomLeft;

  static InsetPosType nextType(InsetPosType type) {
    final newIndex = type.index + 1;
    return newIndex < InsetPosType.values.length
        ? InsetPosType.values[newIndex]
        : InsetPosType.values.first;
  }

  static InsetPosType prevType(InsetPosType type) {
    final newIndex = type.index - 1;
    return newIndex >= 0
        ? InsetPosType.values[newIndex]
        : InsetPosType.values.last;
  }

  AbsInsetPos apply(Box box) {
    AbsInsetPos? result;

    var type = this.type;
    var pos = this.pos;

    while (result == null) {
      if (isSide(type)) {
        late double size;
        switch (type) {
          case InsetPosType.left:
            size = box.leftHeight;
          case InsetPosType.top:
            size = box.topWidth;
          case InsetPosType.right:
            size = box.rightHeight;
          case InsetPosType.bottom:
            size = box.bottomWidth;
          default:
        }

        final offset = pos.apply(size);
        if (offset < 0.0) {
          type = prevType(type);
          pos = Position(ratio: 1, offset: offset);
        } else if (offset > size) {
          type = nextType(type);
          pos = Position(offset: offset - size);
        } else {
          result = AbsInsetPos(type, offset);
        }
      } else {
        late double radius;
        switch (type) {
          case InsetPosType.topLeft:
            radius = box.tlRadius;
          case InsetPosType.topRight:
            radius = box.trRadius;
          case InsetPosType.bottomRight:
            radius = box.brRadius;
          case InsetPosType.bottomLeft:
            radius = box.blRadius;
          default:
        }

        if (pos.offset == 0.0) {
          result = AbsInsetPos(type, pos.ratio * halfPi);
        } else if (cornerOffset == CornerOffset.byLength) {
          final cornerLen = halfPi * radius; // Для дуги угла
          final offset =
              cornerLen * pos.ratio + pos.offset; // Расстояние до точки
          if (offset < 0.0) {
            type = prevType(type);
            pos = Position(ratio: 1, offset: offset);
          } else if (offset > cornerLen) {
            type = nextType(type);
            pos = Position(offset: offset - cornerLen);
          } else {
            result = AbsInsetPos(type, offset / cornerLen * halfPi);
          }
        } else if (cornerOffset == CornerOffset.byHeight &&
                (type == InsetPosType.topLeft ||
                    type == InsetPosType.bottomRight) ||
            cornerOffset == CornerOffset.byWidth &&
                (type == InsetPosType.topRight ||
                    type == InsetPosType.bottomLeft)) {
          final radians = pos.ratio * halfPi;
          final y = math.sin(radians) * radius + pos.offset;
          if (y < 0.0) {
            type = prevType(type);
            pos = Position(ratio: 1, offset: y);
          } else if (y > radius) {
            type = nextType(type);
            pos = Position(offset: y - radius);
          } else {
            result = AbsInsetPos(type, math.asin(y / radius));
          }
        } else {
          final radians = pos.ratio * halfPi;
          final x = (1.0 - math.cos(radians)) * radius + pos.offset;
          if (x < 0.0) {
            type = prevType(type);
            pos = Position(ratio: 1, offset: x);
          } else if (x >= radius) {
            type = nextType(type);
            pos = Position(offset: x - radius);
          } else {
            result = AbsInsetPos(type, math.acos(1.0 - x / radius));
          }
        }
      }
    }

    return result;
  }

  InsetPos copyWith({
    InsetPosType? type,
    Position? pos,
    CornerOffset? cornerOffset,
  }) =>
      InsetPos(
        type ?? this.type,
        pos ?? this.pos,
        cornerOffset ?? this.cornerOffset,
      );

  @override
  String toString() => 'InsetPos($type, $pos, $cornerOffset)';
}

class InsetList {
  const InsetList(this.list);

  final List<Inset> list;

//  void add(Inset element) => _list.add(element);

  List<AbsInset> apply(Box box) {
    final result = <AbsInset>[];
    for (final element in list) {
      result.add(AbsInset(element.start.apply(box), element.end.apply(box)));
    }

    return result;
  }

  @override
  String toString() => 'InsetList($list)';
}

/// Врезка в абсолютных величинах
class AbsInset {
  const AbsInset(this.start, this.end);

  final AbsInsetPos start;
  final AbsInsetPos end;

//  bool get crossesZero => start > end;
//
//  int compareTo(AbsInset other) {
//    // Трудность сравнения пар возникает при переходе нулевой точки
//    if (this.crossesZero) return other.crossesZero ? this.start.compareTo(other.start) : -1;
//    return other.crossesZero ? 1 : this.start.compareTo(other.start);
//  }
//
//  bool operator >(covariant other) {
//    if (this.start > this.end) {
//      return other.start > other.end ? this.start > other.start : false;
//    }
//    if (other.start > other.end) return true;
//    return this.start > other.start;
//  }

  @override
  String toString() => 'AbsInset(start: $start, end: $end)';
}

/// Позиция врезка в абсолютных величинах
class AbsInsetPos {
  const AbsInsetPos(this.type, this.pos);

  final InsetPosType type;
  final double pos;

  bool get isOnSide =>
      type == InsetPosType.left ||
      type == InsetPosType.top ||
      type == InsetPosType.right ||
      type == InsetPosType.bottom;

  bool get isOnCorner =>
      type == InsetPosType.topLeft ||
      type == InsetPosType.topRight ||
      type == InsetPosType.bottomRight ||
      type == InsetPosType.bottomLeft;

  @override
  int get hashCode => Object.hash(type, pos);

  @override
  bool operator ==(Object other) =>
      other is AbsInsetPos && type == other.type && pos == other.pos;

  int compareTo(AbsInsetPos other) {
    var result = type.index.compareTo(other.type.index);
    if (result == 0) result = pos.compareTo(other.pos);
    return result;
  }

  bool operator >(AbsInsetPos other) => compareTo(other) > 0;
  bool operator >=(AbsInsetPos other) => compareTo(other) >= 0;
  bool operator <(AbsInsetPos other) => compareTo(other) < 0;
  bool operator <=(AbsInsetPos other) => compareTo(other) <= 0;

  Point apply(Box box) {
    late Point point;
    switch (type) {
      case InsetPosType.left:
        point = Point(box.left, box.bottom - box.blRadius - pos);

      case InsetPosType.topLeft:
        point = Point(
          box.left + (1.0 - math.cos(pos)) * box.tlRadius,
          box.top + (1.0 - math.sin(pos)) * box.tlRadius,
        );

      case InsetPosType.top:
        point = Point(box.left + box.tlRadius + pos, box.top);

      case InsetPosType.topRight:
        point = Point(
          box.right - (1.0 - math.sin(pos)) * box.trRadius,
          box.top + (1.0 - math.cos(pos)) * box.trRadius,
        );

      case InsetPosType.right:
        point = Point(box.right, box.top + box.trRadius + pos);

      case InsetPosType.bottomRight:
        point = Point(
          box.right - (1.0 - math.cos(pos)) * box.brRadius,
          box.bottom - (1.0 - math.sin(pos)) * box.brRadius,
        );

      case InsetPosType.bottom:
        point = Point(box.right - box.brRadius - pos, box.bottom);

      case InsetPosType.bottomLeft:
        point = Point(
          box.left + (1.0 - math.sin(pos)) * box.blRadius,
          box.bottom - (1.0 - math.cos(pos)) * box.blRadius,
        );
    }

    return point;
  }

  double? getRadius(Box box) {
    double? radius;

    switch (type) {
      case InsetPosType.topLeft:
        radius = box.tlRadius;

      case InsetPosType.topRight:
        radius = box.trRadius;

      case InsetPosType.bottomRight:
        radius = box.brRadius;

      case InsetPosType.bottomLeft:
        radius = box.blRadius;

      default:
    }

    return radius;
  }

  @override
  String toString() => 'AbsInsetPos($type, $pos)';
}
