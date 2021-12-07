import 'dart:math';

import 'package:app/floating_chat.dart';
import 'package:flutter/material.dart';

class FloatingChatView extends StatelessWidget {
  /// variables
  final List<FloatingChat> chatRooms; // chat rooms to be placed
  final LinearGradient?
      surroundingColor; // when new chat arrives, the color will be surrounded
  final FloatingChat centerChatBubble; // main user's bubble
  final double centerChatBubbleRadius; // main user's radius

  /// constructor
  const FloatingChatView({
    Key? key,
    required this.chatRooms,
    required this.centerChatBubble,
    this.surroundingColor,
    required this.centerChatBubbleRadius,
  }) : super(key: key);

  /// check whether chat room is inside the screen
  bool _isInsideScreen(double dist, double maxWidth, double maxHeight) =>
      dist <= min(maxWidth, maxHeight);

  /// find out if the two circles meet together
  bool _hasCollided(double r1, double r2, double d) =>
      !(r1 + r1 < d) ||
      ((max(r1, r2) - min(r1, r2) < d) && (d < r1 + r2)) ||
      (max(r1, r2) - min(r1, r2) == d) ||
      (max(r1, r2) - min(r1, r2) > d);

  /// place chat rooms
  List<FloatingChat> setPositions({
    required double maxHeight,
    required double maxWidth,
  }) {
    List<FloatingChat> result = [];

    /// set mid
    double midWidth = maxWidth / 2;
    double midHeight = maxHeight / 2;

    /// 1) sort by distance
    for (FloatingChat c in chatRooms) {
      result.add(c);
    }
    result.sort((c1, c2) => c1.distance.compareTo(c2.distance));

    /// 2) place the closest chat room first and try N-times
    for (int i = 0; i < result.length; ++i) {
      bool hasPlaced = false;
      FloatingChat fChat = result[i];
      int tried = 0; // try 360 / 5 = 72 times
      /// check the distance first
      if (!_isInsideScreen(fChat.distance, maxWidth, maxHeight)) continue;
      List<int> haveTried = [];
      int radian = 0;
      while (tried < 72) {
        /// try different radian
        do {
          radian = Random().nextInt(360);
        } while (!haveTried.contains(radian));

        /// calculate top(Y) and left(X), also distance from center
        double newTop = midHeight + fChat.distance * sin(radian);
        double newLeft = midWidth + fChat.distance * cos(radian);
        double distancefromCenter =
            sqrt(pow(newTop - midHeight, 2) + pow(newLeft - midWidth, 2));

        /// check if newCircle collides with center circle
        /// if it collides then update the distance a bit longer
        while (_hasCollided(
            fChat.radius, centerChatBubbleRadius, distancefromCenter)) {
          fChat.updateDistance = fChat.distance * 1.15;
        }

        /// check if new Circle collides with other circles
        bool hasCollidedWithOthers = false;
        for (FloatingChat pChat in result) {
          /// check only different circles
          if (fChat.hashCode != pChat.hashCode) {
            if (pChat.top != null && pChat.left != null) {
              double distanceFromPlacedCircle = sqrt(
                  pow(pChat.top! - newTop, 2) + pow(pChat.left! - newLeft, 2));
              if (_hasCollided(
                  pChat.radius, fChat.radius, distanceFromPlacedCircle)) {
                /// has collided with other placed circle, need to re-try
                hasCollidedWithOthers = true;
                break;
              }
            } // if

            /// others not set yet
            break;
          } // if
        } // for
        if (!hasCollidedWithOthers) {
          /// set results, save it
          fChat.top = newTop;
          fChat.left = newLeft;
          hasPlaced = true;
          break;
        }

        /// count up and try different radius
        tried += 1;
      } //while

      if (!hasPlaced) {
        /// the circle has not been set yet
        /// let's try different radius again
        // fChat.updateDistance = fChat.distance * 1.2;
        // i -= 1;
      }
    }

    return result;
  }

  /// rendered view
  @override
  Widget build(BuildContext context) {
    /// get width and height
    final maxHeight = MediaQuery.of(context).size.height;
    final maxWidth = MediaQuery.of(context).size.width;

    return InteractiveViewer(
        minScale: 0.1,
        child: Stack(
          children: [
            /// other chat rooms
            Stack(
              children: setPositions(maxHeight: maxHeight, maxWidth: maxWidth)
                  .map(
                    (item) => Positioned(
                      top: item.top,
                      left: item.left,
                      child: item.getFloatingCircle,
                    ),
                  )
                  .toList(),
            ),

            /// center user
            Align(
              alignment: Alignment.center,
              child: centerChatBubble.getFloatingCircle,
            )
          ],
        ));
  }
}
