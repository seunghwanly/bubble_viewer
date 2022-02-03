import 'dart:math';
import 'dart:collection';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// `BubbleInformation` class is pre-step
/// for the creating offset of the `Bubble` class
///
/// all of the properties are `required` data
///
/// `distance` is for prefered distance from the center
/// which will have effect on the `Offset` of `Bubble`s
///
/// `size` is for the radius of the `CircleAvatar`
/// which will be rendered from class of `Bubble`
///
/// if you want to put image into the bubbles,
/// then give `imageURL` or `imageBinary` information
/// these properties would be set into optional
class BubbleInformation {
  /// required data
  final double distance;
  final double size;

  /// optional data
  final String? imageURL;
  final Uint8List? imageBinary;

  int? updates;

  BubbleInformation({
    required this.distance,
    required this.size,
    this.imageBinary,
    this.imageURL,
    this.updates,
  });
}

/// `Bubble` class is for the component
/// which will be rendered inside of `BubbleViewer`
///
/// this class would not be able to manipulate outside
/// since it is set to private
///
/// `offset` is needed for `Positioned.fromRect`
/// and this property will be set at `setBubbles` method which is method of `BubbleViewer`
///
/// `radius` would be passed from `BubbleInformation` class
///
/// other properties will be decided on `BubbleViewer`
class _Bubble {
  /// required properties
  Offset offset;
  final double radius; // radius occupies the whole width

  /// selected options
  Color? backgroundColor;
  LinearGradient? linearGradient;
  String? defaultImageURL;
  String? imageURL;
  Uint8List? imageBinary;
  Color? badgeColor;
  int? updates;
  VoidCallback? onClick;

  /// if `imageURL` is not `null` then `imageBinary` must be `null`
  _Bubble(
    this.offset,
    this.radius, {
    this.backgroundColor,
    this.linearGradient,
    this.imageURL,
    this.imageBinary,
    this.badgeColor,
    this.updates,
    this.onClick,
  }) : assert((imageURL != null && imageBinary == null) ||
            (imageURL == null && imageBinary != null) ||
            (imageURL == null && imageBinary == null)) {
    /// set up optional values
    backgroundColor ??= const Color(0xff833ab4).withOpacity(0.5);
    defaultImageURL ??= 'https://picsum.photos/seed/picsum/200/300';
    badgeColor ??= const Color(0xfffd1d1d);
    linearGradient ??= const LinearGradient(
      colors: [
        Color(0xff833ab4),
        Color(0xfffd1d1d),
        Color(0xfffcb045),
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
  }

  /// methods
  /// get Postioned Widget
  Widget positionedFromRect(Widget child) => Positioned.fromRect(
        rect: Rect.fromCenter(
          center: offset,
          width: radius,
          height: radius,
        ),
        child: InkWell(
          onTap: onClick,
          child: child,
        ),
      );

  /// basic bubble
  Widget get bubble => positionedFromRect(
        CircleAvatar(
          backgroundColor: backgroundColor,
          radius: radius,
        ),
      );

  /// has updates on its bubble - linear gradient
  Widget linearGradientBoundary(Widget child) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: linearGradient,
        ),
        padding: const EdgeInsets.all(4.0),
        child: child,
      );

  /// has updates on its bubble - badges
  Widget badgeBoundary(Widget child) => SizedBox(
        width: radius + 10,
        height: radius + 10,
        child: Stack(
          children: [
            child,
            Positioned(
              top: 0,
              right: 0,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: badgeColor,
                child: Text(
                  '${updates!}',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      );

  Widget get bubbleWithBadge => positionedFromRect(
        badgeBoundary(
          CircleAvatar(
            backgroundColor: backgroundColor,
            radius: radius,
          ),
        ),
      );
  Widget get bubbleWithGradient => positionedFromRect(
        linearGradientBoundary(
          CircleAvatar(
            backgroundColor: backgroundColor,
            radius: radius,
          ),
        ),
      );

  /// with network image on the background
  Widget get networkImageBubble => positionedFromRect(
        CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
            imageURL ?? defaultImageURL!,
          ),
          radius: radius,
        ),
      );

  Widget get networkImageBubbleWithBadge => updates != null
      ? positionedFromRect(
          badgeBoundary(
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                imageURL ?? defaultImageURL!,
              ),
              radius: radius,
            ),
          ),
        )
      : networkImageBubble;

  Widget get networkImageBubbleWithGradient => updates != null
      ? positionedFromRect(
          linearGradientBoundary(
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                imageURL ?? defaultImageURL!,
              ),
              radius: radius,
            ),
          ),
        )
      : networkImageBubble;

  /// with file image on the background
  Widget get binaryImageBubble => positionedFromRect(
        imageBinary != null
            ? CircleAvatar(
                backgroundImage: Image.memory(imageBinary!).image,
                radius: radius,
              )
            : CircleAvatar(
                backgroundColor: Colors.grey[400],
                radius: radius,
                child: const Text(
                  '☹️',
                  style: TextStyle(fontSize: 20),
                ),
              ),
      );

  Widget get binaryImageBubbleWithBadge => updates != null
      ? positionedFromRect(
          badgeBoundary(
            imageBinary != null
                ? CircleAvatar(
                    backgroundImage: Image.memory(imageBinary!).image,
                    radius: radius,
                  )
                : CircleAvatar(
                    backgroundColor: Colors.grey[400],
                    radius: radius,
                    child: const Text(
                      '☹️',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
          ),
        )
      : binaryImageBubble;

  Widget get binaryImageBubbleWithGradient => updates != null
      ? positionedFromRect(
          linearGradientBoundary(
            imageBinary != null
                ? CircleAvatar(
                    backgroundImage: Image.memory(imageBinary!).image,
                    radius: radius,
                  )
                : CircleAvatar(
                    backgroundColor: Colors.grey[400],
                    radius: radius,
                    child: const Text(
                      '☹️',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
          ),
        )
      : binaryImageBubble;

  /// deep copy
  factory _Bubble.clone(_Bubble bubble) => _Bubble(
        bubble.offset,
        bubble.radius,
      );
}

/// `BubbleViewer` class extends `StatefulWidget`
/// so that loading process seems more powerful
///
/// can set up center bubble with image or colors
/// just set `centerImageURL` or `centerImageBinary` for image
/// and remember not to give values to both property
/// if you willing to use image, then just pass one value
/// `centerImageURL` and `centerImageBinary` cannot be both not null
///
/// `windowSize` can be passed by using `MediaQuery.of(content).size` to use in easy way
///
/// also if the surrounding bubbles has sth to update,
/// give `BubbleViewer` information of what to use!
///
/// same as image for center bubble, you can select either badge or gradient
/// `useBadge` and `useGradient` cannot be both `true`
class BubbleViewer extends StatefulWidget {
  /// for center bubble
  final String? centerImageURL;
  final Uint8List? centerImageBinary;
  final double centerBubbleRadius;

  /// for surroundings
  final List<BubbleInformation> bubbles;
  final Color? backgroundColor;
  final Size windowSize;
  final bool? useBadge;
  final bool? useGradient;

  /// for events
  final VoidCallback? onPressed;
  final VoidCallback? onCenterPressed;

  /// if `imageURL` is not `null` then `imageBinary` must be `null`
  const BubbleViewer({
    Key? key,
    this.centerImageURL,
    this.centerImageBinary,
    required this.centerBubbleRadius,
    required this.bubbles,
    required this.windowSize,
    this.backgroundColor,
    this.useBadge,
    this.useGradient,
    this.onPressed,
    this.onCenterPressed,
  })  : assert(
          /// check `imageURL` and `imageBinary`
          (centerImageBinary != null && centerImageURL == null) ||
              (centerImageBinary == null && centerImageURL != null) ||
              (centerImageURL == null && centerImageBinary == null) ||

              /// check `badge` and `gradient`)
              (useBadge != null && useGradient == null) ||
              (useBadge == null && useGradient != null) ||
              (useBadge == null && useGradient == null),
        ),
        super(key: key);

  @override
  State<BubbleViewer> createState() => _BubbleViewerState();
}

class _BubbleViewerState extends State<BubbleViewer> {
  /// variables
  late List<_Bubble> bubbles;
  late Widget centerBubble;

  @override
  void initState() {
    super.initState();
    centerBubble = _centerBubble();
    bubbles = _setBubbles();
  }

  /// methods
  double _convertDegreeToRadian(int degree) => (pi / 180) * degree;

  double _getDistance(_Bubble c1, _Bubble c2) =>
      sqrt(pow((c1.offset.dy - c2.offset.dy), 2) +
          pow((c1.offset.dx - c2.offset.dx), 2));

  bool _isInside(_Bubble c1, _Bubble c2) {
    /// pretend `c1` is large circle
    if (c1.radius < c2.radius) {
      /// make deep copy
      _Bubble temp = _Bubble.clone(c1);
      c1 = _Bubble.clone(c2);
      c2 = _Bubble.clone(temp);
    }

    return pow((c1.offset.dx - c2.offset.dx), 2) +
            pow((c1.offset.dy - c2.offset.dy), 2) <=
        pow(c1.radius, 2);
  }

  bool _hasOverlapped(_Bubble c1, _Bubble c2) {
    final d = _getDistance(c1, c2);
    if (c1.radius / 2 + c2.radius / 2 < d) {
      return false; // no overlap
    }

    /// inner conditions
    if (d == 0 || (c1.radius / 2 - c2.radius / 2).abs() > d) {
      /// the small circle is inside the large one
      /// check if small circle is inside the large one
      if (_isInside(c1, c2)) {
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

  /// setCircles based on input data
  List<_Bubble> _setBubbles() {
    /// retreive size
    final width = widget.windowSize.width;
    final height = widget.windowSize.height;

    /// middle Offset(dx,dy)
    final cx = width / 2;
    final cy = height / 2;

    /// the value that will be returned
    final centerBubble = _Bubble(Offset(cx, cy), widget.centerBubbleRadius);
    ListQueue<_Bubble> result = ListQueue.from([centerBubble]);

    /// to place bubbles regularly
    int dg = 5; // derivative of gap
    int flag = 0; // to place each quadrant

    /// loop only input data's length
    for (int i = 0; i < widget.bubbles.length; ++i) {
      // given little bit of margin (5 pixel)
      final d = (widget.centerBubbleRadius / 2 +
          dg +
          widget.bubbles[i].size / 2 +
          widget.bubbles[i].distance);

      late int minDegree, maxDegree;

      switch (flag % 4) {
        case 0: // quadrant 1
          minDegree = 0;
          maxDegree = 90;
          break;
        case 1: // quadrant 2
          minDegree = 90;
          maxDegree = 180;
          break;
        case 2: // quadrant 3
          minDegree = 180;
          maxDegree = 270;
          break;
        case 3: // quadrant 4
          minDegree = 270;
          maxDegree = 360;
          break;
        default:
      }

      final int degree = minDegree + Random().nextInt(maxDegree - minDegree);
      final double radian = _convertDegreeToRadian(degree);

      /// create Offset for new bubble !
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

      final _Bubble newBubble = _Bubble(
        newOffset,
        widget.bubbles[i].size,

        /// optional data
        imageBinary: widget.bubbles[i].imageBinary,
        imageURL: widget.bubbles[i].imageURL,
        backgroundColor: widget.backgroundColor,
        updates: widget.bubbles[i].updates,
        onClick: widget.onPressed,
      );

      /// check if it is fine to place
      bool isFineToPlace = true;
      for (int j = 0; j < result.length; ++j) {
        if (_hasOverlapped(result.elementAt(j), newBubble)) {
          isFineToPlace = false;
          break;
        }
      }

      /// check the placement result
      if (isFineToPlace) {
        result.addLast(newBubble);
        flag += 1;
        dg = 5;
      } else {
        dg += 5;
        i -= 1;
      }
    }

    /// remove center bubble, which is on the first element
    result.removeFirst();

    return result.toList();
  }

  Widget _centerBubble() => InkWell(
        onTap: widget.onCenterPressed,
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: widget.centerBubbleRadius - 10,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: CircleAvatar(
                  backgroundColor: (widget.centerImageURL != null ||
                          widget.centerImageBinary != null)
                      ? Colors.transparent
                      : Colors.purpleAccent,

                  /// check if the imageURL is not null or the binary Image file
                  backgroundImage: widget.centerImageURL != null
                      ? CachedNetworkImageProvider(widget.centerImageURL!)
                      : widget.centerImageBinary != null
                          ? Image.memory(widget.centerImageBinary!).image
                          : null,

                  radius: widget.centerBubbleRadius - 20,

                  /// if the imageURL or binary File has passed
                  /// then render blank box
                  child: widget.centerImageURL != null ||
                          widget.centerImageBinary != null
                      ? const SizedBox()
                      : const Text(
                          '🤩',
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
        ),
      );

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
        minScale: 0.1,
        child: Stack(
          children: bubbles
              .map((b) =>

                      /// has updates
                      b.updates != null

                          /// use Badges
                          ? widget.useBadge != null && widget.useBadge!
                              ? b.imageURL != null && b.imageBinary == null

                                  /// use Badges-network
                                  ? b.networkImageBubbleWithBadge
                                  : b.imageURL == null && b.imageBinary != null

                                      /// use Badges-binary
                                      ? b.binaryImageBubbleWithBadge
                                      : b.bubbleWithBadge // use Badge-basic
                              /// use Gradient
                              : widget.useGradient != null &&
                                      widget.useGradient!
                                  ? b.imageURL != null && b.imageBinary == null

                                      /// use Gradient-network
                                      ? b.networkImageBubbleWithGradient
                                      : b.imageURL == null &&
                                              b.imageBinary != null

                                          /// use Gradient-binary
                                          ? b.binaryImageBubbleWithGradient
                                          : b.bubbleWithGradient // use basic
                                  : b.bubble

                          /// no updates
                          /// use network-image
                          : b.imageURL != null && b.imageBinary == null
                              ? b.networkImageBubble

                              /// use binary-image
                              : b.imageURL == null && b.imageBinary != null
                                  ? b.binaryImageBubble
                                  : b.bubble // use basic
                  )
              .toList()
            ..add(
              Positioned.fromRect(
                rect: Rect.fromCenter(
                  center: Offset(
                    widget.windowSize.width / 2,
                    widget.windowSize.height / 2,
                  ),
                  width: widget.centerBubbleRadius,
                  height: widget.centerBubbleRadius,
                ),
                child: centerBubble,
              ),
            ),
        ));
  }
}
