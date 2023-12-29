// ignore_for_file: non_constant_identifier_names, file_names
import 'package:flutter/foundation.dart';

class InfoTicket {
  String? TicketNo;           // 예약번호
  String? TicketQRCodeUrl;    // QR코드 사진 url
  String? EventID;            // 행사 고유키
  String? EventKind;          // 행사 구분("PLAY","PLACE", "Planet")
  String? EventTitle;         // 행사명
  String? EventPlace;         // 행사장소
  String? EventType;          // 행사타입
  String? EventDate;          // 행사일시
  String? EventAddr;          // 행사장(장소) 주소
  double? EventAddrGpsLat;    // 행사장 gps 정보
  double? EventAddrGpsLon;    // 행사장 gps 정보
  String? EventPhotoUrl;      // 행사 대표사진

  InfoTicket({
    this.TicketNo="",
    this.TicketQRCodeUrl="",
    this.EventID = "",
    this.EventKind = "",
    this.EventTitle="",
    this.EventPlace="",
    this.EventType="",
    this.EventDate = "",
    this.EventAddr="",
    this.EventAddrGpsLat=0.0,
    this.EventAddrGpsLon=0.0,
    this.EventPhotoUrl="",
  });

  static List<InfoTicket> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return InfoTicket.fromJson(data);
    }).toList();
  }

  factory InfoTicket.fromJson(Map<String, dynamic> jdata)
  {
    return InfoTicket(
      TicketNo: jdata['TicketNo'],
      TicketQRCodeUrl: jdata['TicketQRCodeUrl'],
    );
  }

  static Future <List<InfoTicket>> getTicketList(int milliseconds) async {
    if (kDebugMode) {
      print("getTicketList() start ............................................");
    }
    await Future.delayed(Duration(milliseconds: milliseconds));
    List<InfoTicket> ticketList = [];
    ticketList.add(InfoTicket(
        TicketNo:"2106141745623",
        EventID: "",
        EventKind: "PLAY",
        EventTitle: "2021 핸드메이드페어(윈터)",
        EventPlace: "벡스코 제 1전시장",
        EventType: "1층 A구역",
        EventDate: "2022.06.08",
        EventAddrGpsLat: 128.0,
        EventAddrGpsLon: 127.0,
        EventAddr: "대전광역시 유성구 도룡동",
        EventPhotoUrl:"https://momo.maxidc.net/data/file/samples/sample_box01.png"));
    ticketList.add(InfoTicket(
        TicketNo:"2206031124012",
        EventID: "",
        EventKind: "PLAY",
        EventTitle: "2021 핸드메이드페어(스프링)",
        EventPlace: "벡스코 제 1전시장",
        EventType: "1층 A구역",
        EventDate: "2022.06.07",
        EventAddrGpsLat: 128.0,
        EventAddrGpsLon: 127.0,
        EventAddr: "대전광역시 유성구 도룡동",
        EventPhotoUrl:"https://momo.maxidc.net/data/file/samples/sample_box02.png"));
    ticketList.add(InfoTicket(
        TicketNo:"2206041608124",
        EventID: "",
        EventKind: "PLAY",
        EventTitle: "2021 핸드메이드페어(서머)",
        EventPlace: "벡스코 제 1전시장",
        EventType: "1층 A구역",
        EventDate: "2022.06.09",
        EventAddrGpsLat: 128.0,
        EventAddrGpsLon: 127.0,
        EventAddr: "대전광역시 유성구 도룡동",
        EventPhotoUrl:"https://momo.maxidc.net/data/file/samples/sample_box03.png"));
    if (kDebugMode) {
      print("getTicketList() end ............................................");
    }
    return ticketList;
  }
}