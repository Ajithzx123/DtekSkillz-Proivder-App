import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CustomText extends StatelessWidget {

  const CustomText(
      {super.key,
      required this.titleText,
      this.fontColor,
      this.showLineThrough = false,
      this.fontWeight = FontWeight.w200,
      this.fontStyle = FontStyle.normal,
      this.fontSize = 16.0,
      this.textAlign = TextAlign.start,
      this.maxLines,});
  final String titleText;
  final Color? fontColor;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final double fontSize;
  final TextAlign textAlign;
  final int? maxLines;
  final bool showLineThrough;

  @override
  Widget build(BuildContext context) {
    return Text(
      titleText,
      maxLines: maxLines,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          color: fontColor ?? Theme.of(context).colorScheme.lightGreyColor,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          fontSize: fontSize,
          letterSpacing: 0.5,
          decoration: showLineThrough ? TextDecoration.lineThrough : null,),
      textAlign: textAlign,
    );
  }
}
