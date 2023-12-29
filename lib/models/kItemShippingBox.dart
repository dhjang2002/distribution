import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemShippingBox {
  int lShippingId;
  String sBoxNo;
  int cnt;
  int fState;
  String sEmployeeName;

  ItemShippingBox({
    this.lShippingId = 0,
    this.cnt = 0,
    this.sEmployeeName = "",
    this.sBoxNo="",
    this.fState = 0,
  });

  static List<ItemShippingBox> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemShippingBox.fromJson(data);
    }).toList();
  }

  factory ItemShippingBox.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemShippingBox item = ItemShippingBox(
        lShippingId: (jdata['lShippingId'] != null)
          ? int.parse(jdata['lShippingId'].toString().trim()) : 0,
      cnt: (jdata['cnt'] != null)
          ? int.parse(jdata['cnt'].toString().trim()) : 0,
      sEmployeeName: (jdata['sEmployeeName'] != null)
          ? jdata['sEmployeeName'].toString().trim() : "",
      sBoxNo: (jdata['sBoxNo'] != null)
          ? jdata['sBoxNo'].toString().trim() : "",
      fState: (jdata['fState'] != null)
          ? int.parse(jdata['fState'].toString().trim()) : 0,
    );

    return item;
  }

}