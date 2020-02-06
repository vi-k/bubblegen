import 'dart:math';
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
    this.size,
    this.radius,
    this.offset,
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
  final double size;
  final double radius;
  final double offset;
  final double startTopAngle;
  final double finishTopPos;
  final double finishTopAngle;
  final double startBottomAngle;
  final double finishBottomPos;
  final double finishBottomAngle;
  final bool drawDraft;

  @override
  void paint(Canvas canvas, Size size) {
    final boxRadius = this.boxRadius > size.height / 2 ? size.height / 2 : this.boxRadius;
    final circleR = this.zoom * boxRadius;
    final circleX = this.zoom * this.size + circleR;
    final circleY = circleR;
    final offsetY = this.offset < 0 ? this.offset : 0.0;

    var paint = Paint();
    var path = Path();

//    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
    canvas.translate(0, -offsetY);

    paint.color = Colors.lightGreen;
    canvas.drawRRect(
        RRect.fromLTRBR(this.zoom * this.size, 0, this.zoom * size.width, this.zoom * size.height + offsetY,
            Radius.circular(this.zoom * boxRadius)),
        paint);

    canvas.drawCircle(Offset(this.zoom * this.radius, this.zoom * (this.offset + this.radius)), zoom * radius, paint);

//    final startTopAngle = this.startTopAngle * pi / 180;
    final startTopAngle = this.topLine.pos * pi / 180;
    final startTopX = this.zoom * this.radius * (1 - sin(startTopAngle));
    final startTopY = this.zoom * (this.offset + this.radius * (1 - cos(startTopAngle)));

    double finishTopX;
    double finishTopY;
    if (this.finishTopPos < 0) {
      final finishTopPos = -this.finishTopPos * pi / 180;
      finishTopX = circleX - this.zoom * boxRadius * sin(finishTopPos);
      finishTopY = circleY - this.zoom * boxRadius * cos(finishTopPos);
    } else {
      var pos = this.finishTopPos + this.offset;
      if (pos < 0) pos = 0;
      finishTopX =
          pos < boxRadius ? circleX - this.zoom * boxRadius * sin(acos(1 - pos / boxRadius)) : this.zoom * this.size;
      finishTopY = this.zoom * pos;
    }
    final finishTopAngle = this.finishTopAngle * pi / 180;

    final topDirectSize = sqrt(pow(finishTopX - startTopX, 2) + pow(finishTopY - startTopY, 2)) / 3;
    final startTopDirectX = startTopX + topDirectSize * cos(startTopAngle);
    final startTopDirectY = startTopY - topDirectSize * sin(startTopAngle);
    final finishTopDirectX = finishTopX + topDirectSize * cos(finishTopAngle);
    final finishTopDirectY = finishTopY - topDirectSize * sin(finishTopAngle);

    final startBottomAngle = this.startBottomAngle * pi / 180;
    final startBottomX = this.zoom * this.radius * (1 + sin(startBottomAngle));
    final startBottomY = this.zoom * (this.offset + this.radius * (1 + cos(startBottomAngle)));

    double finishBottomX;
    double finishBottomY;
    if (this.finishBottomPos < 0) {
      final finishBottomPos = -this.finishBottomPos * pi / 180;
      finishBottomX = circleX - this.zoom * boxRadius * sin(finishBottomPos);
      finishBottomY = circleY - this.zoom * boxRadius * cos(finishBottomPos);
    } else {
      var pos = this.finishBottomPos + this.offset;
      if (pos < 0) pos = 0;
      finishBottomX =
          pos < boxRadius ? circleX - this.zoom * boxRadius * sin(acos(1 - pos / boxRadius)) : this.zoom * this.size;
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

      canvas.drawCircle(Offset(circleX, circleY), circleR, paint);
      canvas.drawLine(Offset(circleX, circleY - circleR), Offset(circleX, circleY + circleR), paint);
      canvas.drawLine(Offset(circleX - circleR, circleY), Offset(circleX + circleR, circleY), paint);

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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
