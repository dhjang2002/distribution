// ignore_for_file: use_build_context_synchronously

import 'package:distribution/LocalNotification/localNotification.dart';
import 'package:distribution/auth/login.dart';
import 'package:distribution/auth/password.dart';
import 'package:distribution/auth/profile.dart';
import 'package:distribution/common/cardFace.dart';
import 'package:distribution/common/cardGridMenu.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/config/appConfig.dart';
import 'package:distribution/home/goods/searchGoods.dart';
import 'package:distribution/home/goods/tempList/masterList.dart';
import 'package:distribution/home/order/cartGoods.dart';
import 'package:distribution/home/order/orderList.dart';
import 'package:distribution/home/orderRequest/orderRequestList.dart';
import 'package:distribution/home/shipping/shippingMain.dart';
import 'package:distribution/home/stock/stockMain.dart';
import 'package:distribution/home/warehousing/confirm/listPackedBoxInfo.dart';
import 'package:distribution/home/warehousing/warehousingMain.dart';
import 'package:distribution/models/kConfig.dart';
import 'package:distribution/models/kInfoStore.dart';
import 'package:distribution/models/kEmployee.dart';
import 'package:distribution/models/kItemNotify.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/push/showNotify.dart';
import 'package:distribution/remote/remote.dart';
import 'package:distribution/utils/mediaView.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';
import 'package:url_launcher/url_launcher.dart';

class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> with WidgetsBindingObserver {
  final LocalNotification notification = LocalNotification();
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey();

  late DateTime _preBackpress;
  Color _appColor = Colors.white;

  bool _bReady = false;
  bool _bRedBell = false;
  int   menuCrossAxisCount = 4;
  bool _isDeveloper = false;
  int  _buildTapCount = 0;
  List<CardGridMenuItem> menuItems = [];

  late SessionData _session;
  String _versionInfo = "";
  String _serverInfo = "";
  String _buildNumber = "";
  Future<void> setVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _buildNumber = packageInfo.buildNumber;
    _versionInfo = "${packageInfo.version} (${packageInfo.buildNumber})";
    _serverInfo  = SERVER.split("//").elementAt(1);
    if (kDebugMode) {
      print("_versionInfo:$_versionInfo");
      print("_serverInfo:$_serverInfo");
    }
  }

  Future<void> procFirebaseMassing() async {
    if (kDebugMode) {
      print("procFirebaseMassing()::start.");
    }

    messaging.getToken().then((token) {
      if (kDebugMode) {
        print("procFirebaseMassing()::getToken(): ---- > $token");
      }
      _session.FirebaseToken = token;
    });

    // 사용자가 클릭한 메시지를 제공함.
    messaging.getInitialMessage().then((message) {
      if (kDebugMode) {
        print("getInitialMessage(user tab) -----------------> ");
      }

      if (message != null && message.notification != null) {
        String action = "";
        if (message.data["action"] != null) {
          action = message.data["action"];
        }

        if (kDebugMode) {
          print("title=${message.notification!.title.toString()},\n"
              "body=${message.notification!.body.toString()},\n"
              "action=$action");
        }
      }

      // if foreground state here.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print("Foreground Status(active) -----------------> ");
        }

        if (message.notification != null) {
          String action = "";
          if (message.data["action"] != null) {
            action = message.data["action"];
          }

          if (kDebugMode) {
            print("title=${message.notification!.title.toString()},\n"
                "body=${message.notification!.body.toString()},\n"
                "action=$action");
          }

          setState(() {
            _bRedBell = true;
          });

          notification.show(message.notification!.title.toString(),
              message.notification!.body.toString());
        }
      });

      // 엡이 죽지않고 백그라운드 상태일때...
      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        if (kDebugMode) {
          print("Background Status(alive) -----------------> ");
        }

        if (message.notification != null) {
          String action = "";
          if (message.data["action"] != null) {
            action = message.data["action"];
          }
          if (kDebugMode) {
            print("title=${message.notification!.title.toString()},\n"
                "body=${message.notification!.body.toString()},\n"
                "action=$action");
          }

          notification.show(message.notification!.title.toString(),
              message.notification!.body.toString());

          setState(() {
            _bRedBell = true;
          });
        }
      });
    });
  }

  Future<void> _setFirebaseSubcribed() async {
    String topic = _session.FireBaseTopic!;
    if (kDebugMode) {
      print("setFirebaseSubcribed($topic)");
    }

    if (_session.FireBaseTopic!.isNotEmpty &&
        _session.FireBaseTopic != _session.FireBaseTopicSaved) {
      if (kDebugMode) {
        print("updated Topics .....");
      }

      await _session.setFirebaseTopic(_session.FireBaseTopic!);

      // 이전 구독정보 삭제
      //bool isValidTopic = RegExp(r'^[a-zA-Z0-9-_.~%]{1,900}$').hasMatch(topic);
      // "본사(HD)", "직영점(SB)", "매출처(SS)", "매입처(RR)"
      await FirebaseMessaging.instance.unsubscribeFromTopic("HD"); // "본사(HD)"
      await FirebaseMessaging.instance.unsubscribeFromTopic("SB"); // "직영점(SB)"
      await FirebaseMessaging.instance.unsubscribeFromTopic("SS"); // "매출처(SS)"
      await FirebaseMessaging.instance.unsubscribeFromTopic("RR"); // "매입처(RR)"

      // 새 구독정보 등록
      if (_session.FireBaseTopic == "SR") {
        await FirebaseMessaging.instance.subscribeToTopic("SS");
        await FirebaseMessaging.instance.subscribeToTopic("RR");
      } else {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
      }
    }
  }

  @override
  void initState() {
    _bReady = false;
    _preBackpress  = DateTime.now();
    _session = Provider.of<SessionData>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    _session.Stroe   = InfoStore();
    _session.User    = Employee();
    _session.Setting = ConfigData();
    Future.microtask(() async {

      await notification.init();
      await notification.requestPermissions();
      await notification.cancel();
      await procFirebaseMassing();
      await setVersionInfo();
      await _session.loadData();
      await _doLoginProc();

    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch(state) {
      case AppLifecycleState.resumed:
        print("AppLifecycleState.resumed");
        _checkAppVerson();
        FlutterAppBadger.removeBadge();
        break;
      case AppLifecycleState.inactive:
        // TODO: Handle this case.
        print("AppLifecycleState.inactive");
        break;
      case AppLifecycleState.paused:
        // TODO: Handle this case.
        print("AppLifecycleState.paused");
        break;
      case AppLifecycleState.detached:
        // TODO: Handle this case.
        print("AppLifecycleState.detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _session = Provider.of<SessionData>(context, listen: true);

    if (!_bReady) {
      return Container(
          color: Colors.white,
          child: Center(
              child: ClipRect(
                child: Container(
                    //padding: EdgeInsets.all(10),
                    color: Colors.white,
                    child: Image.asset(
                      "assets/icon/ic_launcher.png",
                      //width: 180,
                      height: 100,
                      fit: BoxFit.fitHeight,
                    )
                ),
              )
          )
      );
    }

    if (!_session.isSigned()) {
      _bReady = false;
      Future.microtask(() async {
        _doLogin();
      });
    }

    return WillPopScope(
        onWillPop: () {
          return _onWillPop();
        },
        child: Scaffold(
            key: _scaffoldStateKey,
            appBar: AppBar(
              centerTitle: false,
              backgroundColor: _appColor,
              title: Row(
                children: [
                  Visibility(
                    visible: !modeIsDeveloper,
                      child: SizedBox(
                      height: 26,
                      child: (_appColor != Colors.amber) ? Image.asset(
                        "assets/icon/tk_logo.png",
                        fit: BoxFit.fitHeight,
                      ) : Text("주의: 구 버전 사용중.")
                      )
                  ),
                  const Visibility(
                      visible: modeIsDeveloper,
                      child: SizedBox(
                          height: 26,
                          child: Text("(주)한국다까미야"))
                  ),
                ],
              ),
              actions: [
                // 알림
                Visibility(
                  visible: true,
                  child: IconButton(
                      icon: Icon(
                        (_bRedBell)
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_active_outlined,
                        size: 26,
                        color: (_bRedBell)
                            ? Colors.red
                            : ( (modeIsDeveloper) ? Colors.white : Colors.black),
                      ),
                      onPressed: () async {
                        _showNotify();
                      }),
                ),

                // 메뉴
                Visibility(
                  visible: true,
                  child: IconButton(
                      icon: const Icon(
                        Icons.menu,
                        size: 28,
                      ),
                      onPressed: () async {
                        _scaffoldStateKey.currentState!.openEndDrawer();
                      }),
                ),
              ],
            ),
            endDrawer: _renderDrawer(),
            body: _renderBody()));
  }

  Widget _renderBody() {
    if (!_session.isSigned()) {
      return Container();
    }

    double psz = MediaQuery.of(context).size.width/4;
    if(menuItems.length==3) {
      psz = MediaQuery.of(context).size.width/6;
    } else if(menuItems.length==2) {
      psz = MediaQuery.of(context).size.width/3.8;
    } else {
      psz = MediaQuery.of(context).size.width/15;
    }
    final double vheight = MediaQuery.of(context).size.width * 0.56;

    double bottomPading = getMainBottomPading(context, 2);
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.fromLTRB(5, 25, 5, 15),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _session.Stroe!.sName,
                          style: ItemBkB20,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "${_session.User!.sName!}님 환영합니다.",
                          style: ItemBkN16,
                        ),
                      ],
                    ),
                  ),

                  // main View
                  Container(
                    height: vheight,
                    color: Colors.black,
                    child: const MediaView(
                        isMovie: true,
                        sourceUrl: 'http://tkwms.maxidc.net/main/01.mp4'),
                  ),
                ],
              )
          ),

          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                //padding: EdgeInsets.fromLTRB(psz, 0, psz, psz/2),
                padding: EdgeInsets.fromLTRB(psz, 0, psz, bottomPading),
                child: CardGridMenu(
                  crossAxisCount: menuCrossAxisCount,
                  items: menuItems,
                  onTab: (CardGridMenuItem item) {
                    _onAction(item);
                  },
                ),
              ))
        ],
      ),
    );
  }

  Widget _drowerItem({
      required bool visible,
      required String menuText,
      required String imagePath,
      required Function() onTap}) {
    return Visibility(
      visible: visible,
      child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 5, bottom: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              child: Image.asset(
                imagePath,
                width: DrawerItemMenuIconSize,
                height: DrawerItemMenuIconSize,
                color: Colors.white,
              ),
            ),
            title: Text(
              menuText,
              style: ItemBkN16,
            ),
            onTap: () => onTap(),
          )),
    );
  }

  Widget _renderDrawer() {
    final String axisInfo = getMainAxisInfo(context);
    final width = MediaQuery.of(context).size.width * 0.85;
    if (_session.Stroe == null ||
        _session.User == null ||
        _session.Setting == null) {
      return const Drawer();
    }

    final useTestMode = (_session.Setting!.UseTestMode == "YES");
    return Drawer(
        width: width,
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 120,
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // title bar
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: Row(
                          children: [
                            Image.asset("assets/intro/intro_logo.png",
                                height: 80, fit: BoxFit.fitHeight),
                            const Spacer(),
                            IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 24,
                                  color: Colors.black,
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                }),
                          ],
                        ),
                      ),

                      // user info
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    offset: const Offset(0, 0.5), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: CardFace(photoUrl: ""),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 이름/편진
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _session.User!.sName!,
                                            maxLines: 2,
                                            style: ItemBkN20,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Spacer(),
                                          Visibility(
                                            visible: false,
                                            child: TextButton(
                                              onPressed: () {
                                                _doProfile();
                                              },
                                              style: TextButton.styleFrom(
                                                minimumSize: Size.zero,
                                                padding:
                                                    const EdgeInsets.all(5),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: const Text(
                                                "수정",
                                                style: ItemBkN14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // 소속
                                      Container(
                                        padding: const EdgeInsets.only(
                                            top: 3, bottom: 5, right: 10),
                                        //color: Colors.amber,
                                        child: Text(
                                          _session.Stroe!.sName,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14),
                                        ),
                                      ),
                                      // 스토어 유형
                                      Container(
                                        padding: const EdgeInsets.only(
                                            top: 3, bottom: 5, right: 10),
                                        //color: Colors.amber,
                                        child: Text(
                                          _session.Stroe!.sStoreType,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),



                      _drowerItem(
                          visible: true,
                          menuText: '로그아웃',
                          imagePath: 'assets/icon/quick_icon02.png',
                          onTap: () {
                            _doLogout();
                            Navigator.pop(context);
                          }),
                      _drowerItem(
                          visible: true,
                          menuText: '비밀번호 변경',
                          imagePath: 'assets/icon/quick_icon01.png',
                          onTap: () {
                            _doPassword();
                          }),
                      _drowerItem(
                          visible: useTestMode,
                          menuText: '본사',
                          imagePath: 'assets/icon/quick_icon02.png',
                          onTap: () {
                            _doLoginTest("wmstest1", "wmstest1");
                          }),

                      _drowerItem(
                          visible: useTestMode,
                          menuText: '동서울점',
                          imagePath: 'assets/icon/quick_icon02.png',
                          onTap: () {
                            _doLoginTest("eastseoul1 ", "eastseoul1");
                          }),
                      _drowerItem(
                          visible: useTestMode,
                          menuText: '학장점',
                          imagePath: 'assets/icon/quick_icon02.png',
                          onTap: () {
                            _doLoginTest("hakjang1", "hakjang1");
                          }),
                      _drowerItem(
                          visible: useTestMode,
                          menuText: '매입처 로그인',
                          imagePath: 'assets/icon/quick_icon02.png',
                          onTap: () {
                            _doLoginTest("z22102801", "1234");
                          }),

                      _drowerItem(
                          visible: useTestMode,
                          menuText: '매출처 로그인',
                          imagePath: 'assets/icon/quick_icon02.png',
                          onTap: () {
                            _doLoginTest("z22102802", "1234");
                          }),

                      _drowerItem(
                          visible: useTestMode,
                          menuText: '매입/매출처 로그인',
                          imagePath: 'assets/icon/quick_icon02.png',
                          onTap: () {
                            _doLoginTest("z22102803", "1234");
                          }),
                      _drowerItem(
                          visible: true,
                          menuText: '공지사항',
                          imagePath: 'assets/icon/quick_icon05.png',
                          onTap: () {
                            _showNotify();
                          }),
                      _drowerItem(
                          visible: true,
                          menuText: '환경설정',
                          imagePath: 'assets/icon/quick_icon03.png',
                          onTap: () {
                            _doBtnConfig();
                          }),

                      _drowerItem(
                          visible: true,
                          menuText: '캐시 지우기',
                          imagePath: 'assets/icon/quick_icon02.png',
                          onTap: () async {
                            await DefaultCacheManager().emptyCache();
                            showToastMessage("삭제되었습니다.");
                            Navigator.pop(context);
                          }),
                    ],
                  ))),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    _buildTapCount++;
                    if(_buildTapCount>10) {
                      _isDeveloper = !_isDeveloper;
                      _buildTapCount = 0;
                      if(_isDeveloper) {
                        showToastMessage("개발자 모드 활성화.");
                      }
                      else {
                        showToastMessage("개발자 모드 종료.");
                      }
                      setState(() async {
                        if(!_isDeveloper) {
                          _session.Setting!.UseTestMode =
                          (_isDeveloper) ? "YES" : "NO";
                          _session.doNotify();

                        }
                        //await _session.saveSetting();
                      });
                    }
                  },
                  child:Container(
                    width: double.infinity,
                    height: 150,
                    padding: const EdgeInsets.fromLTRB(10, 0, 20, 10),
                    color: Colors.grey[100],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text("빌드정보", style: ItemBkB14,),
                            const Spacer(),
                            TextButton(onPressed: (){
                                  _goUpdate();
                                },
                                child: const Text("업데이트", style: ItemR1B14,)
                            ),
                          ],
                        ),

                        Text("앱버전: $_versionInfo", style: ItemBkN12,),
                        Text("서버: $_serverInfo", style: ItemBkN12),
                        const Text("빌드일자: $buildDate", style: ItemBkN12),
                        Text("실행환경: $axisInfo", style: ItemBkN12),
                        Visibility(
                            visible: _isDeveloper,
                            child: const Text("[개발자 모드]", style: ItemBkN12)
                        )
                      ],
                    ),
                  ),
                )
              ),
            ],
          ),
        ));
  }

  // 메뉴바 닫기
  bool _doCloseDrower() {
    if (_scaffoldStateKey.currentState!.isEndDrawerOpen) {
      Navigator.pop(context);
      return true;
    }
    return false;
  }

  void _buildMenuItems() {
    menuItems = [];
    final double ma = getMainAxis(context);
    //String? StoreType;  // 본사(HD)/직영점(SB)/판매(SS)/공급(RR)/판매-공급(SR)
    if (_session.isSigned()) {
      switch (_session.StoreKind) {
        case "HD": // 본사
          menuCrossAxisCount = 4;
          if(ma>2.40) menuCrossAxisCount = 3;
          if(ma<1.55) menuCrossAxisCount = 6;
          menuItems.add(CardGridMenuItem(
              label: '상품검색', menuId: 101, assetsPath: "icon/main_check.png"));
          menuItems.add(CardGridMenuItem(
              label: '상품진열',
              menuId: 102,
              assetsPath: "icon/main_delivery_box.png"));
          menuItems.add(CardGridMenuItem(
              label: '경합가격',
              menuId: 103,
              assetsPath: "icon/main_increase.png"));
          menuItems.add(CardGridMenuItem(
              label: '재고실사', menuId: 201, assetsPath: "icon/main_file.png"));
          menuItems.add(CardGridMenuItem(
              label: '재고이동', menuId: 202, assetsPath: "icon/main_boxes.png"));
          menuItems.add(CardGridMenuItem(
              label: '입고배분', menuId: 203, assetsPath: "icon/main_parcel.png"));
          menuItems.add(CardGridMenuItem(
              label: '상품출고',
              menuId: 301,
              assetsPath: "icon/main_return_box.png"));
          menuItems.add(CardGridMenuItem(
              label: '임시저장',
              menuId: 1001,
              assetsPath: "icon/main_return_box.png"));

          break;

        case "SB": // 직영점
          menuCrossAxisCount =  4;
          if(ma>2.40)  menuCrossAxisCount = 3;
          if(ma<1.55) menuCrossAxisCount = 6;
          menuItems.add(CardGridMenuItem(
              label: '상품검색', menuId: 101, assetsPath: "icon/main_check.png"));
          menuItems.add(CardGridMenuItem(
              label: '상품진열',
              menuId: 102,
              assetsPath: "icon/main_delivery_box.png"));
          menuItems.add(CardGridMenuItem(
              label: '재고이동', menuId: 202, assetsPath: "icon/main_boxes.png"));
          menuItems.add(CardGridMenuItem(
              label: '경합가격',
              menuId: 103,
              assetsPath: "icon/main_increase.png"));
          menuItems.add(CardGridMenuItem(
              label: '재고실사', menuId: 201, assetsPath: "icon/main_file.png"));
          menuItems.add(CardGridMenuItem(
              label: '임시저장',
              menuId: 1001,
              assetsPath: "icon/main_return_box.png"));
          menuItems.add(CardGridMenuItem(
              label: '입고확인',
              menuId: 2001,
              assetsPath: "icon/main_return_box.png"));
          // menuItems.add(CardGridMenuItem(
          //     label: '상품주문', menuId: 401, assetsPath: "icon/main_file.png"));
          // menuItems.add(CardGridMenuItem(
          //     label: '주문내역', menuId: 402, assetsPath: "icon/main_file.png"));
          break;

        case "SS": // 매출(SS)
          //menuCrossAxisCount = 4;
          menuCrossAxisCount =  4;
          if(ma>2.40) menuCrossAxisCount  = 3;
          if(ma<1.55) menuCrossAxisCount = 6;
          menuItems.add(CardGridMenuItem(
              label: '상품검색', menuId: 101, assetsPath: "icon/main_check.png"));
          menuItems.add(CardGridMenuItem(
              label: '상품주문', menuId: 401, assetsPath: "icon/main_file.png"));
          menuItems.add(CardGridMenuItem(
              label: '주문내역', menuId: 402, assetsPath: "icon/main_file.png"));
          menuItems.add(CardGridMenuItem(
              label: '입고확인',
              menuId: 2001,
              assetsPath: "icon/main_return_box.png"));
          break;

        case "RR": // 매입(RR)
          menuCrossAxisCount = 2;
          if(ma>2.40) menuCrossAxisCount = 3;
          if(ma<1.55) menuCrossAxisCount = 6;
          menuItems.add(CardGridMenuItem(
              label: '상품검색', menuId: 101, assetsPath: "icon/main_check.png"));
          menuItems.add(CardGridMenuItem(
              label: '입고요청', menuId: 501, assetsPath: "icon/main_parcel.png"));
          break;

        case "SR": // 매입-매출(SR)
          menuCrossAxisCount =  4;
          if(ma>2.40) menuCrossAxisCount = 3;
          if(ma<1.55) menuCrossAxisCount = 6;
          menuItems.add(CardGridMenuItem(
              label: '상품검색', menuId: 101, assetsPath: "icon/main_check.png"));
          menuItems.add(CardGridMenuItem(
              label: '상품주문', menuId: 401, assetsPath: "icon/main_file.png"));
          menuItems.add(CardGridMenuItem(
              label: '주문내역', menuId: 402, assetsPath: "icon/main_file.png"));
          menuItems.add(CardGridMenuItem(
              label: '입고요청', menuId: 501, assetsPath: "icon/main_parcel.png"));
          menuItems.add(CardGridMenuItem(
              label: '입고확인',
              menuId: 2001,
              assetsPath: "icon/main_return_box.png"));
          break;
      }
    }
  }

  void _onAction(CardGridMenuItem item) {
    switch (item.menuId) {
      case 101: // 상품검색
        Navigator.push(
          context,
          Transition(
              child: const SearchGoods(
                title: "상품검색",
                target: "SEARCH",
              ),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;
      case 102: // 상품진열
        Navigator.push(
          context,
          Transition(
              child: const SearchGoods(
                title: "상품진열",
                target: "DISPLAY",
              ),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;
      case 103: // 가격변경
        Navigator.push(
          context,
          Transition(
              child: const SearchGoods(
                title: "경합가격",
                target: "PRICE",
              ),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;
      case 201: // 재고실사
        Navigator.push(
          context,
          Transition(
              child: const StockMain(),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;
      case 202: // 재고이동
        Navigator.push(
          context,
          Transition(
              child: const SearchGoods(
                title: "재고이동",
                target: "STOCK",
              ),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;
      case 203: // 입고배분
        Navigator.push(
          context,
          Transition(
              child: const WarehousingMain(),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;

      case 301: // 상품출고
        Navigator.push(
          context,
          Transition(
              child: const ShippingMain(),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;
      case 401: // 주문하기
        Navigator.push(
          context,
          Transition(
              child: CartGoods(lStoreID: _session.Stroe!.lStoreID),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;
      case 402: // 주문내역
        Navigator.push(
          context,
          Transition(
              child: OrderList(lStoreID: _session.Stroe!.lStoreID),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;
      case 501: // 입고요청
        Navigator.push(
          context,
          Transition(
              child: const OrderRequestList(),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        // showToastMessage("공급사 입고요청 처리...");
        break;

      case 1001: // 입고요청
        Navigator.push(
          context,
          Transition(
              child: const MasterList(),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        // showToastMessage("공급사 입고요청 처리...");
        break;

      case 2001: // 입고요청
        Navigator.push(
          context,
          Transition(
              child: const ListPackedBoxInfo(),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;

      default:
        break;
    }
  }

  Future<void> _goUpdate() async {
    String url = "http://twms_win.ensisys.co.kr/takamiyaApp/";
    await launch(url, forceSafariVC:true, forceWebView: false);
    //showUrl(url);
  }

  // backKey event 처리
  Future<bool> _onWillPop() async {
    if (_doCloseDrower()) {
      _doCloseDrower();
      return false;
    }

    //print("check Clossing....");
    final timegap = DateTime.now().difference(_preBackpress);
    final cantExit = timegap >= const Duration(seconds: 2);
    _preBackpress = DateTime.now();

    if (kDebugMode) {
      print("check Clossing....cantExit[$cantExit]");
    }

    if (cantExit) {
      showToastMessage("한번 더 누르면 앱을 종료합니다.");
      return false; // false will do nothing when back press
    }
    Fluttertoast.cancel();
    return true; // true will exit the app
  }

  Future<void> _doLoginProc() async {
    _bReady = false;
    if (_session.Setting != null && _session.Setting!.UseAutoLogin == "YES") {
      await _doTokenLogin();
    }
    if (!_session.isSigned()) {
      await _doLogin();
    }

    if (_session.isSigned()) {
      await _updatePushToken();
      await _setFirebaseSubcribed();
      await _updateNotifyStatus();
      _checkAppVerson();
      _bReady = true;
      setState(() {
        _buildMenuItems();
      });
    }
  }

  Future<void> _updatePushToken() async {
    if (_session.FirebaseToken == _session.User!.sPushToken) {
      return;
    }

    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "auth/update",
        params: {
          "sPushToken": _session.FirebaseToken,
        },
        onResult: (dynamic params) async {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {}
        },
        onError: (String error) {});
  }

  Future<void> _doLogin() async {
    await Navigator.push(
      context,
      Transition(
          child: const Login(),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if (_session.isSigned()) {
      _setFirebaseSubcribed();
      await _updateNotifyStatus();
      _bReady = true;
      setState(() {
        _buildMenuItems();
      });
    }
  }

  Future<void> _doProfile() async {
    await Navigator.push(
      context,
      Transition(
          child: const Profile(),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
    setState(() {
      _bReady = true;
    });
  }

  Future<void> _doPassword() async {
    await Navigator.push(
      context,
      Transition(
          child: const Password(),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
    setState(() {
      _bReady = true;
    });
  }

  Future <void> _doTokenLogin() async {
    if (kDebugMode) {
      print("_doTokenLogin()->token: ${_session.Token!}");
    }

    if(_session.Token!.isEmpty) {
      if (kDebugMode) {
        print("_doTokenLogin()->token: Invalid... skip.");
      }
      return;
    }
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: "",
        method: "auth/token",
        params: {},
        onResult: (dynamic data) {
          if (data['status'] == "success") {
            // if (kDebugMode) {
            //   var logger = Logger();
            //   logger.d(data);
            // }

            Employee person = Employee.fromJson(data['data']['employee']);
            InfoStore store = InfoStore.fromJson(data['data']['store']);
            _session.setUser(person, store);

            // if (kDebugMode) {
            //   print(_session.toString());
            // }
            //showSnackbar(context, "${person.sName}님 환영합니다.");
          }
        },
        onError: (String error) {
          if (kDebugMode) {
            print(error);
          }
        });
  }

  Future<void> _doLogout() async {
    if (_session.isSigned()) {
      await Remote.apiPost(
          context: context,
          session: _session,
          lStoreId: "",
          method: "auth/logout",
          params: {},
          onResult: (dynamic data) {
            if (data['status'] == "success") {
              _session.setLogout();
              setState(() {});
            }
          },
          onError: (String error) {});
    } else {
      _session.setLogout();
      setState(() {});
    }
  }

  Future<void> _doBtnConfig() async {
    Navigator.push(
      context,
      Transition(
          child: AppConfig(isDeveloper: _isDeveloper),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }

  Future<void> _doLoginTest(String ids, String pwd) async {
    //print("_doLoginTest()::ids=$ids, pwd=$pwd");
    Navigator.pop(context);
    await Navigator.push(
      context,
      Transition(
          child: Login(ids: ids, pwd: pwd),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if (_session.isSigned()) {
      _bReady = true;
      setState(() {
        _buildMenuItems();
      });
    }
  }

  Future<void> _showNotify() async {
    await notification.cancel();
    await Navigator.push(
      context,
      Transition(
          child: const ShowNotify(),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    setState(() {
      _bRedBell = false;
    });

    _updateNotifyStatus();
  }

  Future<void> _updateNotifyStatus() async {
    _bRedBell = false;
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/appListNotice",
        params: {"sTopic": _session.FireBaseTopic},
        onResult: (dynamic data) async {
          if (data['data'] != null) {
            var content = data['data'];
            var itemList = ItemNotify.fromSnapshot(content);
            // print("**********************");
            if (itemList.isNotEmpty) {
              String noticeId = itemList[0].lNoticeID.toString();
              if (noticeId != _session.NoticeId) {
                _bRedBell = true;
              }
            }
            setState(() {});
          }
        },
        onError: (String error) {});
  }

  Future<void> _reqAppVersionInfo() async {
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: "",
        method: "taka/version",
        params: {},
        onError: (String error) {},
        onResult: (dynamic data) {

          print(data.toString());

          if (data['status'] == "success") {
            _session.BuildNum = (data['lBuildNumber'] != null ) ? data['lBuildNumber'] : "";
            _session.notifyListeners();
          }
        },
    );
  }

  Future <void> _checkAppVerson() async {
    print("_checkAppVerson(): .............................................");
    if(_session.BuildNum.isEmpty) {
      await _reqAppVersionInfo();
    }

    int iCurrNumber = (int.tryParse(_buildNumber)!=null)
        ? int.parse(_buildNumber) : 0;
    int iBuildNum   = (int.tryParse(_session.BuildNum)!=null)
        ? int.parse(_session.BuildNum):0;

    if(_session.UpdateCancel != "Y" && iCurrNumber>0 && iBuildNum>0) {
      if (iCurrNumber < iBuildNum) {
        setState(() {
          _appColor = Colors.amber;
        });

        showYesNoDialogBox(
            context: context,
            height: 280,
            title: "업데이트",
            btnNo: "다음에",
            reverse: true,
            message: "새로운 버전(${_session.BuildNum})의 앱이 출시되었습니다."
                "\n사용 중인 앱은 (${_buildNumber})입니다."
                "\n최신 버전으로 업데이트 후, 사용해 주십시오."
                "\n\n업데이트 사이트로 이동하시겠습니까?",
            onResult: (bOK) {
              if (bOK) {
                _goUpdate();
              }
              else {
                _session.UpdateCancel = "Y";
              }
            }
        );
      } else {
        setState(() {
          _appColor = Colors.white;
        });
      }
    }
  }
}
