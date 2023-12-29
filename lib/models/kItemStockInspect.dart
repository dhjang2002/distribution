import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemStcokInspect {
  int lStockInspectID;
  int lStockInspectDetailID;
  String sLot1;
  String sLot2;
  String sLot3;
  String sMemo;
  int rVirtualStock;
  int rRealStock;
  int rGapStock;

  TextEditingController? controller;
  ItemStcokInspect({
    this.lStockInspectID=0,
    this.lStockInspectDetailID=0,
    this.sLot1 = "",
    this.sLot2 = "",
    this.sLot3 = "",
    this.sMemo="",
    this.rVirtualStock = 0,
    this.rRealStock    = 0,
    this.rGapStock     = 0,
    this.controller,
  });

  static List<ItemStcokInspect> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemStcokInspect.fromJson(data);
    }).toList();
  }

  factory ItemStcokInspect.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemStcokInspect item = ItemStcokInspect(
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
      rGapStock: (jdata['rGapStock'] != null)
          ? int.parse(jdata['rGapStock'].toString().trim()) : 0,
      rVirtualStock: (jdata['rVirtualStock'] != null)
          ? int.parse(jdata['rVirtualStock'].toString().trim()) : 0,
      rRealStock: (jdata['rRealStock'] != null)
          ? int.parse(jdata['rRealStock'].toString().trim()) : 0,
    );

    item.rGapStock = item.rRealStock-item.rVirtualStock;
    return item;
  }
}