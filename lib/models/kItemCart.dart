import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemCart {
  String lBasketID;
  int lGoodsID;
  String sGoodsName;
  int lCount;
  int lPrice;
  bool bCheck;
  TextEditingController? controller;
  ItemCart({
    this.lBasketID = "",
    this.sGoodsName = "",
    this.lGoodsID = 0,
    this.lCount = 1,
    this.lPrice=0,
    this.bCheck = false,
    this.controller,
  });

  static List<ItemCart> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemCart.fromJson(data);
    }).toList();
  }

  factory ItemCart.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemCart item = ItemCart(
      lBasketID: (jdata['lBasketID'] != null)
          ? jdata['lBasketID'].toString().trim() : "",
      lGoodsID: (jdata['lGoodsID'] != null)
          ? int.parse(jdata['lGoodsID'].toString().trim()) : 0,
      sGoodsName: (jdata['sGoodsName'] != null)
          ? jdata['sGoodsName'].toString().trim() : "",
      lCount: (jdata['lCount'] != null)
          ? int.parse(jdata['lCount'].toString().trim()) : 0,
      lPrice: (jdata['mPrice'] != null)
          ? int.parse(jdata['mPrice'].toString().trim()) : 0,
    );
    return item;
  }
}