import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';

enum AppPlatform { android, ios, windows, macos, linux, web, unknown }

class OrientationApp {
  Orientation get orientation => ConfigApp.orientation;
  double get width => ConfigApp.width;
  double get height => ConfigApp.height;

  void initOrientation(BuildContext context) {
    ConfigApp.initConfig(context);
  }

  bool isPortrait() {
    return orientation == Orientation.portrait;
  }

  bool isLandscape() {
    return orientation == Orientation.landscape;
  }

  bool isPhone() {
    return width < 600;
  }

  bool isTablet() {
    return width >= 600 && width < 1024;
  }

  bool isDesktop() {
    return width >= 1024;
  }

  bool isPhoneInPortrait() {
    return isPhone() && isPortrait();
  }

  bool isPhoneInLandscape() {
    return isPhone() && isLandscape();
  }

  bool isTabletInPortrait() {
    return isTablet() && isPortrait();
  }

  bool isTabletInLandscape() {
    return isTablet() && isLandscape();
  }

  AppPlatform get currentPlatform {
    if (kIsWeb) {
      return AppPlatform.web;
    }

    if (Platform.isAndroid) {
      return AppPlatform.android;
    } else if (Platform.isIOS) {
      return AppPlatform.ios;
    } else if (Platform.isWindows) {
      return AppPlatform.windows;
    } else if (Platform.isMacOS) {
      return AppPlatform.macos;
    } else if (Platform.isLinux) {
      return AppPlatform.linux;
    } else {
      return AppPlatform.unknown;
    }
  }
}
