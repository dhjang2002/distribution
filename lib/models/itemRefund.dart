// ignore_for_file: non_constant_identifier_names, file_names

class ItemRefund {
  final String? Stamp;              // 사용/적립 일시
  final int? Price;                 // 사용/적립 금액
  final String? Summary;            // 사용/적립 내역

  ItemRefund({
    this.Stamp = "",
    this.Price = 0,
    this.Summary = "",
  });

  static List<ItemRefund> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemRefund.fromJson(data);
    }).toList();
  }

  factory ItemRefund.fromJson(Map<String, dynamic> jdata)
  {
    return ItemRefund(
      Summary: jdata['Summary'],
      Price: jdata['Price'],
      Stamp: jdata['Stamp'],
    );
  }

  static Future <List<ItemRefund>> getReserveData(int milliseconds) async {
    List<ItemRefund> dataList = [];
    await Future.delayed(Duration(milliseconds: milliseconds));
    dataList.add(ItemRefund(
      Price: -5030,
      Summary: "사용",
      Stamp: "2022.06.05 10:23:51",
    ));
    dataList.add(ItemRefund(
      Price: 5030,
      Summary: "OO 이벤트 참여 적립",
      Stamp: "2022.06.09 10:23:51",
    ));
    dataList.add(ItemRefund(
      Price: 1120,
      Summary: "포토 후기 적립",
      Stamp: "2022.06.01 10:23:51",
    ));
    return dataList;
  }
}