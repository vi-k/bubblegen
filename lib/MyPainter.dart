import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

import 'bubble.dart';
import 'geometry.dart';

class MyPainter extends CustomPainter {
  MyPainter({
    this.zoom = 1.0,
    @required this.topLine,
    @required this.bottomLine,
    this.boxRadius,
    this.nipWidth,
    this.nipRadius,
    this.nipYOffset,
    this.height,
    this.drawDraft,
  }) : super();

  final double zoom;
  final NipLine topLine;
  final NipLine bottomLine;
  final double boxRadius;
  final double nipWidth;
  final double nipRadius;
  final double nipYOffset;
  final double height;
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

          draft?.addPoint(chord.end);
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

          draft?.addPoint(chord.end);
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
        if (draft != null) {
          draft.showTopCorner = true;
          draft.addLineSegment(ltCircle.center, tangent.end);
        }
      }
    } else if (out.end.y > lbCircle.center.y && nipCircle.center.y + nipCircle.radius <= box.bottom) {
      var tangent = nipCircle.tangentToCircle(lbCircle, inverse ? 1.0 : -1.0, 1.0);
      if (out.end.x > tangent.end.x) {
        processed = true;
        ok = false;
        out.start = tangent.start;
        out.end = tangent.end;
        if (draft != null) {
          draft.showBottomCorner = true;
          draft.addLineSegment(lbCircle.center, tangent.end);
        }
      }
    } else if (draft != null) {
      if (out.end.y == box.top)
        draft.showTopSide = true;
      else if (out.end.y == box.bottom) draft.showBottomSide = true;
    }

    if (!processed) {
      var tangent = nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
      out.start = tangent.start;
    }

    return ok;
  }

  /// Прямая линия к углам бокса
  bool lineToCorner(LineSegment out, double angle, bool inverse, Path path, Circle nipCircle, Rect box, Circle ltCircle,
      Circle lbCircle, Circle rtCircle, Circle rbCircle,
      [DraftInfo draft]) {
    bool ok = true;
    Point draftEnd;

    // Отрицательные значения - верхний круг, положительные - нижний
    draftEnd = out.end = angle <= 0 ? ltCircle.point(angle) : lbCircle.point(angle);

    if (draft != null) {
      draft.addPoint(draftEnd);
      var tangent = nipCircle.tangentToPoint(draftEnd, inverse ? 1.0 : -1.0);
      draft.addLineSegmentCopy(tangent);
    }

    // Проверям выход за границы четвертей
    if (angle <= 0) {
      if (angle > -math.pi / 2) {
        ok = false;
        out.end = Point(ltCircle.center.x, box.top);
      } else if (angle < -math.pi) {
        ok = false;
        out.end = Point(box.left, ltCircle.center.y);
      }
    } else if (angle >= 0) {
      if (angle < math.pi / 2) {
        ok = false;
        out.end = Point(lbCircle.center.x, box.bottom);
      } else if (angle > math.pi) {
        ok = false;
        out.end = Point(box.left, lbCircle.center.y);
      }
    }

    if (angle <= 0) {
      var tangent = nipCircle.tangentToCircle(ltCircle, inverse ? 1.0 : -1.0, -1.0);
      if (out.end.x > tangent.end.x) {
        ok = false;
        out.start = tangent.start;
        out.end = tangent.end;
        if (draft != null) {
          draft.showTopCorner = true;
          draft.addLineSegment(ltCircle.center, tangent.end);
        }
      }
    } else if (angle >= 0) {
      var tangent = nipCircle.tangentToCircle(lbCircle, inverse ? 1.0 : -1.0, 1.0);
      if (out.end.x > tangent.end.x) {
        ok = false;
        out.start = tangent.start;
        out.end = tangent.end;
        if (draft != null) {
          draft.showBottomCorner = true;
          draft.addLineSegment(lbCircle.center, tangent.end);
        }
      }
    }

    if (ok) {
      var tangent = nipCircle.tangentToPoint(out.end, inverse ? 1.0 : -1.0);
      out.start = tangent.start;
    }

    if (draft != null) {
      var tangent = nipCircle.tangentToPoint(draftEnd, inverse ? 1.0 : -1.0);
      out.start = tangent.start;

      draft.addPoint(draftEnd);
      draft.addLineSegment(out.start, draftEnd);

      if (angle <= 0) {
        draft.showTopCorner = true;
        draft.addLineSegment(ltCircle.center, draftEnd);
      } else {
        draft.showBottomCorner = true;
        draft.addLineSegment(lbCircle.center, draftEnd);
      }
    }

    return ok;
  }

  Point addLine(NipLine nipLine, bool inverse, Path path, Circle nipCircle, Rect box, Circle ltCircle, Circle lbCircle,
      Circle rtCircle, Circle rbCircle,
      [DraftInfo draft]) {
    bool ok = true;
    var result = LineSegment(null, null);

//    print(nipLine.type);

    switch (nipLine.lineType) {
      case NipLineType.line:
        switch (nipLine.posType) {
          case NipLinePosType.angle:
            ok = line(result, nipLine.pos * math.pi / 180, inverse, path, nipCircle, box, ltCircle, lbCircle, rtCircle,
                rbCircle, draft);
            break;

          case NipLinePosType.pos:
            ok = lineTo(result, nipLine.pos, inverse, path, nipCircle, box, ltCircle, lbCircle, rtCircle,
                rbCircle, draft);
            break;

          case NipLinePosType.offset:
            ok = lineTo(
                result, nipYOffset + nipLine.pos,
                inverse, path, nipCircle, box, ltCircle, lbCircle, rtCircle,
                rbCircle, draft);
            break;

          case NipLinePosType.corner:
            ok = lineToCorner(result, nipLine.pos * math.pi / 180, inverse, path, nipCircle, box, ltCircle, lbCircle, rtCircle,
                rbCircle, draft);
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
//      print('result: $result');
      path.moveTo(result.start.x, result.start.y);
      path.lineTo(result.end.x, result.end.y);
    }

    return result.start;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    var path = Path();

    var topOffset = -nipYOffset;
    if (topOffset < 0) topOffset = 0.0;

    var bottomOffset = topOffset + nipYOffset + 2 * nipRadius - height;
    if (bottomOffset < 0) bottomOffset = 0;

    var pi = BubblePaintInfo();
    pi.scale = 1.0;
    pi.rect = Rect.fromLTWH(0, 0, size.width, size.height);

    pi.box = Rect.fromLTRB(nipWidth, topOffset, size.width / 3, size.height - bottomOffset);

    final maxRadius = math.min(size.width - nipWidth, size.height) / 2;
    final r = boxRadius > maxRadius ? maxRadius : boxRadius;

    paint.color = Colors.lightGreen;
//    canvas.translate(size.width, 0);
//    canvas.scale(-1, 1);
//    canvas.translate(0, size.height);
//    canvas.scale(1, -1);
//    canvas.drawRRect(RRect.fromRectAndRadius(box, Radius.circular(r)), paint);
    canvas.drawRRect(
        RRect.fromLTRBAndCorners(pi.box.left, pi.box.top, pi.box.right, pi.box.bottom,
            topLeft: Radius.circular(r),
            topRight: Radius.circular(r),
            bottomLeft: Radius.circular(r),
            bottomRight: Radius.circular(r)),
        paint);

    pi.nipCircle = Circle(Point(nipRadius, topOffset + nipYOffset + nipRadius), nipRadius);
    pi.ltCircle = Circle(Point(pi.box.left + r, pi.box.top + r), r);
    pi.lbCircle = Circle(Point(pi.box.left + r, pi.box.bottom - r), r);
    pi.rtCircle = Circle(Point(pi.box.right - r, pi.box.top + r), r);
    pi.rbCircle = Circle(Point(pi.box.right - r, pi.box.bottom - r), r);

    pi.draft = this.drawDraft ? DraftInfo() : null;

    if (pi.draft != null) {
      pi.draft.addPoint(pi.ltCircle.center);
      pi.draft.addPoint(pi.lbCircle.center);
      pi.draft.addPoint(pi.rtCircle.center);
      pi.draft.addPoint(pi.rbCircle.center);
    }

    path.reset();
    addLine(topLine, false, path, pi.nipCircle, pi.box, pi.ltCircle, pi.lbCircle, pi.rtCircle, pi.rbCircle, pi.draft);
    addLine(bottomLine, true, path, pi.nipCircle, pi.box, pi.ltCircle, pi.lbCircle, pi.rtCircle, pi.rbCircle, pi.draft);
    path.close();
    path.addOval(Rect.fromCenter(center: pi.nipCircle.center, width: pi.nipCircle.diameter, height: pi.nipCircle.diameter));

    canvas.drawPath(path, paint);
    if (pi.draft != null) pi.draft.paint(canvas, pi);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
