// ignore_for_file: non_constant_identifier_names, file_names

class ItemCoupon {
  final String? Key;          //
  final String? Benefit;      // 혜택(할인율)
  final String? Title;        // 타이틀
  final String? Description;  // 설명글
  final String? BeginDate;    // 시작일
  final String? EndDate;      // 종료일
  final String? PhotoUrl;     // 사진
  String? discount_value;
  String? unit_name;

  ItemCoupon({

    this.unit_name ="%",
    this.discount_value="5",

    this.Key="",
    this.Benefit = "",
    this.Title = "",
    this.Description = "",
    this.BeginDate="",
    this.EndDate="",
    this.PhotoUrl = "",
  });

  static List<ItemCoupon> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemCoupon.fromJson(data);
    }).toList();
  }

  factory ItemCoupon.fromJson(Map<String, dynamic> jdata)
  {
    return ItemCoupon(
      Title: jdata['Title'],
      Description: jdata['Description'],
      Benefit: jdata['Benefit'],
    );
  }

  static Future <List<ItemCoupon>> getCouponData(int milliseconds) async {
    List<ItemCoupon> dataList = [];
    await Future.delayed(Duration(milliseconds: milliseconds));
    dataList.add(ItemCoupon(
        unit_name:"%",
        discount_value:"10",
        Benefit: "10%",
        Title: "8월 정기 쿠폰",
        Description: "조건(일정금액 이상, 평일 예약 등)",
        BeginDate: "2022.6.5",
        EndDate: "2022.6.15"
    ));

    dataList.add(ItemCoupon(
        unit_name:"%",
        discount_value:"10",
        Benefit: "10%",
        Title: "크리스마스 쿠폰",
        Description: "조건(일정금액 이상, 평일 예약 등)",
        BeginDate: "2022.11.25",
        EndDate: "2022.12.25"
    ));

    dataList.add(ItemCoupon(
        unit_name:"%",
        discount_value:"15",
        Benefit: "15%",
        Title: "회원가입 쿠폰",
        Description: "조건(일정금액 이상, 평일 예약 등)",
        BeginDate: "2022.11.25",
        EndDate: "2022.12.25"
    ));

    return dataList;
  }
}