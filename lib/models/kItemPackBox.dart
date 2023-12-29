import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemPackBox {
  int sCustomerId;
  String sBoxNo;
  String sBoxSeq;
  String sCustomerName;
  int lTotalGoodsCount;

  int fState;

  bool bSelect;
  bool hasFocus;

  ItemPackBox({
    this.sCustomerId=0,
    this.lTotalGoodsCount=0,
    this.sBoxSeq="",
    this.sBoxNo="",
    this.sCustomerName="",
    this.fState=0,
    this.hasFocus = false,
    this.bSelect=false
  });

  static List<ItemPackBox> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemPackBox.fromJson(data);
    }).toList();
  }

  factory ItemPackBox.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemPackBox item = ItemPackBox(
      sCustomerId: (jdata['sCustomerId'] != null)
          ? int.parse(jdata['sCustomerId'].toString().trim()) : 0,
      lTotalGoodsCount: (jdata['lTotalGoodsCount'] != null)
          ? int.parse(jdata['lTotalGoodsCount'].toString().trim()) : 0,

      sBoxSeq: (jdata['sBoxSeq'] != null)
          ? jdata['sBoxSeq'].toString().trim() : "",

      sBoxNo: (jdata['sBoxNo'] != null)
          ? jdata['sBoxNo'].toString().trim() : "",

      sCustomerName: (jdata['sCustomerName'] != null)
          ? jdata['sCustomerName'].toString().trim() : "",

      fState: (jdata['fState'] != null)
          ? int.parse(jdata['fState'].toString().trim()) : 0,
    );
    return item;
  }
}