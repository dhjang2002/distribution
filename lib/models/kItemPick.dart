import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemPick {
  int lShippingID;
  int fState;
  String sState;
  int lStoreID;
  String sStoreCode;
  String sShippingNo;
  String sCustomerName;
  String sCustomerTel;
  int lEmployeeID;
  String sEmployeeName;
  int lKindGoodsCount;
  int lTotalGoodsCount;
  int lTotalPickingCount;
  int lTotalPackingCount;

  bool bSelect;
  //bool bMyWork;
  TextEditingController? controller;
  ItemPick({
    this.lShippingID=0,
    this.fState = 0,
    this.sState = "",
    this.lStoreID = 1,
    this.sStoreCode = "",
    this.sShippingNo = "",
    this.sCustomerName="",
    this.sCustomerTel="",
    this.lEmployeeID = 0,
    this.sEmployeeName="",
    this.bSelect = false,

    this.lTotalPickingCount=0,
    this.lKindGoodsCount=0,
    this.lTotalGoodsCount=0,
    this.lTotalPackingCount=0,

    //this.bMyWork = false,
    this.controller,
  });

  static List<ItemPick> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemPick.fromJson(data);
    }).toList();
  }

  factory ItemPick.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemPick item = ItemPick(
      lShippingID: (jdata['lShippingID'] != null)
          ? int.parse(jdata['lShippingID'].toString().trim()) : 0,
      fState: (jdata['fState'] != null)
          ? int.parse(jdata['fState'].toString().trim()) : 0,
      sState: (jdata['sState'] != null)
          ? jdata['sState'].toString().trim() : "",
      lStoreID: (jdata['lStoreID'] != null)
          ? int.parse(jdata['lStoreID'].toString().trim()) : 0,
      sShippingNo: (jdata['sShippingNo'] != null)
          ? jdata['sShippingNo'].toString().trim() : "",
        sCustomerTel:(jdata['sCustomerTel'] != null)
            ? jdata['sCustomerTel'].toString().trim() : "",
      sCustomerName: (jdata['sCustomerName'] != null)
          ? jdata['sCustomerName'].toString().trim() : "",
      sStoreCode: (jdata['sStoreCode'] != null)
          ? jdata['sStoreCode'].toString().trim() : "",
      lEmployeeID: (jdata['lEmployeeID'] != null)
          ? int.parse(jdata['lEmployeeID'].toString().trim()) : 0,
      sEmployeeName: (jdata['sEmployeeName'] != null)
          ? jdata['sEmployeeName'].toString().trim() : "",

      lTotalGoodsCount: (jdata['lTotalGoodsCount'] != null)
          ? int.parse(jdata['lTotalGoodsCount'].toString().trim()) : 0,
      lKindGoodsCount: (jdata['lKindGoodsCount'] != null)
          ? int.parse(jdata['lKindGoodsCount'].toString().trim()) : 0,
      lTotalPickingCount: (jdata['lTotalPickingCount'] != null)
          ? int.parse(jdata['lTotalPickingCount'].toString().trim()) : 0,
      lTotalPackingCount:(jdata['lTotalPackingCount'] != null)
          ? int.parse(jdata['lTotalPackingCount'].toString().trim()) : 0,
    );

    return item;
  }
}