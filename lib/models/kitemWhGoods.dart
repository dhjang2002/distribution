// ignore_for_file: file_names


class ItemWhGoods {
  String sStoreName;      // 박스 바코드
  String sGoodsName;       // 상품명
  String sBoxNo;         // 상품 바코드
  int    lConfirmCount;         // 상품코드
  int    lGoodsCount;
  bool   hasFocus;// 포장 수량

  ItemWhGoods({
    this.sGoodsName="",
    this.sStoreName = "",
    this.sBoxNo = "",
    this.lGoodsCount = 0,
    this.lConfirmCount = 0,
    this.hasFocus = false,
  });

  static List<ItemWhGoods> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemWhGoods.fromJson(data);
    }).toList();
  }

  factory ItemWhGoods.fromJson(Map<String, dynamic> jdata)
  {
    return ItemWhGoods(
      sGoodsName: (jdata['sGoodsName'] != null)
          ? jdata['sGoodsName'] : "",
      sBoxNo: (jdata['sBoxNo'] != null)
          ? jdata['sBoxNo'].toString().trim() : "",
      sStoreName: (jdata['sStoreName'] != null)
          ? jdata['sStoreName'].toString().trim() : "",
      lGoodsCount: (jdata['lGoodsCount'] != null)
          ? int.parse(jdata['lGoodsCount'].toString().trimLeft()) : 0,
      lConfirmCount: (jdata['lConfirmCount'] != null)
          ? int.parse(jdata['lConfirmCount'].toString().trimLeft()) : 0,
    );
  }
}
