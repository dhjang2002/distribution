// ignore_for_file: non_constant_identifier_names, file_names

class DataDiscount {
  String? status;                // status
  String? unit_name;             // unit_name (%, 원)
  String? discount_title;        // discount_title (국가유공자 할인)
  String? discount_value;        // discount_value (10, 20000)
  String? content_discount_oid;  // content_discount_oid

  DataDiscount({
    this.status = '',
    this.discount_title = "",
    this.unit_name = "",
    this.content_discount_oid   = "",
    this.discount_value="",
  });

  static List<DataDiscount> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return DataDiscount.fromJson(data);
    }).toList();
  }

  factory DataDiscount.fromJson(Map<String, dynamic> jdata)
  {
    return DataDiscount(
      status: jdata['status'],
      discount_title: jdata['discount_title'],
      discount_value: jdata['discount_value'],
      unit_name: jdata['unit_name'],
      content_discount_oid: jdata['content_discount_oid'],
    );
  }

  @override
  String toString(){
    return 'DataDiscount {'
        'status:$status, '
        'discount_title:$discount_title, '
        'discount_value:$discount_value, '
        'unit_name:$unit_name, '
        'content_discount_oid:$content_discount_oid, '
        ' }';
  }
}