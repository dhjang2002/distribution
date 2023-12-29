
class ItemTempMaster {
  String sMemo;
  int lMasterID;
  int lStoreID;
  int lOrder; // app only
  bool bEdit;

  ItemTempMaster({
    this.lMasterID = 0,
    this.lStoreID=0,
    this.lOrder = 0,
    this.sMemo = "",
    this.bEdit = false,
  });

  static List<ItemTempMaster> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemTempMaster.fromJson(data);
    }).toList();
  }

  factory ItemTempMaster.fromJson(Map<String, dynamic> jdata)
  {
    return ItemTempMaster(
      sMemo: (jdata['sMemo'] != null) ? jdata['sMemo'].toString().trim() : "",
      lStoreID: (jdata['lStoreID'] != null)
          ? int.parse(jdata['lStoreID'].toString().trim()) : 0,
      lMasterID: (jdata['lMasterID'] != null)
          ? int.parse(jdata['lMasterID'].toString().trim()) : 0,
      lOrder: (jdata['lOrder'] != null)
          ? int.parse(jdata['lOrder'].toString().trim()) : 0,
    );
  }
}