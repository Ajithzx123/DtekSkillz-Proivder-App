import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class AddFloatingButton extends StatelessWidget {

  const AddFloatingButton(
      {super.key, required this.routeNm, this.callWhenComeBack, this.buttonColor,});
  final String routeNm;
  final Color? buttonColor;
  final Function(dynamic value)? callWhenComeBack;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.accentColor,
      elevation: 0.0,
      child: Icon(
        Icons.add_rounded,
        size: 40,
        color: buttonColor ?? AppColors.whiteColors,
      ),
      onPressed: () {
        Navigator.of(context).pushNamed(routeNm).then((Object? value) {
          callWhenComeBack?.call(value);
        }); //Routes.createService
      }, //open Add service Screen
    );
  }
}
