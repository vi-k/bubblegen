import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'geometry.dart';
import 'custom_bubble.dart';

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

class BubbleStyle extends CustomBubbleStyle {
  const BubbleStyle({
    EdgeInsets margin,
    BubbleRadius radius,
    this.nipSide = NipSide.left,
    bool hFlip,
    bool vFlip,
    this.nipRadius = 0.5,
    this.nipSize = 7.0,
    this.nipPlaceholderSize,
    this.nipOffset = const NipOffset(),
    Color color,
    double elevation,
    Color shadowColor,
    Color strokeColor,
    double strokeWidth,
  })  : assert(nipSide != null),
        assert(nipRadius != null),
        assert(nipSize != null),
        assert(nipOffset != null),
        super(
          margin: margin,
          radius: radius,
          hFlip: hFlip,
          vFlip: vFlip,
          color: color,
          elevation: elevation,
          shadowColor: shadowColor,
          strokeWidth: strokeWidth,
        );

  final NipSide nipSide;
  final double nipRadius;
  final double nipSize;
  final double nipPlaceholderSize;
  final NipOffset nipOffset;

  BubbleStyle copyWith({
      EdgeInsets margin,
      BubbleRadius radius,
      NipSide nipSide,
      bool hFlip,
      bool vFlip,
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
      margin: margin ?? this.margin,
      radius: radius ?? this.radius,
      nipSide: nipSide ?? this.nipSide,
      hFlip: hFlip ?? this.hFlip,
      vFlip: vFlip ?? this.vFlip,
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
    return 'BubbleStyle(margin: $margin, radius: $radius, nipSide: $nipSide, hFlip: $hFlip, vFlip: $vFlip, nipRadius: $nipRadius, nipSize: $nipSize, nipPlaceholderSize: $nipPlaceholderSize, nipOffset: $nipOffset, color: $color, elevation: $elevation, shadowColor: $shadowColor, strokeColor: $strokeColor, strokeWidth: $strokeWidth)';
  }
}

class Bubble extends CustomBubble {
  Bubble({
    double scale = 1.0,
    bool drawDraft = false,
    BubbleStyle style,
    Inset inset,
    @required this.topLine,
    @required this.bottomLine,
    Widget child,
  })  : assert(topLine != null),
        assert(bottomLine != null),
        super(
          scale: scale,
          drawDraft: drawDraft,
          style: style,
          inset: inset,
          child: child,
        );

  final NipLine topLine;
  final NipLine bottomLine;

  @override
  bool needsLayout(CustomBubble other) {
    final style = other.style as BubbleStyle;
    return super.needsLayout(other)
        || style.nipSide != style.nipSide
        || style.nipPlaceholderSize != style.nipPlaceholderSize
        || style.nipPlaceholderSize == null
            && style.nipSize != style.nipSize;
  }

//  void createNip(Path path, BubblePaintInfo pi) {
//    addLine(topLine, false, path, pi);
//    addLine(bottomLine, true, path, pi);
//    path.close();
//  }

//  Point addLine(NipLine nipLine, bool inverse, Path path, BubblePaintInfo pi) {
//    var ok = true;
//    final result = LineSegment(null, null);
//
////    print(nipLine.type);
//
//    switch (nipLine.lineType) {
//      case NipLineType.line:
//        switch (nipLine.posType) {
//          case NipLinePosType.angle:
//            ok = line(result, nipLine.pos * math.pi / 180, inverse, path, pi);
//            break;
//
//          case NipLinePosType.pos:
//            ok = lineTo(result, nipLine.pos, inverse, path, pi);
//            break;
//
//          case NipLinePosType.offset:
//            ok = lineTo(
//                result, pi.nipCircle.center.y + (inverse ? pi.nipCircle.radius : -pi.nipCircle.radius) + nipLine.pos,
//                inverse, path, pi);
//            break;
//
//          case NipLinePosType.corners:
//            ok = lineToCorner(result, nipLine.pos * math.pi / 180, inverse, path, pi);
//            break;
//        }
//        break;
//
//      case NipLineType.arc:
//        // TODO: Handle this case.
//        break;
//
//      case NipLineType.curve:
//        // TODO: Handle this case.
//        break;
//    }
//
//    // Малый круг
//    if (pi.draft != null) {
//      pi.draft.addLineSegment(pi.nipCircle.center, result.start);
//      if (inverse) pi.draft.addPoint(pi.nipCircle.center);
//
//      // Линия
//      final type = ok ? DraftType.Main : DraftType.Error;
//      pi.draft.addLineSegment(result.end, result.start, type);
//      pi.draft.addPoint(result.start, type);
//      pi.draft.addPoint(result.end, type);
//    }
//
//    if (inverse) {
//      path.lineTo(result.end.x, result.end.y);
//      path.lineTo(result.start.x, result.start.y);
////      path.lineTo(result.end.x, result.end.y - 1.0);
////      path.lineTo(result.start.x, result.start.y - 1.0);
//    } else {
////      print('result: $result');
//      path.moveTo(result.start.x, result.start.y);
////      path.lineTo(result.start.x, result.start.y);
//      path.lineTo(result.end.x, result.end.y);
////      path.moveTo(result.start.x, result.start.y - 1.0);
////      path.lineTo(result.end.x, result.end.y - 1.0);
//    }
//
//    return result.start;
//  }
//
//  /// Прямая линия под углом
//  bool line(LineSegment out, double angle, bool inverse, Path path, BubblePaintInfo pi) {
//    var ok = true;
//
//    final beta = inverse ? angle + math.pi / 2 : angle - math.pi / 2; // Точка касательной на малом круге
//
//    final line = Line(pi.nipCircle.point(beta), angle);
//    final tan = line.tan();
//    out.start = line.start;
//
//    if (pi.draft != null) {
//      pi.draft.addPoint(out.start);
//      pi.draft.addLineCopy(line);
//    }
//
//    //
//    // Линия пересекает ровную часть левой стороны бокса
//    //
//    out.end = Point(pi.box.left, out.start.y + (pi.box.left - out.start.x) * tan);
//    if (out.end.y >= pi.ltCircle.center.y && out.end.y <= pi.lbCircle.center.y) {
//      pi.draft?.showLeftSide = true;
//    }
//    //
//    // Линия уходит к верхней части бокса
//    //
//    else if (out.end.y < pi.ltCircle.center.y) {
//      var processed = false;
//
//      //
//      // Линия падает сверху на бокс
//      //
//      if (pi.nipCircle.center.y + (inverse ? pi.nipCircle.radius : -pi.nipCircle.radius) < pi.box.top) {
//        out.end = Point(out.start.x + (pi.box.top - out.start.y) / tan, pi.box.top);
//        if (out.end.x >= pi.ltCircle.center.x || tan < 0) {
//          processed = true;
//          pi.draft?.showTopSide = true;
//
//          //
//          // Линия уходит к правому краю бокса
//          // (касательную к правому кругу не строим, ограничиваемся правым краем ровной стороны)
//          //
//          if (out.end.x > pi.rtCircle.center.x || tan < 0) {
//            ok = false;
//
//            out.end = Point(pi.rtCircle.center.x, pi.box.top);
//            final tangent = pi.nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
//            out.start = tangent.start;
//          }
//        }
//      }
//
//      if (!processed) {
//        pi.draft?.showTopCorner = true;
//
//        // Рассчитываем пересечение линии с верхним кругом. Получаем хорду
//        final chord = line.intersectCircle(pi.ltCircle);
//
//        //
//        // Линия пересекается с дугой угла
//        //
//        if (chord != null) {
//          out.end = chord.start;
//
//          if (pi.draft != null) {
//            final normal = line.normal(pi.ltCircle.center);
//            pi.draft.addLineSegmentCopy(normal);
//            pi.draft.addPoint(normal.end);
//          }
//        }
//        //
//        // Линия выходит за верхний круг
//        // В этом случае за линию берём касательную, общую для малого и нижнего кругов
//        //
//        else {
//          ok = false;
//
//          LineSegment tangent = pi.nipCircle.tangentToCircle(pi.ltCircle, inverse ? 1.0 : -1.0, -1.0);
//          out.start = tangent.start;
//          out.end = tangent.end;
//
//          pi.draft?.addLineSegment(pi.ltCircle.center, out.end);
//        }
//      }
//    }
//    //
//    // Линия уходит к нижней части бокса
//    //
//    else {
//      var processed = false;
//
//      // Линия падает снизу на бокс
//      if (pi.nipCircle.center.y + (inverse ? pi.nipCircle.radius : -pi.nipCircle.radius) > pi.box.bottom) {
//        out.end = Point(out.start.x + (pi.box.bottom - out.start.y) / tan, pi.box.bottom);
//        if (out.end.x >= pi.lbCircle.center.x || tan >= 0) {
//          processed = true;
//          pi.draft?.showBottomSide = true;
//
//          // Линия уходит к правому краю бокса
//          // (касательную к правому кругу не строим, ограничиваемся правым краем ровной стороны)
//          if (out.end.x > pi.rbCircle.center.x || tan >= 0) {
//            ok = false;
//
//            out.end = Point(pi.rbCircle.center.x, pi.box.bottom);
//            final tangent = pi.nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
//            out.start = tangent.start;
//          }
//        }
//      }
//
//      if (!processed) {
//        pi.draft?.showBottomCorner = true;
//
//        // Рассчитываем пересечение линии с нижним кругом
//        final chord = line.intersectCircle(pi.lbCircle);
//
//        //
//        // Линия пересекается с дугой угла
//        //
//        if (chord != null) {
//          out.end = chord.start;
//
//          if (pi.draft != null) {
//            final normal = line.normal(pi.lbCircle.center);
//            pi.draft.addLineSegmentCopy(normal);
//            pi.draft.addPoint(normal.end);
//          }
//        }
//        //
//        // Линия выходит за нижний круг
//        // В этом случае за линию берём касательную, общую для малого и нижнего кругов
//        //
//        else {
//          ok = false;
//
//          LineSegment tangent = pi.nipCircle.tangentToCircle(pi.lbCircle, inverse ? 1.0 : -1.0, 1.0);
//          out.start = tangent.start;
//          out.end = tangent.end;
//
//          pi.draft?.addLineSegment(pi.lbCircle.center, out.end);
//        }
//      }
//    }
//
//    return ok;
//  }
//
//  /// Прямая линия к позиции на стороне бокса
//  bool lineTo(LineSegment out, double pos, bool inverse, Path path, BubblePaintInfo pi) {
//    var ok = true;
//    Point draftEnd;
//
//    //
//    // Линия уходит к верхней стороне бокса
//    //
//    if (pos < 0) {
//      final offset = -pos;
//      draftEnd = out.end = Point(pi.ltCircle.center.x + offset, pi.box.top);
//      if (pi.ltCircle.center.x + offset > pi.rtCircle.center.x) {
//        ok = false;
//        out.end = Point(pi.rtCircle.center.x, pi.box.top);
//      }
//    }
//    //
//    // Линия уходит к нижней стороне бокса
//    //
//    else if (pos > pi.box.height) {
//      final offset = pos - pi.box.height;
//      draftEnd = out.end = Point(pi.lbCircle.center.x + offset, pi.box.bottom);
//      if (pi.lbCircle.center.x + offset > pi.rbCircle.center.x) {
//        ok = false;
//        out.end = Point(pi.rbCircle.center.x, pi.box.bottom);
//      }
//    }
//    //
//    // Линия уходит к левой стороне бокса
//    //
//    else {
//      draftEnd = out.end = Point(pi.box.left, pi.box.top + pos);
//
//      //
//      // Линия пересекается с ровной стороной бокса
//      //
//      if (out.end.y >= pi.ltCircle.center.y && out.end.y <= pi.lbCircle.center.y) {
//        pi.draft?.showLeftSide = true;
//      }
//      //
//      // Линия уходит к верхнему углу
//      //
//      else if (out.end.y < pi.ltCircle.center.y) {
//        draftEnd =
//            out.end = pi.ltCircle.point(math.asin((pi.ltCircle.center.y - out.end.y) / pi.ltCircle.radius) - math.pi);
//
//        if (pi.draft != null) {
//          pi.draft.showTopCorner = true;
//          pi.draft.addLineSegment(out.end, Point(pi.ltCircle.center.x, out.end.y));
//        }
//      }
//      //
//      // Линия уходит к нижнему углу
//      //
//      else {
//        draftEnd =
//            out.end = pi.lbCircle.point(math.asin((pi.lbCircle.center.y - out.end.y) / pi.lbCircle.radius) - math.pi);
//
//        if (pi.draft != null) {
//          pi.draft.showBottomCorner = true;
//          pi.draft.addLineSegment(out.end, Point(pi.lbCircle.center.x, out.end.y));
//        }
//      }
//    }
//
//    if (pi.draft != null) {
//      final tangent = pi.nipCircle.tangentToPoint(draftEnd, inverse ? 1.0 : -1.0);
//      pi.draft.addPoint(draftEnd);
//      if (tangent != null) {
//        pi.draft.addLineSegment(pi.nipCircle.center, tangent.start);
//        pi.draft.addPoint(tangent.start);
//        pi.draft.addLineSegmentCopy(tangent);
//      }
//    }
//
//    // Смотрим, не вышла ли линия за касательную
//    var processed = false;
//    if (out.end.y < pi.ltCircle.center.y && pi.nipCircle.center.y - pi.nipCircle.radius >= pi.box.top) {
//      final tangent = pi.nipCircle.tangentToCircle(pi.ltCircle, inverse ? 1.0 : -1.0, -1.0);
//      if (out.end.x > tangent.end.x) {
//        processed = true;
//        ok = false;
//        out.start = tangent.start;
//        out.end = tangent.end;
//        if (pi.draft != null) {
//          pi.draft.showTopCorner = true;
//          pi.draft.addLineSegment(pi.ltCircle.center, tangent.end);
//        }
//      }
//    } else if (out.end.y > pi.lbCircle.center.y && pi.nipCircle.center.y + pi.nipCircle.radius <= pi.box.bottom) {
//      final tangent = pi.nipCircle.tangentToCircle(pi.lbCircle, inverse ? 1.0 : -1.0, 1.0);
//      if (out.end.x > tangent.end.x) {
//        processed = true;
//        ok = false;
//        out.start = tangent.start;
//        out.end = tangent.end;
//        if (pi.draft != null) {
//          pi.draft.showBottomCorner = true;
//          pi.draft.addLineSegment(pi.lbCircle.center, tangent.end);
//        }
//      }
//    } else if (pi.draft != null) {
//      if (out.end.y == pi.box.top) pi.draft.showTopSide = true;
//      else if (out.end.y == pi.box.bottom) pi.draft.showBottomSide = true;
//    }
//
//    if (!processed) {
//      final tangent = pi.nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
//      out.start = tangent?.start ?? out.end;
//    }
//
//    return ok;
//  }
//
//  /// Прямая линия к углам бокса
//  bool lineToCorner(LineSegment out, double angle, bool inverse, Path path, BubblePaintInfo pi) {
//    var ok = true;
//    Point draftEnd;
//
//    out.start = null;
//
//    // Отрицательные значения - верхний круг, положительные - нижний
//    draftEnd = out.end = angle <= 0 ? pi.ltCircle.point(angle) : pi.lbCircle.point(angle);
//
//    if (pi.draft != null) {
//      pi.draft.addPoint(draftEnd);
//      final tangent = pi.nipCircle.tangentToPoint(draftEnd, inverse ? 1.0 : -1.0);
//      pi.draft.addLineSegmentCopy(tangent);
//    }
//
//    // Проверям выход за границы четвертей
//    if (angle <= 0) {
//      if (angle > -math.pi / 2) {
//        ok = false;
//        out.end = Point(pi.ltCircle.center.x, pi.box.top);
//      } else if (angle < -math.pi) {
//        ok = false;
//        out.end = Point(pi.box.left, pi.ltCircle.center.y);
//      }
//    } else if (angle >= 0) {
//      if (angle < math.pi / 2) {
//        ok = false;
//        out.end = Point(pi.lbCircle.center.x, pi.box.bottom);
//      } else if (angle > math.pi) {
//        ok = false;
//        out.end = Point(pi.box.left, pi.lbCircle.center.y);
//      }
//    }
//
//    if (angle <= 0) {
//      final tangent = pi.nipCircle.tangentToCircle(pi.ltCircle, inverse ? 1.0 : -1.0, -1.0);
//      if (out.end.x > tangent.end.x) {
//        ok = false;
//        out.start = tangent.start;
//        out.end = tangent.end;
//        if (pi.draft != null) {
//          pi.draft.showTopCorner = true;
//          pi.draft.addLineSegment(pi.ltCircle.center, tangent.end);
//        }
//      }
//    } else if (angle >= 0) {
//      final tangent = pi.nipCircle.tangentToCircle(pi.lbCircle, inverse ? 1.0 : -1.0, 1.0);
//      if (out.end.x > tangent.end.x) {
//        ok = false;
//        out.start = tangent.start;
//        out.end = tangent.end;
//        if (pi.draft != null) {
//          pi.draft.showBottomCorner = true;
//          pi.draft.addLineSegment(pi.lbCircle.center, tangent.end);
//        }
//      }
//    }
//
//    if (out.start == null) {
//      final tangent = pi.nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
//      out.start = tangent.start;
//    }
//
//    if (pi.draft != null) {
//      final tangent = pi.nipCircle.tangentToPoint(draftEnd, inverse ? 1.0 : -1.0);
//      out.start = tangent.start;
//
//      pi.draft.addPoint(draftEnd);
//      pi.draft.addLineSegment(out.start, draftEnd);
//
//      if (angle <= 0) {
//        pi.draft.showTopCorner = true;
//        pi.draft.addLineSegment(pi.ltCircle.center, draftEnd);
//      } else {
//        pi.draft.showBottomCorner = true;
//        pi.draft.addLineSegment(pi.lbCircle.center, draftEnd);
//      }
//    }
//
//    return ok;
//  }
}
