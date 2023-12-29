class ItemGoodsList {
  int? lGoodsId;           // 상품 아이디
  String? sGoodsName;      // 상품명
  String? sBarcode;        // 상품 바코드
  bool    isSelect;

  ItemGoodsList({
    this.lGoodsId=0,
    this.sBarcode="",
    this.sGoodsName="",
    this.isSelect = false,
  });

  static List<ItemGoodsList> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemGoodsList.fromJson(data);
    }).toList();
  }

  factory ItemGoodsList.fromJson(Map<String, dynamic> jdata)
  {
    return ItemGoodsList(
      lGoodsId: (jdata['lGoodsId'] != null)
          ? int.parse(jdata['lGoodsId'].toString().trim()) : 0,
      sGoodsName: (jdata['sName'] != null)
          ? jdata['sName'].trim() : "",
      sBarcode: (jdata['sBarcode'] != null)
          ? jdata['sBarcode'].toString().trim() : "",
    );
  }

}
