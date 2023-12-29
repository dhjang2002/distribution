// ignore_for_file: file_names, non_constant_identifier_names

class ItemAmentity {
  String? status;         //
  String? amenity_oid;    // 서버에서 관리하는 고유 key (삭제, 변경시 사용됨)
  String? amenity_data;   //
  String? amenity_title;  //
  String? order_index;    // .
  ItemAmentity({
    this.amenity_oid = "",
    this.status = "",
    this.amenity_data="",
    this.order_index="",
    this.amenity_title = ""
  });

  @override
  String toString(){
    return 'ItemAmentity {'
        'amenity_oid:$amenity_oid, '
        'status:$status, '
        //'amenity_data:$amenity_data, '
        'amenity_data:[-------], '
        'order_index:$order_index, '
        'amenity_title:$amenity_title'
        ' }';
  }

  static List<ItemAmentity> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemAmentity.fromJson(data);
    }).toList();
  }

  factory ItemAmentity.fromJson(Map<String, dynamic> jdata)
  {
    return ItemAmentity(
      status: jdata['status'],
      amenity_oid: jdata['amenity_oid'],
      amenity_title: jdata['amenity_title'],
      amenity_data: jdata['amenity_data'],
      order_index: jdata['order_index'],
    );
  }
}