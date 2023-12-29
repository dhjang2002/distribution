import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemPackStoreList {
  String sCustomerId;
  String sCustomerName;
  int lTotalGoodsCount;
  int lTotalPickingCount;
  int lTotalPackingCount;
  int fState;
  String sState;
  
  bool bSelect;
  bool hasFocus;
  bool checked;

  ItemPackStoreList({
    this.sCustomerId="",
    this.sCustomerName="",
    this.lTotalGoodsCount = 0,
    this.lTotalPickingCount=0,
    this.lTotalPackingCount = 0,
    this.fState = 0,
    this.sState="",
    this.bSelect = false,
    this.hasFocus = false,
    this.checked = false,
  });

  void copy(ItemPackStoreList item) {
    sCustomerId=item.sCustomerId;
    sCustomerName=item.sCustomerName;
    lTotalGoodsCount = item.lTotalGoodsCount;
    lTotalPickingCount=item.lTotalPickingCount;
    lTotalPackingCount = item.lTotalPackingCount;
    fState = item.fState;
    sState = item.sState;
  }
  static List<ItemPackStoreList> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemPackStoreList.fromJson(data);
    }).toList();
  }

  factory ItemPackStoreList.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemPackStoreList item = ItemPackStoreList(
      sCustomerId: (jdata['sCustomerId'] != null)
          ? jdata['sCustomerId'].toString().trim() : "",
      sCustomerName: (jdata['sCustomerName'] != null)
          ? jdata['sCustomerName'].toString().trim() : "",
      lTotalGoodsCount: (jdata['lTotalGoodsCount'] != null)
          ? int.parse(jdata['lTotalGoodsCount'].toString().trim()) : 0,
      lTotalPickingCount: (jdata['lTotalPickingCount'] != null)
          ? int.parse(jdata['lTotalPickingCount'].toString().trim()) : 0,
      lTotalPackingCount: (jdata['lTotalPackingCount'] != null)
          ? int.parse(jdata['lTotalPackingCount'].toString().trim()) : 0,

      fState: (jdata['fState'] != null)
          ? int.parse(jdata['fState'].toString().trim()) : 0,

      sState: (jdata['sState'] != null)
          ? jdata['sState'].toString().trim() : "",
    );

    // if(item.lPackingCount==0) {
    //   item.lPackingCount = item.lGoodsCount;
    // }
    return item;
  }
}