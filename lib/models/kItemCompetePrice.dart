
// ignore_for_file: file_names
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ItemCompetePrice {
  int lStorePriceID;
  int lGoodsID;
  String sGoodsName;
  String sState;
  String dtRequest;
  String dtApproved;
  int mBeforePrice;
  int mAfterPrice;
  int mApprovedPrice;
  String sReasonMemo;

  bool hasFocus;
  bool isTarget;
  ItemCompetePrice({
    this.lStorePriceID = 0,
    this.lGoodsID=0,
    this.sGoodsName = "",
    this.sState="",
    this.dtRequest="",
    this.dtApproved="",
    this.mBeforePrice = 0,
    this.mAfterPrice = 0,
    this.mApprovedPrice = 0,
    this.sReasonMemo="",
    this.hasFocus = false,
    this.isTarget = false,
  });

  static List<ItemCompetePrice> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemCompetePrice.fromJson(data);
    }).toList();
  }

  factory ItemCompetePrice.fromJson(Map<String, dynamic> info)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(info);
    }

    ItemCompetePrice item = ItemCompetePrice(
      lStorePriceID: (info['lStorePriceID'] != null)
          ? int.parse(info['lStorePriceID'].toString().trim()) : 0,
      lGoodsID: (info['lGoodsID'] != null)
          ? int.parse(info['lGoodsID'].toString().trim()) : 0,
      sGoodsName: (info['sGoodsName'] != null)
          ? info['sGoodsName'].toString().trim() : "",
      mBeforePrice: (info['mBeforePrice'] != null)
          ? int.parse(info['mBeforePrice'].toString().trim()) : 0,
      mAfterPrice: (info['mAfterPrice'] != null)
          ? int.parse(info['mAfterPrice'].toString().trim()) : 0,
      mApprovedPrice: (info['mApprovedPrice'] != null)
          ? int.parse(info['mApprovedPrice'].toString().trim()) : 0,
      sState: (info['sState'] != null)
          ? info['sState'].toString().trim() : "",
      sReasonMemo: (info['sReasonMemo'] != null)
          ? info['sReasonMemo'].toString().trim() : "",
      dtRequest: (info['dtRequest'] != null)
          ? info['dtRequest'].toString().trim() : "",
      dtApproved: (info['dtApproved'] != null)
          ? info['dtApproved'].toString().trim() : "",
    );
    return item;
  }
}