import 'dart:math';

import 'package:flutter/material.dart';

const double centerRadius = 100;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// render part
    return const MaterialApp(
      home: Scaffold(
        body: Test(),
      ),
    );
  }
}

class Circle {
  final double x;
  final double y;
  final double radius;

  Circle(this.x, this.y, this.radius);

  factory Circle.clone(Circle c) => Circle(c.x, c.y, c.radius);
}

/// global functions for test
double convertDegreeToRadian(int degree) => (pi / 180) * degree;

double getDistance(Circle c1, Circle c2) =>
    sqrt(pow((c1.y - c2.y), 2) + pow((c1.x - c2.x), 2));

bool isInside(Circle c1, Circle c2) {
  /// pretend `c1` is large circle
  if (c1.radius < c2.radius) {
    /// make deep copy
    Circle temp = Circle.clone(c1);
    c1 = Circle.clone(c2);
    c2 = Circle.clone(temp);
  }

  return pow((c1.x - c2.x), 2) + pow((c1.y - c2.y), 2) <= pow(c1.radius, 2);
}

bool hasOverlapped(Circle c1, Circle c2) {
  final d = getDistance(c1, c2);
  if (c1.radius / 2 + c2.radius / 2 < d) {
    return false; // no overlap
  }

  /// inner conditions
  if (d == 0 || (c1.radius / 2 - c2.radius / 2).abs() > d) {
    /// the small circle is inside the large one
    /// check if small circle is inside the large one
    if (isInside(c1, c2)) {
      return true; // overlaps with no matched points
    }

    /// or meets at 1 point
    return true;
  }

  /// meets at one point
  if (c1.radius / 2 + c2.radius / 2 == d ||
      (c1.radius / 2 - c2.radius / 2).abs() == d) {
    return true;
  }

  /// meets at 2 points
  if ((c1.radius / 2 - c2.radius / 2).abs() < d ||
      d < (c1.radius / 2 + c2.radius / 2)) {
    return true;
  }

  return false;
}

final List<double> dummyData = [60, 80, 100, 120, 160, 100, 80, 60, 100];

List<Circle> setCircles(Size size, List<double> data) {
  final width = size.width;
  final height = size.height;

  /// middle point
  final cx = width / 2;
  final cy = height / 2;

  /// the value that will be returned
  final centerCircle = Circle(cx, cy, centerRadius);
  List<Circle> result = [centerCircle];

  int dg = 10; // derivative of gap
  int flag = 0; // to place each quadrant

  /// loop just for data's length
  for (int i = 0; i < data.length; ++i) {
    final double d = (centerCircle.radius ~/ 2 + dg + (data[i] ~/ 2))
        .toDouble(); // center radius + derivative of gap + input data's radius

    late int minDegree;
    late int maxDegree;

    switch (flag % 4) {
      case 0:
        minDegree = 0;
        maxDegree = 90;
        break;
      case 1:
        minDegree = 90;
        maxDegree = 180;
        break;
      case 2:
        minDegree = 180;
        maxDegree = 270;
        break;
      case 3:
        minDegree = 270;
        maxDegree = 360;
        break;
      default:
        break;
    }

    /// set degree due to flag
    final int degree = minDegree + Random().nextInt(maxDegree - minDegree);
    final double radian = convertDegreeToRadian(degree);

    /// create new circle
    late Offset newOffset;

    final dx = d * cos(radian);
    final dy = d * sin(radian);

    if (0 <= radian && radian < 90) {
      newOffset = Offset(cx + dx, cy - dy);
    } else if (90 <= radian && radian < 180) {
      newOffset = Offset(cx - dx, cy - dy);
    } else if (180 <= radian && radian < 270) {
      newOffset = Offset(cx - dx, cy + dy);
    } else {
      newOffset = Offset(cx + dx, cy + dy);
    }

    final Circle newCircle = Circle(newOffset.dx, newOffset.dy, data[i]);

    bool isFineToPlace = true;
    for (int j = 0; j < result.length; ++j) {
      if (hasOverlapped(result[j], newCircle)) {
        isFineToPlace = false;
        break;
      }
    }

    /// check the result - hasOverlapped
    if (isFineToPlace) {
      result.add(newCircle);

      /// go onto next quadrant
      flag += 1;
      dg = 10;
    } else {
      dg += 5;
      i -= 1;
    }
  }

  // TODO: use queue
  return result..remove(centerCircle);
}

class Test extends StatelessWidget {
  const Test({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final List<Circle> components = setCircles(size, dummyData);

    return Stack(
      /// place bubbles here
      children: components
          .map(
            (c) => Positioned.fromRect(
              rect: Rect.fromCenter(
                center: Offset(c.x, c.y),
                width: c.radius,
                height: c.radius,
              ),
              child: bubble(c.radius, ''),
            ),
          )
          .toList()
        ..add(
          Positioned.fromRect(
            rect: Rect.fromCenter(
              center: Offset(size.width / 2, size.height / 2),
              width: 80,
              height: 80,
            ),
            child: centerBubble(),
          ),
        ),
    );
  }

  Widget centerBubble() => Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.pinkAccent,
              Colors.purpleAccent,
              Colors.deepPurpleAccent,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        // backgroundColor: Colors.orange,
        // radius: centerRadius,
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: centerRadius - 10,
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: CircleAvatar(
                backgroundColor: Colors.purpleAccent,
                radius: centerRadius - 20,
                child: Text(
                  'MY\n프로필',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );

  /// chat bubble
  Widget bubble(double radius, String content) => CircleAvatar(
        radius: radius,
        backgroundColor: [
          Colors.amber,
          Colors.blue,
          Colors.cyan,
          Colors.indigo,
          Colors.pink
        ].elementAt(Random().nextInt(5)).withOpacity(0.5),
        child: Text(
          content,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      );
}

class StrokePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  StrokePainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4;
    canvas.drawLine(start, end, stroke);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
