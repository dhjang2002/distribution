// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

class ConfigData {
  String? ActionButtonLoc;
  String? UseCamera;
  String? UseAutoLogin;
  String? UseTestMode;

  ConfigData({
    this.ActionButtonLoc="0",
    this.UseCamera="YES",
    this.UseAutoLogin = "YES",
    this.UseTestMode = "NO",
  });

  factory ConfigData.fromJson(Map<String, dynamic> jdata)
  {
    return ConfigData(
      ActionButtonLoc: jdata['ActionButtonLoc'],
    );
  }

  @override
  String toString(){
    return 'Config {'
        'ActionButtonLoc:$ActionButtonLoc, '
        'UseCamera:$UseCamera, '
        'UseTestMode:$UseTestMode, '
        'UseAutoLogin:$UseAutoLogin, }';
  }
}
