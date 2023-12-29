import 'package:distribution/models/kItemOrder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemOrderInfo {
  int lWholeSaleOrderID;
  String sEmployeeName;
  String sOrderState;
  String sDtOrdered;
  int fOrderState;
  int totalPrice;
  List<ItemOrder> items;
  ItemOrderInfo({
    this.sEmployeeName = "",
    this.lWholeSaleOrderID = 0,
    this.sOrderState="",
    this.fOrderState = 0,
    this.sDtOrdered="",
    this.items = const [],
    this.totalPrice = 0,
  });

  void computeTotalPrice() {
    totalPrice = 0;
    items.forEach((element) {
      totalPrice = totalPrice + element.mPrice*element.lGoodsCount;
    });
  }

  static List<ItemOrderInfo> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemOrderInfo.fromJson(data);
    }).toList();
  }

  factory ItemOrderInfo.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    var info = jdata['master'];
    ItemOrderInfo item = ItemOrderInfo(
      lWholeSaleOrderID: (info['lWholeSaleOrderID'] != null)
          ? int.parse(info['lWholeSaleOrderID'].toString().trim()) : 0,
      fOrderState: (info['fOrderState'] != null)
          ? int.parse(info['fOrderState'].toString().trim()) : 0,
      sOrderState: (info['sOrderState'] != null)
          ? info['sOrderState'].toString().trim() : "",
      sEmployeeName: (info['sEmployeeName'] != null)
          ? info['sEmployeeName'].toString().trim() : "",
      sDtOrdered: (info['sDtOrdered'] != null)
          ? info['sDtOrdered'].toString().trim() : "",
      items: ItemOrder.fromSnapshot(jdata['detail']),
    );
    item.computeTotalPrice();
    return item;
  }
}