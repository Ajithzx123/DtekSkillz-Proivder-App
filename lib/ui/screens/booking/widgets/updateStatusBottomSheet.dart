import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class UpdateStatusBottomSheet extends StatefulWidget {

  const UpdateStatusBottomSheet({super.key, required this.selectedItem, required this.itemValues});
  final Map<String, String> selectedItem;
  final List<Map<String, String>> itemValues;

  @override
  State<UpdateStatusBottomSheet> createState() => _UpdateStatusBottomSheetState();
}

class _UpdateStatusBottomSheetState extends State<UpdateStatusBottomSheet> {
  late Map<String, String> selectedStatus = widget.selectedItem;

  Widget getFilterOption({
    required Map<String, String> filterOptionName,
  }) {
    return InkWell(
      onTap: () {
        selectedStatus = filterOptionName;
        setState(() {});
        Navigator.pop(context, {'selectedStatus': selectedStatus});
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(filterOptionName['title'].toString().translate(context: context),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.blackColor,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0,),
                textAlign: TextAlign.start,),
            const Spacer(),
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                  color: selectedStatus['value'] == filterOptionName['value']
                      ? Theme.of(context).colorScheme.blackColor
                      : Colors.transparent,
                  border:
                      Border.all(width: 0.5, color: Theme.of(context).colorScheme.lightGreyColor),
                  shape: BoxShape.circle,),
              child: selectedStatus['value'] == filterOptionName['value']
                  ? Icon(
                      size: 18,
                      Icons.done_rounded,
                      color: Theme.of(context).colorScheme.secondaryColor,
                    )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(UiUtils.bottomSheetTopRadius),
              topRight: Radius.circular(UiUtils.bottomSheetTopRadius),),),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: MediaQuery.sizeOf(context).width,
            height: 50,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(UiUtils.bottomSheetTopRadius),
                    topRight: Radius.circular(UiUtils.bottomSheetTopRadius),),),
            child: Center(
              child: CustomText(
                titleText: 'statusLbl'.translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontColor: Theme.of(context).colorScheme.blackColor,
              ),
            ),
          ),
          for (int i = 0; i < widget.itemValues.length; i++) ...[
            getFilterOption(filterOptionName: widget.itemValues[i]),
          ]
        ],
      ),
    );
  }
}
