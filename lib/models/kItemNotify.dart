import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ItemNotify {
  int lNoticeID;
  String sTitle;       // 매장명칭
  String tContent;             // 진열위치
  String dtRegDate;
  bool showMore;

  ItemNotify({
    this.lNoticeID = 0,
    this.sTitle="",
    this.dtRegDate="",
    this.tContent ="",
    this.showMore = false,
  });

  static List<ItemNotify> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemNotify.fromJson(data);
    }).toList();
  }

  factory ItemNotify.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    return ItemNotify(
      lNoticeID:(jdata['lNoticeID'] != null)
          ? int.parse(jdata['lNoticeID'].toString().trim()) : 0,

      sTitle: (jdata['sTitle'] != null)
          ? jdata['sTitle'].toString().trim() : "",

      tContent: (jdata['tContent'] != null)
          ? jdata['tContent'].toString().trim() : "",

      dtRegDate: (jdata['dtRegDate'] != null)
          ? jdata['dtRegDate'].toString().trim() : "",
    );
  }

}
