class ItemWBoxInGoods {
  String? sGoodsName;       // 상품명
  String? sBarcode;         // 상품 바코드
  int?    lGoodsID;         // 상품코드
  int?    lGoodsCount;      // 입고예정 수량
  int?    lConfirmCount;    // 배분 수량
  int?    lScanCount;       // 입고확인 수량 (App only)
  bool    isChecked;        // 처리상태 (App only)
  bool    hasFocus;         // 바코드 스캔된 항목 (App only)

  ItemWBoxInGoods({
    this.lGoodsID = 0,
    this.sGoodsName="",
    this.sBarcode = "",
    this.lGoodsCount = 0,
    this.lConfirmCount = -1,
    this.lScanCount = 0,
    this.isChecked = false,
    this.hasFocus = false,
  });

  // toJson(){
  //   return {
  //     "lGoodsID":lGoodsID,
  //     "goodsName":goodsName,
  //     "lGoodsCount":lGoodsCount,
  //     "lConfirmCount":lConfirmCount,
  //   };
  // }

  static List<ItemWBoxInGoods> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemWBoxInGoods.fromJson(data);
    }).toList();
  }

  factory ItemWBoxInGoods.fromJson(Map<String, dynamic> jdata)
  {
    ItemWBoxInGoods item = ItemWBoxInGoods(
      lGoodsID: (jdata['lGoodsID'] != null)
          ? int.parse(jdata['lGoodsID'].toString().trimLeft()) : 0,
      sGoodsName: (jdata['sGoodsName'] != null)
          ? jdata['sGoodsName'] : "",
      sBarcode: (jdata['sBarcode'] != null)
          ? jdata['sBarcode'].toString().trim() : "",
      lGoodsCount: (jdata['lGoodsCount'] != null)
          ? int.parse(jdata['lGoodsCount'].toString().trimLeft()) : 0,
      lConfirmCount: (jdata['lConfirmCount'] != null)
          ? int.parse(jdata['lConfirmCount'].toString().trimLeft()) : -1,
    );

    item.isChecked = (item.lGoodsCount==item.lConfirmCount);
    return item;
  }
}
