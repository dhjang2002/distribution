class ItemDisplayGoods {
  bool   hasFocus;
  String sBarcode;      // 상품 바코드
  String sGoodsName;    // 상품명
  int    lGoodsId;      // 상품 Key
  int    lStoreId;      // 매장번호
  int    lGoodsCount;   // 진열수량
  int    lDisplay0;     // 진열위치
  int    lDisplay1;     // 진열위치
  int    lDisplay2;     // 진열위치
  int    weight;        // sort order
  String sDisplay;      // 진열위치 ("01-01-16")

  ItemDisplayGoods({
    this.hasFocus = false,
    this.sBarcode = "",
    this.sGoodsName = "",
    this.lGoodsId = 0,
    this.lStoreId = 0,
    this.lGoodsCount = 0,
    this.lDisplay0 = 0,
    this.lDisplay1 = 0,
    this.lDisplay2 = 0,
    this.sDisplay = "",
    this.weight=0,
  });

  @override
  String toString() {
    return (
        '{ "sBarcode":"$sBarcode",'
        '"sGoodsName":"$sGoodsName" }'
    );
  }
  static List<ItemDisplayGoods> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemDisplayGoods.fromJson(data);
    }).toList();
  }

  Map<String, dynamic> toJson() => {
    "sBarcode": "$sBarcode",
    "sGoodsName": "$sGoodsName",
  };

  Map<String, dynamic> toMap(){
    return {
      "sBarcode":"$sBarcode",
      "sGoodsName":"$sGoodsName",
    };
  }

  factory ItemDisplayGoods.fromJson(Map<String, dynamic> jdata)
  {
    return ItemDisplayGoods(
      sGoodsName: (jdata['sGoodsName'] != null)
          ? jdata['sGoodsName'] : "",

      sBarcode: (jdata['sBarcode'] != null)
          ? jdata['sBarcode'] : "",

      lStoreId: (jdata['lStoreId'] != null)
          ? int.parse(jdata['lStoreId'].toString().trimLeft()) : 0,

      lGoodsId: (jdata['lGoodsId'] != null)
          ? int.parse(jdata['lGoodsId'].toString().trimLeft()) : 0,

      lGoodsCount: (jdata['lGoodsCount'] != null)
          ? int.parse(jdata['lGoodsCount'].toString().trimLeft()) : 0,

      lDisplay0: (jdata['lDisplay0'] != null)
          ? int.parse(jdata['lDisplay0'].toString().trimLeft()) : 0,
      lDisplay1: (jdata['lDisplay1'] != null)
          ? int.parse(jdata['lDisplay1'].toString().trimLeft()) : 0,
      lDisplay2: (jdata['lDisplay2'] != null)
          ? int.parse(jdata['lDisplay2'].toString().trimLeft()) : 0,
    );
  }
}
