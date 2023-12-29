// ignore_for_file: non_constant_identifier_names, file_names

class DataEquipment {
  String? status;                 // status
  String? is_basic_item;          // is_basic_item
  String? equipment_title;        // equipment_title
  String? unit_name;              // unit_name
  String? max_units;              // max_units
  String? additional_cost;        // additional_cost
  String? content_equipment_oid;  // content_equipment_oid
  int? price;
  int? count;
  bool? openState;
  DataEquipment({
    this.price = 0,
    this.count = 0,
    this.openState = false,
    this.status = '',
    this.is_basic_item="",
    this.equipment_title = "",
    this.unit_name = "",
    this.content_equipment_oid   = "",
    this.max_units="",
    this.additional_cost="",
  });

  static List<DataEquipment> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return DataEquipment.fromJson(data);
    }).toList();
  }

  factory DataEquipment.fromJson(Map<String, dynamic> jdata)
  {
    return DataEquipment(
      status: jdata['status'],
      is_basic_item: jdata['is_basic_item'],
      equipment_title: jdata['equipment_title'],
      unit_name: jdata['unit_name'],
      content_equipment_oid: jdata['content_equipment_oid'],
      max_units: jdata['max_units'],
      additional_cost: jdata['additional_cost'],
    );
  }

  @override
  String toString(){
    return 'DataEquipment {'
        'status:$status, '
        'is_basic_item:$is_basic_item, '
        'equipment_title:$equipment_title, '
        'unit_name:$unit_name, '
        'content_equipment_oid:$content_equipment_oid, '
        'max_units:$max_units, '
        'additional_cost:$additional_cost, '
        ' }';
  }
}