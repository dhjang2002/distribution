// ignore_for_file: file_names, non_constant_identifier_names
import 'package:distribution/models/dataDate.dart';
import 'package:distribution/models/dataDiscount.dart';
import 'package:distribution/models/dataSession.dart';
import 'package:distribution/models/dataZone.dart';
import 'package:distribution/models/itemCoupon.dart';

class ItemPaymentPlay {
  String dateTitle;
  int? dateListIndex;
  List<DataDate>? dateList;

  int?                   zoneListIndex;    // 선택한 값
  String?                zoneTitle;        // 선택한 옵션 타이틀
  List<DataZone>?        zoneList;           // 구역정보

  int?                   sessionListIndex;    // 선택한 값
  String?                sessionTitle;        // 선택한 옵션 타이틀
  List<DataSession>?     sessionList;

  // 쿠폰
  int?                   couponListIndex;    // 선택한 값
  String?                couponTitle;        // 선택한 옵션 타이틀
  List<ItemCoupon>?      couponList;         // 할인정보 리스트
  int?                   couponValue;        // 할인값 %(10,15,30)

  // 할인정보
  int?                   disCountListIndex;  // 선택한 값
  String?                disCountTitle;      // 선택한 옵션 타이틀
  List<DataDiscount>?    disCountList;       // 할인정보 리스트
  int?                   discountValue;     // 할인값 %(10,15,30)

  String?   name;                 // 결제자 이름
  String?   phoneNumber;          // 휴대폰 번호
  bool?     usePrivateNumber;     // 안심번호 사용여부

  String?   productOid;           // 상품ID:  콘텐츠 oid
  String?   productName;          // 상품명:  콘텐츠 타이틀
  String?   productDescription;   // 상품설명:  PLAY="일정,장소"
  String?   productThumbnail;      // 상품사진: 행사 이미지

  String?   reserveDateTime;      // 예약:일시
  int?      reservePersonCount;   // 예약:인원수
  String?   reserveZone;          // 예약:구역

  int?      priceProduct;           // 상품 가격
  int?      priceDiscount;          // 할인금액
  int?      priceCoupon;            // 쿠폰 사용금액
  int?      priceReserveTotal;      // 보유 적립금
  int?      priceReserves;          // 적립금
  int       pricePayment;           // 결제금액

  bool?     agreeAll;
  bool?     agreePrivate;
  bool?     agreePayment;

  ItemPaymentPlay({
    this.dateTitle = "",
    this.dateListIndex = -1,
    this.dateList,

    this.sessionTitle = "",
    this.sessionListIndex = -1,
    this.sessionList,

    this.couponList = const[],
    this.couponTitle = "",
    this.couponListIndex = -1,

    this.disCountListIndex = -1,
    this.disCountTitle = "할인선택",
    this.disCountList,

    this.name = "",
    this.phoneNumber="",
    this.usePrivateNumber = false,

    this.productOid="",
    this.productName="",
    this.productDescription = "",
    this.productThumbnail = "",

    this.reserveDateTime="",
    this.reservePersonCount=0,
    this.reserveZone="",

    this.priceProduct=0,
    this.priceDiscount =0,
    this.priceCoupon = 0,
    this.priceReserveTotal = 0,
    this.priceReserves=0,
    this.pricePayment=0,

    this.agreeAll = false,
    this.agreePayment = false,
    this.agreePrivate = false,
  });

}