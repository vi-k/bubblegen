import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

enum NipPosType { angle, side, corner }
enum NipLineType { line, lineR, arc, isosceles, triangle, curve }

class NipPos {
  const NipPos(this.posType, this.pos);

  final NipPosType posType;
  final double pos;
}

class NipLine {
  const NipLine._internal(
    this.posType,
    this.pos, {
    this.h = 0.0,
    this.a1,
    this.a2,
    this.sz1,
    this.sz2,
  }) : assert(pos != null);

  const NipLine.line(double lineAngle) : this._internal(NipPosType.angle, lineAngle);
  const NipLine.lineTo(double sidePos) : this._internal(NipPosType.side, sidePos);
  const NipLine.lineToCorner(double cornerPos) : this._internal(NipPosType.corner, cornerPos);

  const NipLine.arc(double lineAngle, height) : this._internal(NipPosType.angle, lineAngle, h: height);
  const NipLine.arcTo(double sidePos, height) : this._internal(NipPosType.side, sidePos, h: height);
  const NipLine.arcToCorner(double cornerPos, height) : this._internal(NipPosType.corner, cornerPos, h: height);

  const NipLine.curve(double lineAngle, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this._internal(
          NipPosType.angle,
          lineAngle,
          a1: angle1,
          a2: angle2,
          sz1: size1,
          sz2: size2,
        );

  const NipLine.curveTo(double sidePos, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this._internal(
          NipPosType.side,
          sidePos,
          a1: angle1,
          a2: angle2,
          sz1: size1,
          sz2: size2,
        );

  const NipLine.curveToCorner(double cornerPos, {angle1, angle2, size1 = 2 / 3, size2 = 2 / 3})
      : this._internal(
          NipPosType.corner,
          cornerPos,
          a1: angle1,
          a2: angle2,
          sz1: size1,
          sz2: size2,
        );

  final NipPosType posType;
  final double pos;
  final double h; // arc's radius
  final double a1; // curve's α₁
  final double a2; // curve's α₂
  final double sz1; // curve's sz₁
  final double sz2; // curve's sz₂
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
    this.startTopAngle,
    this.finishTopPos,
    this.finishTopAngle,
    this.startBottomAngle,
    this.finishBottomPos,
    this.finishBottomAngle,
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
  final double startTopAngle;
  final double finishTopPos;
  final double finishTopAngle;
  final double startBottomAngle;
  final double finishBottomPos;
  final double finishBottomAngle;
  final bool drawDraft;

  @override
  void paint(Canvas canvas, Size size) {
    final offsetY = nipYOffset < 0 ? nipYOffset : 0.0;

    final boxCircle1R = boxRadius > size.height / 2 ? size.height / 2 : boxRadius;
    final boxCircle2R = boxCircle1R;
    final boxCircle1X = nipWidth + boxCircle1R;
    final boxCircle1Y = boxCircle1R;
    final boxCircle2X = nipWidth + boxCircle2R;
    final boxCircle2Y = offsetY + size.height - boxCircle2R;

    var paint = Paint();
    var path = Path();

    var paintDraftMain = Paint();
    paintDraftMain.strokeWidth = 1;
    paintDraftMain.style = PaintingStyle.stroke;
    paintDraftMain.color = Colors.black;

    var paintDraftSecond = Paint();
    paintDraftSecond.strokeWidth = 1;
    paintDraftSecond.style = PaintingStyle.stroke;
    paintDraftSecond.color = Colors.black26;

    var paintDraftError = Paint();
    paintDraftError.strokeWidth = 1;
    paintDraftError.style = PaintingStyle.stroke;
    paintDraftError.color = Colors.red;

//    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
    canvas.translate(0, -offsetY);

    paint.color = Colors.lightGreen;
    canvas.drawRRect(
        RRect.fromLTRBR(this.zoom * this.nipWidth, 0, this.zoom * size.width, this.zoom * size.height + offsetY,
            Radius.circular(this.zoom * boxCircle1R)),
        paint);

    canvas.drawCircle(
        Offset(this.zoom * this.nipRadius, this.zoom * (this.nipYOffset + this.nipRadius)), zoom * nipRadius, paint);

    final startTopAngle = this.startTopAngle * pi / 180;
    final startTopX = this.zoom * this.nipRadius * (1 - sin(startTopAngle));
    final startTopY = this.zoom * (this.nipYOffset + this.nipRadius * (1 - cos(startTopAngle)));

    double finishTopX;
    double finishTopY;
    if (this.finishTopPos < 0) {
      final finishTopPos = -this.finishTopPos * pi / 180;
      finishTopX = boxCircle1X - this.zoom * boxCircle1R * sin(finishTopPos);
      finishTopY = boxCircle1Y - this.zoom * boxCircle1R * cos(finishTopPos);
    } else {
      var pos = this.finishTopPos + this.nipYOffset;
      if (pos < 0) pos = 0;
      finishTopX = pos < boxCircle1R
          ? boxCircle1X - this.zoom * boxCircle1R * sin(acos(1 - pos / boxCircle1R))
          : this.zoom * this.nipWidth;
      finishTopY = this.zoom * pos;
    }
    final finishTopAngle = this.finishTopAngle * pi / 180;

    final topDirectSize = sqrt(pow(finishTopX - startTopX, 2) + pow(finishTopY - startTopY, 2)) / 3;
    final startTopDirectX = startTopX + topDirectSize * cos(startTopAngle);
    final startTopDirectY = startTopY - topDirectSize * sin(startTopAngle);
    final finishTopDirectX = finishTopX + topDirectSize * cos(finishTopAngle);
    final finishTopDirectY = finishTopY - topDirectSize * sin(finishTopAngle);

    final startBottomAngle = this.startBottomAngle * pi / 180;
    final startBottomX = this.zoom * this.nipRadius * (1 + sin(startBottomAngle));
    final startBottomY = this.zoom * (this.nipYOffset + this.nipRadius * (1 + cos(startBottomAngle)));

    double finishBottomX;
    double finishBottomY;
    if (this.finishBottomPos < 0) {
      final finishBottomPos = -this.finishBottomPos * pi / 180;
      finishBottomX = boxCircle1X - this.zoom * boxCircle1R * sin(finishBottomPos);
      finishBottomY = boxCircle1Y - this.zoom * boxCircle1R * cos(finishBottomPos);
    } else {
      var pos = this.finishBottomPos + this.nipYOffset;
      if (pos < 0) pos = 0;
      finishBottomX = pos < boxCircle1R
          ? boxCircle1X - this.zoom * boxCircle1R * sin(acos(1 - pos / boxCircle1R))
          : this.zoom * this.nipWidth;
      finishBottomY = this.zoom * pos;
    }
    final finishBottomAngle = this.finishBottomAngle * pi / 180;

    final bottomDirectSize = sqrt(pow(finishBottomX - startBottomX, 2) + pow(finishBottomY - startBottomY, 2)) / 3;
    final startBottomDirectX = startBottomX + bottomDirectSize * cos(startBottomAngle);
    final startBottomDirectY = startBottomY - bottomDirectSize * sin(startBottomAngle);
    final finishBottomDirectX = finishBottomX + bottomDirectSize * cos(finishBottomAngle);
    final finishBottomDirectY = finishBottomY - bottomDirectSize * sin(finishBottomAngle);

    path.reset();
    path.moveTo(startTopX, startTopY);
//    path.lineTo(finishTopX, finishTopY);
    path.cubicTo(startTopDirectX, startTopDirectY, finishTopDirectX, finishTopDirectY, finishTopX, finishTopY);

//    path.lineTo(finishTopX, finishTopY + this.zoom * 10);
    path.lineTo(finishBottomX, finishBottomY);
    path.cubicTo(
        finishBottomDirectX, finishBottomDirectY, startBottomDirectX, startBottomDirectY, startBottomX, startBottomY);

    path.close();
    canvas.drawPath(path, paint);

//    path.reset();
//    path.moveTo(tX, tY + (nY - ntY));
//    //path.lineTo(nX, nY);
//    path.arcToPoint(Offset(nX, nY),
//        radius: Radius.circular(this.nipCurve1.abs()), largeArc: false, clockwise: this.nipCurve1 < 0 ? true : false);
//    //path.lineTo(bX, bY - (nbY - nY));
//    path.arcToPoint(Offset(bX, bY - (nbY - nY)),
//        radius: Radius.circular(this.nipCurve2.abs()), largeArc: false, clockwise: this.nipCurve1 < 0 ? false : true);
//    //var d = sqrt(pow((bX - tX), 2) + pow(bY - (nbY - nY) - (tY + (nY - ntY)), 2));
//    //path.arcToPoint(Offset(tX, tY + (nY - ntY)), radius: Radius.circular(d / 2), largeArc: false, clockwise: false);
//    path.close();

//    paint.color = Colors.blue;
//    canvas.drawPath(path, paint);

    if (this.drawDraft) {
      paint.color = Colors.black;
      paint.strokeWidth = 1 / 2.65;
      paint.style = PaintingStyle.stroke;
//      canvas.drawPath(path, paint);

      canvas.drawCircle(Offset(boxCircle1X, boxCircle1Y), boxCircle1R, paint);
      canvas.drawLine(
          Offset(boxCircle1X, boxCircle1Y - boxCircle1R), Offset(boxCircle1X, boxCircle1Y + boxCircle1R), paint);
      canvas.drawLine(
          Offset(boxCircle1X - boxCircle1R, boxCircle1Y), Offset(boxCircle1X + boxCircle1R, boxCircle1Y), paint);

      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(startTopX, startTopY), 1, paint);
      canvas.drawLine(Offset(startTopX, startTopY), Offset(startTopDirectX, startTopDirectY), paint);

      canvas.drawCircle(Offset(finishTopX, finishTopY), 1, paint);
      canvas.drawLine(Offset(finishTopX, finishTopY), Offset(finishTopDirectX, finishTopDirectY), paint);

      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(startBottomX, startBottomY), 1, paint);
      canvas.drawLine(Offset(startBottomX, startBottomY), Offset(startBottomDirectX, startBottomDirectY), paint);

      canvas.drawCircle(Offset(finishBottomX, finishBottomY), 1, paint);
      canvas.drawLine(Offset(finishBottomX, finishBottomY), Offset(finishBottomDirectX, finishBottomDirectY), paint);
    }

//    double x1 = 100, y1 = 10;
//    double x2 = 300, y2 = 10;
//    double x3 = (x1 + x2) / 5, y3 = 110;
//
//    path.reset();
//    path.moveTo(x1, y1);
//    path.lineTo(x2, y2);
////    path.conicTo(x3, y3, x1, y1, 3);
//    path.quadraticBezierTo(x3, y3, x1, y1);
//    path.close();
//    paint.color = Colors.red;
//    paint.style = PaintingStyle.fill;
//    canvas.drawPath(path, paint);
//
//    double k = 2/3;
//    path.reset();
//    path.moveTo(x1, y1);
//    path.lineTo(x2, y2);
//    path.cubicTo(x2 - (x2 - x3) * k , y2 - (y2 - y3) * k, x1 + (x3 - x1) * 2*k, y1 + (y3 - y1) * 2*k, x1, y1);
//    path.close();
//    paint.color = Colors.brown;//.withAlpha(128);
//    paint.style = PaintingStyle.fill;
//    canvas.drawPath(path, paint);

//    path.reset();
//    path.moveTo(100, 100);
//    path.arcToPoint(Offset(300, 100), radius: Radius.circular(50));
//    path.lineTo(200, 200);
//    path.close();
//    paint.color = Colors.red;
//    paint.style = PaintingStyle.fill;
//    canvas.drawPath(path, paint);

    final nipCircleX = nipRadius;
    final nipCircleY = nipYOffset + nipRadius;

    double topX1;
    double topY1;
    double topX2;
    double topY2;

    var topLineHasError = false;

    // Малый круг
    paintDraftSecond.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(nipCircleX, nipCircleY), nipRadius, paintDraftSecond);

    // Прямая линия под углом
    if (topLine.posType == NipPosType.angle) {
      var alpha = topLine.pos * pi / 180; // Угол наклона линии
      var beta = alpha - pi / 2; // Точка касательной (угол) на малом круге
      topX1 = nipCircleX + nipRadius * cos(beta);
      topY1 = nipCircleY + nipRadius * sin(beta);
      topY2 = topY1 + tan(alpha) * (nipWidth - topX1);

      if (topY2 >= boxCircle1Y && topY2 <= boxCircle2Y) {
        //
        // Линия пересекается с ровной стороной бокса
        //
        topX2 = nipWidth;

        path.reset();
        path.moveTo(nipWidth, boxCircle1Y);
        path.lineTo(boxCircle1X, boxCircle1Y);
        path.lineTo(boxCircle2X, boxCircle2Y);
        path.lineTo(nipWidth, boxCircle2Y);
        path.close();

        paintDraftSecond.style = PaintingStyle.fill;
        canvas.drawPath(path, paintDraftSecond);
      } else if (topY2 < boxCircle1Y) {
        //
        // Линия уходит к верхнему кругу и выше
        //
        paintDraftSecond.style = PaintingStyle.fill;
        canvas.drawArc(
            Rect.fromCenter(center: Offset(boxCircle1X, boxCircle1Y), width: 2 * boxCircle1R, height: 2 * boxCircle1R),
            -pi / 2,
            -pi / 2,
            true,
            paintDraftSecond);

        // Рассчитываем нормаль к линии от центра верхнего круга
        var normal = Line(Offset(topX1, topY1), alpha).normal(Offset(boxCircle1X, boxCircle1Y));

        if (normal.length <= boxCircle1R) {
          //
          // Линия пересекается с дугой угла
          //
          var chord = sqrt(boxCircle1R * boxCircle1R - normal.length * normal.length); // Половина хорды
          topX2 = normal.end.dx - cos(alpha) * chord;
          topY2 = normal.end.dy - sin(alpha) * chord;

          paintDraftSecond.style = PaintingStyle.stroke;
          canvas.drawLine(Offset(boxCircle1X, boxCircle1Y), normal.end, paintDraftSecond);
          canvas.drawLine(Offset(topX2, topY2), normal.end, paintDraftSecond);
          paintDraftSecond.style = PaintingStyle.fill;
          canvas.drawCircle(normal.end, 2, paintDraftSecond);
        } else {
          //
          // Линия выходит за верхний круг
          // В этом случае за линию берём касательную, общую для малого и верхнего кругов
          //
          topLineHasError = true;

          // Расстояние между центрами кругов
          var d = sqrt(pow(boxCircle1X - nipCircleX, 2) + pow(boxCircle1Y - nipCircleY, 2));

          // Точка касательной (угол) на малом и верхнем кругах
          beta = atan2(boxCircle1Y - nipCircleY, boxCircle1X - nipCircleX) + atan2(nipRadius - boxCircle1R, d) - pi / 2;

          topX1 = nipCircleX + cos(beta) * nipRadius;
          topY1 = nipCircleY + sin(beta) * nipRadius;
          topX2 = boxCircle1X + cos(beta) * boxCircle1R;
          topY2 = boxCircle1Y + sin(beta) * boxCircle1R;

          paintDraftSecond.style = PaintingStyle.stroke;
          canvas.drawLine(Offset(nipCircleX, nipCircleY), Offset(topX1, topY1), paintDraftSecond);
          canvas.drawLine(Offset(boxCircle1X, boxCircle1Y), Offset(topX2, topY2), paintDraftSecond);

          if (beta > -pi / 2) {
            //
            // Линия уходит вправо
            //
            paintDraftSecond.style = PaintingStyle.fill;
            canvas.drawArc(
                Rect.fromCenter(
                    center: Offset(boxCircle1X, boxCircle1Y), width: 2 * boxCircle1R, height: 2 * boxCircle1R),
                0,
                -pi / 2,
                true,
                paintDraftSecond);
          }
        }
      } else if (topY2 > boxCircle2Y) {
        //
        // Линия уходит к нижнему углу и ниже
        //
        paintDraftSecond.style = PaintingStyle.fill;
        canvas.drawArc(
            Rect.fromCenter(center: Offset(boxCircle2X, boxCircle2Y), width: 2 * boxCircle2R, height: 2 * boxCircle2R),
            pi / 2,
            pi / 2,
            true,
            paintDraftSecond);

        var kX = topX1 + (boxCircle2Y - topY1) / tan(alpha);
        var kY = boxCircle2Y;
        var kR = boxCircle2X - kX;
        var kH = sin(alpha) * kR;
        var kW = cos(alpha) * kR;
        if (kH > boxCircle2R) {
          //
          // Выходит за угол
          //
          topLineHasError = true;

          var b = atan2(boxCircle2Y - nipCircleY, boxCircle2X - nipCircleX);
          var dist = sqrt(pow(boxCircle2X - nipCircleX, 2) + pow(boxCircle2Y - nipCircleY, 2));
          var g = b - atan2(boxCircle2R - nipRadius, dist) - pi / 2;

          topX1 = nipCircleX + cos(g) * nipRadius;
          topY1 = nipCircleY + sin(g) * nipRadius;
          topX2 = boxCircle2X + cos(g) * boxCircle2R;
          topY2 = boxCircle2Y + sin(g) * boxCircle2R;
        } else {
          //
          // Пересекается с дугой угла
          //
          var l = kW - sqrt(boxCircle2R * boxCircle2R - kH * kH);
          topX2 = kX + cos(alpha) * l;
          topY2 = kY + sin(alpha) * l;

          var b = pi / 2 - alpha;
          var mX = boxCircle2X - cos(b) * kH;
          var mY = boxCircle2Y + sin(b) * kH;

          paint.strokeWidth = 1;
          paint.style = PaintingStyle.stroke;
          paint.color = Colors.black45;
          canvas.drawLine(Offset(boxCircle2X, boxCircle2Y), Offset(mX, mY), paint);
          canvas.drawLine(Offset(topX2, topY2), Offset(mX, mY), paint);

          paint.color = Colors.black;
          paint.style = PaintingStyle.fill;
          canvas.drawCircle(Offset(mX, mY), 2, paint);
        }
      }
    } else if (topLine.posType == NipPosType.side) {
      topX2 = nipWidth;
      topY2 = nipYOffset + topLine.pos;

      if (topY2 < boxCircle1Y - boxCircle1R) {
        topY2 = boxCircle1Y - boxCircle1R;
        topX2 = boxCircle1X;
      } else if (topY2 < boxCircle1Y) {
        topX2 = boxCircle1X - boxCircle1R * cos(asin((boxCircle1Y - topY2) / boxCircle1R));
      }

      if (topY2 > boxCircle2Y + boxCircle2R) {
        topY2 = boxCircle2Y + boxCircle2R;
        topX2 = boxCircle2X;
      } else if (topY2 > boxCircle2Y) {
        topX2 = boxCircle2X - boxCircle2R * cos(asin((topY2 - boxCircle2Y) / boxCircle2R));
      }

      var l = sqrt(pow(topX2 - nipCircleX, 2) + pow(topY2 - nipCircleY, 2));
      var a1 = asin((topY2 - nipCircleY) / l);
      var a2 = -atan2(l, nipRadius);

      topX1 = nipCircleX + nipRadius * cos(a1 + a2);
      topY1 = nipCircleY + nipRadius * sin(a1 + a2);
    } else if (topLine.posType == NipPosType.corner) {
      var a = topLine.pos * pi / 180;
      if (topLine.pos <= 0) {
        topX2 = boxCircle1X + boxCircle1R * cos(a);
        topY2 = boxCircle1Y + boxCircle1R * sin(a);
      } else {
        topX2 = boxCircle2X + boxCircle2R * cos(a);
        topY2 = boxCircle2Y + boxCircle2R * sin(a);
      }

      var l = sqrt(pow(topX2 - nipCircleX, 2) + pow(topY2 - nipCircleY, 2));
      var a1 = asin((topY2 - nipCircleY) / l);
      var a2 = -atan2(l, nipRadius);

      topX1 = nipCircleX + nipRadius * cos(a1 + a2);
      topY1 = nipCircleY + nipRadius * sin(a1 + a2);
    }

    var p = topLineHasError ? paintDraftError : paintDraftMain;
    p.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(topX1, topY1), 2, p);
    canvas.drawCircle(Offset(topX2, topY2), 2, p);
    p.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(topX1, topY1), Offset(topX2, topY2), p);

//    var ls = LineSegment(Offset(0,0), Offset(0, -100));
//    var ls = LineSegment.direct(Offset(0,0), 90 * pi / 180, 100);
    var ls = Line(Offset(0, 0), 90 * pi / 180).normal(Offset(100, 0));
    print('start: ${ls.start}, end: ${ls.end}, direct: ${ls.direct * 180 / pi}, length: ${ls.length}');
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Отрезок
///
/// Неконстантный класс. Необходимые значения вычисляются по необходимости и сохраняются
class LineSegment {
  LineSegment(this._start, this._end);
  LineSegment.direct(this._start, this._direct, this._length);

  final Offset _start;
  Offset _end;
  double _length;
  double _direct;

  Offset get start => _start;

  Offset get end {
    if (_end == null) {
      _end = Offset(_start.dx + _length * cos(_direct), _start.dy + _length * sin(_direct));
    }
    return _end;
  }

  double get length {
    if (_length == null) {
      _length = sqrt(pow(_end.dx - _start.dx, 2) + pow(_end.dy - _start.dy, 2));
    }
    return _length;
  }

  double get direct {
    if (_direct == null) {
      _direct = atan2(_end.dy - _start.dy, _end.dx - _start.dy);
    }
    return _direct;
  }
}

class Line {
  const Line(this.start, this.direct);
  Line.toPoint(this.start, Offset end) : direct = atan2(1,2);

  final Offset start;
  final double direct;

  LineSegment normal(Offset point) {
    double distance;
    double angle;

    var tn = tan(direct);
    if (tn == 0.0) {
      distance = start.dy - point.dy;
      angle = pi / 2;
    } else {
      // Вспомогательный треугольник, гипотенуза которого находится на одной горизонтали с точкой
      var x = start.dx + (point.dy - start.dy) / tn;
      distance = sin(direct) * (point.dx - x); // Дальний катет треуголника - искомое расстояние
      angle = direct + pi / 2;
    }

    if (distance < 0) {
      distance = -distance;
      angle -= pi;
    }

    return LineSegment.direct(point, angle, distance);
  }
}
