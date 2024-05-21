import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class PageNumberIndicator extends StatelessWidget {

  const PageNumberIndicator({
    super.key,
    required this.currentIndex,
    required this.total,
  });
  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    final String strValue =
        "${"stepLbl".translate(context: context)} $currentIndex ${"ofLbl".translate(context: context)} $total";
    return Container(
      padding: const EdgeInsetsDirectional.only(end: 10),
      alignment: Alignment.center,
      child: CustomText(
        titleText: strValue,
        fontSize: 14.0,
        fontColor: Theme.of(context).colorScheme.lightGreyColor,
      ),
    );
  }
}
