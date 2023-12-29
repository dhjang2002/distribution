import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemConfirmGoods {
  int    lPackingID;
  int    lPackingCount;
  int    lGoodsId;
  String sBarcode;
  String sGoodsName;
  int    fState;
  String sState;
  bool   hasFocus;
  bool   isChecked;
  String sLotNo;
  String sLotMemo;
  ItemConfirmGoods({
    this.lPackingID = 0,
    this.lPackingCount = 0,
    this.sGoodsName = "",
    this.lGoodsId=0,
    this.sBarcode="",
    this.fState=0,
    this.sState="",
    this.sLotMemo="",
    this.sLotNo="",
    this.hasFocus = false,
    this.isChecked = false,
  });

  static List<ItemConfirmGoods> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemConfirmGoods.fromJson(data);
    }).toList();
  }

  factory ItemConfirmGoods.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemConfirmGoods item = ItemConfirmGoods(
      lPackingID: (jdata['lPackingID'] != null)
          ? int.parse(jdata['lPackingID'].toString().trim()) : 0,
      lPackingCount: (jdata['lPackingCount'] != null)
          ? int.parse(jdata['lPackingCount'].toString().trim()) : 0,
      sGoodsName: (jdata['sGoodsName'] != null)
          ? jdata['sGoodsName'].toString().trim() : "",
      lGoodsId: (jdata['lGoodsId'] != null)
          ? int.parse(jdata['lGoodsId'].toString().trim()) : 0,
      sBarcode:(jdata['sBarcode'] != null)
          ? jdata['sBarcode'].toString().trim() : "",
      fState: (jdata['fState'] != null)
          ? int.parse(jdata['fState'].toString().trim()) : 0,
      sState: (jdata['sState'] != null)
          ? jdata['sState'].toString().trim() : "",
      sLotNo: (jdata['sLotNo'] != null)
          ? jdata['sLotNo'].toString().trim() : "",
      sLotMemo: (jdata['sLotMemo'] != null)
          ? jdata['sLotMemo'].toString().trim() : "",
    );

    return item;
  }

}