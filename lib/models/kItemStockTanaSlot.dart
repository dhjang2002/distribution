import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemStockTanaSlot {
  String sLot2;
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

  ItemStockTanaSlot({
    this.sLot2="",
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

  static List<ItemStockTanaSlot> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemStockTanaSlot.fromJson(data);
    }).toList();
  }

  factory ItemStockTanaSlot.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemStockTanaSlot item = ItemStockTanaSlot(
      sLot2: (jdata['sLot2'] != null)
          ? jdata['sLot2'].toString().trim() : "",
      detailCount: (jdata['detailCount'] != null)
           ? int.parse(jdata['detailCount'].toString().trim()) : 0,
    );
    return item;
  }
}