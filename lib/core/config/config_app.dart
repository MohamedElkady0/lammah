import 'package:flutter/material.dart';

class ConfigApp {
  static late MediaQueryData _mediaQueryData;
  static late double width;
  static late double height;
  static late Orientation orientation;

  static initConfig(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    width = _mediaQueryData.size.width;
    height = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
  }

  static double getProportionateScreenHeight(double inputHeight) {
    double screenHeight = ConfigApp.height;

    return (inputHeight / 812.0) * screenHeight;
  }

  static double getProportionateScreenWidth(double inputWidth) {
    double screenWidth = ConfigApp.width;

    return (inputWidth / 375.0) * screenWidth;
  }
}
