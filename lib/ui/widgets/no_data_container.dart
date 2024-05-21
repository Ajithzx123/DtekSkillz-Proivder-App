import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class NoDataContainer extends StatelessWidget {

  const NoDataContainer({super.key, this.textColor, required this.titleKey});
  final Color? textColor;
  final String titleKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * (0.025),
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * (0.35),
            child: UiUtils.setSVGImage('no_data_found'),
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * (0.025),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              titleKey,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: textColor ?? Theme.of(context).colorScheme.blackColor, fontSize: 16,),
            ),
          ),
        ],
      ),
    );
  }
}
