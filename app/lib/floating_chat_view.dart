import 'dart:developer' as d;
import 'dart:math';

import 'package:app/floating_chat.dart';
import 'package:flutter/material.dart';

class FloatingChatView extends StatefulWidget {
  /// constructor
  const FloatingChatView({
    Key? key,
    required this.globalKey,
    required this.chatRooms,
    required this.centerChatBubble,
    required this.maxHeight,
    required this.maxWidth,
    this.surroundingColor,
  }) : super(key: key);

  /// variables
  final GlobalKey globalKey;
  final List<FloatingChat> chatRooms; // chat rooms to be placed
  final LinearGradient?
      surroundingColor; // when new chat arrives, the color will be surrounded
  final FloatingChat centerChatBubble; // main user's bubble
  // final double centerChatBubbleRadius; // main user's radius
  final double maxHeight;
  final double maxWidth;

  @override
  _FloatingChatViewState createState() => _FloatingChatViewState();
}

class _FloatingChatViewState extends State<FloatingChatView> {
  // ignore: non_constant_identifier_names
  static double PI = 3.141592653589793238;

  double degreeToRadian(double degree) {
    return degree * PI / 180;
  }

  double radianToDegree(double radian) {
    return radian * 180 / PI;
  }

  /// TODO distance should be updated within screen
  /// check whether chat room is inside the screen
  bool _isInsideScreen(
    double dist,
    double radius,
    double maxWidth,
    double maxHeight,
  ) =>
      dist < (min(maxWidth, maxHeight) - radius * 2 - 40);

  /// find out if the two circles meet together
  /// returns `true` when collides
  bool _hasCollided(double r1, double r2, double d) => (
      // meets at 2 points
      ((r1 - r2).abs() < d && d < r1 + r2) ||
          // meets at only 1 point
          (r1 + r2 == d) || // outer circle
          ((r1 - r2).abs() == d) || // inner circle
          // doesn't meet but is inside the bigger circle
          (d < (r1 - r2).abs()));

  // TODO change into functional programming style
  /// place chat rooms
  List<FloatingChat> setPositions() {
    d.log("chatRooms length : ${widget.chatRooms.length}");
    d.log("the window size : ${widget.maxWidth} * ${widget.maxHeight}");
    List<FloatingChat> result = [];

    /// set mid
    double midWidth = widget.maxWidth / 2;
    double midHeight = widget.maxHeight / 2;

    /// 1) sort by distance
    for (FloatingChat c in widget.chatRooms) {
      result.add(c);
    }

    /// needs additional task for distance
    /// * get the min and max distance from `widget.chatRooms`
    /// then convert into ratios
    result.sort((c1, c2) => c1.distance.compareTo(c2.distance));
    d.log("candidates set : ${result.map((e) => e.name)}");

    /// to set circles in regularly
    int flag = 0;

    /// 2) place the closest chat room first and try N-times
    for (int i = 0; i < result.length; ++i) {
      bool hasPlaced = false;
      FloatingChat fChat = result[i];
      int tried = 0; // try 360 / 5 = 72 times
      /// check the distance first
      if (!_isInsideScreen(
        fChat.distance,
        fChat.radius,
        midWidth,
        midHeight,
      )) continue;

      double radian = 0;
      while (tried < 72) {
        // bool isNotDuplicated = false;

        /// try different radian
        int maxDegree = 360;
        int minDegree = 0;
        switch (flag % 4) {
          case 0:
            maxDegree = 90;
            break;
          case 1:
            maxDegree = 180;
            minDegree = 90;
            break;
          case 2:
            maxDegree = 270;
            minDegree = 180;
            break;
          case 3:
            maxDegree = 360;
            minDegree = 270;
            break;
          default:
            break;
        }
        radian = degreeToRadian(
            (Random().nextInt((maxDegree + 1) - minDegree) + minDegree) ~/
                10 *
                10);

        /// calculate top(Y) and left(X), also distance from center
        /// since it needs to be painted, the sign should be opposite
        double canvasSinTheta = (-1) * sin(radian);
        double canvasCosTheta = (-1) * cos(radian);
        const double K = 1.05;
        double canvasDistance = (midWidth ~/ result.length) * (i + 1) * K;

        /// get canvas position
        double newTop = midHeight + canvasDistance * canvasSinTheta;
        double newLeft = midWidth + canvasDistance * canvasCosTheta;

        /// check if new Circle collides with other circles
        bool hasCollidedWithOthers = false;
        for (FloatingChat pChat in result) {
          /// check only different circles
          if (fChat.hashCode != pChat.hashCode) {
            if (pChat.top != null && pChat.left != null) {
              /// calculate distances from each circle
              double distanceFromPlacedCircle = sqrt(
                  pow(pChat.top! - newTop, 2) + pow(pChat.left! - newLeft, 2));
              double distancefromCenter =
                  sqrt(pow(newTop - midHeight, 2) + pow(newLeft - midWidth, 2));

              /// check if it has collided
              if (_hasCollided(
                      pChat.radius, fChat.radius, distanceFromPlacedCircle) ||
                  _hasCollided(widget.centerChatBubble.radius, pChat.radius,
                      distancefromCenter)) {
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
          flag += 1;
          break;
        }
        d.log("fChat has collided : ${fChat.name}");

        /// count up and try different radius
        tried += 1;
      } //while

      if (!hasPlaced) {
        /// the circle has not been set yet
        /// let's try different radius again
        fChat.updateDistance = fChat.distance * 1.05;
        i -= 1;
      } else {
        d.log(
            "${fChat.name} has positioned at : (${cos(radian)}, ${sin(radian)}) > flag : $flag & radian : ${radianToDegree(radian)}");
        // d.log("set circle : ${fChat.name}");
      }
    }

    return result;
  }

  late final List<FloatingChat> setChatRooms;

  @override
  void initState() {
    setChatRooms = setPositions();

    super.initState();
  }

  /// rendered view
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: InteractiveViewer(
            minScale: 0.1,
            child: Stack(
              children: [
                /// other chat rooms
                Stack(
                  children: setChatRooms
                      .map(
                        (item) => Positioned(
                          top: item.top,
                          left: item.left,
                          child: InkWell(
                              onTap: () {
                                /// in default, show chatting room
                                showBottomSheet(
                                    context: context,
                                    builder: (_) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(item.name),
                                            Text("Y : " +
                                                item.top.toString() +
                                                "\n" +
                                                "X : " +
                                                item.left.toString() +
                                                "\ndistance : ${item.distance}"),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: item.getFloatingCircle),
                        ),
                      )
                      .toList(),
                ),

                /// center user
                Align(
                  alignment: Alignment.center,
                  child: widget.centerChatBubble
                      .getCenterCircle()
                      .getFloatingCircle,
                ),
              ],
            )),
      ),
    );
  }
}
