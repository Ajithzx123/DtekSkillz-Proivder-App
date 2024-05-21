import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class ShadowButton extends StatelessWidget {

  const ShadowButton(
      {super.key,
      this.width,
      this.height,
      this.backgroundColor,
      required this.text,
      this.fontColor,
      this.fontWeight,
      this.fontStyle,
      required this.onPressed,
      this.shadowOFF = false,
      this.borderRadius,
      this.fontSize,});
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final String text;
  final Color? fontColor;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final VoidCallback onPressed;
  final bool shadowOFF;
  final double? borderRadius;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onPressed,
        child: Container(
          width: width ?? MediaQuery.sizeOf(context).width - 40, //335,
          height: height ?? 56,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 16)),
              boxShadow: shadowOFF
                  ? null
                  : [
                      BoxShadow(
                          color: Theme.of(context).colorScheme.lightGreyColor,
                          offset: const Offset(0, 6), //8
                          blurRadius: 10,)
                    ],
              color: backgroundColor ?? Theme.of(context).colorScheme.lightGreyColor,),
          child: Center(
            child: Text(text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: fontColor ?? Theme.of(context).colorScheme.blackColor,
                    fontWeight: fontWeight ?? FontWeight.w400,
                    fontStyle: fontStyle ?? FontStyle.normal,
                    fontSize: fontSize,),
                textAlign: TextAlign.center,),
          ),
        ),);
  }
}
