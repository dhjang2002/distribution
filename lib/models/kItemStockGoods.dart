import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemStockGoods {
  int lStockInspectID;
  int lStockInspectDetailID;
  int lGoodsId;
  int sIsErrorConfirm;
  String sGoodsName;
  String sBarcode;

  String sLot1;
  String sLot2;
  String sLot3;
  String sMemo;

  int rVirtualStock;
  int rRealStock;
  int rGapStock;

  bool isTarget;
  bool hasFocus;
  TextEditingController? controller;

  ItemStockGoods({
    this.lStockInspectID=0,
    this.lStockInspectDetailID=0,
    this.sLot1 = "",
    this.sLot2 = "",
    this.sLot3 = "",
    this.sMemo = "",
    this.lGoodsId = 0,
    this.sGoodsName = "",
    this.sBarcode="",
    this.rVirtualStock = 0,
    this.rRealStock    = 0,
    this.rGapStock     = 0,
    this.sIsErrorConfirm = 0,
    this.isTarget      = false,
    this.hasFocus      = false,
    this.controller,
  });

  static List<ItemStockGoods> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemStockGoods.fromJson(data);
    }).toList();
  }

  factory ItemStockGoods.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemStockGoods item = ItemStockGoods(
      lStockInspectID: (jdata['lStockInspectID'] != null)
          ? int.parse(jdata['lStockInspectID'].toString().trim()) : 0,
      lStockInspectDetailID: (jdata['lStockInspectDetailID'] != null)
          ? int.parse(jdata['lStockInspectDetailID'].toString().trim()) : 0,

      sLot1: (jdata['sLot1'] != null)
          ? jdata['sLot1'].toString().trim() : "",
      sLot2: (jdata['sLot2'] != null)
          ? jdata['sLot2'].toString().trim() : "",
      sLot3: (jdata['sLot3'] != null)
          ? jdata['sLot3'].toString().trim() : "",
      sMemo: (jdata['sMemo'] != null)
          ? jdata['sMemo'].toString().trim() : "",
      lGoodsId: (jdata['lGoodsID'] != null)
          ? int.parse(jdata['lGoodsID'].toString().trim()) : 0,
      sGoodsName: (jdata['sGoodsName'] != null)
          ? jdata['sGoodsName'].toString().trim() : "",
      sBarcode: (jdata['sBarcode'] != null)
          ? jdata['sBarcode'].toString().trim() : "",
      rGapStock: (jdata['rGapStock'] != null)
          ? int.parse(jdata['rGapStock'].toString().trim()) : 0,
      rVirtualStock: (jdata['rVirtualStock'] != null)
          ? int.parse(jdata['rVirtualStock'].toString().trim()) : 0,
      rRealStock: (jdata['rRealStock'] != null)
          ? int.parse(jdata['rRealStock'].toString().trim()) : 0,
      sIsErrorConfirm: (jdata['sIsErrorConfirm'] != null)
          ? int.parse(jdata['sIsErrorConfirm'].toString().trim()) : 0,
    );

    item.rGapStock = item.rRealStock-item.rVirtualStock;
    return item;
  }
}