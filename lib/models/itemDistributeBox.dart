class ItemDistributeBox {
  int?    BoxId;        // 상품 아이디
  String? BoxCode;      // 상품명
  int?    GoodsCount;
  int?    ConfirmCount;
  bool?   IsFinished;
  String? Description;  // 설명

  ItemDistributeBox({
    this.BoxId=0,
    this.BoxCode="",
    this.GoodsCount = 0,
    this.ConfirmCount = 0,
    this.IsFinished = false,
    this.Description=""
  });

  static List<ItemDistributeBox> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemDistributeBox.fromJson(data);
    }).toList();
  }

  factory ItemDistributeBox.fromJson(Map<String, dynamic> jdata)
  {
    return ItemDistributeBox(
      BoxCode: jdata['sName'],
      BoxId: jdata['lGoodsID'],
      Description: jdata['SGoodsType'],
    );
  }

  static Future<List<ItemDistributeBox>> getTestData(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    return [
      ItemDistributeBox(
        BoxId: 12,
        BoxCode: "0012",
        GoodsCount:5,
        ConfirmCount: 5,
        IsFinished: true,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 13,
        BoxCode: "0013",
        GoodsCount:10,
        ConfirmCount: 8,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 14,
        BoxCode: "0014",
        GoodsCount:10,
        ConfirmCount: 0,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 15,
        BoxCode: "0015",
        GoodsCount:7,
        ConfirmCount: 0,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 12,
        BoxCode: "0012",
        GoodsCount:5,
        ConfirmCount: 5,
        IsFinished: true,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 13,
        BoxCode: "0013",
        GoodsCount:10,
        ConfirmCount: 8,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 14,
        BoxCode: "0014",
        GoodsCount:10,
        ConfirmCount: 0,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 15,
        BoxCode: "0015",
        GoodsCount:7,
        ConfirmCount: 0,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 12,
        BoxCode: "0012",
        GoodsCount:5,
        ConfirmCount: 5,
        IsFinished: true,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 13,
        BoxCode: "0013",
        GoodsCount:10,
        ConfirmCount: 8,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 14,
        BoxCode: "0014",
        GoodsCount:10,
        ConfirmCount: 0,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 15,
        BoxCode: "0015",
        GoodsCount:7,
        ConfirmCount: 0,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 12,
        BoxCode: "0012",
        GoodsCount:5,
        ConfirmCount: 5,
        IsFinished: true,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 13,
        BoxCode: "0013",
        GoodsCount:10,
        ConfirmCount: 8,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 14,
        BoxCode: "0014",
        GoodsCount:10,
        ConfirmCount: 0,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 15,
        BoxCode: "0015",
        GoodsCount:7,
        ConfirmCount: 0,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 12,
        BoxCode: "0012",
        GoodsCount:5,
        ConfirmCount: 5,
        IsFinished: true,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 13,
        BoxCode: "0013",
        GoodsCount:10,
        ConfirmCount: 8,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 14,
        BoxCode: "0014",
        GoodsCount:10,
        ConfirmCount: 0,
        IsFinished: false,
        Description: "",
      ),
      ItemDistributeBox(
        BoxId: 15,
        BoxCode: "0015",
        GoodsCount:7,
        ConfirmCount: 0,
        IsFinished: false,
        Description: "",
      ),
    ];
  }
}
