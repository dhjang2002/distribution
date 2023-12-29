
class ItemSBox {
  String sBoxNo;
  int lGoodsCount;
  int lShipmentId;
  bool isChecked; // app only
  bool hasFocus;  // app only

  ItemSBox({
    this.sBoxNo = "",
    this.lGoodsCount = 0,
    this.lShipmentId=0,
    this.isChecked = false,
    this.hasFocus = false,
  });

  static List<ItemSBox> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemSBox.fromJson(data);
    }).toList();
  }

  factory ItemSBox.fromJson(Map<String, dynamic> jdata)
  {
    return ItemSBox(
      sBoxNo: (jdata['sBoxNo'] != null) ? jdata['sBoxNo'] : "",
      lShipmentId: (jdata['lShipmentId'] != null)
          ? int.parse(jdata['lShipmentId'].toString().trim()) : 0,
      lGoodsCount: (jdata['lGoodsCount'] != null)
          ? int.parse(jdata['lGoodsCount'].toString().trim()) : 0,
    );
  }
}