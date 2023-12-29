// ignore_for_file: non_constant_identifier_names, file_names

class DataZone {
  String? status;             // status
  String? zone_title;         // zone_title
  String? unit_name;          // unit_name
  String? max_capacity;       // max_capacity
  String? additional_cost;    // unit_name
  String? content_zone_oid;   // content_zone_oid

  DataZone({
    this.status = '',
    this.zone_title = "",
    this.unit_name = "",
    this.content_zone_oid   = "",
    this.max_capacity="",
    this.additional_cost="",
  });

  static List<DataZone> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return DataZone.fromJson(data);
    }).toList();
  }

  factory DataZone.fromJson(Map<String, dynamic> jdata)
  {
    return DataZone(
      status: jdata['status'],
      zone_title: jdata['zone_title'],
      unit_name: jdata['unit_name'],
      content_zone_oid: jdata['content_zone_oid'],
      max_capacity: jdata['max_capacity'],
      additional_cost: jdata['additional_cost'],
    );
  }

  @override
  String toString(){
    return 'DataZone {'
        'status:$status, '
        'zone_title:$zone_title, '
        'unit_name:$unit_name, '
        'additional_cost:$additional_cost, '
        'max_capacity:$max_capacity, '
        'content_zone_oid:$content_zone_oid, '
        ' }';
  }
}