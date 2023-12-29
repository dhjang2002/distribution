import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ListConfirmPacking {
  String sCustomerId;
  String sCustomerName;
  String sBoxNo;
  String sBoxSeq;
  int    fState;
  String sState;
  int    lGoodsKind;
  int    lTotalGoodsCount;

  // int lStoreID;
  // int sCustomerID;
  //
  // String dDatetime;

  ListConfirmPacking({
    this.sCustomerId = "",
    this.lTotalGoodsCount = 0,
    this.sCustomerName = "",
    this.sBoxNo="",
    this.sBoxSeq="",
    this.fState=0,
    this.sState="",
    this.lGoodsKind = 0,
  });

  static List<ListConfirmPacking> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ListConfirmPacking.fromJson(data);
    }).toList();
  }

  factory ListConfirmPacking.fromJson(Map<String, dynamic> jdata)
  {
    // if (kDebugMode) {
    //   var logger = Logger();
    //   logger.d(jdata);
    // }

    ListConfirmPacking item = ListConfirmPacking(
      sCustomerId: (jdata['sCustomerId'] != null)
          ? jdata['sCustomerId'].toString().trim() : "",
      sCustomerName: (jdata['sCustomerName'] != null)
          ? jdata['sCustomerName'].toString().trim() : "",
      sBoxNo:(jdata['sBoxNo'] != null)
          ? jdata['sBoxNo'].toString().trim() : "",
      sBoxSeq:(jdata['sBoxSeq'] != null)
          ? jdata['sBoxSeq'].toString().trim() : "",
      fState: (jdata['fState'] != null)
          ? int.parse(jdata['fState'].toString().trim()) : 0,
      sState: (jdata['sState'] != null)
          ? jdata['sState'].toString().trim() : "",
      lTotalGoodsCount: (jdata['lTotalGoodsCount'] != null)
          ? int.parse(jdata['lTotalGoodsCount'].toString().trim()) : 0,
      lGoodsKind: (jdata['lGoodsKind'] != null)
          ? int.parse(jdata['lGoodsKind'].toString().trim()) : 0,
    );

    return item;
  }

}