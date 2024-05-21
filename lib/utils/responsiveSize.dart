// ignore_for_file: file_names

import 'package:flutter/material.dart';

//Warning Don't Edit or change this file otherwise your whole UI will get error

extension Sizing on num {
  double rh(context) {
    //!Don't change [812]
    const double aspectedScreenHeight = 812;

    final Size size = MediaQuery.sizeOf(context);
    final double responsiveHeight = size.height * (this / aspectedScreenHeight);
    return responsiveHeight;
  }

  double rw(context) {
    //!Don't change  [375]
    const double aspectedScreenWidth = 375;

    final Size size = MediaQuery.sizeOf(context);
    final double responsiveWidth = size.width * (this / aspectedScreenWidth);
    return responsiveWidth;
  }

  ///Responsive font
  double rf(context) {
    const double aspectedScreenHeight = 812;
    return (this / aspectedScreenHeight) * MediaQuery.sizeOf(context).height;
  }

  // double get h {
  //   return ScreenSize.instance.getSize.height;
  // }
  //  double get w {
  //   return ScreenSize.instance.getSize.width;
  // }
}

// class ScreenSize {
//   ScreenSize._privateConstructor();

//   static final ScreenSize _instance = ScreenSize._privateConstructor();

//   static ScreenSize get instance => _instance;

//   static double _width = 0;
//   static double _height = 0;
//   Size get getSize => Size(_width, _height);

//   void setScreenSize({required double width, required double height}) {
//     _width = width;
//     _height = height;
//   }
// }
