import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ItemPackedGoods {
  int lPackingID;
  int lPackingCount;
  int lGoodsId;
  String sBarcode;
  String sGoodsName;
  int fState;
  String sState;

  bool hasFocus;
  ItemPackedGoods({
    this.lGoodsId=0,
    this.sBarcode="",
    this.sGoodsName = "",
    this.lPackingID = 0,
    this.lPackingCount = 0,
    this.fState = 0,
    this.sState = "",
    this.hasFocus = false,
  });

  void copy(ItemPackedGoods item) {
    lGoodsId=item.lGoodsId;
    sBarcode=item.sBarcode;
    sGoodsName = item.sGoodsName;
    lPackingID = item.lPackingID;
    lPackingCount = item.lPackingCount;
    //fState = item.fState;
  }
  static List<ItemPackedGoods> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemPackedGoods.fromJson(data);
    }).toList();
  }

  factory ItemPackedGoods.fromJson(Map<String, dynamic> jdata)
  {
    // if (kDebugMode) {
    //   var logger = Logger();
    //   logger.d(jdata);
    // }

    ItemPackedGoods item = ItemPackedGoods(
      lPackingID: (jdata['lPackingID'] != null)
          ? int.parse(jdata['lPackingID'].toString().trim()) : 0,

      lPackingCount: (jdata['lPackingCount'] != null)
          ? int.parse(jdata['lPackingCount'].toString().trim()) : 0,

      lGoodsId: (jdata['lGoodsId'] != null)
          ? int.parse(jdata['lGoodsId'].toString().trim()) : 0,
      sBarcode: (jdata['sBarcode'] != null)
          ? jdata['sBarcode'].toString().trim() : "",
      sGoodsName: (jdata['sGoodsName'] != null)
          ? jdata['sGoodsName'].toString().trim() : "",

      fState: (jdata['fState'] != null)
          ? int.parse(jdata['fState'].toString().trim()) : 0,

      sState: (jdata['sState'] != null)
          ? jdata['sState'].toString().trim() : "",
    );

    return item;
  }
}