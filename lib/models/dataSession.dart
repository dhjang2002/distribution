// ignore_for_file: non_constant_identifier_names, file_names

class DataSession {
  String? status;       // status
  String? session_title;       // session_title
  String? session_start_time;   // session_start_time
  String? session_end_time;     // session_start_time
  String? content_session_oid;  // content_session_oid
  bool?   select;
  DataSession({
    this.select = false,
    this.status = '',
    this.session_title = "",
    this.session_start_time = "",
    this.session_end_time="",
    this.content_session_oid   = "",
  });

  static List<DataSession> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return DataSession.fromJson(data);
    }).toList();
  }

  factory DataSession.fromJson(Map<String, dynamic> jdata)
  {
    return DataSession(
      status: jdata['status'],
      session_title: jdata['session_title'],
      session_start_time: jdata['session_start_time'],
      session_end_time: jdata['session_end_time'],
      content_session_oid: jdata['content_session_oid'],
    );
  }
  @override
  String toString(){
    return 'DataSession {'
        'status:$status, '
        'session_title:$session_title, '
        'session_start_time:$session_start_time, '
        'session_end_time:$session_end_time, '
        'content_session_oid:$content_session_oid, '
        ' }';
  }
}