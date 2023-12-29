// ignore_for_file: non_constant_identifier_names, file_names

class InfoSetting {
  bool? useVibrateMode;       // 진동모드        (false)
  bool? usePrivateTime;       // 방해금지 사용여부 (true)
  String? BeginPravateTime;   // 방해금지 시작시간 (18:00)
  String? EndPravateTime;     // 방해금지 종료시간 (07:59)
  bool? PushAllowQuestion;    // 문의 알림       (true)
  bool? PushAllowKeyword;     // 키워드 알림      (true)
  bool? PushAllowActivity;    // 활동 알림        (true)
  bool? PushAllowPromotion;   // 광고 마케팅 수신  (true)

  InfoSetting({
    this.useVibrateMode = false,
    this.usePrivateTime = true,
    this.BeginPravateTime = "18:00",
    this.EndPravateTime   = "07:59",
    this.PushAllowQuestion =false,
    this.PushAllowKeyword  = false,
    this.PushAllowActivity = false,
    this.PushAllowPromotion = false,
  });

  static List<InfoSetting> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return InfoSetting.fromJson(data);
    }).toList();
  }

  factory InfoSetting.fromJson(Map<String, dynamic> jdata)
  {
    return InfoSetting(
      useVibrateMode: jdata['useVibrateMode'],
      usePrivateTime: jdata['usePrivateTime'],
    );
  }

}