// ignore_for_file: non_constant_identifier_names, file_names

class DataDate {
  String? status;            // status
  String? content_oid;       // content_oid
  String? content_date;      // content_date
  String? content_date_oid;  // content_date_oid

  DataDate({
    this.status = '',
    this.content_oid = "",
    this.content_date = "",
    this.content_date_oid   = "",
  });

  static List<DataDate> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return DataDate.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'DataDate {'
        'status:$status, '
        'content_date:$content_date, '
        'content_oid:$content_oid, '
        'content_date_oid:$content_date_oid, '
        ' }';
  }

  factory DataDate.fromJson(Map<String, dynamic> jdata)
  {
    return DataDate(
      status: jdata['status'],
      content_oid: jdata['content_oid'],
      content_date: jdata['content_date'],
      content_date_oid: jdata['content_date_oid'],
    );
  }

}