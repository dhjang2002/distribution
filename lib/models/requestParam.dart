// ignore_for_file: non_constant_identifier_names

// enum eContentType { PLAY , PLACE , PLANET, ANY }   // ContentType : PLANET, PLAY, PLACE, ANY
// enum eContentStatus { R , P , E, C }               // ContentStatus : R:"대기중", P:"진행", E:"종료", C:"마감"

import 'package:distribution/provider/sessionData.dart';

class RequestParam {
  int? PageNo;
  int? RowsPerPage;
  String? ContentType;
  String? ContentStatus;
  String? CostType;
  String? OrderByType;
  String? OrderByDirection;
  String? OwnerType;
  String? content_oid;
  late SessionData session;

  RequestParam({
    this.content_oid = "",
    this.PageNo = 1,
    this.RowsPerPage = 25,
    this.ContentType = "ANY",
    this.ContentStatus = "",
    this.CostType = "",
    this.OrderByType = "date_created",
    this.OrderByDirection = "DESC",
    this.OwnerType = "A",
  });

  @override
  String toString(){
    return 'RequestParam {'
        'content_oid:$content_oid, '
        'PageNo:$PageNo, '
        'RowsPerPage:$RowsPerPage, '
        'ContentType:$ContentType, '
        'ContentStatus:$ContentStatus, '
        'OrderByType:$OrderByType, '
        'OwnerType:$OwnerType }';
  }

  void setSession(SessionData session) {
    this.session = session;
  }

  void setContentType(String contentType) {
    ContentType = contentType;
  }

  void setStatus(final String status) {
    switch(status) {
      case "진행":
        ContentStatus = "P";
        break;
      case "마감":
        ContentStatus = "C";
        break;
      case "대기":
        ContentStatus = "R";
        break;
      case "종료":
        ContentStatus = "E";
        break;
    }
  }

  void setCostType(final String status) {
    switch(status) {
      case "유료":
        CostType = "C";
        break;
      case "무료":
        CostType = "F";
        break;
    }
  }

  /*
content_oid - 'Planet OID'
user_oid - '등록자 OID'
content_type - '종류-PLAY, PLACE, PLANET
content_title - '모임제목'
content_detail - '모임내용'
event_code - '이벤트 코드'
event_start_datetime - '이벤트 시작 일'
event_end_datetime - '이벤트 종료 일시'
register_begin_datetime - '참가신청 시작'
register_end_datetime - '참가신청 종료'
event_address - '행사장 주소'
event_place - '모임장소'
event_place_area - '행사구역'
geo_location - 'GPS 위치'
location_direction - '장소 설명'
bank_account - '전화번호'
contact_phone_no - '안심번호 여부'
is_safe_phone_no - '안심번호 여부'
homepage - '장소 홈페이지'
additional_info - '추가 정보'
entry_fee - '참가비'
max_participants - '최대참가인원'
cancel_condition - '환불제한 (0: 제한없음, 1:"취소 불가", 2:"모임 1일 전", 3:"모임 2일 전")'
refund_policy - '환불정책'
introduction_items - '소개항목'
amenities_info - '편의시설 상세정보'
regulation_info - '유의사항'
selection_types - '선택타입'
selection_options - '선택옵션'
external_id - '외부 ID'
external_id_type - '외부ID 타입'
share_url - '행사 공유 Url'
thumbnail - '아이콘'
event_status - '행사 진행상태 (R:"대기중", P:"진행", E:"종료", C:"마감")'
notes - '노트'
date_created - '등록일시'
date_updated - '수정일시'
status - '자료 상태 A:정상, D:삭제'
   */
  void setOrder(String orderby) {
    // "OrderBy":{"최신순","인기순","낮은가격순","높은가격순","마감임박순"}
    switch(orderby) {
      case "최신순":
        OrderByType = "date_created";
        OrderByDirection = "DESC";
        break;
      case "인기순":
        //OrderByType = "인기순";
        OrderByType = "date_created";
        OrderByDirection = "DESC";
        break;
      case "낮은 가격순":
        OrderByType = "entry_fee";
        OrderByDirection = "ASC";
        break;
      case "높은 가격순":
        OrderByType = "entry_fee";
        OrderByDirection = "DESC";
        break;
      case "마감 임박순":
        OrderByType = "register_end_datetime";
        OrderByDirection = "DESC";
        break;
      default:
        OrderByType = orderby;
        OrderByDirection = "ASC";
    }
  }


  // void setOrderDirection(bool isAsc) {
  //   if(isAsc)
  //     OrderByDirection = "ASC";
  //   else
  //     OrderByDirection = "DESC";
  // }

  Map<String, dynamic> toRequest({String keyword="request"}) {
    return {"$keyword":toMap()};
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (content_oid!.isEmpty) {
      map.addAll({'PageNo': PageNo.toString()});
      map.addAll({'RowsPerPage': RowsPerPage.toString()});

      if(ContentType!.isNotEmpty) {
        map.addAll({'ContentType': ContentType});
      }

      if(ContentStatus!.isNotEmpty) {
        map.addAll({'ContentStatus': ContentStatus});
      }

      if(OrderByType!.isNotEmpty) {
        map.addAll({'OrderByType': OrderByType});
      }

      if(OrderByDirection!.isNotEmpty) {
        map.addAll({'OrderByDirection': OrderByDirection});
      }

      if(OwnerType!.isNotEmpty) {
        map.addAll({'OwnerType': OwnerType});
      }
    }
    else {
      map = {
        'content_oid': content_oid,
      };
    }
    return map;
  }
}
