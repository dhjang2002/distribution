import 'package:distribution/models/kItemStockInspect.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ItemStockGoodsInfo {
  int lGoodsId;
  int lStockInspectID;
  String sName;
  String sBarcode;
  String sLotNo;
  String sLotMemo;
  int rNowStock;
  int isStockInspect;
  ItemStcokInspect? inspectData;

  ItemStockGoodsInfo({
    this.lStockInspectID=0,
    this.sLotNo = "",
    this.sLotMemo = "",
    this.lGoodsId = 0,
    this.sName = "",
    this.sBarcode="",
    this.rNowStock = 0,
    this.isStockInspect=0,
    this.inspectData,
  });

  static List<ItemStockGoodsInfo> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemStockGoodsInfo.fromJson(data);
    }).toList();
  }

  factory ItemStockGoodsInfo.fromJson(Map<String, dynamic> goodsData)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(goodsData);
    }

    // var goodsData   = data['goodsData'];
    // int lStockInspectID = (goodsData['lStockInspectID'] != null)
    //     ? int.parse(goodsData['lStockInspectID'].toString().trim()) : 0;

    ItemStockGoodsInfo item = ItemStockGoodsInfo(
      lStockInspectID: (goodsData['lStockInspectID'] != null)
          ? int.parse(goodsData['lStockInspectID'].toString().trim()) : 0,
      sLotNo: (goodsData['sLotNo'] != null)
          ? goodsData['sLotNo'].toString().trim() : "",
      sLotMemo: (goodsData['sLotMemo'] != null)
          ? goodsData['sLotMemo'].toString().trim() : "",
      lGoodsId: (goodsData['lGoodsID'] != null)
          ? int.parse(goodsData['lGoodsID'].toString().trim()) : 0,
      sName: (goodsData['sName'] != null)
          ? goodsData['sName'].toString().trim() : "",
      sBarcode: (goodsData['sBarcode'] != null)
          ? goodsData['sBarcode'].toString().trim() : "",
      rNowStock: (goodsData['rNowStock'] != null)
          ? int.parse(goodsData['rNowStock'].toString().trim()) : 0,

      isStockInspect:(goodsData['isStockInspect'] != null)
            ? int.parse(goodsData['isStockInspect'].toString().trim()) : 0,
      inspectData: ItemStcokInspect.fromJson(goodsData),
    );

    return item;
  }
}