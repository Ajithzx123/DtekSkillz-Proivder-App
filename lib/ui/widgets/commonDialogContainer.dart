import 'package:edemand_partner/app/generalImports.dart';
import 'package:flutter/material.dart';

class CommonDialogContainer extends StatelessWidget {
  final Icon? dialogIcon;
  final String dialogTitle;
  final String dialogSubTitle;
  final String cancelButtonName;
  final String confirmButtonName;
  final Function? onConfirmButtonPressed;
  final Function? onCancelButtonPressed;

  const CommonDialogContainer(
      {final Key? key,
      this.dialogIcon,
      required this.dialogTitle,
      required this.dialogSubTitle,
      this.onConfirmButtonPressed,
      this.onCancelButtonPressed,
      required this.cancelButtonName,
      required this.confirmButtonName})
      : super(key: key);

  @override
  Widget build(final BuildContext context) => Container(
        height: MediaQuery.sizeOf(context).height * 0.3,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.3 - 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (dialogIcon != null) dialogIcon!,
                  //Icon(Icons.info, color: Theme.of(context).colorScheme.accentColor, size: 70),
                  Text(
                    dialogTitle.translate(context: context),
                    // 'loginRequired'.translate(context: context),
                    style: TextStyle(color: Theme.of(context).colorScheme.blackColor, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dialogSubTitle.translate(context: context),
                    //  'pleaseLogin'.translate(context: context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightGreyColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          onCancelButtonPressed?.call();
                        },
                        // onTap: () {
                        //   Navigator.of(context).pop();
                        // },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1c343f53),
                                offset: Offset(0, -3),
                                blurRadius: 10,
                              )
                            ],
                            color: Theme.of(context).colorScheme.secondaryColor,
                          ),
                          child: Center(
                            child: Text(
                              cancelButtonName.translate(context: context),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.blackColor,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          onConfirmButtonPressed?.call();
                        },
                        // onTap: () {
                        //   Navigator.pop(context);
                        //   Navigator.pushNamed(context, loginRoute, arguments: {'source': 'dialog'});
                        // },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1c343f53),
                                offset: Offset(0, -3),
                                blurRadius: 10,
                              )
                            ],
                            color: Theme.of(context).colorScheme.accentColor,
                          ),
                          child: Center(
                            child: Text(
                              confirmButtonName.translate(context: context),
                              style: TextStyle(
                                color: AppColors.whiteColors,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
}
