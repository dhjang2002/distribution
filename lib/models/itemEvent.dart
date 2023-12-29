class ItemEvent {
  String? Key;
  String? Title;      // 이벤트 타이틀
  String? Period;     // 이벤트 기간
  String? PhotoUrl;   // 사진
  String? Status;     // 진행상태

  ItemEvent({
    this.Key   = "",
    this.Title = "",
    this.Period = "",
    this.PhotoUrl = "",
    this.Status = "",
  });

  static List<ItemEvent> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemEvent.fromJson(data);
    }).toList();
  }

  factory ItemEvent.fromJson(Map<String, dynamic> jdata)
  {
    return ItemEvent(
      Key: jdata['key'],
      Title: jdata['Title'],
      Period: jdata['Period'],
      PhotoUrl: jdata['PhotoUrl'],
      Status: jdata['Status'],
    );
  }

  @override
  String toString() {
    return 'ItemPromotion{'
        'Key:$Key, '
        'Title:$Title, '
        'Period:$Period, '
        'PhotoUrl:$PhotoUrl, '
        'Status:$Status}';
  }
}