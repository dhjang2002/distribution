import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemRequestConfig {
  String sName;
  String sPhone;
  String sFax;
  String sKaKao;
  String sEmail;
  String tComment1;
  String tComment2;
  ItemRequestConfig({
    this.sName="",
    this.sPhone = "",
    this.sFax="",
    this.sKaKao="",
    this.sEmail = "",
    this.tComment1="",
    this.tComment2="",
  });

  static List<ItemRequestConfig> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemRequestConfig.fromJson(data);
    }).toList();
  }

  factory ItemRequestConfig.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemRequestConfig item = ItemRequestConfig(
      sName: (jdata['sName'] != null)
          ? jdata['sName'].toString().trim() : "",
      sPhone: (jdata['sPhone'] != null)
          ? jdata['sPhone'].toString().trim() : "",
      sFax: (jdata['sFax'] != null)
          ? jdata['sFax'].toString().trim() : "",
      sKaKao: (jdata['sKaKao'] != null)
          ? jdata['sKaKao'].toString().trim() : "",
      sEmail: (jdata['sEmail'] != null)
          ? jdata['sEmail'].toString().trim() : "",
      tComment1: (jdata['tComment1'] != null)
          ? jdata['tComment1'].toString().trim() : "",
      tComment2: (jdata['tComment2'] != null)
          ? jdata['tComment2'].toString().trim() : "",
    );
    return item;
  }
}