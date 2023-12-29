class ItemGoods {
  int? lGoodsID;           // 상품 아이디
  String? sGoodsName;      // 상품명
  String? sBarcode;        // 상품 바코드
  String? Description;
  int mSalePrice;// 설명

  ItemGoods({
    this.lGoodsID=0,
    this.sBarcode="",
    this.sGoodsName="",
    this.Description="",
    this.mSalePrice=0,
  });

  static List<ItemGoods> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemGoods.fromJson(data);
    }).toList();
  }

  factory ItemGoods.fromJson(Map<String, dynamic> jdata)
  {
    return ItemGoods(
      lGoodsID: (jdata['lGoodsID'] != null)
          ? int.parse(jdata['lGoodsID'].toString().trimLeft()) : 0,
      sGoodsName: (jdata['sName'] != null)
          ? jdata['sName'] : "",
      sBarcode: (jdata['sBarcode'] != null)
          ? jdata['sBarcode'].toString().trim() : "",

      mSalePrice:(jdata['mSalePrice'] != null)
          ? double.parse(jdata['mSalePrice'].toString().trimLeft()).toInt() : 0,
      Description: jdata['SGoodsType'],
    );
  }

  static Future<List<ItemGoods>> getTestAccount(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    return [
      ItemGoods(
        lGoodsID: 1234,
        sGoodsName: "낚시대",
        Description: "미노리",
      ),
      ItemGoods(
        lGoodsID: 2343,
        sGoodsName: "릴뭉치",
        Description: "스마트에스엔",
      ),
    ];
  }
}
