// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CustomShimmerContainer extends StatelessWidget {
  const CustomShimmerContainer({super.key, this.height, this.width, this.borderRadius, this.margin});
  final double? height;
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      height: height ?? 10,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.shimmerContentColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 10),),
    );
  }
}
