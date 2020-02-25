import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

enum NipLineType {
  line,
  lineTo,
  relativeLineTo,
  lineToCorner,
  arc,
  arcTo,
  relativeArcTo,
  arcToCorner,
  curve,
  curveTo,
  relativeCurveTo,
  curveToCorner
}

class NipLine {
  final NipLineType type;
  final double pos;
  final double h; // arc's radius
  final double a1; // curve's α₁
  final double a2; // curve's α₂
  final double sz1; // curve's sz₁
  final double sz2; // curve's sz₂

  const NipLine._internal(
    this.type,
    this.pos, {
    this.h = 0.0,
    this.a1,
    this.a2,
    this.sz1,
    this.sz2,
  }) : assert(pos != null);

  const NipLine.line(double lineAngle) : this._internal(NipLineType.line, lineAngle);
  const NipLine.lineTo(double pos) : this._internal(NipLineType.lineTo, pos);
  const NipLine.relativeLineTo(double offset) : this._internal(NipLineType.relativeLineTo, offset);
  const NipLine.lineToCorner(double cornerAngle) : this._internal(NipLineType.lineToCorner, cornerAngle);

  const NipLine.arc(double lineAngle, double arcAngle) : this._internal(NipLineType.arc, lineAngle, a1: arcAngle);
  const NipLine.arcTo(double pos, double arcAngle) : this._internal(NipLineType.arcTo, pos, a1: arcAngle);
  const NipLine.relativeArcTo(double offset, double arcAngle)
      : this._internal(NipLineType.relativeArcTo, offset, a1: arcAngle);
  const NipLine.arcToCorner(double cornerAngle, double arcAngle)
      : this._internal(NipLineType.arcToCorner, cornerAngle, a1: arcAngle);

  const NipLine.curve(double lineAngle, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this._internal(
          NipLineType.curve,
          lineAngle,
          a1: angle1,
          a2: angle2,
          sz1: size1,
          sz2: size2,
        );

  const NipLine.curveTo(double pos, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this._internal(
          NipLineType.curveTo,
          pos,
          a1: angle1,
          a2: angle2,
          sz1: size1,
          sz2: size2,
        );

  const NipLine.relativeCurveTo(double pos, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this._internal(
          NipLineType.relativeCurveTo,
          pos,
          a1: angle1,
          a2: angle2,
          sz1: size1,
          sz2: size2,
        );

  const NipLine.curveToCorner(double cornerAngle, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this._internal(
          NipLineType.curveToCorner,
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

  void paint(Canvas draftCanvas, Circle nipCircle, Rect box, Circle ltCircle, Circle lbCircle, Circle rtCircle,
      Circle rbCircle) {
    var draftPath = Path();

    var paint = Paint();
    paint.strokeWidth = 1;

    paint.style = PaintingStyle.fill;
    paint.color = draftColor;

    // Малый круг
    if (showNip) {
      draftCanvas.drawCircle(nipCircle.center, nipCircle.radius, paint);
    }

    // Верхняя сторона
    if (showTopSide) {
      draftPath.reset();
      draftPath.moveTo(ltCircle.center.x, box.top);
      draftPath.lineTo(rtCircle.center.x, box.top);
      draftPath.lineTo(rtCircle.center.x, box.top + 4);
      draftPath.lineTo(ltCircle.center.x, box.top + 4);
      draftPath.close();

      draftCanvas.drawPath(draftPath, paint);
    }

    // Левая сторона
    if (showLeftSide) {
      draftPath.reset();
      draftPath.moveTo(box.left, ltCircle.center.y);
      draftPath.lineTo(box.left + 4, ltCircle.center.y);
      draftPath.lineTo(box.left + 4, lbCircle.center.y);
      draftPath.lineTo(box.left, lbCircle.center.y);
      draftPath.close();

      draftCanvas.drawPath(draftPath, paint);
    }

    // Нижняя сторона
    if (showBottomSide) {
      draftPath.reset();
      draftPath.moveTo(lbCircle.center.x, box.bottom);
      draftPath.lineTo(rbCircle.center.x, box.bottom);
      draftPath.lineTo(rbCircle.center.x, box.bottom - 4);
      draftPath.lineTo(lbCircle.center.x, box.bottom - 4);
      draftPath.close();

      draftCanvas.drawPath(draftPath, paint);
    }

    // Верхний угол
    if (showTopCorner) {
      draftCanvas.drawArc(Rect.fromCenter(center: ltCircle.center, width: ltCircle.diameter, height: ltCircle.diameter),
          -math.pi / 2, -math.pi / 2, true, paint);
    }

    // Нижний угол
    if (showBottomCorner) {
      draftCanvas.drawArc(Rect.fromCenter(center: lbCircle.center, width: lbCircle.diameter, height: lbCircle.diameter),
          math.pi / 2, math.pi / 2, true, paint);
    }

    // Линии
    paint.style = PaintingStyle.stroke;
    DraftType.values.forEach((type) {
      paint.color = type == DraftType.Error ? errorColor : type == DraftType.Main ? mainColor : draftColor;

      lines.forEach((item) {
        if (item.type == type) {
          draftCanvas.drawLine(item.line.start, item.line.point(1000.0), paint);
        }
      });
    });

    // Отрезки
    paint.style = PaintingStyle.stroke;
    DraftType.values.forEach((type) {
      paint.color = type == DraftType.Error ? errorColor : type == DraftType.Main ? mainColor : draftColor;

      lineSegments.forEach((item) {
        if (item.type == type) {
          draftCanvas.drawLine(item.lineSegment.start, item.lineSegment.end, paint);
        }
      });
    });

    // Точки
    paint.style = PaintingStyle.fill;
    DraftType.values.forEach((type) {
      paint.color = type == DraftType.Error ? errorColor : type == DraftType.Main ? mainColor : draftColor;

      points.forEach((item) {
        if (item.type == type) {
          draftCanvas.drawCircle(item.point, 2, paint);
        }
      });
    });
  }
}

class MyPainter extends CustomPainter {
  MyPainter({
    this.zoom = 1.0,
    @required this.topLine,
    @required this.bottomLine,
    this.boxRadius,
    this.nipWidth,
    this.nipRadius,
    this.nipYOffset,
    this.drawDraft,
  }) : //assert(pos >= -1.0 && pos <= 1.0),
        super();

  final double zoom;
  final NipLine topLine;
  final NipLine bottomLine;
  final double boxRadius;
  final double nipWidth;
  final double nipRadius;
  final double nipYOffset;
  final bool drawDraft;

  /// Прямая линия под углом
  bool line(LineSegment out, NipLine nipLine, bool inverse, Path path, Circle nipCircle, Rect box, Circle ltCircle,
      Circle lbCircle, Circle rtCircle, Circle rbCircle,
      [DraftInfo draft]) {
    bool ok = true;

    var alpha = nipLine.pos * math.pi / 180; // Угол наклона линии
    var beta = inverse ? alpha + math.pi / 2 : alpha - math.pi / 2; // Точка касательной на малом круге

    var line = Line(nipCircle.point(beta), alpha);
    var tan = line.tan();
    out.start = line.start;

    if (draft != null) {
      draft.addPoint(out.start);
      draft.addLineCopy(line);
    }

    // Линия пересекает ровную часть левой стороны бокса
    out.end = Point(box.left, out.start.y + (box.left - out.start.x) * tan);
    if (out.end.y >= ltCircle.center.y && out.end.y <= lbCircle.center.y) {
      draft?.showLeftSide = true;
    }
    //
    // Линия уходит к верхнему кругу или выше
    //
    else if (out.end.y < ltCircle.center.y) {
      var processed = false;

      // Линия падает сверху
      if (nipCircle.center.y - nipCircle.radius < box.top) {
        out.end = Point(out.start.x + (box.top - out.start.y) / tan, box.top);
        if (out.end.x >= ltCircle.center.x || tan < 0) {
          processed = true;
          draft?.showTopSide = true;

          // Линия уходит к правому краю бокса
          // (касательную к правому верхнему кругу не строим, ограничиваемся правым краем ровной стороны)
          if (out.end.x > rtCircle.center.x || tan < 0) {
            ok = false;

            out.end = Point(rtCircle.center.x, box.top);
            var tangent = nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
            out.start = tangent.start;
          }
        }
      }

      if (!processed) {
        draft?.showTopCorner = true;

        // Рассчитываем пересечение линии с верхним кругом. Получаем хорду
        var line = Line(out.start, alpha);
        var chord = line.intersectCircle(ltCircle);

        //
        // Линия пересекается с дугой угла
        //
        if (chord.isNotNull) {
          out.end = chord.start;

          if (draft != null) {
            var normal = line.normal(ltCircle.center);
            draft.addLineSegment(ltCircle.center, normal.end);
            draft.addLineSegment(chord.start, normal.end);
            draft.addPoint(normal.end);
          }
        }
        //
        // Линия выходит за верхний круг
        // В этом случае за линию берём касательную, общую для малого и нижнего кругов
        //
        else {
          ok = false;

          LineSegment tangent = nipCircle.tangentToCircle(ltCircle, inverse ? 1.0 : -1.0, -1.0);
          out.start = tangent.start;
          out.end = tangent.end;

          draft?.addLineSegment(ltCircle.center, out.end);
        }
      }
    }
    //
    // Линия уходит к нижнему углу или ниже
    //
    else {
      var processed = false;

      // Линия падает снизу
      if (nipCircle.center.y + nipCircle.radius > box.bottom) {
        out.end = Point(out.start.x + (box.bottom - out.start.y) / tan, box.bottom);
        if (out.end.x >= lbCircle.center.x || tan >= 0) {
          processed = true;
          draft?.showBottomSide = true;

          // Линия уходит к правому краю бокса
          // (касательную к правому верхнему кругу не строим, ограничиваемся правым краем ровной стороны)
          if (out.end.x > rbCircle.center.x || tan >= 0) {
            ok = false;

            out.end = Point(rbCircle.center.x, box.bottom);
            var tangent = nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
            out.start = tangent.start;
          }
        }
      }

      if (!processed) {
        draft?.showBottomCorner = true;

        // Рассчитываем пересечение линии с нижним кругом
        var line = Line(out.start, alpha);
        var chord = line.intersectCircle(lbCircle);

        //
        // Линия пересекается с дугой угла
        //
        if (!chord.isNull) {
          out.end = chord.start;

          if (draft != null) {
            var normal = line.normal(lbCircle.center);
            draft.addLineSegment(lbCircle.center, normal.end);
            draft.addLineSegment(chord.start, normal.end);
            draft.addPoint(normal.end);
          }
        }
        //
        // Линия выходит за нижний круг
        // В этом случае за линию берём касательную, общую для малого и нижнего кругов
        //
        else {
          ok = false;

          LineSegment tangent = nipCircle.tangentToCircle(lbCircle, inverse ? 1.0 : -1.0, 1.0);
          out.start = tangent.start;
          out.end = tangent.end;

          draft?.addLineSegment(lbCircle.center, out.end);
        }
      }
    }

    return ok;
  }

  bool lineTo(LineSegment out, NipLine nipLine, bool inverse, Path path, Circle nipCircle, Rect box, Circle ltCircle,
      Circle lbCircle, Circle rtCircle, Circle rbCircle,
      [DraftInfo draft]) {
    bool ok = true;

    out.end = Point(box.left, box.top + nipLine.pos);

    //
    // Линия уходит к верхнему углу
    //
    if (out.end.y < ltCircle.center.y) {
      if (out.end.y < ltCircle.center.y - ltCircle.radius) {
        out.end = Point(ltCircle.center.x, ltCircle.center.y - ltCircle.radius);
      } else {
        out.end = ltCircle.point(math.asin((ltCircle.center.y - out.end.y) / ltCircle.radius) - math.pi);
      }

      if (draft != null) {
        draft.showTopCorner = true;
        draft.addLineSegment(out.end, Point(ltCircle.center.x, out.end.y));
      }
    }
    //
    // Линия пересекается с ровной стороной бокса
    //
    else if (out.end.y <= lbCircle.center.y) {
      draft?.showLeftSide = true;
    }
    //
    // Линия уходит к нижнему углу
    //
    else {
      if (out.end.y > lbCircle.center.y + lbCircle.radius) {
        out.end = Point(lbCircle.center.x, lbCircle.center.y + lbCircle.radius);
      } else {
        out.end = lbCircle.point(math.asin((lbCircle.center.y - out.end.y) / lbCircle.radius) - math.pi);
      }

      if (draft != null) {
        draft.showBottomCorner = true;
        draft.addLineSegment(out.end, Point(lbCircle.center.x, out.end.y));
      }
    }

    var tangent = nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
    out.start = tangent.start;

//    if (draft != null) {
//      out.start = tangent.start;
//
//      draft.addPoint(out.start);
//      draft.addLineSegmentCopy(tangent);
//    }

//    var l = math.sqrt(math.pow(out.end.x - nipCircle.center.x, 2) + math.pow(out.end.y - nipCircle.center.y, 2));
//    var a1 = math.asin((out.end.y - nipCircle.center.y) / l);
//    var a2 = -math.atan2(l, nipRadius);
//
//    out.start = nipCircle.point(a1 + a2);

    return ok;
  }

  /// Прямая линия к левой стороне бокса
  bool relativeLineTo(LineSegment result, NipLine nipLine, bool inverse, Path path, Circle nipCircle, Rect box,
      Circle ltCircle, Circle lbCircle, Circle rtCircle, Circle rbCircle,
      [DraftInfo draft]) {
    bool ok = true;

    result.end = Point(box.left, nipYOffset + nipLine.pos);

    //
    // Линия уходит к верхнему углу
    //
    if (result.end.y < ltCircle.center.y) {
      if (result.end.y < ltCircle.center.y - ltCircle.radius) {
        result.end = Point(ltCircle.center.x, ltCircle.center.y - ltCircle.radius);
      } else {
        result.end = ltCircle.point(math.asin((ltCircle.center.y - result.end.y) / ltCircle.radius) - math.pi);
      }

      if (draft != null) {
        draft.showTopCorner = true;
        draft.addLineSegment(result.end, Point(ltCircle.center.x, result.end.y));
      }
    }
    //
    // Линия пересекается с ровной стороной бокса
    //
    else if (result.end.y <= lbCircle.center.y) {
      draft?.showLeftSide = true;
    }
    //
    // Линия уходит к нижнему углу
    //
    else {
      if (result.end.y > lbCircle.center.y + lbCircle.radius) {
        result.end = Point(lbCircle.center.x, lbCircle.center.y + lbCircle.radius);
      } else {
        result.end = lbCircle.point(math.asin((lbCircle.center.y - result.end.y) / lbCircle.radius) - math.pi);
      }

      if (draft != null) {
        draft.showBottomCorner = true;
        draft.addLineSegment(result.end, Point(lbCircle.center.x, result.end.y));
      }
    }

    var l = math.sqrt(math.pow(result.end.x - nipCircle.center.x, 2) + math.pow(result.end.y - nipCircle.center.y, 2));
    var a1 = math.asin((result.end.y - nipCircle.center.y) / l);
    var a2 = -math.atan2(l, nipRadius);

    result.start = nipCircle.point(a1 + a2);

    return ok;
  }

  /// Прямая линия к углам бокса
  bool lineToCorner(LineSegment result, NipLine nipLine, bool inverse, Path path, Circle nipCircle, Rect box,
      Circle ltCircle, Circle lbCircle, Circle rtCircle, Circle rbCircle,
      [DraftInfo draft]) {
    bool ok = true;

    // Отрицательные значения - верхний круг, положительные - нижний
    var a = nipLine.pos * math.pi / 180;
    result.end = nipLine.pos <= 0 ? ltCircle.point(a) : lbCircle.point(a);

    var l = math.sqrt(math.pow(result.end.x - nipCircle.center.x, 2) + math.pow(result.end.y - nipCircle.center.y, 2));
    var a1 = math.asin((result.end.y - nipCircle.center.y) / l);
    var a2 = -math.atan2(l, nipRadius);

    result.start = nipCircle.point(a1 + a2);

    if (draft != null) {
      // Четверть верхнего круга
      if (nipLine.pos <= 0) {
        draft.showTopCorner = true;
        draft.addLineSegment(ltCircle.center, result.end);
      }
      // Четверть нижнего круга
      else {
        draft.showBottomCorner = true;
        draft.addLineSegment(lbCircle.center, result.end);
      }
    }

    return ok;
  }

  Point addLine(NipLine nipLine, bool inverse, Path path, Circle nipCircle, Rect box, Circle ltCircle, Circle lbCircle,
      Circle rtCircle, Circle rbCircle,
      [DraftInfo draft]) {
    bool ok = true;
    var result = LineSegment(null, null);

    print(nipLine.type);

    switch (nipLine.type) {
      case NipLineType.line:
        ok = line(result, nipLine, inverse, path, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle, draft);
        break;

      case NipLineType.lineTo:
        ok = lineTo(result, nipLine, inverse, path, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle, draft);
        break;

      case NipLineType.relativeLineTo:
        ok = relativeLineTo(
            result, nipLine, inverse, path, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle, draft);
        break;

      case NipLineType.lineToCorner:
        ok =
            lineToCorner(result, nipLine, inverse, path, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle, draft);
        break;

      case NipLineType.arc:
        // TODO: Handle this case.
        break;

      case NipLineType.arcTo:
        // TODO: Handle this case.
        break;

      case NipLineType.relativeArcTo:
        // TODO: Handle this case.
        break;

      case NipLineType.arcToCorner:
        // TODO: Handle this case.
        break;

      case NipLineType.curve:
        // TODO: Handle this case.
        break;

      case NipLineType.curveTo:
        // TODO: Handle this case.
        break;

      case NipLineType.relativeCurveTo:
        // TODO: Handle this case.
        break;

      case NipLineType.curveToCorner:
        // TODO: Handle this case.
        break;
    }

    // Малый круг
    if (draft != null) {
      draft.addLineSegment(nipCircle.center, result.start);
      if (inverse) draft.addPoint(nipCircle.center);

      // Линия
      var type = ok ? DraftType.Main : DraftType.Error;
      draft.addLineSegment(result.end, result.start, type);
      draft.addPoint(result.start, type);
      draft.addPoint(result.end, type);
    }

    if (inverse) {
      path.lineTo(result.end.x, result.end.y);
      path.lineTo(result.start.x, result.start.y);
    } else {
      print('result: $result');
      path.moveTo(result.start.x, result.start.y);
      path.lineTo(result.end.x, result.end.y);
    }

    return result.start;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final offsetY = nipYOffset < 0 ? nipYOffset : 0.0;

    size = Size(size.width / 4, size.height);
    final maxRadius = math.min(size.width - nipWidth, size.height) / 2;
    final boxCircle1R = boxRadius > maxRadius ? maxRadius : boxRadius;

    var paint = Paint();
    var path = Path();

//    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
    canvas.translate(0, -offsetY);

    paint.color = Colors.lightGreen;
    canvas.drawRRect(
        RRect.fromLTRBR(this.zoom * this.nipWidth, 0, this.zoom * size.width, this.zoom * size.height + offsetY,
            Radius.circular(this.zoom * boxCircle1R)),
        paint);

    final box = Rect.fromLTRB(nipWidth, 0, size.width, size.height + offsetY);
    final nipCircle = Circle(Point(nipRadius, nipYOffset + nipRadius), nipRadius);

    var r = boxCircle1R;
    final ltCircle = Circle(Point(box.left + r, r), r);
    final lbCircle = Circle(Point(box.left + r, box.bottom - r), r);
    final rtCircle = Circle(Point(box.right - r, r), r);
    final rbCircle = Circle(Point(box.right - r, box.bottom - r), r);

    DraftInfo draft = this.drawDraft ? DraftInfo() : null;

    draft?.addPoint(ltCircle.center);
    draft?.addPoint(lbCircle.center);
    draft?.addPoint(rtCircle.center);
    draft?.addPoint(rbCircle.center);

    path.reset();
    addLine(topLine, false, path, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle, draft);
    addLine(bottomLine, true, path, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle, draft);
    path.close();
    path.addOval(Rect.fromCenter(center: nipCircle.center, width: nipCircle.diameter, height: nipCircle.diameter));

    canvas.drawPath(path, paint);
    if (draft != null) draft.paint(canvas, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Отрезок
///
/// Конструируется либо через две точки:
///   LineSegment(Offset(0, 0), Offset(100, 0))
/// Либо по направлению и длине:
///   LineSegment.direct(Offset(0, 0), pi/4, 100)
///
/// При запросе не заданных параметров они вычисляются и сохраняются в переменных.
class LineSegment {
  LineSegment(this._start, this._end);
  LineSegment.direct(this._start, this._direct, this._length)
      : assert(_direct != null),
        assert(_length != null);

  Point _start;
  Point _end;
  double _length;
  double _direct;

  get start => _start;

  set start(value) {
    // При установке новой начальной точки сохраняем конечную точку и сбрасываем направление и размер
    _start = value;
    _end = end;
    _direct = null;
    _length = null;
  }

  get end {
    if (_end == null && _direct != null)
      _end = Point(start.x + _length * math.cos(_direct), start.y + _length * math.sin(_direct));
    return _end;
  }

  set end(value) {
    _end = value;
    _length = null;
    _direct = null;
  }

  get length {
    if (_length == null) _length = math.sqrt(math.pow(_end.x - start.x, 2) + math.pow(_end.y - start.y, 2));
    return _length;
  }

  get direct {
    if (_direct == null) _direct = math.atan2(_end.y - start.y, _end.x - start.x);
    return _direct;
  }

  get isNull => _start == null;
  get isNotNull => _start != null;

  String toString() {
    return "LineSegment($_start, $_end)";
  }
}

/// Линия
class Line {
  final Point start;
  final double direct;

  const Line(this.start, this.direct);
  //Line.toPoint(this.start, Offset end) : direct = atan2(1,2);

  String toString() {
    return "Line($start, ${direct * 180 / math.pi})";
  }

  double tan() => inf(math.tan(direct));

  /// Точка на линии
  Point point(double distance) {
    return Point(start.x + distance * math.cos(direct), start.y + distance * math.sin(direct));
  }

  /// Точка на линии
  Point pointByX(double x) {
    return Point(x, start.y + (x - start.x) * tan());
  }

  /// Точка на линии
  Point pointByY(double y) {
    return Point(start.x + (y - start.y) / tan(), y);
  }

  /// Вычисляет нормаль к линии из точки
  LineSegment normal(Point point) {
    double distance;
    double angle;

    var tan = this.tan();
    if (tan == 0.0) {
      distance = start.y - point.y;
      angle = math.pi / 2;
    } else {
      // Вспомогательный треугольник, гипотенуза которого находится на одной горизонтали с точкой
      var x = start.x + (point.y - start.y) / tan;
      distance = math.sin(direct) * (point.x - x); // Дальний катет треугольника - искомое расстояние
      angle = direct + math.pi / 2;
    }

    if (distance < 0) {
      distance = -distance;
      angle -= math.pi;
    }

    return LineSegment.direct(point, angle, distance);
  }

  /// Вычисляет пересечение линии с окружностью
  LineSegment intersectCircle(Circle circle) {
    var normal = this.normal(circle.center);

    // Линия не пересекается с окружностью
    if (normal.length > circle.radius) return LineSegment(null, null);

    var halfChord = math.sqrt(circle.radius * circle.radius - normal.length * normal.length); // Половина хорды
    var dx = math.cos(direct) * halfChord;
    var dy = math.sin(direct) * halfChord;
    var start = Point(normal.end.x - dx, normal.end.y - dy);
    var end = Point(normal.end.x + dx, normal.end.y + dy);

    return LineSegment(start, end);
  }

  /// Вычисляет пересечение линии с другой линией
  Point intersectLine(Line other) {
    var thisTan = this.tan();
    if (thisTan == 0.0) return other.pointByY(this.start.y);
    if (thisTan.isInfinite) return other.pointByX(this.start.x);

    final mX = this.start.x + (other.start.y - this.start.y) / thisTan;
//    if (mX == this.start.x) return Point(mX, other.start.y + (mX - other.start.x) * otherTn);
    final x = other.start.x - (other.start.x - mX) * thisTan / (thisTan - other.tan());
    final r = (x - this.start.x) / math.cos(this.direct);
    final y = this.start.y + math.sin(this.direct) * r;

    return Point(x, y);
  }

  /// Вычисляет пересечение линии с отрезком
  Point intersectLineSegment(LineSegment lineSegment) {
    Point point = intersectLine(Line(lineSegment.start, lineSegment.direct));

    if (point.x < math.min(lineSegment.start.x, lineSegment.end.x) ||
        point.x > math.max(lineSegment.start.x, lineSegment.end.x) ||
        point.y < math.min(lineSegment.start.y, lineSegment.end.y) ||
        point.y > math.max(lineSegment.start.y, lineSegment.end.y)) return null;

    return point;
  }
}

class Circle {
  const Circle(this.center, this.radius);

  final Point center;
  final double radius;

  double get diameter => 2 * radius;

  /// Точка на окружности: point(alpha)
  /// Точка на расстоянии от центра окружности: point(alpha, distance)
  Point point(double alpha, [double distance]) {
    if (distance == null) distance = radius;
    return Point(center.x + distance * math.cos(alpha), center.y + distance * math.sin(alpha));
  }

  LineSegment tangentToCircle(Circle other, double firstSide, double secondSide) {
    // Линия, соединяющая центры
    var c2c = LineSegment(this.center, other.center);

    // Вспомогательный треугольник, где касательная - гипотенуза
    var alpha = math.asin((this.radius - firstSide * secondSide * other.radius) / c2c.length).abs();
//    print('alpha: ${alpha / pi * 180}');

    // Угол наклона касательной
    var beta = c2c.direct + secondSide * alpha;
//    print('beta: ${beta / pi * 180}');

    var gamma1 = firstSide > 0 ? beta + math.pi / 2 : beta - math.pi / 2;
    var gamma2 = secondSide > 0 ? beta + math.pi / 2 : beta - math.pi / 2;

//    print('tanget: ${LineSegment(this.point(gamma1), other.point(gamma2))}');
    return LineSegment(this.point(gamma1), other.point(gamma2));
  }

  LineSegment tangentToPoint(Point point, double side) {
    // Линия, соединяющая центр и точку
    var c2c = LineSegment(this.center, point);

    // Вспомогательный треугольник, где касательная - гипотенуза
    var alpha = math.asin((this.radius) / c2c.length);
//    print('alpha: ${alpha / pi * 180}');

    // Угол наклона касательной
    var beta = c2c.direct - side * alpha;
//    print('beta: ${beta / pi * 180}');

    var gamma = side > 0 ? beta + math.pi / 2 : beta - math.pi / 2;

//    print('tanget: ${LineSegment(this.point(gamma), point)}');
    return LineSegment(this.point(gamma), point);
  }
}

/// Большие числа превращает в infinity/-infinity
double inf(double value) {
  final double max = 1e15;
  if (value > max) return double.infinity;
  if (value < -max) return double.negativeInfinity;
  return value;
}

class Point extends Offset {
  const Point(double x, double y) : super(x, y);

  static const Point infinite = Point(double.infinity, double.infinity);

  double get x => dx;
  double get y => dy;

  @override
  String toString() => "Point($dx, $dy)";
}
