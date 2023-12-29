import 'package:flutter/material.dart';

class ItemPBoxInGoods {
  String sBoxBarcode;      // 박스 바코드
  String sGoodsName;       // 상품명
  String sBarcode;         // 상품 바코드
  int    lGoodsID;         // 상품코드
  int    lGoodsCount;      // 포장 수량
  //int    lConfirmCount;    // 배분 수량
  bool    isChecked;        // 처리상태 (App only)
  bool    hasFocus;         // 바코드 스캔된 항목 (App only)
  TextEditingController? controller;    //

  ItemPBoxInGoods({
    this.sBoxBarcode = "",
    this.lGoodsID = 0,
    this.sGoodsName="",
    this.sBarcode = "",
    this.lGoodsCount = 0,
    this.controller,
    this.isChecked = false,
    this.hasFocus = false,
  });

  static List<ItemPBoxInGoods> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemPBoxInGoods.fromJson(data);
    }).toList();
  }

  factory ItemPBoxInGoods.fromJson(Map<String, dynamic> jdata)
  {
    return ItemPBoxInGoods(
      lGoodsID: (jdata['lGoodsID'] != null)
          ? int.parse(jdata['lGoodsID'].toString().trimLeft()) : 0,
      sGoodsName: (jdata['sGoodsName'] != null)
          ? jdata['sGoodsName'] : "",
      sBarcode: (jdata['sBarcode'] != null)
          ? jdata['sBarcode'].toString().trim() : "",
      sBoxBarcode: (jdata['sBoxBarcode'] != null)
          ? jdata['sBoxBarcode'].toString().trim() : "",
      lGoodsCount: int.parse(jdata['lGoodsCount'].toString().trimLeft()),
      // lConfirmCount: (jdata['lConfirmCount'] != null)
      //     ? int.parse(jdata['lConfirmCount'].toString().trimLeft()) : 0,
    );
  }
}
