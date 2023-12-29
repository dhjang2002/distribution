import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemDistDataQty {
  int    lWarehousingDetailID;
  int    lWarehousingID;
  String sStoreName;       // 매장명
  int    lStoreId;         // 매장번호
  int    lGoodsCount;      // 입고예정 상품수량
  int    lConfirmCount;    // 입고배정 확인수량
  int    fConfirm;
  TextEditingController? controller;

  ItemDistDataQty({
    this.lWarehousingDetailID = 0,
    this.lWarehousingID = 0,
    this.lStoreId = 0,
    this.lGoodsCount = 0,
    this.lConfirmCount = 0,
    this.fConfirm = 0,
    this.sStoreName="",
    this.controller,
  });

  @override
  String toString() {
    return (
        '{ "lWarehousingDetailID":"$lWarehousingDetailID",'
        '"lConfirmCount":"$lConfirmCount" }'
    );
  }

  static List<ItemDistDataQty> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemDistDataQty.fromJson(data);
    }).toList();
  }

  Map<String, dynamic> toJson() => {
    "lWarehousingDetailID": "$lWarehousingDetailID",
    "lConfirmCount": "$lConfirmCount",
  };

  Map<String, dynamic> toMap(){
    return {
      "lWarehousingDetailID":"$lWarehousingDetailID",
      "lStoreId":"$lStoreId",
      "lConfirmCount":"$lConfirmCount",
      "lGoodsCount":"$lGoodsCount",
      "sStoreName":sStoreName
    };
  }
  /*
    "lWarehousingDetailID": 2014709,
    "sStoreName": "동서울",
    "lStoreId": 457,
    "lGoodsCount": 2,
    "lConfirmCount": null
   */
  factory ItemDistDataQty.fromJson(Map<String, dynamic> jdata)
  {
    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }

    ItemDistDataQty data = ItemDistDataQty(
      lWarehousingDetailID: (jdata['lWarehousingDetailID'] != null)
          ? int.parse(jdata['lWarehousingDetailID'].toString().trimLeft()) : 0,
      lWarehousingID: (jdata['lWarehousingID'] != null)
          ? int.parse(jdata['lWarehousingID'].toString().trimLeft()) : 0,
      sStoreName: (jdata['sStoreName'] != null)
          ? jdata['sStoreName'] : "",

      lStoreId: (jdata['lStoreId'] != null)
          ? int.parse(jdata['lStoreId'].toString().trim()) : 0,

      lGoodsCount: (jdata['lGoodsCount'] != null)
          ? int.parse(jdata['lGoodsCount'].toString().trim()) : 0,

      lConfirmCount: (jdata['lConfirmCount'] != null)
          ? int.parse(jdata['lConfirmCount'].toString().trim()) : -1,

      fConfirm: (jdata['fConfirm'] != null)
          ? int.parse(jdata['fConfirm'].toString().trim()) : 0,
    );

    // 입고 확정이 안된경우
    if(data.fConfirm == 0) {
      // 초기 데이터 겂을 입고예정 수량으로 초기화 한다.
      // -> 이상없을 경우 작업 단순화 목적임.
      if(data.lConfirmCount<0) {
        data.lConfirmCount = data.lGoodsCount;
      }
    } else {
      if(data.lConfirmCount<0) {
        data.lConfirmCount = 0;
      }
    }
    return data;
  }
}
