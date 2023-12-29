import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ItemOrder {
  String sGoodsName;
  int lGoodsCount;
  int mPrice;
  ItemOrder({
    this.sGoodsName = "",
    this.lGoodsCount = 0,
    this.mPrice = 0,
  });

  static List<ItemOrder> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemOrder.fromJson(data);
    }).toList();
  }

  factory ItemOrder.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemOrder item = ItemOrder(
      mPrice: (jdata['mPrice'] != null)
          ? int.parse(jdata['mPrice'].toString().trim()) : 0,
      sGoodsName: (jdata['sGoodsName'] != null)
          ? jdata['sGoodsName'].toString().trim() : "",
      lGoodsCount: (jdata['lGoodsCount'] != null)
          ? int.parse(jdata['lGoodsCount'].toString().trim()) : 0,
    );
    return item;
  }
}