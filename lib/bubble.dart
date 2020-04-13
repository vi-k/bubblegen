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
            final start = item.line.point(size);
            if (start.x < pi.rect.left - padding || start.x > pi.rect.right + padding
                || start.y < pi.rect.top - padding || start.y > pi.rect.bottom + padding) break;
            final end = item.line.point(size + interval);
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
  CustomBubble({
    this.child,
    this.style = const BubbleStyle(),
    this.scale = 1.0,
    this.drawDraft = false,
    Inset inset,
    List<Inset> insets,
  })  : assert(style != null),
        assert(scale != null),
        assert(drawDraft != null),
        assert(inset == null || insets == null),
        insets = InsetList(insets ?? (inset != null ? [inset] : []));

  final BubbleStyle style;
  final Widget child;
  final double scale;
  final bool drawDraft;
  final InsetList insets;

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

  void generateInsets() {
    insets.list.clear();
    insets.list.add(Inset(
        InsetPos(InsetPosType.topLeft, Position(ratio: 0.5)),
        InsetPos(InsetPosType.top, Position(offset: 5.0))
    ));
    insets.list.add(Inset(
        InsetPos(InsetPosType.topRight, Position(ratio: 0.5)),
        InsetPos(InsetPosType.right, Position(offset: 5.0))
    ));
    insets.list.add(Inset(
        InsetPos(InsetPosType.bottomRight, Position(ratio: 0.5)),
        InsetPos(InsetPosType.bottom, Position(offset: 5.0))
    ));
    insets.list.add(Inset(
        InsetPos(InsetPosType.bottomLeft, Position(ratio: 0.5)),
        InsetPos(InsetPosType.left, Position(offset: 5.0))
    ));
  }

  void createInset(int index, Path path, Box box, Point start, Point end, Inset inset, AbsInset absInset) {
//    print('--- inset: $absInset $end');
    path.arcToPoint(end, radius: Radius.circular(1.0), largeArc: false, clockwise: true);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CustomBubble(${scale == 1.0 ? '' : 'scale: $scale, '}${drawDraft == false ? '' : 'drawDraft: $drawDraft, '}style: $style, insets: $insets)';
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

    final pi = BubblePaintInfo();
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
    var k = 1.0;

    if (bubble.style.radius.topLeft + bubble.style.radius.topRight > pi.box.width) {
      final tK = pi.box.width / (bubble.style.radius.topLeft + bubble.style.radius.topRight);
      if (tK < k) k = tK;
    }

    if (bubble.style.radius.bottomLeft + bubble.style.radius.bottomRight > pi.box.width) {
      final bK = pi.box.width / (bubble.style.radius.bottomLeft + bubble.style.radius.bottomRight);
      if (bK < k) k = bK;
    }

    if (bubble.style.radius.topLeft + bubble.style.radius.bottomLeft > pi.box.height) {
      final lK = pi.box.height / (bubble.style.radius.topLeft + bubble.style.radius.bottomLeft);
      if (lK < k) k = lK;
    }

    if (bubble.style.radius.topRight + bubble.style.radius.bottomRight > pi.box.height) {
      final rK = pi.box.height / (bubble.style.radius.topRight + bubble.style.radius.bottomRight);
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
//    path.moveTo(0.0, 0.0);
//    path.lineTo(20.0, 0.0);
//    path.lineTo(20.0, 10.0);
//    path.lineTo(0.0, 10.0);
//    bubble.createNip(path, pi);
//    path.close();

    final box = Box.fromLTRBAndCorners(pi.box.left, pi.box.top, pi.box.right, pi.box.bottom,
        topLeft: pi.ltCircle.radius,
        topRight: pi.rtCircle.radius,
        bottomLeft: pi.lbCircle.radius,
        bottomRight: pi.rbCircle.radius
    );

    bubble.generateInsets();
    createBox(path, box);

    var thirdPath = Path()
      ..addOval(Rect.fromCenter(center: pi.nipCircle.center - Offset(0.0, 0.0), width: pi.nipCircle.diameter, height: pi.nipCircle.diameter));
//    path = Path.combine(PathOperation.union, path, thirdPath);

    var path4 = Path();
    bubble.createNip(path4, pi);
    path4.close();

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

    final paint = Paint();
    paint.color = bubble.style.color;
    paint.style = PaintingStyle.fill;
    if (pi.draft != null) pi.draft.paintBackground(context.canvas, pi);
    context.canvas.drawShadow(path, bubble.style.shadowColor, bubble.style.elevation * bubble.scale, true);
    context.canvas.drawPath(path, paint);

    // Обводка
    if (bubble.style.strokeWidth != 0.0) {
      paint.style = PaintingStyle.stroke;
      paint.color = bubble.style.strokeColor;
      paint.strokeWidth = bubble.style.strokeWidth;
//      paint.strokeCap = StrokeCap.round;
      paint.strokeJoin = StrokeJoin.round;
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

  void createBox(Path path, Box box) {
//    print('createBox()');

    final absInsets = bubble.insets.apply(box);

//    print('box: $box');

    final start = absInsets.list.length > 0 ? absInsets.list[0].start : AbsInsetPos(InsetPosType.topLeft, 0.0);
    var lastPoint = start.apply(box);
//    print('moveTo: $start $lastPoint');
    path.moveTo(lastPoint.x, lastPoint.y);

    if (absInsets.list.length == 0) {
      pathFromTo(path, box, start, AbsInsetPos(InsetPosType.left, 0.0));
    } else {
      for (var index = 0; index < absInsets.list.length; index++) {
        var inset = bubble.insets.list[index];
        var absInset = absInsets.list[index];

        // Врезка
        var nextPoint = absInset.end.apply(box);
        bubble.createInset(
            index,
            path,
            box,
            lastPoint,
            nextPoint,
            inset,
            absInset);
        lastPoint = nextPoint;

        // Путь до следующей врезки
        final pos = index < absInsets.list.length - 1 ? absInsets.list[index + 1].start : start;
        nextPoint = pathFromTo(path, box, absInset.end, pos);
        if (nextPoint != null) lastPoint = nextPoint;
      }
    }

    path.close();
  }

  Point pathFromTo(Path path, Box box, AbsInsetPos start, AbsInsetPos end) {
    Point point;

//    print('$start $end');
//    print('start: ${start.apply(box)}');

    var pos = start;
    while (pos != end) {
      final prevPos = pos;
      if (pos.type == end.type && pos.pos < end.pos) pos = end;
      else {
        var nextTypeIndex = pos.type.index + 1;
        if (nextTypeIndex == InsetPosType.values.length) nextTypeIndex = 0;
        pos = AbsInsetPos(InsetPosType.values[nextTypeIndex], 0.0);
      }

      point = pos.apply(box);
      if (prevPos.isOnCorner) {
//        print('arcTo: $pos $point');
        path.arcToPoint(point, radius: Radius.circular(box.tlRadius));
      } else {
//        print('lineTo: $pos $point');
        path.lineTo(point.x, point.y);
      }
    }

    return point;
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
    var ok = true;
    final result = LineSegment(null, null);

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
      final type = ok ? DraftType.Main : DraftType.Error;
      pi.draft.addLineSegment(result.end, result.start, type);
      pi.draft.addPoint(result.start, type);
      pi.draft.addPoint(result.end, type);
    }

    if (inverse) {
      path.lineTo(result.end.x, result.end.y);
      path.lineTo(result.start.x, result.start.y);
//      path.lineTo(result.end.x, result.end.y - 1.0);
//      path.lineTo(result.start.x, result.start.y - 1.0);
    } else {
//      print('result: $result');
      path.moveTo(result.start.x, result.start.y);
//      path.lineTo(result.start.x, result.start.y);
      path.lineTo(result.end.x, result.end.y);
//      path.moveTo(result.start.x, result.start.y - 1.0);
//      path.lineTo(result.end.x, result.end.y - 1.0);
    }

    return result.start;
  }

  /// Прямая линия под углом
  bool line(LineSegment out, double angle, bool inverse, Path path, BubblePaintInfo pi) {
    var ok = true;

    final beta = inverse ? angle + math.pi / 2 : angle - math.pi / 2; // Точка касательной на малом круге

    final line = Line(pi.nipCircle.point(beta), angle);
    final tan = line.tan();
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
            final tangent = pi.nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
            out.start = tangent.start;
          }
        }
      }

      if (!processed) {
        pi.draft?.showTopCorner = true;

        // Рассчитываем пересечение линии с верхним кругом. Получаем хорду
        final chord = line.intersectCircle(pi.ltCircle);

        //
        // Линия пересекается с дугой угла
        //
        if (chord != null) {
          out.end = chord.start;

          if (pi.draft != null) {
            final normal = line.normal(pi.ltCircle.center);
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
            final tangent = pi.nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
            out.start = tangent.start;
          }
        }
      }

      if (!processed) {
        pi.draft?.showBottomCorner = true;

        // Рассчитываем пересечение линии с нижним кругом
        final chord = line.intersectCircle(pi.lbCircle);

        //
        // Линия пересекается с дугой угла
        //
        if (chord != null) {
          out.end = chord.start;

          if (pi.draft != null) {
            final normal = line.normal(pi.lbCircle.center);
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
    var ok = true;
    Point draftEnd;

    //
    // Линия уходит к верхней стороне бокса
    //
    if (pos < 0) {
      final offset = -pos;
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
      final offset = pos - pi.box.height;
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
      final tangent = pi.nipCircle.tangentToPoint(draftEnd, inverse ? 1.0 : -1.0);
      pi.draft.addPoint(draftEnd);
      if (tangent != null) {
        pi.draft.addLineSegment(pi.nipCircle.center, tangent.start);
        pi.draft.addPoint(tangent.start);
        pi.draft.addLineSegmentCopy(tangent);
      }
    }

    // Смотрим, не вышла ли линия за касательную
    var processed = false;
    if (out.end.y < pi.ltCircle.center.y && pi.nipCircle.center.y - pi.nipCircle.radius >= pi.box.top) {
      final tangent = pi.nipCircle.tangentToCircle(pi.ltCircle, inverse ? 1.0 : -1.0, -1.0);
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
      final tangent = pi.nipCircle.tangentToCircle(pi.lbCircle, inverse ? 1.0 : -1.0, 1.0);
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
      if (out.end.y == pi.box.top) pi.draft.showTopSide = true;
      else if (out.end.y == pi.box.bottom) pi.draft.showBottomSide = true;
    }

    if (!processed) {
      final tangent = pi.nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
      out.start = tangent?.start ?? out.end;
    }

    return ok;
  }

  /// Прямая линия к углам бокса
  bool lineToCorner(LineSegment out, double angle, bool inverse, Path path, BubblePaintInfo pi) {
    var ok = true;
    Point draftEnd;

    out.start = null;

    // Отрицательные значения - верхний круг, положительные - нижний
    draftEnd = out.end = angle <= 0 ? pi.ltCircle.point(angle) : pi.lbCircle.point(angle);

    if (pi.draft != null) {
      pi.draft.addPoint(draftEnd);
      final tangent = pi.nipCircle.tangentToPoint(draftEnd, inverse ? 1.0 : -1.0);
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
      final tangent = pi.nipCircle.tangentToCircle(pi.ltCircle, inverse ? 1.0 : -1.0, -1.0);
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
      final tangent = pi.nipCircle.tangentToCircle(pi.lbCircle, inverse ? 1.0 : -1.0, 1.0);
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
      final tangent = pi.nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
      out.start = tangent.start;
    }

    if (pi.draft != null) {
      final tangent = pi.nipCircle.tangentToPoint(draftEnd, inverse ? 1.0 : -1.0);
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

class Position {
  const Position({this.ratio = 0.0, this.offset = 0.0})
      : assert(ratio != null),
        assert(ratio >= 0.0 && ratio <= 1.0),
        assert(offset != null);

  final double ratio;
  final double offset;

  static const zero = Position();

  double apply(double size) => size * ratio + offset;

  @override
  bool operator ==(covariant other) {
    return other.ratio == ratio && other.offset == offset;
  }

  @override
  int get hashCode => hashValues(ratio.hashCode, offset.hashCode);

  @override
  String toString() {
    return 'Position(ratio: $ratio, offset: $offset)';
  }
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
  })  : assert(left != null),
        assert(top != null),
        assert(right != null),
        assert(bottom != null),
        assert(tlRadius != null),
        assert(trRadius != null),
        assert(brRadius != null),
        assert(blRadius != null);

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
      })  : this._(
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
    var radius = tlRadius == trRadius && tlRadius == brRadius && tlRadius == blRadius
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
  String toString() {
    return 'Inset(start: $start, end: $end)';
  }
}

/// Тип позиции врезки
enum InsetPosType { left, topLeft, top, topRight, right, bottomRight, bottom, bottomLeft }

/// Тип рассчёта смещения по углу
/// byLength - по длине дуги угла
/// byHeight - по высоте угла
/// byWidth - по ширине угла
enum CornerOffsetType { byLength, byHeight, byWidth }

/// Позиция врезки
class InsetPos {
  const InsetPos(this.type, this.pos, {offsetType})
      : assert(type != null),
        assert(pos != null),
        assert(offsetType == null
            || type == InsetPosType.topLeft
            || type == InsetPosType.topRight
            || type == InsetPosType.bottomRight
            || type == InsetPosType.bottomLeft
        ),
        offsetType = offsetType ?? CornerOffsetType.byLength;

  final InsetPosType type;
  final Position pos;
  final CornerOffsetType offsetType;

  /// Переводит Position в позицию на стороне, применяя соответствующие ограничения
  /// @param size Размер стороны
  /// @result Расстояние в пикселях
  double _posOnSide(double size) {
    return math.max(math.min(pos.apply(size), size), 0.0);
  }

  /// Переводит относительную позицию в позицию на углу
  /// @param radius Радиус дуги
  /// @result Относительный угол в радианах
  double _posOnCorner(double radius) {
    final halfPi = math.pi / 2.0;
    var radians = pos.ratio * halfPi;

    if (pos.offset != 0.0) {
      switch (offsetType) {
        case CornerOffsetType.byLength:
          final cornerLen = halfPi * radius; // Для дуги угла
          final distance = cornerLen * pos.ratio + pos.offset; // Расстояние до точки
          if (distance <= 0.0) radians = 0.0;
          else if (distance >= cornerLen) radians = halfPi;
          else radians = distance / cornerLen * halfPi;
          break;

        case CornerOffsetType.byHeight:
          final y = math.sin(radians) * radius + pos.offset;
          if (y <= 0.0) radians = 0.0;
          else if (y >= radius) radians = halfPi;
          else radians = math.asin(y / radius);
          break;

        case CornerOffsetType.byWidth:
          final x = math.cos(radians) * radius + pos.offset;
          if (x <= 0.0) radians = 0.0;
          else if (x >= radius) radians = halfPi;
          else radians = math.acos(x / radius);
          break;
      }
    }

    return radians;
  }

  AbsInsetPos apply(Box box) {
    AbsInsetPos result;

    switch (type) {
      case InsetPosType.left:
        result = AbsInsetPos(type, _posOnSide(box.leftHeight));
        break;

      case InsetPosType.topLeft:
        result = AbsInsetPos(type, _posOnCorner(box.tlRadius));
        break;

      case InsetPosType.top:
        result = AbsInsetPos(type, _posOnSide(box.topWidth));
        break;

      case InsetPosType.topRight:
        result = AbsInsetPos(type, _posOnCorner(box.trRadius));
        break;

      case InsetPosType.right:
        result = AbsInsetPos(type, _posOnSide(box.rightHeight));
        break;

      case InsetPosType.bottomRight:
        result = AbsInsetPos(type, _posOnCorner(box.brRadius));
        break;

      case InsetPosType.bottom:
        result = AbsInsetPos(type, _posOnSide(box.bottomWidth));
        break;

      case InsetPosType.bottomLeft:
        result = AbsInsetPos(type, _posOnCorner(box.blRadius));
        break;
    }

    return result;
  }

  @override
  String toString() {
    var offsetTypeStr = type == InsetPosType.left || type == InsetPosType.top
        || type == InsetPosType.right || type == InsetPosType.bottom ? '' : ', offsetType: $offsetType';
    return 'InsetPos($type, $pos$offsetTypeStr)';
  }
}

class InsetList {
  const InsetList(this._list);

//  InsetList([List<Inset> list])
//      : _list = list ?? [];

  final List<Inset> _list;
  List<Inset> get list => _list;

//  void add(Inset element) => _list.add(element);

  AbsInsetList apply(Box box) {
    final result = AbsInsetList();
    for (var i = 0; i < list.length; i++) {
      result.list.add(AbsInset(i, list[i].start.apply(box), list[i].end.apply(box)));
    }

//    result.sort();

    return result;
  }

  @override
  String toString() {
    return 'InsetList($_list)';
  }
}

/// Врезка в абсолютных величинах
class AbsInset {
  const AbsInset(this.index, this.start, this.end)
      : assert(index != null),
        assert(start != null),
        assert(end != null);

  final int index;
  final AbsInsetPos start;
  final AbsInsetPos end;

  bool get crossesZero => start > end;

  int compareTo(AbsInset other) {
    // Трудность сравнения пар возникает при переходе нулевой точки
    if (this.crossesZero) {
      return other.crossesZero ? this.start.compareTo(other.start) : -1;
    }
    return other.crossesZero ? 1 : this.start.compareTo(other.start);
  }

  bool operator >(covariant other) {
    if (this.start > this.end) {
      return other.start > other.end ? this.start > other.start : false;
    }
    if (other.start > other.end) return true;
    return this.start > other.start;
  }

  @override
  String toString() {
    return 'AbsInset(index: $index, start: $start, end: $end)';
  }
}

/// Позиция врезка в абсолютных величинах
class AbsInsetPos {
  const AbsInsetPos(this.type, this.pos)
      : assert(type != null),
        assert(pos != null);

  final InsetPosType type;
  final double pos;

  bool get isOnSide {
    return type == InsetPosType.left
        || type == InsetPosType.top
        || type == InsetPosType.right
        || type == InsetPosType.bottom;
  }

  bool get isOnCorner {
    return type == InsetPosType.topLeft
      || type == InsetPosType.topRight
      || type == InsetPosType.bottomRight
      || type == InsetPosType.bottomLeft;
  }

  static const zero = AbsInsetPos(InsetPosType.left, 0.0);

  @override
  int get hashCode => hashValues(type.hashCode, pos.hashCode);

  @override
  bool operator ==(covariant other) {
    return this.type == other.type && this.pos == other.pos;
  }

  int compareTo(AbsInsetPos other) {
    var result = this.type.index.compareTo(other.type.index);
    if (result == 0) result = this.pos.compareTo(other.pos);
    return result;
  }

  bool operator >(AbsInsetPos other) => this.compareTo(other) > 0;
  bool operator >=(AbsInsetPos other) => this.compareTo(other) >= 0;
  bool operator <(AbsInsetPos other) => this.compareTo(other) < 0;
  bool operator <=(AbsInsetPos other) => this.compareTo(other) <= 0;

  Point apply(Box box) {
    Point point;
    switch (type) {
      case InsetPosType.left:
        point = Point(box.left, box.bottom - box.blRadius - pos);
        break;

      case InsetPosType.topLeft:
        point = Point(
            box.left + (1.0 - math.cos(pos)) * box.tlRadius,
            box.top + (1.0 - math.sin(pos)) * box.tlRadius
        );
        break;

      case InsetPosType.top:
        point = Point(box.left + box.tlRadius + pos, box.top);
        break;

      case InsetPosType.topRight:
        point = Point(
            box.right - (1.0 - math.sin(pos)) * box.trRadius,
            box.top + (1.0 - math.cos(pos)) * box.trRadius
        );
        break;

      case InsetPosType.right:
        point = Point(box.right, box.top + box.trRadius + pos);
        break;

      case InsetPosType.bottomRight:
        point = Point(
            box.right - (1.0 - math.cos(pos)) * box.brRadius,
            box.bottom - (1.0 - math.sin(pos)) * box.brRadius
        );
        break;

      case InsetPosType.bottom:
        point = Point(box.right - box.brRadius - pos, box.bottom);
        break;

      case InsetPosType.bottomLeft:
        point = Point(
            box.left + (1.0 - math.sin(pos)) * box.blRadius,
            box.bottom - (1.0 - math.cos(pos)) * box.blRadius
        );
        break;
    }

    return point;
  }

  @override
  String toString() {
    return 'AbsInsetPos($type, $pos)';
  }
}

class AbsInsetList {
  var list = <AbsInset>[];

  void sort() {
    list.sort((a, b) => a.compareTo(b));
  }
}
