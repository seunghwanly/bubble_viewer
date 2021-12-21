import 'package:flutter/material.dart';

class FloatingChat {
  final String name;
  double distance;
  double radius;
  final bool hasUpdate;

  /// `backgroundImageURL` or `backgroundColor` cannot be both null
  final String? backgroundImageURL;
  final Color? backgroundColor;

  LinearGradient? surroundingColor;
  double? top;
  double? left;

  FloatingChat({
    required this.name,
    required this.distance,
    required this.radius,
    required this.hasUpdate,
    this.backgroundImageURL,
    this.backgroundColor,
    this.surroundingColor,
    required this.top,
    required this.left,
  }) : assert(backgroundImageURL == null && backgroundColor == null) {
    surroundingColor ??= LinearGradient(
      colors: [
        HSLColor.fromColor(const Color(0xFFBFE299)).withSaturation(1).toColor(),
        const Color(0xFF66B5F6),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  /// returns `Container` with set color
  Widget get getFloatingCircle => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: const Color(0xFF000000).withOpacity(0.15),
              spreadRadius: 1,
            )
          ],
          gradient: hasUpdate ? surroundingColor : null,
        ),
        padding: EdgeInsets.all(radius * 0.2),
        child: CircleAvatar(
          radius: radius,
          backgroundImage: backgroundImageURL != null
              ? NetworkImage(backgroundImageURL!)
              : null,
          backgroundColor: backgroundImageURL == null && backgroundColor != null
              ? backgroundColor
              : Colors.white,
        ),
      );

  set updateRadius(double rad) => radius = rad;
  set updateDistance(double dist) => distance = dist;
}
