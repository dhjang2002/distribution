import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ItemPackGoods {
  int lTotalPickingCount;
  int lTotalPackingCount;
  int lTotalCurrentPackingCount;
  int lGoodsId;
  String sBarcode;
  String sGoodsName;

  ItemPackGoods({
    this.lGoodsId=0,
    this.sBarcode="",
    this.sGoodsName = "",
    this.lTotalPickingCount = 0,
    this.lTotalPackingCount = 0,
    this.lTotalCurrentPackingCount = 0,
  });

  void copy(ItemPackGoods item) {
    lGoodsId=item.lGoodsId;
    sBarcode=item.sBarcode;
    sGoodsName = item.sGoodsName;
    lTotalPickingCount = item.lTotalPickingCount;
    lTotalPackingCount = item.lTotalPackingCount;
    lTotalCurrentPackingCount = item.lTotalCurrentPackingCount;
  }
  static List<ItemPackGoods> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemPackGoods.fromJson(data);
    }).toList();
  }

  factory ItemPackGoods.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemPackGoods item = ItemPackGoods(
      lGoodsId: (jdata['lGoodsId'] != null)
          ? int.parse(jdata['lGoodsId'].toString().trim()) : 0,
      sBarcode: (jdata['sBarcode'] != null)
          ? jdata['sBarcode'].toString().trim() : "",
      sGoodsName: (jdata['sGoodsName'] != null)
          ? jdata['sGoodsName'].toString().trim() : "",

      lTotalPickingCount: (jdata['lTotalPickingCount'] != null)
          ? int.parse(jdata['lTotalPickingCount'].toString().trim()) : 0,

      lTotalPackingCount: (jdata['lTotalPackingCount'] != null)
          ? int.parse(jdata['lTotalPackingCount'].toString().trim()) : 0,

      lTotalCurrentPackingCount: (jdata['lTotalCurrentPackingCount'] != null)
          ? int.parse(jdata['lTotalCurrentPackingCount'].toString().trim()) : 0,
    );

    return item;
  }
}