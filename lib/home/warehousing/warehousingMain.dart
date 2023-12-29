// ignore_for_file: file_names

import 'package:distribution/common/cardGridMenu.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/warehousing/distribute/processDistribute.dart';
import 'package:distribution/home/warehousing/classify/classifyGoodsBox.dart';
import 'package:distribution/home/warehousing/goods/findWarehousingGoods.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:distribution/utils/calendarDaySelect.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class WarehousingMain extends StatefulWidget {
  const WarehousingMain({Key? key}) : super(key: key);

  @override
  State<WarehousingMain> createState() => _WarehousingMainState();
}

class _WarehousingMainState extends State<WarehousingMain> {
  List<CardGridMenuItem> menuItems = [];

  String workDay = "";
  bool _bAvailScan = false;
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _buildMenuItems();
    Future.microtask(() async {
      await _daySelect();
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
          label: 'Box분류', menuId: 2031, assetsPath: "icon/main_check.png"));
      menuItems.add(CardGridMenuItem(
          label: '입고배분', menuId: 2032, assetsPath: "icon/main_parcel.png"));
      menuItems.add(CardGridMenuItem(
          label: '단품조회', menuId: 2033, assetsPath: "icon/main_file.png"));
    }
  }

  void _onAction(CardGridMenuItem item) {
    switch (item.menuId) {
      case 2031: // 입고처리
        Navigator.push(
          context,
          Transition(
              child: ClassifyGoodsBox(workDay: workDay),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;

      case 2032: // 배분처리
        Navigator.push(
          context,
          Transition(
              child: ProcessDistribute(workDay: workDay),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;
      case 2033: // 단품조회
        Navigator.push(
          context,
          Transition(
              child: FindWarehousingGoods(workDay: workDay),
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
          title: const Text("입고배분"),
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
    double mainPictHeight = MediaQuery.of(context).size.height*0.35;
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
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
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
                        "입고배분 업무를 처리합니다.",
                        style: ItemBkN16,
                      ),
                    ],
                  ),
                ),

                Container(
                    padding: const EdgeInsets.fromLTRB(10,10,0,0),
                    child: const Text("입고일자", style: ItemG1N14,)
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(10,0,0,0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          workDay,
                          style: ItemBkB20,
                        ),
                        const Spacer(),
                        Visibility(
                          visible: true,
                          child: Container(
                            padding: const EdgeInsets.only(right: 10),
                              child:OutlinedButton(
                            onPressed: () async {
                              await _daySelect();
                              setState(() {});
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black,
                              side: const BorderSide(width: 1.0, color: ColorG4),
                            ),
                            child: const Text(
                              "일자선택",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          )),
                        ),
                      ],
                  )
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  height: mainPictHeight,
                  width: double.infinity,
                  //color: Colors.amber,
                  child: Image.asset("assets/intro/menu_distribute.png", fit: BoxFit.cover,),
                ),
              ],
            )
        ),

        Positioned(
            bottom: 0, left: 0, right: 0,
            child: Visibility(
                visible: _bAvailScan,
                child:Container(
                    padding: EdgeInsets.only(bottom: bottomPading),
                    width: double.infinity,
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
                    ))
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
                        child: const Text("입고배분 데이터가 없습니다.", style: ItemBkN20,),
                      ),
                    ))
            )
        ),
      ],
    );
  }

  Future<void> _daySelect() async {
    var result = await Navigator.push(
      context,
      Transition(
          child: CalendarDaySelect(
            target: "warehousing",
            seletedDay: workDay,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if (result != null && result.toString().isNotEmpty) {
      setState(() {
        workDay = result;
        _reqWorkStatus();
      });
    } else {
      // 선택한 날짜가 없으면 이전화면으로 이동.
      if (workDay.isEmpty) {
        Navigator.pop(context);
      }
    }
  }

  // 작업가능 상태조회
  Future <void> _reqWorkStatus() async {
    _bAvailScan = false;
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/infoWarehousing",
        params: {
          "dWarehousing":workDay
        },
        onResult: (dynamic response) {
          if (kDebugMode) {
            var logger = Logger();
            logger.d(response);
          }

          if (response['status'] == "success") {
            int fState = (response['data'] != null)
                ? int.parse(response['data'].toString().trim()) : 0;
            if(fState == 1) {
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
