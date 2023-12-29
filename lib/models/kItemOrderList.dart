import 'package:distribution/common/dateForm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemOrderList {
  int lWholeSaleOrderID;
  String sDtOrdered;
  String sEmployeeName;
  int fOrderState;
  String sOrderState;
  ItemOrderList({
    this.sEmployeeName = "",
    this.sDtOrdered = "",
    this.lWholeSaleOrderID = 0,
    this.fOrderState = 0,
    this.sOrderState = "",
  });

  static List<ItemOrderList> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemOrderList.fromJson(data);
    }).toList();
  }

  factory ItemOrderList.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemOrderList item = ItemOrderList(
      lWholeSaleOrderID: (jdata['lWholeSaleOrderID'] != null)
          ? int.parse(jdata['lWholeSaleOrderID'].toString().trim()) : 0,
      sDtOrdered: (jdata['sDtOrdered'] != null)
          ? jdata['sDtOrdered'].toString().trim() : "",
      sEmployeeName: (jdata['sEmployeeName'] != null)
          ? jdata['sEmployeeName'].toString().trim() : "",
      fOrderState: (jdata['fOrderState'] != null)
          ? int.parse(jdata['fOrderState'].toString().trim()) : 0,
      sOrderState: (jdata['sOrderState'] != null)
          ? jdata['sOrderState'].toString().trim() : "",
    );

    if(item.sDtOrdered.isNotEmpty) {
      item.sDtOrdered = DateForm.cvtDateStamp(item.sDtOrdered);
    }
    return item;
  }
}