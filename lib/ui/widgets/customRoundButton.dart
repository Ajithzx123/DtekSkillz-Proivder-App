import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CustomRoundedButton extends StatelessWidget {

  const CustomRoundedButton({
    super.key,
    required this.widthPercentage,
    required this.backgroundColor,
    this.child,
    this.maxLines,
    this.borderColor,
    this.elevation,
    required this.buttonTitle,
    this.onTap,
    this.radius,
    this.shadowColor,
    required this.showBorder,
    this.height,
    this.width,
    this.titleColor,
    this.fontWeight,
    this.textSize,
  });
  final String? buttonTitle;
  final double? height;
  final double? width;

  ///widthPercentage will apply if the value of width is null
  final double widthPercentage;
  final Function? onTap;
  final Color backgroundColor;
  final double? radius;
  final Color? shadowColor;
  final bool showBorder;
  final Color? borderColor;
  final Color? titleColor;
  final double? textSize;
  final FontWeight? fontWeight;
  final double? elevation;
  final int? maxLines;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Material(
      shadowColor: shadowColor ?? Colors.black54,
      elevation: elevation ?? 0.0,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius ?? 10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius ?? 10.0),
        onTap: onTap as void Function()?,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          //
          alignment: Alignment.center,
          height: height ?? 48.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 10.0),
            border: showBorder
                ? Border.all(
                    color: borderColor ?? Theme.of(context).scaffoldBackgroundColor,
                  )
                : null,
          ),
          width: width ?? MediaQuery.sizeOf(context).width * widthPercentage,
          child: child ??
              Text(
                '$buttonTitle',
                maxLines: maxLines ?? 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: textSize ?? 18.0,
                    color: titleColor ?? AppColors.whiteColors,
                    fontWeight: fontWeight ?? FontWeight.normal,),
              ),
        ),
      ),
    );
  }
}
