import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemRequestMaster {
  int lDeliveryRequestID;
  int lStoreID;
  String sStoreCode;
  String sStoreEmpName;
  String dtRequested;

  int fRequestState;
  String sRequestState;
  int lEmployeeID;
  String sEmployeeName;
  String sStoreName;
  int count;
  bool bSelect;
  ItemRequestMaster({
    this.lDeliveryRequestID = 0,
    this.lStoreID = 0,
    this.sStoreCode = "",
    this.sStoreEmpName="",
    this.dtRequested="",
    this.fRequestState = 1,
    this.sRequestState = "",
    this.lEmployeeID=0,
    this.sEmployeeName="",
    this.sStoreName="",
    this.count=0,
    this.bSelect = false,
  });

  static List<ItemRequestMaster> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemRequestMaster.fromJson(data);
    }).toList();
  }

  factory ItemRequestMaster.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemRequestMaster item = ItemRequestMaster(
        lDeliveryRequestID: (jdata['lDeliveryRequestID'] != null)
          ? int.parse(jdata['lDeliveryRequestID'].toString().trim()) : 0,
      lStoreID: (jdata['lStoreID'] != null)
          ? int.parse(jdata['lStoreID'].toString().trim()) : 0,
      lEmployeeID: (jdata['lEmployeeID'] != null)
          ? int.parse(jdata['lEmployeeID'].toString().trim()) : 0,
      count: (jdata['count'] != null)
          ? int.parse(jdata['count'].toString().trim()) : 0,
      sStoreCode: (jdata['sStoreCode'] != null)
          ? jdata['sStoreCode'].toString().trim() : "",
      sEmployeeName: (jdata['sEmployeeName'] != null)
          ? jdata['sEmployeeName'].toString().trim() : "",
      sStoreEmpName: (jdata['sStoreEmpName'] != null)
          ? jdata['sStoreEmpName'].toString().trim() : "",
      sStoreName: (jdata['sStoreName'] != null)
          ? jdata['sStoreName'].toString().trim() : "",
      sRequestState: (jdata['sRequestState'] != null)
          ? jdata['sRequestState'].toString().trim() : "",
      fRequestState: (jdata['fRequestState'] != null)
          ? int.parse(jdata['fRequestState'].toString().trim()) : 0,
      dtRequested: (jdata['dtRequested'] != null)
          ? jdata['dtRequested'].toString().trim() : "",
    );
    return item;
  }
}