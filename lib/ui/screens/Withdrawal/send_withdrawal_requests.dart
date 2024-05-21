import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class SendWithdrawalRequest extends StatefulWidget {
  const SendWithdrawalRequest({super.key});

  @override
  SendWithdrawalRequestScreenState createState() => SendWithdrawalRequestScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (BuildContext context) => BlocProvider(
        create: (BuildContext context) => SendWithdrawalRequestCubit(),
        child: const SendWithdrawalRequest(),
      ),
    );
  }
}

class SendWithdrawalRequestScreenState extends State<SendWithdrawalRequest> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController bankDetailsController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  FocusNode bankDetailsFocus = FocusNode();
  FocusNode amountFocus = FocusNode();
  bool? isRquestAdded;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, isRquestAdded);
        return false;
      },
      child: withdrawAmountForm(),
    );
  }

  Widget withdrawAmountForm() {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryColor,
          borderRadius: BorderRadiusDirectional.only(
              topEnd: Radius.circular(UiUtils.bottomSheetTopRadius),
              topStart: Radius.circular(UiUtils.bottomSheetTopRadius),),),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.all(15),
              child: Text(
                'sendWithdrawalRequest'.translate(context: context),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.blackColor,
                  fontSize: 18,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            Container(
              color: Theme.of(context).colorScheme.primaryColor,
              padding: const EdgeInsetsDirectional.all(15),
              child: Column(
                children: [
                  //account details field
                  UiUtils.setTitleAndTFF(
                    context,
                    titleText: 'bankDetailsHint'.translate(context: context),
                    controller: bankDetailsController,
                    currNode: bankDetailsFocus,
                    // backgroundColor: Theme.of(context).colorScheme.secondaryColor,
                    nextFocus: amountFocus,
                    validator: (String? val) => Validator.nullCheck(val),
                    textInputType: TextInputType.multiline,
                    expands: true,
                    minLines: 4,
                  ),
                  //withdraw amount field
                  UiUtils.setTitleAndTFF(context,
                      titleText: 'amountLbl'.translate(context: context),
                      controller: amountController,
                      currNode: amountFocus,
                      //   backgroundColor: Theme.of(context).colorScheme.secondaryColor,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
                      validator: (String? val) {
                    if (val != '') {
                      if (double.parse(val!) >
                          double.parse((context.read<FetchSystemSettingsCubit>().state
                                  as FetchSystemSettingsSuccess)
                              .availableAmount,)) {
                        return 'bigAmount'.translate(context: context);
                      }
                    }

                    return Validator.nullCheck(val);
                  }, textInputType: TextInputType.number,),
                  //

                  resetAndSubmitButton()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding resetAndSubmitButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Expanded(child: resetBtn()),
          const SizedBox(width: 10),
          Expanded(child: submitBtn()),
        ],),
      ),
    );
  }

  BlocConsumer<SendWithdrawalRequestCubit, SendWithdrawalRequestState> submitBtn() {
    return BlocConsumer<SendWithdrawalRequestCubit, SendWithdrawalRequestState>(
      listener: (BuildContext context, SendWithdrawalRequestState state) {
        if (state is SendWithdrawalRequestSuccess) {
          //update amount globally
          context.read<FetchSystemSettingsCubit>().updateAmount(state.balance);

          UiUtils.showMessage(context, 'success'.translate(context: context), MessageType.success,
              onMessageClosed: () {},);

          // little bit delay because bottom sheet is closing very fast
          Future.delayed(const Duration(milliseconds: 500))
              .then((value) => Navigator.pop(context, true));
        }

        if (state is SendWithdrawalRequestFailure) {
          UiUtils.showMessage(context, 'failed'.translate(context: context), MessageType.error);
        }
      },
      builder: (BuildContext context, SendWithdrawalRequestState state) {
        Widget? child;

        if (state is SendWithdrawalRequestInProgress) {
          child = CircularProgressIndicator(
            color: AppColors.whiteColors,
          );
        }

        return CustomRoundedButton(
          widthPercentage: 1,
          buttonTitle: 'submitBtnLbl'.translate(context: context),
          backgroundColor: Theme.of(context).colorScheme.accentColor,
          showBorder: true,
          child: child,
          onTap: () {
            UiUtils.removeFocus();
            onSubmitClick();
          },
        );
      },
    );
  }

  CustomRoundedButton resetBtn() {
    return CustomRoundedButton(
      widthPercentage: 1,
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      buttonTitle: 'resetBtnLbl'.translate(context: context),
      titleColor: Theme.of(context).colorScheme.blackColor,
      showBorder: true,
      borderColor: Theme.of(context).colorScheme.blackColor,
      onTap: () {
        bankDetailsController.text = '';
        amountController.text = '';

        FocusScope.of(context).requestFocus(bankDetailsFocus);
        setState(() {});
      },
    );
  }

  Future<void> onSubmitClick() async {
    final FormState? form = formKey.currentState; //default value
    if (form == null) return;
    form.save();
    if (form.validate()) {
      context.read<SendWithdrawalRequestCubit>().sendWithdrawalRequest(
          amount: amountController.text, paymentAddress: bankDetailsController.text,);
    }
  }
}
