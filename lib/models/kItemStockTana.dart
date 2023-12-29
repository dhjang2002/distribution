import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemStockTana {
  String sLot1;
  int detailCount;
  // int lShippingDetailID;
  // int lGoodsId;
  // String sGoodsName;
  // int lGoodsCount;
  // int lConfirmCount;
  // int fState;

  bool bSelect;
  bool hasFocus;
  //TextEditingController? controller;

  ItemStockTana({
    this.sLot1="",
    this.detailCount=0,
    // this.lShippingDetailID=0,
    // this.lGoodsId=0,
    // this.sGoodsName = "",
    // this.lGoodsCount = 0,
    // this.lConfirmCount = 1,
    // this.fState = 0,
    this.bSelect = false,
    this.hasFocus = false,
    //this.controller,
  });

  static List<ItemStockTana> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemStockTana.fromJson(data);
    }).toList();
  }

  factory ItemStockTana.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemStockTana item = ItemStockTana(
      sLot1: (jdata['sLot1'] != null)
          ? jdata['sLot1'].toString().trim() : "",
      detailCount: (jdata['detailCount'] != null)
           ? int.parse(jdata['detailCount'].toString().trim()) : 0,
      // lShippingDetailID: (jdata['lShippingDetailID'] != null)
      //     ? int.parse(jdata['lShippingDetailID'].toString().trim()) : 0,
      // lGoodsId: (jdata['lGoodsId'] != null)
      //     ? int.parse(jdata['lGoodsId'].toString().trim()) : 0,
      // sGoodsName: (jdata['sGoodsName'] != null)
      //     ? jdata['sGoodsName'].toString().trim() : "",
      // lGoodsCount: (jdata['lGoodsCount'] != null)
      //     ? int.parse(jdata['lGoodsCount'].toString().trim()) : 0,
      //
      // lConfirmCount: (jdata['lConfirmCount'] != null)
      //     ? int.parse(jdata['lConfirmCount'].toString().trim()) : 0,
      //
      // fState: (jdata['fState'] != null)
      //     ? int.parse(jdata['fState'].toString().trim()) : 0,
    );
    return item;
  }
}