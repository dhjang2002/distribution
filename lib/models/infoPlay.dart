// ignore_for_file: non_constant_identifier_names
import 'package:flutter/foundation.dart';
import 'package:distribution/common/gpsPoint.dart';
import 'package:distribution/models/dataDate.dart';
import 'package:distribution/models/dataDiscount.dart';
import 'package:distribution/models/dataEquipment.dart';
import 'package:distribution/models/dataSession.dart';
import 'package:distribution/models/dataZone.dart';
import 'package:distribution/models/facilityItem.dart';
import 'package:distribution/models/itemPhoto.dart';
import 'package:distribution/models/specItem.dart';
import 'package:logger/logger.dart';

class InfoPlay {
  bool? IsFavorite;

  String? thumbnail;
  List<DataDate>?       dateList;           // 예약 가능일
  List<DataDiscount>?   disCountList;       // 할인정보
  List<DataEquipment>?  equipmentList;      // 부대장비
  List<DataSession>?    sessionList;        // 세션정보
  List<DataZone>?       zoneList;           // 구역정보

  String?             content_oid;              // key
  String?             ChannelID;              // 이벤트 host ID
  String?             ContentTitle;           // 행사명칭  ("핸드메이드 페어(윈터)")
  String?             EventPlaceArea;         // 구역     (ex: "1층 1구역" )
  String?             BeginDate;              // 행사시작  ("2022.06.15")
  String?             EndDate;                // 행사종료  ("2022.06.29")
  int?                Price;                  // 참가비    (50000)
  int?                Capacity;               // 수용인원
  String?             Place;                  // 행사장소  ("엑스포공원" )
  String?             PlaceAddress;           // 행사장소 주소 ("대전시 유성구 대덕대로 512")
  double?             PlaceGpsLon;            // 행사장소 GPS 좌표 (129.124)
  double?             PlaceGpsLat;            // 행사장소 GPS 좌표 (34.342)
  int?                total_favorites;     // 즐겨찾기 총 갯수 (150)
  int?                TotalQuestionCount;     // 문의 총 갯수   (15)
  int?                TotalPostCount;         // 후기 총 갯수   (25)
  double?             AveragePostRating;      // 후기 평균 평점  (4.5)
  String?             PlayStatus;             // { "진행", "종료", "마감"}
  String?             ShareUrl;               // 공유 ("https://~")
  String?             RefundPolicy;           // 환불정책
  List<SpecItem>?     RefundList;             // 환불조건
  List<SpecItem>?     introItems;             // 소개항목
  List<String>?       KeywordList;            // 키워드
  List<FacilityItem>? facilityItems;          // 편의시설
  List<SpecItem>?     facilityDescriptions;   // 편의시설 안내 (최대 10개)
  List<SpecItem>?     NoticeDescriptions;     // 유의사항 (최대 10개)
  List<String>?       TypeList;               // 선택타입
  List<String>?       OptionList;             // 선택옵션
  List<ItemPhoto>?    PhotoList;              // 이벤트 사진 URL
  GpsPoint? geo_location;
  InfoPlay({
    this.IsFavorite=false,
    this.thumbnail,
    this.content_oid   = "",
    this.ChannelID = "",
    this.ContentTitle = "",
    this.Place = "",
    this.EventPlaceArea = "",
    this.BeginDate = "",
    this.EndDate = "",

    this.Price = 0,
    this.Capacity = 0,
    this.TotalQuestionCount=0,
    this.TotalPostCount  = 0,
    this.total_favorites = 0,
    this.AveragePostRating = 0,
    this.PlaceAddress = "",
    this.PlaceGpsLon,
    this.PlaceGpsLat,
    this.PlayStatus = "",
    this.ShareUrl="",
    this.KeywordList = const <String>[],
    this.introItems = const [],
    this.facilityItems = const[],
    this.facilityDescriptions = const[],
    this.RefundPolicy="",
    this.RefundList = const[],
    this.NoticeDescriptions = const[],
    this.TypeList    = const <String>[],
    this.OptionList  = const <String>[],
    this.PhotoList   = const <ItemPhoto>[],
    this.dateList    = const <DataDate>[],
    this.zoneList =  const <DataZone>[],
    this.sessionList =  const <DataSession>[],
    this.disCountList =  const <DataDiscount>[],
    this.equipmentList =  const <DataEquipment>[],
    this.geo_location,
  });

  static List<InfoPlay> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return InfoPlay.fromJson(data);
    }).toList();
  }

  factory InfoPlay.fromJson(Map<String, dynamic> jdata)
  {
    return InfoPlay(
      content_oid: jdata['ContentID'],
      ChannelID: jdata['ChannelID'],
    );
  }


  void fromContent(Map<String, dynamic> parsedJson) {

    if (kDebugMode) {
      print("InfoPlay::fromContent()==========>");
      var logger = Logger();
      logger.d(parsedJson);
    }

    total_favorites = int.parse(parsedJson['total_favorites']);
    IsFavorite = (parsedJson['saved_favorite']=="1") ? true: false;

    thumbnail = (parsedJson['thumbnail']==null) ? "" : parsedJson['thumbnail'];
    // content_date_list
    if(parsedJson['content_date_list'] != null) {
      var list = parsedJson['content_date_list']['dates'];
      if(list != null) {
        if (list is List) {
          dateList = DataDate.fromSnapshot(list);
        }
        else {
          dateList = DataDate.fromSnapshot([list]);
        }
      }
      if (kDebugMode) {
        if(dateList!.isNotEmpty) {
          print("예약가능 일자:");
          print(dateList.toString());
        }
      }
    }

    // content_discount_list
    if((parsedJson['content_discount_list'] != null)) {
      var list = parsedJson['content_discount_list']['discount'];
      if(list != null) {
        if (list is List) {
          disCountList =
              DataDiscount.fromSnapshot(list);
        }
        else {
          disCountList =
              DataDiscount.fromSnapshot([list]);
        }
      }
      if (kDebugMode) {
        if(disCountList!.isNotEmpty) {
          print("할인정보:");
          print(disCountList.toString());
        }
      }
    }

    // zone_list
    if((parsedJson['zone_list'] != null)) {
      var list = parsedJson['zone_list']['zone'];
      if(list != null) {
        if (list is List) {
          zoneList =
              DataZone.fromSnapshot(list);
        }
        else {
          zoneList =
              DataZone.fromSnapshot([list]);
        }
      }
      if (kDebugMode) {
        if(zoneList!.isNotEmpty) {
          print("구역:");
          print(zoneList.toString());
        }
      }
    }

    // content_equipment_list
    if((parsedJson['content_equipment_list'] != null)) {
      var list = parsedJson['content_equipment_list']['amenities'];
      if(list != null) {
        if (list is List) {
          equipmentList =
              DataEquipment.fromSnapshot(list);
        }
        else {
          equipmentList =
              DataEquipment.fromSnapshot([list]);
        }
      }
      if (kDebugMode) {
        if(equipmentList!.isNotEmpty) {
          print("대여장비 목록:");
          print(equipmentList.toString());
        }
      }
    }

    // content_session_list
    if((parsedJson['content_session_list'] != null)) {
      var list = parsedJson['content_session_list']['sessions'];
      if(list != null) {
        if (list is List) {
          sessionList =
              DataSession.fromSnapshot(list);
        }
        else {
          sessionList =
              DataSession.fromSnapshot([list]);
        }
      }
      if (kDebugMode) {
        print("세션정보:");
        if(sessionList!.isNotEmpty) {
          print(sessionList.toString());
        }
      }
    }

    // 행사기간
    BeginDate = parsedJson['event_start_datetime'];
    EndDate = parsedJson['event_end_datetime'];

    // 편의시설
    if((parsedJson['content_amenity_list'] != null)) {
      var amenities = parsedJson['content_amenity_list']['amenities'];
      if(amenities != null) {
        if (amenities is List) {
          facilityItems =
              FacilityItem.fromSnapshot(amenities);
        }
        else {
          facilityItems =
              FacilityItem.fromSnapshot([amenities]);
        }
      }
      if (kDebugMode) {
        print("편의시설:");
        print(facilityItems.toString());
      }
    }

    // 사진
    if(parsedJson['image_list'] != null) {
      var images = parsedJson['image_list']['image'];
      if(images != null) {
        if (images is List) {
          PhotoList = ItemPhoto.fromSnapshot(images);
        }
        else {
          PhotoList = ItemPhoto.fromSnapshot([images]);
        }
      }
    }

    // keyword
    if(parsedJson['content_keyword_list'] != null) {
      if (kDebugMode) {
        print("키워드::content_keyword_list");
      }
      if (kDebugMode) {
        print(parsedJson['content_keyword_list'].toString());
      }
      var keywords = parsedJson['content_keyword_list']['keywords'];
      if(keywords is List) {
        KeywordList = List.generate(keywords.length, (i) => '${keywords[i]['keyword']}');
      }
      else
      {
        KeywordList = List.generate(1, (i) => '${keywords['keyword']}');
      }
    }

    content_oid    = parsedJson['content_oid'];
    ChannelID    = parsedJson['host_oid'];
    ContentTitle = parsedJson['content_title'];
    String content_detail    = parsedJson['content_detail'];

    if(content_detail != null) {
      //print("content_detail:"+content_detail);
      content_detail = content_detail.replaceAll("\\n", "\n");
      var data = content_detail.split("\\");
      print("content_detail:"+data.toString());
      introItems = List.generate(data.length, (idx) {
        return SpecItem(Description: data[idx]);
      });
      //content_detail = content_detail.replaceAll("\\", "");
    }

    Place    = (parsedJson['event_place'] != null) ? parsedJson['event_place'] : "행사장소";
    ShareUrl = (parsedJson['share_url'] != null) ? parsedJson['share_url'] : "http://www.kkk.com";
    Price    = int.parse(parsedJson['entry_fee']);
    Capacity = int.parse(parsedJson['max_participants']);
    //TotalRecomandCount = int.parse(parsedJson['total_likes']);
    TotalQuestionCount=0;
    TotalPostCount  = 0;
    AveragePostRating = 0;

    //PlaceHomepage="";
    //Available    = "${parsedJson['event_start_datetime']} - ${parsedJson['event_end_datetime']}" ;
    PlaceAddress = parsedJson['event_address'];
    //PlaceAddressGuide = parsedJson['event_address'];

    geo_location=GpsPoint.parse(parsedJson['geo_location']);
    print(geo_location.toString());

    PlaceGpsLon = geo_location!.longitude;
    PlaceGpsLat = geo_location!.latitude;
    //facilityDescriptions!.clear();
    if(parsedJson['amenities_info'] != null) {
      String info = parsedJson['amenities_info'];
      var data = info.split("|#|");
      if (kDebugMode) {
        print(data);
      }
      facilityDescriptions = List.generate(data.length, (idx) {
        return SpecItem(Description: data[idx]);
      });
    }

    //this.NoticeDescriptions!.clear();
    if(parsedJson['regulation_info'] != null) {
      String info = parsedJson['regulation_info'];
      var data = info.split("|#|");
      if (kDebugMode) {
        print(data);
      }
      NoticeDescriptions = List.generate(data.length, (idx) {
        return SpecItem(Description: data[idx]);
      });
    }

    RefundPolicy="";
    if(parsedJson['refund_option_list'] != null) {
      if (kDebugMode) {
        print("환불정책::refund_option_list");
        //print(parsedJson['refund_option_list'].toString());
      }
      dynamic refundList = parsedJson['refund_option_list']['refund'];
      if(refundList is List) {
        List item = refundList;
        item.forEach((element) {
          if(element['status']=='A' && element['selected']=='true') {
            print(element.toString());
            if(element['refund_detail'] != null) {
              RefundPolicy = element['refund_detail'];
            }
            List option_list = element['refund_option_items_list']['refund_item'];
            RefundList = List.generate(option_list.length, (idx) {
              return SpecItem(Description: "${option_list[idx]['refund_title']}: ${option_list[idx]['refund_value']}%");
            });
          }
        });
      }
    }

    TypeList    = const <String>[];
    OptionList  = const <String>[];
  }
}