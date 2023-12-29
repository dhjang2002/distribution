
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ItemHBox {
  String sBoxNo;
  int totalCount;
  int finishCount;
  bool isChecked;
  bool hasFocus;

  ItemHBox({
    this.isChecked = false,
    this.hasFocus = false,
    this.sBoxNo = "",
    this.totalCount  = -1,
    this.finishCount = -1,
  });

  @override
  String toString() {
    return 'ItemHBox{'
        'sBoxNo=>$sBoxNo<'
        'totalCount=$totalCount'
        'finishCount=$finishCount'
        '}';
    // TODO: implement toString
    //return super.toString();
  }

  static List<ItemHBox> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemHBox.fromJson(data);
    }).toList();
  }

  factory ItemHBox.fromJson(Map<String, dynamic> jdata)
  {
    // if (kDebugMode) {
    //   var logger = Logger();
    //   logger.d(jdata);
    // }

    int totalCount = (int.tryParse(jdata['totalCount'].toString().trim()) != null)
        ? int.parse(jdata['totalCount'].toString().trim()) : -1;
    int finishCount = (int.tryParse(jdata['finishCount'].toString().trim()) != null)
        ? int.parse(jdata['finishCount'].toString().trim()) : -1;
    return ItemHBox(
      sBoxNo: (jdata['sBoxNo'] != null) ? jdata['sBoxNo'].toString().trim() : "",
      totalCount: totalCount,
      finishCount: finishCount,
        isChecked : (totalCount==finishCount)
    );
  }
}