import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemStockMissGoods {
  int lGoodsId;
  String sName;
  String sBarcode;
  String sLotNo;
  String sLotMemo;
  int rNowStock;
  bool isTarget;
  bool hasFocus;

  ItemStockMissGoods({
    this.sLotNo = "",
    this.sLotMemo = "",
    this.lGoodsId = 0,
    this.sName = "",
    this.sBarcode="",
    this.rNowStock = 0,
    this.isTarget      = false,
    this.hasFocus      = false,
    //this.controller,
  });

  static List<ItemStockMissGoods> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemStockMissGoods.fromJson(data);
    }).toList();
  }

  factory ItemStockMissGoods.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemStockMissGoods item = ItemStockMissGoods(
      sLotNo: (jdata['sLotNo'] != null)
          ? jdata['sLotNo'].toString().trim() : "",
      sLotMemo: (jdata['sLotMemo'] != null)
          ? jdata['sLotMemo'].toString().trim() : "",

      lGoodsId: (jdata['lGoodsId'] != null)
          ? int.parse(jdata['lGoodsId'].toString().trim()) : 0,
      sName: (jdata['sName'] != null)
          ? jdata['sName'].toString().trim() : "",
      sBarcode: (jdata['sBarcode'] != null)
          ? jdata['sBarcode'].toString().trim() : "",
      rNowStock: (jdata['rNowStock'] != null)
          ? int.parse(jdata['rNowStock'].toString().trim()) : 0,
    );

    return item;
  }
}