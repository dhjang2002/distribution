
class ItemWarehousingDate {
  String date;
  int cnt;

  ItemWarehousingDate({
    this.date = "",
    this.cnt = 0,
  });

  static List<ItemWarehousingDate> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemWarehousingDate.fromJson(data);
    }).toList();
  }

  factory ItemWarehousingDate.fromJson(Map<String, dynamic> jdata)
  {
    String date = "";
    if(jdata['dWarehousing'] != null) {
      date = jdata['dWarehousing'].toString().trim();
    } else if(jdata['dShipping'] != null) {
      date = jdata['dShipping'].toString().trim();
    }else if(jdata['dDateTime'] != null) {
      date = jdata['dDateTime'].toString().trim();
    }

    return ItemWarehousingDate(
      date: date,
      cnt: (jdata['cnt'] != null)
          ? int.parse(jdata['cnt'].toString().trim()) : 0,
    );
  }
}