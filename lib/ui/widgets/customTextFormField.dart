// ignore_for_file:file_names

import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CustomTextFormField extends StatefulWidget {

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.textInputAction,
    this.currNode,
    this.nextFocus,
    this.textInputType = TextInputType.text,
    this.isPswd = false,
    this.heightVal,
    this.prefix,
    this.suffix,
    this.hintText,
    this.labelText,
    this.isReadOnly,
    this.callback,
    this.isDense,
    this.backgroundColor,
    this.isRoundedBorder,
    this.borderColor,
    this.hintTextColor,
    this.validator,
    this.forceUnfocus,
    this.onSubmit,
    this.inputFormatters,
    this.expand,
    this.minLines,
    this.labelStyle,
  });
  final TextEditingController? controller;
  final FocusNode? currNode;
  final FocusNode? nextFocus;
  final TextInputAction? textInputAction;
  final TextInputType textInputType;
  final bool isPswd;
  final double? heightVal;
  final Widget? prefix;
  final Widget? suffix;
  final String? hintText;
  final String? labelText;
  final bool? isReadOnly;
  final VoidCallback? callback;
  final bool? isDense;
  final Color? backgroundColor;
  final bool? isRoundedBorder;
  final Color? borderColor;
  final Color? hintTextColor;
  final String? Function(String?)? validator;
  final bool? forceUnfocus;
  final Function()? onSubmit;
  final List<TextInputFormatter>? inputFormatters;
  final bool? expand;
  final int? minLines;
  final TextStyle? labelStyle;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isPasswordVisible = false;

  IconButton togglePassword() {
    return IconButton(
        onPressed: () {
          setState(() {
            isPasswordVisible = !isPasswordVisible;
          });
        },
        icon: Icon(isPasswordVisible ? Icons.visibility_off : Icons.visibility),);
  }

  bool _checkPasswordField() {
    if (widget.isPswd == true) {
      // if it is password field.
      // it will check the variable to check if we should show password or not
      return isPasswordVisible == false;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextFormField(
        focusNode: widget.currNode,
        inputFormatters: widget.inputFormatters,

        onEditingComplete: () {
          if (widget.nextFocus != null) {
            FocusScope.of(context).requestFocus(widget.nextFocus);
          } else if (widget.currNode != null) {
            if (widget.forceUnfocus ?? false) widget.currNode!.unfocus();
            widget.onSubmit?.call();
          }
        },
        onFieldSubmitted: (String value) {
          FocusScope.of(context).unfocus();
        },
        validator: widget.validator,
        onTap: widget.callback,
        cursorColor: Theme.of(context).colorScheme.lightGreyColor,

        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: widget.labelStyle ??
              TextStyle(color: Theme.of(context).colorScheme.blackColor, fontSize: 12),
          prefixIcon: widget.prefix,
          suffix: widget.suffix,
          hintText: widget.hintText,
          floatingLabelStyle: MaterialStateTextStyle.resolveWith(
            (Set<MaterialState> states) {
              final Color color = states.contains(MaterialState.error)
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.accentColor.withOpacity(0.5);
              return TextStyle(color: color, letterSpacing: 1.3);
            },
          ),
          hintStyle: TextStyle(
              color: widget.hintTextColor ??
                  Theme.of(context).colorScheme.blackColor.withOpacity(0.5),),
          isDense: widget.isDense ?? true,
          suffixIcon: widget.isPswd ? togglePassword() : null,
          fillColor: widget.backgroundColor ?? Colors.transparent,
          errorStyle: const TextStyle(fontSize: 10, color: AppColors.redColor),
          filled: true,
          errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.redColor),
              borderRadius: BorderRadius.circular(10),),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ((widget.isRoundedBorder ?? false) && widget.borderColor != null)
                      ? widget.borderColor!
                      : Theme.of(context).colorScheme.accentColor,),
              borderRadius: BorderRadius.circular(10),),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ((widget.isRoundedBorder ?? false) && widget.borderColor != null)
                      ? widget.borderColor!
                      : Theme.of(context).colorScheme.lightGreyColor,),
              borderRadius: BorderRadius.circular(10),),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ((widget.isRoundedBorder ?? false) && widget.borderColor != null)
                      ? widget.borderColor!
                      : Theme.of(context).colorScheme.accentColor,),
              borderRadius: BorderRadius.circular(10),),
          border: OutlineInputBorder(
            borderSide: widget.isRoundedBorder == true ? const BorderSide() : BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        textAlignVertical: TextAlignVertical.center,
        style: Theme.of(context).textTheme.titleSmall,
        readOnly: widget.isReadOnly ?? false,
        keyboardType: widget.textInputType,
        minLines: widget.minLines,
        maxLines: (widget.textInputType == TextInputType.multiline)
            ? (widget.expand == true ? null : 3)
            : 1,
        //assigned 1 because null is not working with ObsecureText
        textInputAction: widget.textInputAction ??
            ((widget.nextFocus != null)
                ? TextInputAction.next
                : (widget.textInputType == TextInputType.multiline)
                    ? TextInputAction.newline
                    : TextInputAction.done),
        obscureText: _checkPasswordField(),
        controller: widget.controller,
      ),
    );
  }
}
