import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';

class AppSpacing {
  AppSpacing._();

  static const double _spaceXXS = 4.0;
  static const double _spaceXS = 8.0;
  static const double _spaceS = 12.0;
  static const double _spaceM = 16.0;
  static const double _spaceL = 24.0;
  static const double _spaceXL = 32.0;
  static const double _spaceXXL = 48.0;

  static final double xxs = ConfigApp.getProportionateScreenWidth(_spaceXXS);
  static final double xs = ConfigApp.getProportionateScreenWidth(_spaceXS);
  static final double s = ConfigApp.getProportionateScreenWidth(_spaceS);
  static final double m = ConfigApp.getProportionateScreenWidth(_spaceM);
  static final double l = ConfigApp.getProportionateScreenWidth(_spaceL);
  static final double xl = ConfigApp.getProportionateScreenWidth(_spaceXL);
  static final double xxl = ConfigApp.getProportionateScreenWidth(_spaceXXL);

  static EdgeInsets get allXXS => EdgeInsets.all(xxs);
  static EdgeInsets get allXS => EdgeInsets.all(xs);
  static EdgeInsets get allS => EdgeInsets.all(s);
  static EdgeInsets get allM => EdgeInsets.all(m);
  static EdgeInsets get allL => EdgeInsets.all(l);

  static EdgeInsets get horizontalXS => EdgeInsets.symmetric(horizontal: xs);
  static EdgeInsets get horizontalS => EdgeInsets.symmetric(horizontal: s);
  static EdgeInsets get horizontalM => EdgeInsets.symmetric(horizontal: m);
  static EdgeInsets get horizontalL => EdgeInsets.symmetric(horizontal: l);

  static EdgeInsets get verticalXS => EdgeInsets.symmetric(vertical: xs);
  static EdgeInsets get verticalS => EdgeInsets.symmetric(vertical: s);
  static EdgeInsets get verticalM => EdgeInsets.symmetric(vertical: m);
  static EdgeInsets get verticalL => EdgeInsets.symmetric(vertical: l);

  static SizedBox get vSpaceXXS => SizedBox(height: xxs);
  static SizedBox get vSpaceXS => SizedBox(height: xs);
  static SizedBox get vSpaceS => SizedBox(height: s);
  static SizedBox get vSpaceM => SizedBox(height: m);
  static SizedBox get vSpaceL => SizedBox(height: l);
  static SizedBox get vSpaceXL => SizedBox(height: xl);
  static SizedBox get vSpaceXXL => SizedBox(height: xxl);

  static SizedBox get hSpaceXXS => SizedBox(width: xxs);
  static SizedBox get hSpaceXS => SizedBox(width: xs);
  static SizedBox get hSpaceS => SizedBox(width: s);
  static SizedBox get hSpaceM => SizedBox(width: m);
  static SizedBox get hSpaceL => SizedBox(width: l);
  static SizedBox get hSpaceXL => SizedBox(width: xl);
  static SizedBox get hSpaceXXL => SizedBox(width: xxl);

  static BorderRadius get radiusS => BorderRadius.circular(s);
  static BorderRadius get radiusM => BorderRadius.circular(m);
  static BorderRadius get radiusL => BorderRadius.circular(l);

  static const Divider divider = Divider(height: 1);
  static const Divider thickDivider = Divider(height: 1, thickness: 2);
}
