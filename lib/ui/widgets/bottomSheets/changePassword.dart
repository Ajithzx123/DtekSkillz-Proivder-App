import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  @override
  State<ChangePasswordBottomSheet> createState() => _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  //
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //
  final TextEditingController _oldPasswordTextController = TextEditingController();
  final TextEditingController _newPasswordTextController = TextEditingController();
  final TextEditingController _confirmNewPasswordTextController = TextEditingController();

  //
  Widget _getSelectLanguageHeading() {
    return Text('changePassword'.translate(context: context),
        style: TextStyle(
          color: Theme.of(context).colorScheme.blackColor,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.normal,
          fontSize: 20.0,
        ),
        textAlign: TextAlign.start,);
  }

  //
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (BuildContext context, ChangePasswordState state) async {
        if (state is ChangePasswordSuccess) {
          //
          _oldPasswordTextController.clear();
          _newPasswordTextController.clear();
          _confirmNewPasswordTextController.clear();
          //
          UiUtils.showMessage(context, state.errorMessage, MessageType.success);
          //
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pop(context);
          }
          //
        } else if (state is ChangePasswordFailure) {
          UiUtils.showMessage(context, state.errorMessage, MessageType.error);
        }
      },
      builder: (BuildContext context, ChangePasswordState state) {
        Widget? child;
        if (state is ChangePasswordInProgress) {
          child = CircularProgressIndicator(
            color: AppColors.whiteColors,
          );
        }
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.5),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(UiUtils.bottomSheetTopRadius),
                topRight: Radius.circular(UiUtils.bottomSheetTopRadius),
              ),),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(UiUtils.bottomSheetTopRadius),
                      topRight: Radius.circular(UiUtils.bottomSheetTopRadius),
                    ),),
                width: MediaQuery.sizeOf(context).width,
                child: _getSelectLanguageHeading(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                child: CustomTextFormField(
                                  controller: _oldPasswordTextController,
                                  isPswd: true,
                                  labelText: 'oldPassword'.translate(context: context),
                                  validator: (String? value) => Validator.nullCheck(value),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                child: CustomTextFormField(
                                  controller: _newPasswordTextController,
                                  isPswd: true,
                                  labelText: 'newPassword'.translate(context: context),
                                  validator: (String? value) => Validator.nullCheck(value),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                child: CustomTextFormField(
                                  controller: _confirmNewPasswordTextController,
                                  isPswd: true,
                                  labelText: 'confirmPasswordLbl'.translate(context: context),
                                  validator: (String? value) => Validator.nullCheck(value),
                                ),
                              ),
                            ],
                          ),),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
                        child: CustomRoundedButton(
                          widthPercentage: 1,
                          backgroundColor: Theme.of(context).colorScheme.accentColor,
                          buttonTitle: 'changePassword'.translate(context: context),
                          titleColor: AppColors.whiteColors,
                          showBorder: false,
                          child: child,
                          onTap: () {
                            UiUtils.removeFocus();
                            final FormState? form = formKey.currentState; //default value
                            if (form == null) return;
                            form.save();
                            if (form.validate()) {
                              final String newPassword =
                                  _newPasswordTextController.text.trim();
                              final String confirmNewPassword =
                                  _confirmNewPasswordTextController.text.trim();
                              final String oldPassword =
                                  _oldPasswordTextController.text.trim();

                              final bool isNewAndConfirmPasswordAreSame =
                                  newPassword == confirmNewPassword;
                              if (isNewAndConfirmPasswordAreSame) {
                                if (context.read<FetchSystemSettingsCubit>().isDemoModeEnable()) {
                                  UiUtils.showDemoModeWarning(context: context);
                                  return;
                                }
                                context.read<ChangePasswordCubit>().changePassword(
                                    oldPassword: oldPassword, newPassword: newPassword,);
                              } else {
                                UiUtils.showMessage(
                                    context,
                                    'passwordDoesNotMatch'.translate(context: context),
                                    MessageType.warning,);
                              }
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
