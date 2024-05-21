import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

typedef RatingChangeCallback = void Function(double rating);

class StarRating extends StatelessWidget {

  const StarRating(
      {super.key, this.starCount = 5, this.rating = .0, required this.onRatingChanged,});
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = Icon(
        Icons.star,
        color: Theme.of(context).colorScheme.lightGreyColor,
      );
    } else if (index > rating - 1 && index < rating) {
      icon = const Icon(
        Icons.star_half,
        color: Color(0xfff9bd3d),
      );
    } else {
      icon = const Icon(
        Icons.star,
        color: Color(0xfff9bd3d),
      );
    }
    return InkResponse(
      onTap: () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(starCount, (int index) => buildStar(context, index)));
  }
}
