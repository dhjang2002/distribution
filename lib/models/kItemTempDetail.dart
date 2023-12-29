import 'package:distribution/models/kItemStockInspect.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ItemTempDetail {
  int lDetailId;
  int lGoodsId;
  double mNormalPrice;
  int mSalePrice;
  String sMemo;
  int fState;
  String sState;
  String sBarcode;
  String sName;
  String sLotNo;
  String sLotMemo;
  int rNowStock;

  bool bSelect;
  ItemTempDetail({
    this.fState=0,
    this.sState="",
    this.lGoodsId=0,
    this.sName = "",
    this.sLotNo = "",
    this.sLotMemo = "",
    this.lDetailId = 0,
    this.sMemo = "",
    this.sBarcode="",
    this.mNormalPrice = 0,
    this.mSalePrice=0,
    this.rNowStock=0,

    this.bSelect = false,
  });

  static List<ItemTempDetail> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemTempDetail.fromJson(data);
    }).toList();
  }

  factory ItemTempDetail.fromJson(Map<String, dynamic> goodsData)
  {
    // if (kDebugMode) {
    //   var logger = Logger();
    //   logger.d(goodsData);
    // }

    ItemTempDetail item = ItemTempDetail(
      lGoodsId:(goodsData['lGoodsId'] != null)
            ? int.parse(goodsData['lGoodsId'].toString().trim()) : 0,
      sName: (goodsData['sName'] != null)
          ? goodsData['sName'].toString().trim() : "",
      sLotMemo: (goodsData['sLotMemo'] != null)
          ? goodsData['sLotMemo'].toString().trim() : "",
      lDetailId: (goodsData['lDetailId'] != null)
          ? int.parse(goodsData['lDetailId'].toString().trim()) : 0,
      sMemo: (goodsData['sMemo'] != null)
          ? goodsData['sMemo'].toString().trim() : "",
      sBarcode: (goodsData['sBarcode'] != null)
          ? goodsData['sBarcode'].toString().trim() : "",
      mNormalPrice: (goodsData['mNormalPrice'] != null)
          ? double.parse(goodsData['mNormalPrice'].toString().trim()) : 0,
      mSalePrice: (goodsData['mSalePrice'] != null)
          ? int.parse(goodsData['mSalePrice'].toString().trim()) : 0,
      rNowStock: (goodsData['rNowStock'] != null)
          ? int.parse(goodsData['rNowStock'].toString().trim()) : 0,
      fState: (goodsData['fState'] != null)
          ? int.parse(goodsData['fState'].toString().trim()) : 0,
      sState: (goodsData['sState'] != null)
          ? goodsData['sState'].toString().trim() : "",
    );
    return item;
  }
}