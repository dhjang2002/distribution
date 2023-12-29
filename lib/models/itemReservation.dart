
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:distribution/models/itemPhoto.dart';

class ItemReservation {
  String? ReservationNo;        // 예약번호 (Key)
  String? ReservationStatus;    // 예약상태 (예약완료/최소완료)
  String? ReservationDate;      // 예약일자
  String? ReservationSpec;      // 예약상세(인원/타입/추가옵션)
  String  ContentID;            // 행사ID
  String? ContentTitle;         // 행사명
  String? EventDate;            // 행사일자
  List<ItemPhoto>? ContentPhotoList;  // 행사 대표사진

  ItemReservation({
    this.ContentID="",
    this.ContentTitle = "",
    this.EventDate = "",
    this.ReservationStatus = "",
    this.ReservationNo = "",
    this.ReservationDate = "",
    this.ReservationSpec = "",
    this.ContentPhotoList = const <ItemPhoto>[],
  });

  static List<ItemReservation> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemReservation.fromContent(data);
    }).toList();
  }

  factory ItemReservation.fromJson(Map<String, dynamic> jdata)
  {
    return ItemReservation(
    );

  }

  factory ItemReservation.fromContent(Map<String, dynamic> parsedJson) {
    ItemReservation item = ItemReservation();
    if (kDebugMode) {
      print("ItemReservation::fromContent()==========>");
      var logger = Logger();
      logger.d(parsedJson);
    }

    var reserved_session = parsedJson['session_list']['reserved_session'];

    // "예약상태"; [최소요청, 취소완료, 예약완료]
    item.ReservationStatus = StatusText(parsedJson['status']);
    item.ContentID         = parsedJson['content_oid'];
    item.ContentTitle      = parsedJson['content_title'];
    item.EventDate         = reserved_session['date_info']['event_date'];
    item.ReservationNo     = parsedJson['reservation_oid'];
    item.ReservationDate   = parsedJson['date_created'];
    item.ReservationSpec = "인원:"+parsedJson['participants'];

    if(reserved_session['zone_info']['zone'] != null) {
      item.ReservationSpec  = item.ReservationSpec!
          + " / 구역:${reserved_session['zone_info']['zone']}";
    }

    if(parsedJson['equipment_list'] != null) {
      if (parsedJson['equipment_list']['equipment'] != null) {
        var equipList = parsedJson['equipment_list']['equipment'];
        String equipInfo = "";
        if (equipList is List) {
          for (int n = 0; n < equipList.length; n++) {
            var item = equipList[n];
            if (equipInfo.isNotEmpty) {
              equipInfo = equipInfo + " / ";
            }
            equipInfo = equipInfo + "${item['equipment']} ${item['qty']}";
          }
        }
        else {
          equipInfo =
              equipInfo + "${equipList['equipment']} ${equipList['qty']}";
        }

        print("<><><><><><><");
        print(equipInfo);
        if (equipInfo.isNotEmpty) {
          item.ReservationSpec = item.ReservationSpec! + " / ${equipInfo}";
        }
      }
    }
    // 사진
    if(parsedJson['image_list'] != null) {
      var images = parsedJson['image_list']['image'];
      if(images != null) {
        if (images is List) {
          item.ContentPhotoList = ItemPhoto.fromSnapshot(images);
        }
        else {
          item.ContentPhotoList = ItemPhoto.fromSnapshot([images]);
        }
      }
    }
    return item;
  }

  static String StatusText(String status) {
    if(status==null)
      return "NULL";

    switch(status) {
      case "A": return "예약완료";
      case "C": return "취소요청";
      case "CC": return "취소완료";
      case "D": return "행사완료";
      default: return status;
    }
  }

  static Future<List<ItemReservation>> getTestItem(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));

    List<ItemReservation> list = <ItemReservation>[];
    list.add(ItemReservation(
        ReservationNo: "2106141745623",
        ContentTitle: "2021 핸드메이드 페어 (윈터)",
        EventDate: "2021.04.26 14:00",
        ReservationSpec: "인원:1명 / 타입:A구역 / 추가옵션:1번,2번",
        ReservationDate: "2021.08.21 09:45",
        ReservationStatus:"예약완료",
        ContentPhotoList:[ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_box01.png")]),
    );

    list.add(ItemReservation(
        ReservationNo: "2106141745623",
        ContentTitle: "2021 핸드메이드 페어 (윈터)",
        EventDate: "2021.04.26 14:00",
        ReservationSpec: "인원:1명 / 타입:A구역 / 추가옵션:1번,2번",
        ReservationDate: "2021.08.21 09:45",
        ReservationStatus:"취소요청",
        ContentPhotoList:[ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_box03.png")]),
    );

    list.add(ItemReservation(
        ReservationNo: "2106141745623",
        ContentTitle: "2021 핸드메이드 페어 (윈터)",
        EventDate: "2021.04.26 14:00",
        ReservationSpec: "인원:1명 / 타입:A구역 / 추가옵션:1번,2번",
        ReservationDate: "2021.08.21 09:45",
        ReservationStatus:"취소완료",
        ContentPhotoList:[ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_box02.png")]),
    );
    return list;
  }
  static Future<List<ItemReservation>> getTestCancelItem(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));

    List<ItemReservation> list = <ItemReservation>[];
    list.add(ItemReservation(
        ReservationNo: "2106141745623",
        ContentTitle: "2021 핸드메이드 페어 (윈터)",
        EventDate: "2021.04.26 14:00",
        ReservationSpec: "인원:1명 / 타입:A구역 / 추가옵션:1번,2번",
        ReservationDate: "2021.08.21 09:45",
        ReservationStatus:"취소완료",
        ContentPhotoList:[ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_box01.png")]),
    );

    list.add(ItemReservation(
        ReservationNo: "2106141745623",
        ContentTitle: "2021 핸드메이드 페어 (윈터)",
        EventDate: "2021.04.26 14:00",
        ReservationSpec: "인원:1명 / 타입:A구역 / 추가옵션:1번,2번",
        ReservationDate: "2021.08.21 09:45",
        ReservationStatus:"취소요청",
        ContentPhotoList:[ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_box03.png")]),
    );

    list.add(ItemReservation(
        ReservationNo: "2106141745623",
        ContentTitle: "2021 핸드메이드 페어 (윈터)",
        EventDate: "2021.04.26 14:00",
        ReservationSpec: "인원:1명 / 타입:A구역 / 추가옵션:1번,2번",
        ReservationDate: "2021.08.21 09:45",
        ReservationStatus:"취소완료",
        ContentPhotoList:[ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_box02.png")]),
    );
    return list;
  }
}

