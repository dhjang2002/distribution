// ignore_for_file: non_constant_identifier_names, file_names

class DataTime {
  String? status;            // status
  String? content_oid;       // content_oid
  String? content_time;      // content_date
  String? content_time_oid;  // content_date_oid

  DataTime({
    this.status = '',
    this.content_oid = "",
    this.content_time = "",
    this.content_time_oid   = "",
  });

  static List<DataTime> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return DataTime.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'DataTime {'
        'status:$status, '
        'content_date:$content_time, '
        'content_oid:$content_oid, '
        'content_date_oid:$content_time_oid, '
        ' }';
  }

  factory DataTime.fromJson(Map<String, dynamic> jdata)
  {
    return DataTime(
      status: jdata['status'],
      content_oid: jdata['content_oid'],
      content_time: jdata['content_time'],
      content_time_oid: jdata['content_time_oid'],
    );
  }

}