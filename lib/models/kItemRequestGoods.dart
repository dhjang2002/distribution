import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemRequestGoods {
  int lDeliveryRequestDetailID;
  int lDeliveryRequestID;
  int lRequestStoreID;
  int lGoodsID;
  String sGoodsName;
  int lGoodsCount;
  int lConfirmedCount;
  String sMemo;
  int mPriceA;
  int mPriceB;
  String dtActioned;
  int fConfirm;

  bool isTarget;
  bool hasFocus;
  TextEditingController? controller;

  ItemRequestGoods({
    this.lDeliveryRequestDetailID = 0,
    this.lDeliveryRequestID = 0,
    this.sGoodsName = "",
    this.sMemo="",
    this.dtActioned="",
    this.lRequestStoreID = 0,
    this.lConfirmedCount = 0,
    this.lGoodsID=0,
    this.mPriceA=0,
    this.mPriceB=0,
    this.lGoodsCount=0,
    this.fConfirm=0,
    this.isTarget      = false,
    this.hasFocus      = false,
    this.controller,
  });

  void copyFrom(ItemRequestGoods item) {
    this.lDeliveryRequestDetailID = item.lDeliveryRequestDetailID;
    this.lDeliveryRequestID = item.lDeliveryRequestID;
    this.sGoodsName = item.sGoodsName;
    this.sMemo=item.sMemo;
    this.dtActioned=item.dtActioned;
    this.lRequestStoreID = item.lRequestStoreID;
    this.lConfirmedCount = item.lConfirmedCount;
    this.lGoodsID=item.lGoodsID;
    this.mPriceA=item.mPriceA;
    this.mPriceB=item.mPriceB;
    this.lGoodsCount=item.lGoodsCount;
    this.fConfirm = item.fConfirm;
  }

  static List<ItemRequestGoods> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemRequestGoods.fromJson(data);
    }).toList();
  }

  factory ItemRequestGoods.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemRequestGoods item = ItemRequestGoods(
        lDeliveryRequestDetailID: (jdata['lDeliveryRequestDetailID'] != null)
          ? int.parse(jdata['lDeliveryRequestDetailID'].toString().trim()) : 0,
      lDeliveryRequestID: (jdata['lDeliveryRequestID'] != null)
          ? int.parse(jdata['lDeliveryRequestID'].toString().trim()) : 0,
      lGoodsID: (jdata['lGoodsID'] != null)
          ? int.parse(jdata['lGoodsID'].toString().trim()) : 0,
      lGoodsCount: (jdata['lGoodsCount'] != null)
          ? int.parse(jdata['lGoodsCount'].toString().trim()) : 0,
      sGoodsName: (jdata['sGoodsName'] != null)
          ? jdata['sGoodsName'].toString().trim() : "",
      mPriceA: (jdata['mPriceA'] != null)
          ? int.parse(jdata['mPriceA'].toString().trim()) : 0,
      mPriceB: (jdata['mPriceB'] != null)
          ? int.parse(jdata['mPriceB'].toString().trim()) : 0,
      sMemo: (jdata['sMemo'] != null)
          ? jdata['sMemo'].toString().trim() : "",
      lConfirmedCount: (jdata['lConfirmedCount'] != null)
          ? int.parse(jdata['lConfirmedCount'].toString().trim()) : -1,
      lRequestStoreID: (jdata['lRequestStoreID'] != null)
          ? int.parse(jdata['lRequestStoreID'].toString().trim()) : 0,

      fConfirm: (jdata['fConfirm'] != null)
          ? int.parse(jdata['fConfirm'].toString().trim()) : 0,
    );

    if(item.fConfirm == 0 && item.lConfirmedCount<0) {
      item.lConfirmedCount = item.lGoodsCount;
    }
    return item;
  }

}