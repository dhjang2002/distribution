// ignore_for_file: file_names

import 'package:distribution/common/cardGridMenu.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/stock/workArea.dart';
import 'package:distribution/home/stock/workErrorScanGoods.dart';
import 'package:distribution/home/stock/workMissScanGoods.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class StockMain extends StatefulWidget {
  const StockMain({Key? key}) : super(key: key);

  @override
  State<StockMain> createState() => _StockMainState();
}

class _StockMainState extends State<StockMain> {
  List<CardGridMenuItem> menuItems = [];

  String workDay = "";
  bool _bAvailScan = false;
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _buildMenuItems();
    Future.microtask(() async {
      _reqWorkStatus();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _buildMenuItems() {
    menuItems = [];
    if (_session.isSigned()) {
      menuItems.add(CardGridMenuItem(
          label: '재고실사', menuId: 3031, assetsPath: "icon/main_check.png"));
      menuItems.add(CardGridMenuItem(
          label: '오차확인', menuId: 3032, assetsPath: "icon/main_parcel.png"));
      menuItems.add(CardGridMenuItem(
          label: '실사누락', menuId: 3033, assetsPath: "icon/main_parcel.png"));
    }
  }

  void _onAction(CardGridMenuItem item) {
    switch (item.menuId) {
      case 3031: // 재고실사
        Navigator.push(
          context,
          Transition(
              child: WorkArea(workDay: workDay),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;

      case 3032: // 오류확인
        Navigator.push(
          context,
          Transition(
              child: WorkErrorScanGoods(workDay: workDay),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;
      case 3033: // 실사누락
        Navigator.push(
          context,
          Transition(
              child: WorkMissScanGoods(workDay: workDay),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("재고실사"),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 28,),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: _renderBody());
  }

  Widget _renderBody() {
    double psz = MediaQuery.of(context).size.width/6;
    double bottomPading = getMainBottomPading(context, 1);
    double mainPictHeight = MediaQuery.of(context).size.height*0.4;
    return Stack(
      children: [
        Positioned(
            top: 0, left: 0, right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
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
                      const Text(
                        "재고실사 업무를 처리합니다.",
                        style: ItemBkN16,
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: mainPictHeight,
                  width: double.infinity,
                  child: Image.asset("assets/intro/menu_distribute.png",
                    fit: BoxFit.cover,),
                ),
              ],
            )
        ),

        Positioned(
            bottom: 0, left: 0, right: 0,
            child: Visibility(
                visible: _bAvailScan,
                child:Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(bottom: bottomPading),
                    color: Colors.white,
                    child: Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(psz, 0, psz, 0),
                    child: CardGridMenu(
                      crossAxisCount: 3,
                      items: menuItems,
                      onTab: (CardGridMenuItem item) {
                        _onAction(item);
                      },
                    ),
                  ),
                )
                )
            )
        ),
        Positioned(
            bottom: 0, left: 0, right: 0,
            child: Visibility(
              visible: !_bAvailScan,
              child:Container(
                height: 240,
                width: double.infinity,
                  //margin: EdgeInsets.only(bottom: 25),
                color: Colors.grey[50],
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: const Text("재고실사 기간이 아닙니다.", style: ItemBkN20,),
                  ),
                ))
            )
        ),
      ],
    );
  }

  // 작업가능 상태조회
  Future <void> _reqWorkStatus() async {
    _bAvailScan = false;
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/infoInspect",
        params: {},
        onResult: (dynamic response) {
          if (kDebugMode) {
            var logger = Logger();
            logger.d(response);
          }

          if (response['status'] == "success") {
            var data = response['data'];
            int fState = (data['fState'] != null)
                ? int.parse(data['fState'].toString().trim()) : 0;
            if(fState != 1) {
              _bAvailScan = true;
            }
          }
          else {
            showToastMessage(response['message']);
          }
          setState(() {});
        },
        onError: (String error) {}
    );
  }
}
