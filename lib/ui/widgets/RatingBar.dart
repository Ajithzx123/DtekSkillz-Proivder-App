import 'package:flutter/material.dart';

typedef RatingCallback = void Function(double rating);

class RatingBar extends StatefulWidget {
  const RatingBar({
    super.key,
    this.maxRating = 5,
    required this.onRatingChanged,
    required this.filledIcon,
    required this.emptyIcon,
    required this.halfFilledIcon,
    this.isHalfAllowed = false,
    this.aligns = Alignment.centerLeft,
    this.initialRating = 0.0,
    required this.filledColor,
    this.emptyColor = Colors.grey,
    required this.halfFilledColor,
    this.size = 40,
  })  : _readOnly = false;

  const RatingBar.readOnly({
    super.key,
    this.maxRating = 5,
    required this.filledIcon,
    required this.emptyIcon,
    required this.halfFilledIcon,
    this.isHalfAllowed = false,
    this.aligns = Alignment.centerLeft,
    this.initialRating = 0.0,
    required this.filledColor,
    this.emptyColor = Colors.amber,
    required this.halfFilledColor,
    this.size = 25,
    required this.onRatingChanged,
  })  : _readOnly = true;

  final int maxRating;
  final IconData filledIcon;
  final IconData emptyIcon;
  final IconData halfFilledIcon;
  final RatingCallback onRatingChanged;
  final double initialRating;
  final Color filledColor;
  final Color emptyColor;
  final Color halfFilledColor;
  final double size;
  final bool isHalfAllowed;
  final Alignment aligns;
  final bool _readOnly;

  @override
  _RatingBarState createState() {
    return _RatingBarState();
  }
}

class _RatingBarState extends State<RatingBar> {
  late double _currentRating;
  late Alignment _algins;
  @override
  void initState() {
    super.initState();
    _algins = widget.aligns;
    if (widget.isHalfAllowed) {
      _currentRating = widget.initialRating;
    } else {
      _currentRating = widget.initialRating.roundToDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _algins,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.maxRating, (int index) {
          return Builder(
            builder: (BuildContext rowContext) => widget._readOnly
                ? buildIcon(context, index + 1)
                : buildStar(rowContext, index + 1),
          );
        }),
      ),
    );
  }

  Widget buildIcon(BuildContext context, int position) {
    IconData iconData;
    Color color;
    double rating;
    if (widget._readOnly) {
      if (widget.isHalfAllowed) {
        rating = widget.initialRating;
      } else {
        rating = widget.initialRating.roundToDouble();
      }
    } else {
      rating = _currentRating;
    }
    if (position > rating + 0.5) {
      iconData = widget.emptyIcon;
      color = widget.emptyColor;
    } else if (position == rating + 0.5) {
      iconData = widget.halfFilledIcon;
      color = widget.halfFilledColor;
    } else {
      iconData = widget.filledIcon;
      color = widget.filledColor;
    }
    return Icon(iconData, color: color, size: widget.size);
  }

  Widget buildStar(BuildContext context, int position) {
    return GestureDetector(
      child: buildIcon(context, position),
      onTap: () {
        setState(() => _currentRating = position.toDouble());
        widget.onRatingChanged(_currentRating);
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
        double rating = localPosition.dx / widget.size;

        if (rating < 0) {
          rating = 0;
        } else if (rating > widget.maxRating) {
          rating = widget.maxRating.toDouble();
        } else {
          rating = widget.isHalfAllowed
              ? (2 * rating).ceilToDouble() / 2
              : rating.ceilToDouble();
        }
        if (_currentRating != rating) {
          setState(() => _currentRating = rating);
          widget.onRatingChanged(_currentRating);
        }
      },
    );
  }
}
