import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class InfoStore {
  int lStoreID;        // 매장ID  "1"
  String sName;        // 매장명칭 "(주)한국다까미
  String sOwnerName;   // 대표자 "한경민"
  String sAddr;        // 주소 "부산시 사상구 학감대로 192번길 6 POINT낚시"
  String sTel;         // 전화 "051-323-9794"
  String sFax;         // 팩스 "051-325-1446"
  String sStoreState;  // "영업"
  String sStoreType;   // "본사"
  String sVendorType;  // "매입매출처"

  InfoStore({
    this.lStoreID = 0,
    this.sName="",
    this.sOwnerName="",
    this.sAddr="",
    this.sTel="",
    this.sFax="",
    this.sStoreState ="",
    this.sStoreType ="",
    this.sVendorType ="",
  });

  @override
  String toString(){
    return 'InfoStore {'
        'lStoreID:$lStoreID, '
        'sName:$sName, '
        'sOwnerName:$sOwnerName, '
        'sAddr:$sAddr, '
        'sTel:$sTel, '
        'sFax:$sFax, '
        'sStoreState:$sStoreState, '
        'sStoreType:$sStoreType, '
        'sVendorType:$sVendorType }';
  }

  static List<InfoStore> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return InfoStore.fromJson(data);
    }).toList();
  }

  factory InfoStore.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      print("InfoStore:fromJson()----------->");
      var logger = Logger();
      logger.d(jdata);
    }

    return InfoStore(
      lStoreID:(jdata['lStoreID'] != null)
          ? int.parse(jdata['lStoreID'].toString().trim()) : 0,

      sName: (jdata['sName'] != null)
          ? jdata['sName'].toString().trim() : "",

      sOwnerName: (jdata['sOwnerName'] != null)
          ? jdata['sOwnerName'].toString().trim() : "",

      sAddr: (jdata['sAddr'] != null)
          ? jdata['sAddr'].toString().trim() : "",

      sTel:(jdata['sTel'] != null)
          ? jdata['sTel'].toString().trim() : "",

      sFax:(jdata['sFax'] != null)
          ? jdata['sFax'].toString().trim() : "",

      sStoreState:(jdata['sStoreState'] != null)
          ? jdata['sStoreState'].toString().trim() : "",

      sStoreType:(jdata['sStoreType'] != null)
          ? jdata['sStoreType'].toString().trim() : "",

      sVendorType:(jdata['sVendorType'] != null)
          ? jdata['sVendorType'].toString().trim() : "",

    );
  }

}
