import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CustomIconButton extends StatelessWidget {

  const CustomIconButton(
      {super.key,
      required this.imgName,
      required this.titleText,
      required this.fontSize,
      required this.titleColor,
      required this.bgColor,
      this.fontWeight = FontWeight.w200,
      this.borderColor,
      this.borderRadius = 10,
      this.textDirection = TextDirection.ltr,
      this.onPressed,
      this.iconColor,});
  final String imgName;
  final String titleText;
  final double fontSize;
  final FontWeight fontWeight;
  final Color titleColor;
  final Color bgColor;
  final Color? borderColor;
  final double borderRadius;
  final TextDirection textDirection;
  final VoidCallback? onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(0),
              padding:
                  MaterialStateProperty.all(const EdgeInsetsDirectional.only(start: 2, end: 2)),
              shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
                  side: BorderSide(color: borderColor ?? bgColor),
                  borderRadius: BorderRadius.circular(borderRadius),),),
              backgroundColor: MaterialStateProperty.all(bgColor),),
          icon: UiUtils.setSVGImage(imgName,
              imgColor: iconColor ?? Theme.of(context).colorScheme.primaryColor,),
          label: CustomText(
            titleText: titleText,
            fontColor: titleColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),),
    );
  }
}
