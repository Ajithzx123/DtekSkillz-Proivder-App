import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class CustomReadMoreTextContainer extends StatelessWidget {
  final String text;
  final int? trimLines;
  final TextStyle? textStyle;
  final Color? readLessColor;
  final Color? readMoreColor;

  const CustomReadMoreTextContainer(
      {super.key,
      required this.text,
      this.trimLines,
      this.textStyle,
      this.readLessColor,
      this.readMoreColor,});

  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      text,
      trimLines: trimLines ?? 3,
      trimMode: TrimMode.Line,
      style: textStyle,
      trimCollapsedText: "showMore".translate(context: context),
      trimExpandedText: "showLess".translate(context: context),
      lessStyle: TextStyle(
        color:readLessColor ?? Theme.of(context).colorScheme.blackColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      moreStyle: TextStyle(
        color: readMoreColor ?? Theme.of(context).colorScheme.blackColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),

    );
  }
}
