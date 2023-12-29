// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String appName = "Taka 물류";
const String buildDate = "2023.03.16";

// 개발서버
//-----------------------------------------------------------
const bool   modeIsDeveloper = true;
const String IP     = "http://114.108.134.94";
const String HTTP   = "http://tkwms.maxidc.net";
const String HTTPS  = "https://tkwms.maxidc.net";
//------------------------------------------------------------

// 운용서버
//-----------------------------------------------------------
// const bool   modeIsDeveloper = false;
// const String IP     = "http://114.108.134.94";
// const String HTTP   = "http://wms.point-i.co.kr";
// const String HTTPS  = "https://wms.point-i.co.kr";
//------------------------------------------------------------

const String SERVER         = HTTPS;
const String URL_ROOT       = SERVER;
const String URL_HOME       = SERVER;
const String URL_IMAGE      = "$SERVER/files/";
const String URL_API        = "$SERVER/api";
const String URL_NO_IMAGE   = "${URL_IMAGE}no-img.png";
const String URL_MALL       = "https://smartstore.naver.com/bcfmall1/products";

const int STATUS_PICK_READY      = 0;
const int STATUS_PICK_START      = 1;
const int STATUS_PICK_END        = 2;

const int STATUS_PACK_READY      = 2;
const int STATUS_PACK_START      = 3;
const int STATUS_PACK_END        = 4;

const int STATUS_PACK_MOVE       = 5;
const int STATUS_PACK_SCONFIRM   = 6;
const int STATUS_PACK_MCONFIRM   = 7;

const Color STD_READY   = Colors.white;
const Color STD_OK      = Colors.greenAccent;
const Color STD_ING     = Colors.amber;
const Color STD_DIFF    = Colors.amber;

const Color ColorY0 = Color(0xFFFFFCF1);

const Color ColorB0 = Color(0xFF57ABFF);
const Color ColorB1 = Color(0xFF4C83B6);
const Color ColorB2 = Color(0xFF133D86);
const Color ColorB3 = Color(0xFF14327A);

const Color ColorG1 = Colors.grey;
const Color ColorG2 = Color(0xFFB1B2B9);
const Color ColorG3 = Color(0xFFC0C0C0);
const Color ColorG4 = Color(0xFFD0D0D0);
const Color ColorG5 = Color(0xFFE0E0E0);
const Color ColorG6 = Color(0xFFF0F0F0);
// drawer Menu
const double CardItemIconSize = 14;
const double DrawerItemMenuIconSize = 16;
const double ItemMenuIconSize = 16;
const TextStyle ItemBkN11 = TextStyle(fontSize: 11, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.1, color: Colors.black, );

const TextStyle ItemBkN12 = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.2, color: Colors.black, );
const TextStyle ItemBkB12 = TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: -0.5, height: 1.2, color: Colors.black, );

const TextStyle ItemG1N12 = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.2, color: Colors.grey, );
const TextStyle ItemG2N12 = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.2, color: ColorG2);

const TextStyle ItemBkB14 = TextStyle(fontSize: 14, fontWeight: FontWeight.bold,   letterSpacing: -0.5, height: 1.2, color: Colors.black, );
const TextStyle ItemBkN14 = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.2, color: Colors.black, );
const TextStyle ItemB1B14 = TextStyle(fontSize: 14, fontWeight: FontWeight.bold,   letterSpacing: -0.5, height: 1.2, color: ColorB1);
const TextStyle ItemB1N14 = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.2, color: ColorB1);
const TextStyle ItemR1B14 = TextStyle(fontSize: 14, fontWeight: FontWeight.bold,   letterSpacing: -0.5, height: 1.2, color: Colors.red,);
const TextStyle ItemR1N12 = TextStyle(fontSize: 12, fontWeight: FontWeight.normal,   letterSpacing: -0.5, height: 1.2, color: Colors.red,);
const TextStyle ItemR1N14 = TextStyle(fontSize: 14, fontWeight: FontWeight.normal,   letterSpacing: -0.5, height: 1.2, color: Colors.red,);
const TextStyle ItemG1N14 = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.2, color: Colors.grey, );
const TextStyle ItemG2N14 = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.2, color: ColorG2);

const TextStyle ItemBkB15 = TextStyle(fontSize: 15, fontWeight: FontWeight.bold,   letterSpacing: -1.0, height: 1.2, color: Colors.black,);
const TextStyle ItemBkN15 = TextStyle(fontSize: 15, fontWeight: FontWeight.normal, letterSpacing: -1.0, height: 1.2, color: Colors.black, );
const TextStyle ItemB1N15 = TextStyle(fontSize: 15, fontWeight: FontWeight.normal, letterSpacing: -1.0, height: 1.2, color: ColorB1);
const TextStyle ItemR1B15 = TextStyle(fontSize: 15, fontWeight: FontWeight.normal, letterSpacing: -1.0, height: 1.2, color: Colors.red,);
const TextStyle ItemA1B15 = TextStyle(fontSize: 15, fontWeight: FontWeight.normal, letterSpacing: -1.0, height: 1.2, color: Colors.amber,);
const TextStyle ItemG1N15 = TextStyle(fontSize: 15, fontWeight: FontWeight.normal, letterSpacing: -1.0, height: 1.2, color: Colors.grey,  );
const TextStyle ItemG2N15 = TextStyle(fontSize: 15, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.2, color: ColorG2);

const TextStyle ItemBkB16 = TextStyle(fontSize: 16, fontWeight: FontWeight.bold,   letterSpacing: -1.0, height: 1.2, color: Colors.black,);
const TextStyle ItemBkN16 = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: -1.0, height: 1.2, color: Colors.black, );
const TextStyle ItemWkN16 = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: -1.0, height: 1.2, color: Colors.white, );
const TextStyle ItemB1N16 = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: -1.0, height: 1.2, color: ColorB1);
const TextStyle ItemG1N16 = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: -1.0, height: 1.2, color: Colors.grey, );
const TextStyle ItemR1B16 = TextStyle(fontSize: 16, fontWeight: FontWeight.bold,   letterSpacing: -1.0, height: 1.2, color: Colors.red, );

const TextStyle ItemBkB18 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold,   letterSpacing: -0.5, height: 1.1, color: Colors.black);
const TextStyle ItemBkN18 = TextStyle(fontSize: 18, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.1, color: Colors.black);
const TextStyle ItemBuN18 = TextStyle(fontSize: 18, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.1, color: Colors.blue);
const TextStyle ItemBuN16 = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.1, color: Colors.blue);
const TextStyle ItemBuN15 = TextStyle(fontSize: 15, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.1, color: Colors.blue);
const TextStyle ItemBuN14 = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.1, color: Colors.blue);
const TextStyle ItemBuN12 = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.1, color: Colors.blue);
const TextStyle ItemB1N18 = TextStyle(fontSize: 18, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.1, color: ColorB1);
const TextStyle ItemB1B18 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold,   letterSpacing: -0.5, height: 1.1, color: ColorB1);
const TextStyle ItemG1N18 = TextStyle(fontSize: 18, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.1, color: Colors.grey,  );
const TextStyle ItemG2B18 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold,   letterSpacing: -0.5, height: 1.1, color: ColorG2);

// dialog title, menu item
const TextStyle ItemBkB20 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold,   letterSpacing: -0.5, height: 1.0, color: Colors.black, );
const TextStyle ItemBkN20 = TextStyle(fontSize: 20, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.0, color: Colors.black, );
const TextStyle ItemB1N20 = TextStyle(fontSize: 20, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.0, color: ColorB1);
const TextStyle ItemB1B20 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold,   letterSpacing: -0.5, height: 1.0, color: ColorB1);
const TextStyle ItemBkB24 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold,   letterSpacing: -0.5, height: 1.0, color: Colors.black, );
const TextStyle ItemG1N24 = TextStyle(fontSize: 24, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.1, color: Colors.grey,  );
const TextStyle ItemG1N20 = TextStyle(fontSize: 20, fontWeight: FontWeight.normal, letterSpacing: -0.5, height: 1.1, color: Colors.grey,  );

const TextStyle ContBkN15 = TextStyle(fontSize: 15, fontWeight: FontWeight.normal, letterSpacing: -1.0, height: 1.4, color: Colors.black, );
const TextStyle ContBkN16 = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: -1.0, height: 1.4, color: Colors.black, );

const int moveMilisceond = 300;

double AxisExtentWidth  = 0;
double AxisExtentHeight = 0;
double AxisExtentRatio  = 0;
double mainAxisExtent   = 0;
double getMainAxis(BuildContext context) {
  return (MediaQuery.of(context).size.height/MediaQuery.of(context).size.width);
}

double getMainAxisExtent(BuildContext context) {
  AxisExtentWidth  = MediaQuery.of(context).size.width;
  AxisExtentHeight = MediaQuery.of(context).size.height;
  AxisExtentRatio = AxisExtentHeight / AxisExtentWidth;

  if (AxisExtentRatio < 1.18) {        // 캘럭시 플립 wide: 589 X 688
    mainAxisExtent = 240;
  } else if (AxisExtentRatio < 1.51) { // tab: normal 1.5
    mainAxisExtent = 480;
  } else if (AxisExtentRatio < 1.54) { // tab: 685 X 1049
    mainAxisExtent = 480;
  } else if (AxisExtentRatio < 1.76) { // phone:
    mainAxisExtent = 440;
  } else if (AxisExtentRatio < 1.93) { // phone: 360 X 692
    mainAxisExtent = 340;
  } else if (AxisExtentRatio < 2.11) { // phone: 360x732, 384x805, 2.10:384X805
    mainAxisExtent = 340;
  } else if (AxisExtentRatio < 2.17) { // ios: 360x732, 414 X 896
    mainAxisExtent = 380;
  } else if (AxisExtentRatio < 2.63) { // 캘럭시 플립 small: 320, 320 X 838
    mainAxisExtent = 380;
  }else {
    mainAxisExtent = 380;
  }
  return mainAxisExtent;
}

String getMainAxisInfo(BuildContext context) {
  getMainAxisExtent(context);

  String info = "${mainAxisExtent.toInt()},"
      " RT:${AxisExtentRatio.toStringAsFixed(2)},"
      " (${AxisExtentWidth.toInt()} x ${AxisExtentHeight.toInt()})";

  if (kDebugMode) {
    print("------------------------------------------------------------------------------");
    print("AxisExtentWidth: $AxisExtentWidth");
    print("AxisExtentHeight: $AxisExtentHeight");
    print("AxisExtentRatio: $AxisExtentRatio");
    print("mainAxisExtent: $mainAxisExtent");
    print("------------------------------------------------------------------------------");

    print("Axis Info => $info");
  }

  return info;
}

double getMainBottomPading(BuildContext context, int row) {
  final double rt = getMainAxis(context);
  double value = 0;
  if(rt<1.18) {
    value = 10*2/row;
  } else if(rt<1.55) {
    value = 40*2/row;
  } else if(rt<1.93) {
    value = 24*2/row;
  } else if(rt<2.42) {
    value = 40*2/row;
  } else if(rt<2.70) {
    value = 40*2/row;
  }
  return value;
}
double getMainTopPading(BuildContext context, int row) {
  final double rt = getMainAxis(context);
  if(rt<1.18) {
  } else if(rt<1.55) {
  } else if(rt<1.93) {
  } else if(rt<2.20) {
  } else if(rt<2.42) {
  } else if(rt<2.70) {
  }
  return 20;
}