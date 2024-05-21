import 'package:flutter/material.dart';

///Container with circular corner radius & given Child
class CustomContainer extends StatelessWidget {
  const CustomContainer(
      {super.key,
      this.width,
      this.height,
      required this.cornerRadius,
      required this.bgColor,
      this.padding,
      this.margin,
      this.child,});
  final double? width;
  final double? height;
  final double cornerRadius;
  final Color bgColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(cornerRadius), color: bgColor),
        child: child,);
  }
}
