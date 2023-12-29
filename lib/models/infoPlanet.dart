// ignore_for_file: non_constant_identifier_names

import 'package:distribution/models/itemPhoto.dart';

class InfoPlanet {
  String? ContentID;            // 레코드 key
  String? OwnerID;              // 주최자 UserID
  String? ContentTitle;         // 모임제목 (최대 ?)
  String? Content;              // 모임내용 (최대 300자)
  String? EventDay;             // 모임일자: 2021.11.24
  String? EventTime;            // 모임시간: 10:45
  String? BeginPeriod;          // 모집시작: 2021.11.19(금)
  String? EndPeriod;            // 모집마감: 2021.11.23(화)
  String? Place;                // 모임장소: (주)필리스 회의실
  String? PlaceAddress;         // 행사장 주소
  double? PlaceGpsLon;          // 행사장 주소 GPS 좌표
  double? PlaceGpsLat;          // 행사장 주소 GPS 좌표
  int?    Price;                // 참가비:  20,000원
  int?    NumberOfRecruits;     // 모집인원: 10명
  int?    NumberOfReservations; // 신청인원: 5명
  bool?   ConditionOfLimit;     // 인원제한 없음
  String? MinmumRestrict;       // 환불제한 ("취소 불가", "모임 1일 전", "모임 2일 전")
  String? ShareUrl;             // 행사 공유 Url
  List<ItemPhoto>? photoList;   // 사진 (최대 10장)

  InfoPlanet({
    this.ContentID="",
    this.OwnerID = "",
    this.EventDay,
    this.EventTime,
    this.BeginPeriod,
    this.EndPeriod,
    this.Place = "",
    this.PlaceAddress ="",
    this.PlaceGpsLon=0,
    this.PlaceGpsLat=0,
    this.Price = 0,
    this.NumberOfRecruits = 0,
    this.ConditionOfLimit = false,
    this.NumberOfReservations = 0,
    this.MinmumRestrict = "",
    this.ContentTitle = "",
    this.Content = "",
    this.ShareUrl="",
    this.photoList = const <ItemPhoto>[],
  });

  static List<InfoPlanet> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return InfoPlanet.fromJson(data);
    }).toList();
  }

  factory InfoPlanet.fromJson(Map<String, dynamic> jdata)
  {
    return InfoPlanet(
      ContentID: jdata['ContentID'],
      OwnerID: jdata['OwnerID'],
    );
  }

  static Future<InfoPlanet> getPlanetInfo(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    InfoPlanet info = InfoPlanet(
      ContentID:"p20220610241234",
      OwnerID: "01020010937",
      EventDay:"2022.06.30",
      EventTime:"09:00",
      BeginPeriod:"2022.06.15",
      EndPeriod:"2022.06.23",
      Price:30000,
      NumberOfRecruits:0,
      ConditionOfLimit:true,
      MinmumRestrict:"모임 1일 전",
      ContentTitle:"아따맘마 음식 만들기",
      Place:"(주)필리스 회의실",
      Content:'만화 "아따맘마"에 나오는 음식을 만들어 보는 시간을 가져 보아요! 만화처럼 정말 맛있어 보인다니까요!',
      ShareUrl: "https://momo.maxidc.net/data/file/samples/sample_box02.png",
      photoList:[
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_box01.png"),
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_box02.png"),
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_box03.png"),
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_box04.png"),
      ],
    );
    return info;
  }
}