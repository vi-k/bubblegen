import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

import 'geometry.dart';

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

    DraftType.values.forEach((type) {
      paint.color = type == DraftType.Error ? errorColor : type == DraftType.Main ? mainColor : draftColor;

      paint.style = PaintingStyle.stroke;

      // Линии
      lines.forEach((item) {
        if (item.type == type) {
          draftCanvas.drawLine(item.line.start, item.line.point(1000.0), paint);
        }
      });

      // Отрезки
      lineSegments.forEach((item) {
        if (item.type == type) {
          draftCanvas.drawLine(item.lineSegment.start, item.lineSegment.end, paint);
        }
      });

      paint.style = PaintingStyle.fill;

      // Точки
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
  }) : super();

  final double zoom;
  final NipLine topLine;
  final NipLine bottomLine;
  final double boxRadius;
  final double nipWidth;
  final double nipRadius;
  final double nipYOffset;
  final bool drawDraft;

  /// Прямая линия под углом
  bool line(LineSegment out, double angle, bool inverse, Path path, Circle nipCircle, Rect box, Circle ltCircle,
      Circle lbCircle, Circle rtCircle, Circle rbCircle,
      [DraftInfo draft]) {
    bool ok = true;

    var beta = inverse ? angle + math.pi / 2 : angle - math.pi / 2; // Точка касательной на малом круге

    var line = Line(nipCircle.point(beta), angle);
    var tan = line.tan();
    out.start = line.start;

    if (draft != null) {
      draft.addPoint(out.start);
      draft.addLineCopy(line);
    }

    //
    // Линия пересекает ровную часть левой стороны бокса
    //
    out.end = Point(box.left, out.start.y + (box.left - out.start.x) * tan);
    if (out.end.y >= ltCircle.center.y && out.end.y <= lbCircle.center.y) {
      draft?.showLeftSide = true;
    }
    //
    // Линия уходит к верхней части бокса
    //
    else if (out.end.y < ltCircle.center.y) {
      var processed = false;

      //
      // Линия падает сверху на бокс
      //
      if (nipCircle.center.y - nipCircle.radius < box.top) {
        out.end = Point(out.start.x + (box.top - out.start.y) / tan, box.top);
        if (out.end.x >= ltCircle.center.x || tan < 0) {
          processed = true;
          draft?.showTopSide = true;

          //
          // Линия уходит к правому краю бокса
          // (касательную к правому кругу не строим, ограничиваемся правым краем ровной стороны)
          //
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
        var chord = line.intersectCircle(ltCircle);

        //
        // Линия пересекается с дугой угла
        //
        if (chord != null) {
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
    // Линия уходит к нижней части бокса
    //
    else {
      var processed = false;

      // Линия падает снизу на бокс
      if (nipCircle.center.y + nipCircle.radius > box.bottom) {
        out.end = Point(out.start.x + (box.bottom - out.start.y) / tan, box.bottom);
        if (out.end.x >= lbCircle.center.x || tan >= 0) {
          processed = true;
          draft?.showBottomSide = true;

          // Линия уходит к правому краю бокса
          // (касательную к правому кругу не строим, ограничиваемся правым краем ровной стороны)
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
        var chord = line.intersectCircle(lbCircle);

        //
        // Линия пересекается с дугой угла
        //
        if (chord != null) {
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

  /// Прямая линия к позиции на стороне бокса
  bool lineTo(LineSegment out, double pos, bool inverse, Path path, Circle nipCircle, Rect box, Circle ltCircle,
      Circle lbCircle, Circle rtCircle, Circle rbCircle,
      [DraftInfo draft]) {
    bool ok = true;
    Point draftEnd;

    //var pos = relative ? nipYOffset: nipLine.pos;
    //
    // Линия уходит к верхней стороне бокса
    //
    if (pos < 0) {
      var offset = -pos;
      draftEnd = out.end = Point(ltCircle.center.x + offset, box.top);
      if (ltCircle.center.x + offset > rtCircle.center.x) {
        ok = false;
        out.end = Point(rtCircle.center.x, box.top);
      }
    }
    //
    // Линия уходит к нижней стороне бокса
    //
    else if (pos > box.height) {
      var offset = pos - box.height;
      draftEnd = out.end = Point(lbCircle.center.x + offset, box.bottom);
      if (lbCircle.center.x + offset > rbCircle.center.x) {
        ok = false;
        out.end = Point(rbCircle.center.x, box.bottom);
      }
    }
    //
    // Линия уходит к левой стороне бокса
    //
    else {
      draftEnd = out.end = Point(box.left, box.top + pos);

      //
      // Линия пересекается с ровной стороной бокса
      //
      if (out.end.y >= ltCircle.center.y && out.end.y <= lbCircle.center.y) {
        draft?.showLeftSide = true;
      }
      //
      // Линия уходит к верхнему углу
      //
      else if (out.end.y < ltCircle.center.y) {
        draftEnd = out.end = ltCircle.point(math.asin((ltCircle.center.y - out.end.y) / ltCircle.radius) - math.pi);

        if (draft != null) {
          draft.showTopCorner = true;
          draft.addLineSegment(out.end, Point(ltCircle.center.x, out.end.y));
        }
      }
      //
      // Линия уходит к нижнему углу
      //
      else {
        draftEnd = out.end = lbCircle.point(math.asin((lbCircle.center.y - out.end.y) / lbCircle.radius) - math.pi);

        if (draft != null) {
          draft.showBottomCorner = true;
          draft.addLineSegment(out.end, Point(lbCircle.center.x, out.end.y));
        }
      }
    }

    if (draft != null) {
      var tangent = nipCircle.tangentToPoint(draftEnd, inverse ? 1.0 : -1.0);
      draft.addPoint(draftEnd);
      draft.addLineSegment(tangent.start, draftEnd);
    }

    // Смотрим, не вышла ли линия за касательную
    bool processed = false;
    if (out.end.y < ltCircle.center.y && nipCircle.center.y - nipCircle.radius >= box.top) {
      var tangent = nipCircle.tangentToCircle(ltCircle, inverse ? 1.0 : -1.0, -1.0);
      if (out.end.x > tangent.end.x) {
        processed = true;
        ok = false;
        out.start = tangent.start;
        out.end = tangent.end;
        draft?.showTopCorner = true;
      }
    } else if (out.end.y > lbCircle.center.y && nipCircle.center.y + nipCircle.radius <= box.bottom) {
      var tangent = nipCircle.tangentToCircle(lbCircle, inverse ? 1.0 : -1.0, 1.0);
      if (out.end.x > tangent.end.x) {
        processed = true;
        ok = false;
        out.start = tangent.start;
        out.end = tangent.end;
        draft?.showBottomCorner = true;
      }
    } else if (draft != null) {
      if (out.end.y == box.top) draft.showTopSide = true;
      else if (out.end.y == box.bottom) draft.showBottomSide = true;
    }

    if (!processed) {
      var tangent = nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
      out.start = tangent.start;
    }

    return ok;
  }

  /// Прямая линия к углам бокса
  bool lineToCorner(LineSegment out, double angle, bool inverse, Path path, Circle nipCircle, Rect box,
      Circle ltCircle, Circle lbCircle, Circle rtCircle, Circle rbCircle,
      [DraftInfo draft]) {
    bool ok = true;

    // Отрицательные значения - верхний круг, положительные - нижний
    out.end = angle <= 0 ? ltCircle.point(angle) : lbCircle.point(angle);

    var tangent = nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
    out.start = tangent.start;

    if (draft != null) {
      draft.addPoint(out.end);
      draft.addLineSegmentCopy(out);
    }

    if (angle <= 0) {
      var tangent = nipCircle.tangentToCircle(ltCircle, inverse ? 1.0 : -1.0, -1.0);
      if (out.end.x > tangent.end.x) {
        ok = false;
        out.start = tangent.start;
        out.end = tangent.end;
        draft?.showTopCorner = true;
      }
    } else if (angle >= 0) {
      var tangent = nipCircle.tangentToCircle(lbCircle, inverse ? 1.0 : -1.0, 1.0);
      if (out.end.x > tangent.end.x) {
        ok = false;
        out.start = tangent.start;
        out.end = tangent.end;
        draft?.showBottomCorner = true;
      }
    }

    if (draft != null) {
      if (angle <= 0) {
        draft.showTopCorner = true;
        draft.addLineSegment(ltCircle.center, out.end);
      } else {
        draft.showBottomCorner = true;
        draft.addLineSegment(lbCircle.center, out.end);
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
        ok = line(result, nipLine.pos * math.pi / 180, inverse, path, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle, draft);
        break;

      case NipLineType.lineTo:
        ok = lineTo(result, nipLine.pos, inverse, path, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle, draft);
        break;

      case NipLineType.relativeLineTo:
        ok = lineTo(
            result, nipYOffset + nipLine.pos, inverse, path, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle, draft);
        break;

      case NipLineType.lineToCorner:
        ok =
            lineToCorner(result, nipLine.pos * math.pi / 180, inverse, path, nipCircle, box, ltCircle, lbCircle, rtCircle, rbCircle, draft);
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
