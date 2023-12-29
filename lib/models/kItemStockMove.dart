import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemStockMove {
  int lStockMoveLogId;
  String sTargetStoreName;
  int lTargetStoreId;
  int rMoveStock;
  String sRegDate;
  String sMemo;

  bool isTarget;
  bool hasFocus;

  ItemStockMove({
    this.lStockMoveLogId = 0,
    this.lTargetStoreId = 0,
    this.sTargetStoreName="",
    this.rMoveStock = 0,
    this.sRegDate = "",
    this.sMemo="",

    this.isTarget      = false,
    this.hasFocus      = false,
  });

  static List<ItemStockMove> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemStockMove.fromJson(data);
    }).toList();
  }

  factory ItemStockMove.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemStockMove item = ItemStockMove(
      lStockMoveLogId: (jdata['lStockMoveLogId'] != null)
          ? int.parse(jdata['lStockMoveLogId'].toString().trim()) : 0,

      sTargetStoreName: (jdata['sTargetStoreName'] != null)
          ? jdata['sTargetStoreName'].toString().trim() : "",

      lTargetStoreId: (jdata['lTargetStoreId'] != null)
          ? int.parse(jdata['lTargetStoreId'].toString().trim()) : 0,

      rMoveStock: (jdata['rMoveStock'] != null)
          ? int.parse(jdata['rMoveStock'].toString().trim()) : 0,

      sRegDate: (jdata['sRegDate'] != null)
          ? jdata['sRegDate'].toString().trim() : "",
      sMemo: (jdata['sMemo'] != null)
          ? jdata['sMemo'].toString().trim() : "",

    );

    return item;
  }
}