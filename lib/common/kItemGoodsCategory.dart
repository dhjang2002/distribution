class ItemGoodsCategory {
  String sName;
  String sCode;

  ItemGoodsCategory({
    this.sName="",
    this.sCode ="",
  });

  static List<ItemGoodsCategory> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemGoodsCategory.fromJson(data);
    }).toList();
  }

  factory ItemGoodsCategory.fromJson(Map<String, dynamic> jdata)
  {
    return ItemGoodsCategory(
      sName: (jdata['sName'] != null)
          ? jdata['sName'].toString().trim() : "",
      sCode: (jdata['sCode'] != null)
          ? jdata['sCode'].toString().trim() : "",
    );
  }
}
