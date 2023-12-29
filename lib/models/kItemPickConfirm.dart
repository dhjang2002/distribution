import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemPickConfirm {
  int lShippingID;
  int lShippingDetailID;
  String sShippingNo;
  int lGoodsCount;
  int lPickingCount;
  int lPickingEmpId;

  int fState;



  int lGoodsId;
  String sGoodsName;
  String sBarcode;

  String sLotNo;
  String sLotMemo;
  String sStoreName;
  int rNowStock;

  bool isTarget;
  bool hasFocus;
  bool bScaned;
  bool bSelect;
  bool bValid;
  TextEditingController? controller;

  ItemPickConfirm({
    this.lShippingID=0,
    this.lShippingDetailID=0,

    this.sStoreName="",
    this.sShippingNo="",
    this.fState = 0,

    this.sLotNo = "",
    this.sLotMemo = "",

    this.lGoodsId = 1,
    this.sGoodsName = "",
    this.sBarcode = "",
    this.lGoodsCount = 0,
    this.lPickingCount = -1,
    this.lPickingEmpId = 0,
    this.rNowStock = 0,

    this.isTarget = false,
    this.hasFocus = false,
    this.bScaned = false,
    this.bSelect = false,
    this.bValid = false,
    this.controller,
  });

  void copy(ItemPickConfirm item) {
    this.lShippingID=item.lShippingID;
    this.lShippingDetailID=item.lShippingDetailID;
    this.sStoreName=item.sStoreName;
    this.fState = item.fState;
    this.sLotNo = item.sLotNo;
    this.sLotMemo = item.sLotMemo;
    this.lGoodsId = item.lGoodsId;
    this.sGoodsName = item.sGoodsName;
    this.sBarcode = item.sBarcode;
    this.lGoodsCount = item.lGoodsCount;
    this.lPickingCount = item.lPickingCount;
    this.rNowStock = item.rNowStock;
  }

  static List<ItemPickConfirm> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemPickConfirm.fromJson(data);
    }).toList();
  }

  factory ItemPickConfirm.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemPickConfirm item = ItemPickConfirm(
      lShippingID: (jdata['lShippingID'] != null)
          ? int.parse(jdata['lShippingID'].toString().trim()) : 0,
      lShippingDetailID: (jdata['lShippingDetailID'] != null)
          ? int.parse(jdata['lShippingDetailID'].toString().trim()) : 0,
      fState: (jdata['fState'] != null)
          ? int.parse(jdata['fState'].toString().trim()) : 0,

      sLotNo: (jdata['sLotNo'] != null)
          ? jdata['sLotNo'].toString().trim() : "",
      sLotMemo: (jdata['sLotMemo'] != null)
          ? jdata['sLotMemo'].toString().trim() : "",

      lGoodsId: (jdata['lGoodsId'] != null)
          ? int.parse(jdata['lGoodsId'].toString().trim()) : 0,
      sGoodsName: (jdata['sGoodsName'] != null)
          ? jdata['sGoodsName'].toString().trim() : "",
      sStoreName: (jdata['sStoreName'] != null)
            ? jdata['sStoreName'].toString().trim() : "",
      sShippingNo: (jdata['sShippingNo'] != null)
          ? jdata['sShippingNo'].toString().trim() : "",
      sBarcode: (jdata['sBarcode'] != null)
          ? jdata['sBarcode'].toString().trim() : "",
      rNowStock: (jdata['rNowStock'] != null)
          ? int.parse(jdata['rNowStock'].toString().trim()) : 0,

      lGoodsCount: (jdata['lGoodsCount'] != null)
          ? int.parse(jdata['lGoodsCount'].toString().trim()) : 0,

      lPickingCount: (jdata['lPickingCount'] != null)
          ? int.parse(jdata['lPickingCount'].toString().trim()) : 0,
      lPickingEmpId: (jdata['lPickingEmpId'] != null)
          ? int.parse(jdata['lPickingEmpId'].toString().trim()) : 0,
    );
    return item;
  }
}