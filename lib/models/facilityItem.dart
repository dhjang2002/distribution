// ignore_for_file: file_names, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:convert';

class FacilityItem {
  String?    ID;
  String? Label;
  var image;
  FacilityItem({
    this.ID = "0",
    this.image,
    this.Label = "",
  });

  @override
  String toString(){
    return 'FacilityItem {'
        'ID:$ID, '
        'Label:$Label, '
        //'image:${image.toString()}, '
        ' }';
  }

  static List<FacilityItem> fromSnapshot(List snapshot) {
    //print("FacilityItem:"+snapshot.toString());
    return snapshot.map((data) {
      return FacilityItem.fromJson(data);
    }).toList();
  }

  factory FacilityItem.fromJson(Map<String, dynamic> jdata)
  {
    String icon = jdata['amenity_icon'];//.toString();
    //print("before icon=======>");
    //print(icon);

    icon = icon.replaceAll("\\n", "");
    icon = icon.replaceAll("\\", "");
    //print("after icon=======>");
    //print(icon);
    return FacilityItem(
      ID: jdata['amenity_oid'],
      Label: jdata['amenity_title'],
      image: base64Decode(icon),
    );
  }
}