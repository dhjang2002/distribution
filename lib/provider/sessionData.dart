// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:distribution/models/kConfig.dart';
import 'package:distribution/models/kInfoStore.dart';
import 'package:distribution/models/kEmployee.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionData with ChangeNotifier {
  String? IsSigned;
  String? Token;
  String? UserIds;
  String? UserPwd;
  String? FirebaseToken;
  String? FireBaseTopic;
  String? FireBaseTopicSaved;
  String? NoticeId;
  int     lStoreID;
  String? StoreKind;  // 본사(HD)/직영점(SB)/판매(SS)/공급(RR)/판매-공급(SR)
  String? Permission; // 관리자(ADMIN)/직원(USER)
  InfoStore? Stroe;
  Employee? User;
  ConfigData? Setting;
  String BuildNum;
  String UpdateCancel;
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(accountName: "Taka_distribute"),
    aOptions: const AndroidOptions(encryptedSharedPreferences: true)
  );

  SessionData({
    this.lStoreID = 1,
    this.BuildNum = "",
    this.UpdateCancel = "N",
    StroeName = "",
    this.IsSigned = "N",
    this.Token = "",
    this.StoreKind="",
    this.Permission="",
    this.FirebaseToken = "",
    this.FireBaseTopic = "",
    this.FireBaseTopicSaved = "",
    this.NoticeId = "",
    this.UserIds = "",
    this.UserPwd = "",
    this.User,
    this.Stroe,
    this.Setting
  });

  @override
  String toString(){
    return 'SessionData {'
        'IsSigned:$IsSigned, '
        'token:$Token, '
        'UserIds:$UserIds, '
        'FirebaseToken:$FirebaseToken, '
        'FireBaseTopicSaved:$FireBaseTopicSaved, '
        'Stroe:${Stroe.toString()}, '
        'User:${User.toString()}, '
        'Setting:${Setting.toString()} }';
  }

  bool isSigned() {
    return (IsSigned=="Y") ? true : false;
  }

  void doNotify() {
    notifyListeners();
  }

  // 자동 로그인 처리
  Future<void> setUser(Employee user, InfoStore store) async {
    IsSigned  = "Y";
    User      = user;
    Stroe     = store;
    lStoreID = Stroe!.lStoreID;

    setPermission();
    notifyListeners();
  }

  // 신규 로그인 처리
  Future<void> setLogin(String token, String ids, String pwd, Employee user, InfoStore store) async {
    IsSigned  = "Y";
    User      = user;
    Stroe     = store;
    lStoreID = Stroe!.lStoreID;

    setPermission();

    Token     = token;
    UserIds   = ids;
    await _storage.write(key: 'Token',   value: Token,);
    await _storage.write(key: 'UserIds', value: UserIds,);
    notifyListeners();
  }

  String getAccessStore() {
    if (StoreKind=="HD" || StoreKind == "SB") {
      return lStoreID.toString();
    }
    return "1";
  }

  String getMyStore() {
    return lStoreID.toString();
  }

  void setPermission() {
    StoreKind = "";
    FireBaseTopic = "";
    switch(Stroe!.sStoreType) {
    // sName: "(주)한국다까미야",
    // fVendorType:02, sVendorType: 매입매출처,
    // fStoreType":00, sStoreType": 본사,
      case "본사":
        StoreKind   = "HD";
        FireBaseTopic = "HD";
        break;

    // sName: 학장점,
    // fVendorType:02, sVendorType: 매입매출처
    // fStoreType":03, sStoreType: 직영,
      case "직영":
        StoreKind   = "SB";
        FireBaseTopic = "SB";
        break;

      case "거래처":
        if(Stroe!.sVendorType == "매출처") {
          // sName:스마트에스엔_매출처,
          // fVendorType:01,sVendorType:매출처,
          // fStoreType: 05,sStoreType:거래처,
          StoreKind   = "SS";
          FireBaseTopic = "SS";

        } else if(Stroe!.sVendorType == "매입처") {
          // sName:스마트에스엔_매입처,
          // fVendorType:00, sVendorType:매입처,
          // fStoreType: 05, sStoreType":거래처,
          StoreKind   = "RR";
          FireBaseTopic = "RR";

        } else if(Stroe!.sVendorType == "매입매출처") {
          // sName:스마트에스엔_매입매출처,
          // fVendorType:02,sVendorType:매입매출처,
          // fStoreType: 05,sStoreType:거래처,
          StoreKind   = "SR";
          FireBaseTopic = "SR";
        }
        break;
    }

    /*
    1. 본사 관리자/직원
    2. 직영점 관리자/직원
    3. 판매사 직원
    4. 공급사 직원
    5. 공급사/판매사 직원
    본사(HD)/직영점(SB)/판매(SS)/매압(RR)/매입-매출(SR)
    관리자(ADMIN)/직원(USER)
     */
    //StoreKind   = "HD";
    Permission  = "ADMIN";
  }

  Future<void> setLogout() async {
    Token    = "";
    IsSigned = "N";
    await _storage.write(key: 'Token', value: Token);
    await _storage.write(key: 'UserIds', value: UserIds);
    notifyListeners();
  }

  Future <void> saveSetting() async {
    await _storage.write(key: 'ActionButtonLoc', value: Setting!.ActionButtonLoc);
    await _storage.write(key: 'UseCamera', value: Setting!.UseCamera);
    await _storage.write(key: 'UseAutoLogin', value: Setting!.UseAutoLogin);
    await _storage.write(key: 'UseTestMode', value: Setting!.UseTestMode);
    notifyListeners();
  }

  Future <void> setFirebaseToken(String firebaseToken) async {
    if(FirebaseToken != firebaseToken) {
      FirebaseToken = firebaseToken;
      await _storage.write(key: 'FirebaseToken', value: FirebaseToken);
      notifyListeners();
    }
  }

  Future <void> setFirebaseTopic(String topic) async {
      FireBaseTopicSaved = topic;
      await _storage.write(key: 'FireBaseTopicSaved', value: FireBaseTopicSaved);
  }

  Future <void> setNoticeId(String noticeId) async {
    NoticeId = noticeId;
    await _storage.write(key: 'NoticeId', value: NoticeId);
  }

  Future <void> loadData() async {
    Setting ??= ConfigData();

    if(await _storage.containsKey(key:'NoticeId')) {
      NoticeId = await _storage.read(key: 'NoticeId');
    }

    if(await _storage.containsKey(key:'Token')) {
      Token = await _storage.read(key: 'Token');
    }

    if(await _storage.containsKey(key:'UserIds')) {
      UserIds = await _storage.read(key: 'UserIds');
    }

    if(await _storage.containsKey(key:'FirebaseToken')) {
      FirebaseToken = await _storage.read(key: 'FirebaseToken');
    }
    if(await _storage.containsKey(key:'FireBaseTopicSaved')) {
      FireBaseTopicSaved = await _storage.read(key: 'FireBaseTopicSaved');
    }
    if(await _storage.containsKey(key:'ActionButtonLoc')) {
      Setting!.ActionButtonLoc = await _storage.read(key: 'ActionButtonLoc');
    }

    if(await _storage.containsKey(key:'UseCamera')) {
      Setting!.UseCamera = await _storage.read(key: 'UseCamera');
    }

    if(await _storage.containsKey(key:'UseAutoLogin')) {
      Setting!.UseAutoLogin = await _storage.read(key: 'UseAutoLogin');
    }

    if(await _storage.containsKey(key:'UseTestMode')) {
      Setting!.UseTestMode = await _storage.read(key: 'UseTestMode');
    }

    Setting!.UseTestMode = "NO";
    // if(Setting!.UseTestMode == "YES") {
    //   UserIds = "wmstest1";
    //   UserPwd = "wmstest1";
    // }
    notifyListeners();
  }

}