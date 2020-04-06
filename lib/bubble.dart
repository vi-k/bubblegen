import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'geometry.dart';

RRect rect;

enum NipSideEnum { left, right, top, bottom }
class NipSide {
  const NipSide._internal(this._value);

  final NipSideEnum _value;

  static const left = const NipSide._internal(NipSideEnum.left);
  static const right = const NipSide._internal(NipSideEnum.right);
  static const top = const NipSide._internal(NipSideEnum.top);
  static const bottom = const NipSide._internal(NipSideEnum.bottom);
  static const int minIndex = 0;
  static const int maxIndex = 3;

  static NipSide byIndex(int index) {
    switch (index) {
      case 0: return left;
      case 1: return right;
      case 2: return top;
      case 3: return bottom;
    }

    throw RangeError.range(index, 0, 3);
  }

  int get index => _value.index;
  bool get isLeft => _value == NipSideEnum.left;
  bool get isRight => _value == NipSideEnum.right;
  bool get isTop => _value == NipSideEnum.top;
  bool get isBottom => _value == NipSideEnum.bottom;
  bool get isHorizontal => _value == NipSideEnum.left || _value == NipSideEnum.right;
  bool get isVertical => _value == NipSideEnum.top || _value == NipSideEnum.bottom;

  @override
  String toString({bool onlyValue = false}) {
    String str = _value.toString().substring(12);
    return onlyValue ? str : 'NipSide.$str';
  }
}

class BubbleRadius {
  const BubbleRadius({
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  });

  const BubbleRadius.all(double radius)
      : this(
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        );

  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  @override
  String toString() {
    return topLeft == topRight && bottomLeft == bottomRight && topLeft == bottomLeft
        ? 'BubbleRadius($topLeft)'
        : 'BubbleRadius(topLeft: $topLeft, topRight: $topRight, bottomLeft: $bottomLeft, bottomRight: $bottomRight)';
  }
}

class NipOffset {
  const NipOffset({this.relative = 0, this.absolute = 0});

  final double relative;
  final double absolute;

  double pos(double nipRadius, double sideSize) {
    return (sideSize - 2 * nipRadius) * relative + absolute;
  }

  @override
  bool operator ==(other) {
    return other is NipOffset && other.relative == relative && other.absolute == absolute;
  }

  @override
  int get hashCode => hashValues(relative.hashCode, absolute.hashCode);

  @override
  String toString() {
    return 'NipOffset(relative: $relative, absolute: $absolute)';
  }
}

enum NipLineType {
  line,
//  lineTo,
//  relativeLineTo,
//  lineToCorner,
  arc,
//  arcTo,
//  relativeArcTo,
//  arcToCorner,
  curve,
//  curveTo,
//  relativeCurveTo,
//  curveToCorner
}

enum NipLinePosType {
  angle,
  pos,
  offset,
  corners,
}

class NipLine {
  const NipLine(
    this.lineType,
    this.posType,
    this.pos, {
    this.h = 0.0,
    this.a1,
    this.a2,
    this.sz1,
    this.sz2,
  }) : assert(pos != null);

  final NipLineType lineType;
  final NipLinePosType posType;
  final double pos;
  final double h; // arc's radius
  final double a1; // curve's α₁
  final double a2; // curve's α₂
  final double sz1; // curve's sz₁
  final double sz2; // curve's sz₂

  const NipLine.line(double lineAngle) : this(NipLineType.line, NipLinePosType.angle, lineAngle);
  const NipLine.lineTo(double pos) : this(NipLineType.line, NipLinePosType.pos, pos);
  const NipLine.relativeLineTo(double offset) : this(NipLineType.line, NipLinePosType.offset, offset);
  const NipLine.lineToCorner(double cornerAngle) : this(NipLineType.line, NipLinePosType.corners, cornerAngle);

  const NipLine.arc(double lineAngle, double arcAngle) : this(NipLineType.arc, NipLinePosType.angle, lineAngle, a1: arcAngle);
  const NipLine.arcTo(double pos, double arcAngle) : this(NipLineType.arc, NipLinePosType.pos, pos, a1: arcAngle);
  const NipLine.relativeArcTo(double offset, double arcAngle)
      : this(NipLineType.arc, NipLinePosType.offset, offset, a1: arcAngle);
  const NipLine.arcToCorner(double cornerAngle, double arcAngle)
      : this(NipLineType.arc, NipLinePosType.corners, cornerAngle, a1: arcAngle);

  const NipLine.curve(double lineAngle, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this(
          NipLineType.curve,
          NipLinePosType.angle,
          lineAngle,
          a1: angle1,
          a2: angle2,
          sz1: size1,
          sz2: size2,
        );

  const NipLine.curveTo(double pos, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this(
          NipLineType.curve,
          NipLinePosType.pos,
          pos,
          a1: angle1,
          a2: angle2,
          sz1: size1,
          sz2: size2,
        );

  const NipLine.relativeCurveTo(double pos, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this(
          NipLineType.curve,
          NipLinePosType.offset,
          pos,
          a1: angle1,
          a2: angle2,
          sz1: size1,
          sz2: size2,
        );

  const NipLine.curveToCorner(double cornerAngle, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this(
          NipLineType.curve,
          NipLinePosType.corners,
          cornerAngle,
          a1: angle1,
          a2: angle2,
          sz1: size1,
          sz2: size2,
        );
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

  static final Color draftColor = Colors.black26;
  static final Color lineColor = Colors.orange;
  static final Color mainColor = Colors.black;
  static final Color errorColor = Colors.red;

  List<DraftLine> _lines = [];
  List<DraftLineSegment> _lineSegments = [];
  List<DraftPoint> _points = [];

  get lines => _lines;
  get lineSegments => _lineSegments;
  get points => _points;

  void addLine(Point start, double direct, [DraftType type = DraftType.Draft]) =>
      lines.add(DraftLine(Line(start, direct), type));
  void addLineCopy(Line line, [DraftType type = DraftType.Draft]) =>
      lines.add(DraftLine(Line(line.start, line.direct), type));

  void addLineSegment(Point start, Point end, [DraftType type = DraftType.Draft]) =>
      lineSegments.add(DraftLineSegment(LineSegment(start, end), type));
  void addLineSegmentCopy(LineSegment lineSegment, [DraftType type = DraftType.Draft]) =>
      lineSegments.add(DraftLineSegment(LineSegment(lineSegment.start, lineSegment.end), type));

  void addPoint(Point point, [DraftType type = DraftType.Draft]) => points.add(DraftPoint(point, type));

  void paintBackground(Canvas canvas, BubblePaintInfo pi) {
    final dp = 1.0 / pi.scale;
    final limitSize = 10.0 * dp;

    var paint = Paint();
    paint.strokeWidth = 1 * dp;
    paint.color = draftColor;
    paint.style = PaintingStyle.stroke;

    var path = Path();

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

    var path = Path();
    var paint = Paint()
      ..strokeWidth = 1 * dp
      ..color = draftColor
      ..style = PaintingStyle.fill;

    // Малый круг
    if (showNip) {
      canvas.drawCircle(pi.nipCircle.center, pi.nipCircle.radius, paint);
    }

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
          Rect.fromCenter(center: pi.ltCircle.center, width: pi.ltCircle.diameter, height: pi.ltCircle.diameter),
          -math.pi / 2,
          -math.pi / 2,
          true,
          paint);
    } else {
      path.reset();
      path.moveTo(pi.ltCircle.center.dx, pi.ltCircle.center.dy - pi.ltCircle.radius);
      path.lineTo(pi.ltCircle.center.dx, pi.ltCircle.center.dy);
      path.lineTo(pi.ltCircle.center.dx - pi.ltCircle.radius, pi.ltCircle.center.dy);
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }

    // Нижний угол
    if (showBottomCorner) {
      paint.style = PaintingStyle.fill;
      canvas.drawArc(
          Rect.fromCenter(center: pi.lbCircle.center, width: pi.lbCircle.diameter, height: pi.lbCircle.diameter),
          math.pi / 2,
          math.pi / 2,
          true,
          paint);
    } else {
      path.reset();
      path.moveTo(pi.lbCircle.center.dx, pi.lbCircle.center.dy + pi.lbCircle.radius);
      path.lineTo(pi.lbCircle.center.dx, pi.lbCircle.center.dy);
      path.lineTo(pi.lbCircle.center.dx - pi.lbCircle.radius, pi.lbCircle.center.dy);
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }

    // Правый верхний угол
    path.reset();
    path.moveTo(pi.rtCircle.center.dx, pi.rtCircle.center.dy - pi.rtCircle.radius);
    path.lineTo(pi.rtCircle.center.dx, pi.rtCircle.center.dy);
    path.lineTo(pi.rtCircle.center.dx + pi.rtCircle.radius, pi.rtCircle.center.dy);
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);

    // Правый нижний угол
    path.reset();
    path.moveTo(pi.rbCircle.center.dx, pi.rbCircle.center.dy + pi.rbCircle.radius);
    path.lineTo(pi.rbCircle.center.dx, pi.rbCircle.center.dy);
    path.lineTo(pi.rbCircle.center.dx + pi.rbCircle.radius, pi.rbCircle.center.dy);
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);

    DraftType.values.forEach((type) {
      paint.color = type == DraftType.Error ? errorColor : type == DraftType.Main ? mainColor : draftColor;

      paint.style = PaintingStyle.stroke;

      // Линии
      lines.forEach((item) {
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
            var start = item.line.point(size);
            if (start.x < pi.rect.left - padding || start.x > pi.rect.right + padding
                || start.y < pi.rect.top - padding || start.y > pi.rect.bottom + padding) break;
            var end = item.line.point(size + interval);
            size += 2 * interval;
            canvas.drawLine(start, end, paint);
          }
        }
      });

      // Отрезки
      lineSegments.forEach((item) {
        if (item.type == type) {
          canvas.drawLine(item.lineSegment.start, item.lineSegment.end, paint);
        }
      });

      paint.style = PaintingStyle.fill;

      // Точки
      points.forEach((item) {
        if (item.type == type) {
          canvas.drawCircle(item.point, pointSize, paint);
        }
      });
    });
  }
}

class BubblePaintInfo {
  double scale;
  Rect rect;
  Circle nipCircle;
  Rect box;
  Circle ltCircle;
  Circle lbCircle;
  Circle rtCircle;
  Circle rbCircle;
  DraftInfo draft;
}

class BubbleStyle {
  const BubbleStyle({
    this.radius = const BubbleRadius.all(4.0),
    this.nipSide = NipSide.left,
    this.inverse = false,
    this.nipRadius = 0.5,
    this.nipSize = 7.0,
    this.nipPlaceholderSize,
    this.nipOffset = const NipOffset(),
    this.color = Colors.white,
    this.elevation = 1.0,
    this.shadowColor = Colors.black,
    this.strokeColor = Colors.orange,
    this.strokeWidth = 0.0,
  })  : assert(radius != null),
        assert(nipSide != null),
        assert(inverse != null),
        assert(nipRadius != null),
        assert(nipSize != null),
        assert(nipOffset != null),
        assert(color != null),
        assert(elevation != null),
        assert(shadowColor != null),
        assert(strokeColor != null),
        assert(strokeWidth != null);

  final BubbleRadius radius;
  final NipSide nipSide;
  final bool inverse;
  final double nipRadius;
  final double nipSize;
  final double nipPlaceholderSize;
  final NipOffset nipOffset;
  final Color color;
  final double elevation;
  final Color shadowColor;
  final Color strokeColor;
  final double strokeWidth;

  BubbleStyle copyWith({
      BubbleRadius radius,
      NipSide nipSide,
      bool inverse,
      double nipRadius,
      double nipSize,
      double nipPlaceholderSize,
      NipOffset nipOffset,
      Color color,
      double elevation,
      Color shadowColor,
      Color strokeColor,
      double strokeWidth,
  }) {
    return BubbleStyle(
      radius: radius ?? this.radius,
      nipSide: nipSide ?? this.nipSide,
      inverse: inverse ?? this.inverse,
      nipRadius: nipRadius ?? this.nipRadius,
      nipSize: nipSize ?? this.nipSize,
      nipPlaceholderSize: nipPlaceholderSize ?? this.nipPlaceholderSize,
      nipOffset: nipOffset ?? this.nipOffset,
      color: color ?? this.color,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  String toString() {
    return 'BubbleStyle(radius: $radius, nipSide: $nipSide, inverse: $inverse, nipRadius: $nipRadius, nipSize: $nipSize, nipPlaceholderSize: $nipPlaceholderSize, nipOffset: $nipOffset, color: $color, elevation: $elevation, shadowColor: $shadowColor)';
  }
}

class CustomBubble extends SingleChildRenderObjectWidget {
  const CustomBubble({
    this.child,
    this.style = const BubbleStyle(),
    this.scale = 1.0,
    this.drawDraft = false,
  })  : assert(style != null),
        assert(scale != null),
        assert(drawDraft != null);

  final BubbleStyle style;
  final Widget child;
  final double scale;
  final bool drawDraft;

  @override
  RenderObject createRenderObject(BuildContext context) {
//    print('createRenderObject');
    return RenderBubble(this);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBubble renderObject) {
//    print('updateRenderObject');
    renderObject.bubble = this;
  }

  @protected
  void createNip(Path path, BubblePaintInfo pi) {}

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CustomBubble(style: $style, scale: $scale, drawDraft: $drawDraft)';
  }
}

class RenderBubble extends RenderProxyBox {
  RenderBubble(
    CustomBubble bubble, {
    RenderBox child,
  })  : assert(bubble != null),
        _bubble = bubble,
        super(child);

  CustomBubble _bubble;

  CustomBubble get bubble => _bubble;

  set bubble(CustomBubble bubble) {
    assert(bubble != null);
    if (_bubble.scale != bubble.scale
        || _bubble.style.nipSide != bubble.style.nipSide
        || _bubble.style.nipPlaceholderSize != bubble.style.nipPlaceholderSize
        || _bubble.style.nipPlaceholderSize == null
            && _bubble.style.nipSize != bubble.style.nipSize) {
      markNeedsLayout();
    }
    markNeedsPaint();
    _bubble = bubble;
  }

  @override
  void performLayout() {
//    print('performLayout');

    if (child != null) {
      // Вычисляем размер child
      BoxConstraints childConstraints;
      Offset changes;
      final nipPlaceholderSize = bubble.style.nipPlaceholderSize ?? bubble.style.nipSize;

      if (bubble.style.nipSide.isHorizontal) {
        changes = Offset(nipPlaceholderSize, 0);
        final maxWidth = constraints.maxWidth - nipPlaceholderSize * bubble.scale;
        final minWidth = math.min(constraints.minWidth, maxWidth);
        childConstraints = constraints.copyWith(
          maxWidth: maxWidth,
          minWidth: minWidth,
        );
      } else if (bubble.style.nipSide.isVertical) {
        changes = Offset(0, nipPlaceholderSize);
        final maxHeight = constraints.maxHeight - nipPlaceholderSize * bubble.scale;
        final minHeight = math.min(constraints.minHeight, maxHeight);
        childConstraints = constraints.copyWith(
          maxHeight: maxHeight,
          minHeight: minHeight,
        );
      }

      childConstraints = childConstraints / bubble.scale;
//      print('constraints: $constraints');
//      print('childConstraints: $childConstraints');

      child.layout(childConstraints, parentUsesSize: true);
      size = Size(child.size.width + changes.dx, child.size.height + changes.dy) * bubble.scale;
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

    var pi = BubblePaintInfo();
    pi.scale = bubble.scale;
    var childOffset = offset;

    final nipPlaceholderSize = bubble.style.nipPlaceholderSize ?? bubble.style.nipSize;

//    print('$bubble');
//    print('size: $size');
//    print('original size: ${size / pi.scale}');

    if (bubble.style.nipSide.isHorizontal) {
      pi.rect = Rect.fromLTWH(0, 0, size.width / bubble.scale, size.height / bubble.scale);
      pi.box = Rect.fromLTWH(nipPlaceholderSize, 0, size.width / bubble.scale - nipPlaceholderSize, size.height / bubble.scale);
      if (bubble.style.nipSide.isLeft) childOffset = offset.translate(nipPlaceholderSize * bubble.scale, 0);
    } else {
      pi.rect = Rect.fromLTWH(0, 0, size.height / bubble.scale, size.width / bubble.scale);
      pi.box = Rect.fromLTWH(nipPlaceholderSize, 0, size.height / bubble.scale - nipPlaceholderSize, size.width / bubble.scale);
      if (bubble.style.nipSide.isTop) childOffset = offset.translate(0, nipPlaceholderSize * bubble.scale);
    }

//    print('childOffset: $childOffset');
//    print('pi.rect: ${pi.rect}');
//    print('pi.box: ${pi.box}');

    //
    // Если радиусы больше сторон бокса, рассчитываем коэффициент, чтобы равномерно уменьшить все радиусы
    //
    double k = 1.0;

    if (bubble.style.radius.topLeft + bubble.style.radius.topRight > pi.box.width) {
      var tK = pi.box.width / (bubble.style.radius.topLeft + bubble.style.radius.topRight);
      if (tK < k) k = tK;
    }

    if (bubble.style.radius.bottomLeft + bubble.style.radius.bottomRight > pi.box.width) {
      var bK = pi.box.width / (bubble.style.radius.bottomLeft + bubble.style.radius.bottomRight);
      if (bK < k) k = bK;
    }

    if (bubble.style.radius.topLeft + bubble.style.radius.bottomLeft > pi.box.height) {
      var lK = pi.box.height / (bubble.style.radius.topLeft + bubble.style.radius.bottomLeft);
      if (lK < k) k = lK;
    }

    if (bubble.style.radius.topRight + bubble.style.radius.bottomRight > pi.box.height) {
      var rK = pi.box.height / (bubble.style.radius.topRight + bubble.style.radius.bottomRight);
      if (rK < k) k = rK;
    }

    pi.nipCircle = Circle(
        Point(pi.box.left - bubble.style.nipSize + bubble.style.nipRadius,
            pi.box.top + bubble.style.nipOffset.pos(bubble.style.nipRadius, pi.box.height) + bubble.style.nipRadius),
        bubble.style.nipRadius);

    var r = bubble.style.radius.topLeft * k;
    pi.ltCircle = Circle(Point(pi.box.left + r, pi.box.top + r), r);

    r = bubble.style.radius.bottomLeft * k;
    pi.lbCircle = Circle(Point(pi.box.left + r, pi.box.bottom - r), r);

    r = bubble.style.radius.topRight * k;
    pi.rtCircle = Circle(Point(pi.box.right - r, pi.box.top + r), r);

    r = bubble.style.radius.bottomRight * k;
    pi.rbCircle = Circle(Point(pi.box.right - r, pi.box.bottom - r), r);

    pi.draft = bubble.drawDraft ? DraftInfo() : null;

    var path = Path();
    bubble.createNip(path, pi);
    path.close();

    path.addOval(
        Rect.fromCenter(center: pi.nipCircle.center, width: pi.nipCircle.diameter, height: pi.nipCircle.diameter));

    path.addRRect(RRect.fromLTRBAndCorners(pi.box.left, pi.box.top, pi.box.right, pi.box.bottom,
        topLeft: Radius.circular(pi.ltCircle.radius),
        topRight: Radius.circular(pi.rtCircle.radius),
        bottomLeft: Radius.circular(pi.lbCircle.radius),
        bottomRight: Radius.circular(pi.rbCircle.radius)));

    // Без этого части останутся разрозненными
    path = Path.combine(PathOperation.union, path, Path());

    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);

    if (bubble.style.nipSide.isRight) {
      context.canvas.translate(size.width, 0);
      context.canvas.scale(-1, 1);
    } else if (bubble.style.nipSide.isTop) {
      context.canvas.scale(-1, 1);
      context.canvas.rotate(math.pi * 90 / 180);
    } else if (bubble.style.nipSide.isBottom) {
      context.canvas.translate(0, size.height);
      context.canvas.scale(-1, -1);
      context.canvas.rotate(math.pi * 90 / 180);
    }

    if (bubble.style.inverse) {
      context.canvas.translate(0, bubble.style.nipSide.isHorizontal ? size.height : size.width);
      context.canvas.scale(1, -1);
    }

    context.canvas.scale(bubble.scale);

    var paint = Paint();
    paint.color = bubble.style.color;
    paint.style = PaintingStyle.fill;
    if (pi.draft != null) pi.draft.paintBackground(context.canvas, pi);
    context.canvas.drawShadow(path, bubble.style.shadowColor, bubble.style.elevation * bubble.scale, false);
    context.canvas.drawPath(path, paint);

    // Обводка
    if (bubble.style.strokeWidth != 0.0) {
      paint.style = PaintingStyle.stroke;
      paint.color = bubble.style.strokeColor;
      paint.strokeWidth = bubble.style.strokeWidth;
      context.canvas.drawPath(path, paint);
    }

    if (pi.draft != null) pi.draft.paint(context.canvas, pi);

    context.canvas.restore();

    context.canvas.save();
    context.canvas.translate(childOffset.dx, childOffset.dy);
    context.canvas.scale(bubble.scale);
    context.paintChild(child, Offset.zero);
    context.canvas.restore();
  }
}

class Bubble extends CustomBubble {
  Bubble({
    Widget child,
    BubbleStyle style,
    double scale = 1.0,
    bool drawDraft = false,
    @required this.topLine,
    @required this.bottomLine,
  })  : assert(topLine != null),
        assert(bottomLine != null),
        super(
          child: child,
          style: style,
          scale: scale,
          drawDraft: drawDraft,
        );

  final NipLine topLine;
  final NipLine bottomLine;

  @override
  void createNip(Path path, BubblePaintInfo pi) {
    addLine(topLine, false, path, pi);
    addLine(bottomLine, true, path, pi);
    path.close();
  }

  Point addLine(NipLine nipLine, bool inverse, Path path, BubblePaintInfo pi) {
    bool ok = true;
    var result = LineSegment(null, null);

//    print(nipLine.type);

    switch (nipLine.lineType) {
      case NipLineType.line:
        switch (nipLine.posType) {
          case NipLinePosType.angle:
            ok = line(result, nipLine.pos * math.pi / 180, inverse, path, pi);
            break;

          case NipLinePosType.pos:
            ok = lineTo(result, nipLine.pos, inverse, path, pi);
            break;

          case NipLinePosType.offset:
            ok = lineTo(
                result, pi.nipCircle.center.y + (inverse ? pi.nipCircle.radius : -pi.nipCircle.radius) + nipLine.pos,
                inverse, path, pi);
            break;

          case NipLinePosType.corners:
            ok = lineToCorner(result, nipLine.pos * math.pi / 180, inverse, path, pi);
            break;
        }
        break;

      case NipLineType.arc:
        // TODO: Handle this case.
        break;

      case NipLineType.curve:
        // TODO: Handle this case.
        break;
    }

    // Малый круг
    if (pi.draft != null) {
      pi.draft.addLineSegment(pi.nipCircle.center, result.start);
      if (inverse) pi.draft.addPoint(pi.nipCircle.center);

      // Линия
      var type = ok ? DraftType.Main : DraftType.Error;
      pi.draft.addLineSegment(result.end, result.start, type);
      pi.draft.addPoint(result.start, type);
      pi.draft.addPoint(result.end, type);
    }

    if (inverse) {
      path.lineTo(result.end.x, result.end.y);
      path.lineTo(result.start.x, result.start.y);
    } else {
//      print('result: $result');
      path.moveTo(result.start.x, result.start.y);
      path.lineTo(result.end.x, result.end.y);
    }

    return result.start;
  }

  /// Прямая линия под углом
  bool line(LineSegment out, double angle, bool inverse, Path path, BubblePaintInfo pi) {
    bool ok = true;

    var beta = inverse ? angle + math.pi / 2 : angle - math.pi / 2; // Точка касательной на малом круге

    var line = Line(pi.nipCircle.point(beta), angle);
    var tan = line.tan();
    out.start = line.start;

    if (pi.draft != null) {
      pi.draft.addPoint(out.start);
      pi.draft.addLineCopy(line);
    }

    //
    // Линия пересекает ровную часть левой стороны бокса
    //
    out.end = Point(pi.box.left, out.start.y + (pi.box.left - out.start.x) * tan);
    if (out.end.y >= pi.ltCircle.center.y && out.end.y <= pi.lbCircle.center.y) {
      pi.draft?.showLeftSide = true;
    }
    //
    // Линия уходит к верхней части бокса
    //
    else if (out.end.y < pi.ltCircle.center.y) {
      var processed = false;

      //
      // Линия падает сверху на бокс
      //
      if (pi.nipCircle.center.y + (inverse ? pi.nipCircle.radius : -pi.nipCircle.radius) < pi.box.top) {
        out.end = Point(out.start.x + (pi.box.top - out.start.y) / tan, pi.box.top);
        if (out.end.x >= pi.ltCircle.center.x || tan < 0) {
          processed = true;
          pi.draft?.showTopSide = true;

          //
          // Линия уходит к правому краю бокса
          // (касательную к правому кругу не строим, ограничиваемся правым краем ровной стороны)
          //
          if (out.end.x > pi.rtCircle.center.x || tan < 0) {
            ok = false;

            out.end = Point(pi.rtCircle.center.x, pi.box.top);
            var tangent = pi.nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
            out.start = tangent.start;
          }
        }
      }

      if (!processed) {
        pi.draft?.showTopCorner = true;

        // Рассчитываем пересечение линии с верхним кругом. Получаем хорду
        var chord = line.intersectCircle(pi.ltCircle);

        //
        // Линия пересекается с дугой угла
        //
        if (chord != null) {
          out.end = chord.start;

          if (pi.draft != null) {
            var normal = line.normal(pi.ltCircle.center);
            pi.draft.addLineSegmentCopy(normal);
            pi.draft.addPoint(normal.end);
          }
        }
        //
        // Линия выходит за верхний круг
        // В этом случае за линию берём касательную, общую для малого и нижнего кругов
        //
        else {
          ok = false;

          LineSegment tangent = pi.nipCircle.tangentToCircle(pi.ltCircle, inverse ? 1.0 : -1.0, -1.0);
          out.start = tangent.start;
          out.end = tangent.end;

          pi.draft?.addLineSegment(pi.ltCircle.center, out.end);
        }
      }
    }
    //
    // Линия уходит к нижней части бокса
    //
    else {
      var processed = false;

      // Линия падает снизу на бокс
      if (pi.nipCircle.center.y + (inverse ? pi.nipCircle.radius : -pi.nipCircle.radius) > pi.box.bottom) {
        out.end = Point(out.start.x + (pi.box.bottom - out.start.y) / tan, pi.box.bottom);
        if (out.end.x >= pi.lbCircle.center.x || tan >= 0) {
          processed = true;
          pi.draft?.showBottomSide = true;

          // Линия уходит к правому краю бокса
          // (касательную к правому кругу не строим, ограничиваемся правым краем ровной стороны)
          if (out.end.x > pi.rbCircle.center.x || tan >= 0) {
            ok = false;

            out.end = Point(pi.rbCircle.center.x, pi.box.bottom);
            var tangent = pi.nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
            out.start = tangent.start;
          }
        }
      }

      if (!processed) {
        pi.draft?.showBottomCorner = true;

        // Рассчитываем пересечение линии с нижним кругом
        var chord = line.intersectCircle(pi.lbCircle);

        //
        // Линия пересекается с дугой угла
        //
        if (chord != null) {
          out.end = chord.start;

          if (pi.draft != null) {
            var normal = line.normal(pi.lbCircle.center);
            pi.draft.addLineSegmentCopy(normal);
            pi.draft.addPoint(normal.end);
          }
        }
        //
        // Линия выходит за нижний круг
        // В этом случае за линию берём касательную, общую для малого и нижнего кругов
        //
        else {
          ok = false;

          LineSegment tangent = pi.nipCircle.tangentToCircle(pi.lbCircle, inverse ? 1.0 : -1.0, 1.0);
          out.start = tangent.start;
          out.end = tangent.end;

          pi.draft?.addLineSegment(pi.lbCircle.center, out.end);
        }
      }
    }

    return ok;
  }

  /// Прямая линия к позиции на стороне бокса
  bool lineTo(LineSegment out, double pos, bool inverse, Path path, BubblePaintInfo pi) {
    bool ok = true;
    Point draftEnd;

    //
    // Линия уходит к верхней стороне бокса
    //
    if (pos < 0) {
      var offset = -pos;
      draftEnd = out.end = Point(pi.ltCircle.center.x + offset, pi.box.top);
      if (pi.ltCircle.center.x + offset > pi.rtCircle.center.x) {
        ok = false;
        out.end = Point(pi.rtCircle.center.x, pi.box.top);
      }
    }
    //
    // Линия уходит к нижней стороне бокса
    //
    else if (pos > pi.box.height) {
      var offset = pos - pi.box.height;
      draftEnd = out.end = Point(pi.lbCircle.center.x + offset, pi.box.bottom);
      if (pi.lbCircle.center.x + offset > pi.rbCircle.center.x) {
        ok = false;
        out.end = Point(pi.rbCircle.center.x, pi.box.bottom);
      }
    }
    //
    // Линия уходит к левой стороне бокса
    //
    else {
      draftEnd = out.end = Point(pi.box.left, pi.box.top + pos);

      //
      // Линия пересекается с ровной стороной бокса
      //
      if (out.end.y >= pi.ltCircle.center.y && out.end.y <= pi.lbCircle.center.y) {
        pi.draft?.showLeftSide = true;
      }
      //
      // Линия уходит к верхнему углу
      //
      else if (out.end.y < pi.ltCircle.center.y) {
        draftEnd =
            out.end = pi.ltCircle.point(math.asin((pi.ltCircle.center.y - out.end.y) / pi.ltCircle.radius) - math.pi);

        if (pi.draft != null) {
          pi.draft.showTopCorner = true;
          pi.draft.addLineSegment(out.end, Point(pi.ltCircle.center.x, out.end.y));
        }
      }
      //
      // Линия уходит к нижнему углу
      //
      else {
        draftEnd =
            out.end = pi.lbCircle.point(math.asin((pi.lbCircle.center.y - out.end.y) / pi.lbCircle.radius) - math.pi);

        if (pi.draft != null) {
          pi.draft.showBottomCorner = true;
          pi.draft.addLineSegment(out.end, Point(pi.lbCircle.center.x, out.end.y));
        }
      }
    }

    if (pi.draft != null) {
      var tangent = pi.nipCircle.tangentToPoint(draftEnd, inverse ? 1.0 : -1.0);
      pi.draft.addPoint(draftEnd);
      pi.draft.addLineSegment(pi.nipCircle.center, tangent.start);
      pi.draft.addPoint(tangent.start);
      pi.draft.addLineSegmentCopy(tangent);
    }

    // Смотрим, не вышла ли линия за касательную
    bool processed = false;
    if (out.end.y < pi.ltCircle.center.y && pi.nipCircle.center.y - pi.nipCircle.radius >= pi.box.top) {
      var tangent = pi.nipCircle.tangentToCircle(pi.ltCircle, inverse ? 1.0 : -1.0, -1.0);
      if (out.end.x > tangent.end.x) {
        processed = true;
        ok = false;
        out.start = tangent.start;
        out.end = tangent.end;
        if (pi.draft != null) {
          pi.draft.showTopCorner = true;
          pi.draft.addLineSegment(pi.ltCircle.center, tangent.end);
        }
      }
    } else if (out.end.y > pi.lbCircle.center.y && pi.nipCircle.center.y + pi.nipCircle.radius <= pi.box.bottom) {
      var tangent = pi.nipCircle.tangentToCircle(pi.lbCircle, inverse ? 1.0 : -1.0, 1.0);
      if (out.end.x > tangent.end.x) {
        processed = true;
        ok = false;
        out.start = tangent.start;
        out.end = tangent.end;
        if (pi.draft != null) {
          pi.draft.showBottomCorner = true;
          pi.draft.addLineSegment(pi.lbCircle.center, tangent.end);
        }
      }
    } else if (pi.draft != null) {
      if (out.end.y == pi.box.top)
        pi.draft.showTopSide = true;
      else if (out.end.y == pi.box.bottom) pi.draft.showBottomSide = true;
    }

    if (!processed) {
      var tangent = pi.nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
      out.start = tangent.start;
    }

    return ok;
  }

  /// Прямая линия к углам бокса
  bool lineToCorner(LineSegment out, double angle, bool inverse, Path path, BubblePaintInfo pi) {
    bool ok = true;
    Point draftEnd;

    out.start = null;

    // Отрицательные значения - верхний круг, положительные - нижний
    draftEnd = out.end = angle <= 0 ? pi.ltCircle.point(angle) : pi.lbCircle.point(angle);

    if (pi.draft != null) {
      pi.draft.addPoint(draftEnd);
      var tangent = pi.nipCircle.tangentToPoint(draftEnd, inverse ? 1.0 : -1.0);
      pi.draft.addLineSegmentCopy(tangent);
    }

    // Проверям выход за границы четвертей
    if (angle <= 0) {
      if (angle > -math.pi / 2) {
        ok = false;
        out.end = Point(pi.ltCircle.center.x, pi.box.top);
      } else if (angle < -math.pi) {
        ok = false;
        out.end = Point(pi.box.left, pi.ltCircle.center.y);
      }
    } else if (angle >= 0) {
      if (angle < math.pi / 2) {
        ok = false;
        out.end = Point(pi.lbCircle.center.x, pi.box.bottom);
      } else if (angle > math.pi) {
        ok = false;
        out.end = Point(pi.box.left, pi.lbCircle.center.y);
      }
    }

    if (angle <= 0) {
      var tangent = pi.nipCircle.tangentToCircle(pi.ltCircle, inverse ? 1.0 : -1.0, -1.0);
      if (out.end.x > tangent.end.x) {
        ok = false;
        out.start = tangent.start;
        out.end = tangent.end;
        if (pi.draft != null) {
          pi.draft.showTopCorner = true;
          pi.draft.addLineSegment(pi.ltCircle.center, tangent.end);
        }
      }
    } else if (angle >= 0) {
      var tangent = pi.nipCircle.tangentToCircle(pi.lbCircle, inverse ? 1.0 : -1.0, 1.0);
      if (out.end.x > tangent.end.x) {
        ok = false;
        out.start = tangent.start;
        out.end = tangent.end;
        if (pi.draft != null) {
          pi.draft.showBottomCorner = true;
          pi.draft.addLineSegment(pi.lbCircle.center, tangent.end);
        }
      }
    }

    if (out.start == null) {
      var tangent = pi.nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
      out.start = tangent.start;
    }

    if (pi.draft != null) {
      var tangent = pi.nipCircle.tangentToPoint(draftEnd, inverse ? 1.0 : -1.0);
      out.start = tangent.start;

      pi.draft.addPoint(draftEnd);
      pi.draft.addLineSegment(out.start, draftEnd);

      if (angle <= 0) {
        pi.draft.showTopCorner = true;
        pi.draft.addLineSegment(pi.ltCircle.center, draftEnd);
      } else {
        pi.draft.showBottomCorner = true;
        pi.draft.addLineSegment(pi.lbCircle.center, draftEnd);
      }
    }

    return ok;
  }
}
