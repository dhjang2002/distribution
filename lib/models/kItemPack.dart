import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemPack {
  int lGoodsId;
  String sBarcode;
  String sGoodsName;
  int lTotalPickingCount;
  int lTotalPackingCount;
  int lTotalGoodsCount;
  int lCurrentPackingCount;
  bool bSelect;
  bool hasFocus;
  bool checked;
  TextEditingController? controller;

  ItemPack({
    this.lGoodsId=0,
    this.sBarcode="",
    this.sGoodsName = "",
    this.lTotalPickingCount = 0,
    this.lTotalPackingCount=0,
    this.lTotalGoodsCount = 0,
    this.lCurrentPackingCount = 0,

    this.bSelect = false,
    this.hasFocus = false,
    this.checked = false,
    this.controller,
  });

  void copy(ItemPack item) {
    lGoodsId=item.lGoodsId;
    sBarcode=item.sBarcode;
    sGoodsName = item.sGoodsName;
    lTotalGoodsCount     = item.lTotalGoodsCount;
    lTotalPickingCount   = item.lTotalPickingCount;
    lTotalPackingCount   = item.lTotalPackingCount;
    lCurrentPackingCount = item.lCurrentPackingCount;
  }
  static List<ItemPack> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemPack.fromJson(data);
    }).toList();
  }

  factory ItemPack.fromJson(Map<String, dynamic> jdata)
  {
    // if (kDebugMode) {
    //   var logger = Logger();
    //   logger.d(jdata);
    // }

    ItemPack item = ItemPack(
      lGoodsId: (jdata['lGoodsId'] != null)
          ? int.parse(jdata['lGoodsId'].toString().trim()) : 0,
      sGoodsName: (jdata['sGoodsName'] != null)
          ? jdata['sGoodsName'].toString().trim() : "",
      sBarcode: (jdata['sBarcode'] != null)
          ? jdata['sBarcode'].toString().trim() : "",

      lTotalPickingCount: (jdata['lTotalPickingCount'] != null)
          ? int.parse(jdata['lTotalPickingCount'].toString().trim()) : 0,
      lTotalPackingCount: (jdata['lTotalPackingCount'] != null)
          ? int.parse(jdata['lTotalPackingCount'].toString().trim()) : 0,
      lTotalGoodsCount: (jdata['lTotalGoodsCount'] != null)
          ? int.parse(jdata['lTotalGoodsCount'].toString().trim()) : 0,
      lCurrentPackingCount: (jdata['lCurrentPackingCount'] != null)
          ? int.parse(jdata['lCurrentPackingCount'].toString().trim()) : 0,
    );
    return item;
  }
}