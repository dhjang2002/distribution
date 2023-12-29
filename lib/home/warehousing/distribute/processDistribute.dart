// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/warehousing/distribute/processDistributeBoxGoods.dart';
import 'package:distribution/models/kItemHBox.dart';
import 'package:distribution/models/kitemBoxInGoods.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:transition/transition.dart';

class ProcessDistribute extends StatefulWidget {
  final String workDay;
  const ProcessDistribute({Key? key,
    required this.workDay}) : super(key: key);

  @override
  State<ProcessDistribute> createState() => _ProcessDistributeState();
}

class _ProcessDistributeState extends State<ProcessDistribute> with WidgetsBindingObserver {
  late AutoScrollController _controller;
  late SessionData _session;
  List<ItemHBox> _boxList = [];

  @override
  void deactivate() {
    print("deactivate():------------------------------------------");
    pausePeriodicRefresh();
  }

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    _controller = AutoScrollController();
    Future.microtask(() async {
      _reqHousingBoxList();
      startPeriodicRefresh();
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Timer? timer;
  double _progressValue = 0.0;
  double _targrtPeriodicSec = 5;
  double _currPeriodicSec = 0;

  void startPeriodicRefresh() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _currPeriodicSec++;
      if(_currPeriodicSec>_targrtPeriodicSec) {
        _currPeriodicSec = 0;
        _reqHousingBoxList();
      }

      setState(() {
        _progressValue = _currPeriodicSec/_targrtPeriodicSec;
      //print("_progressValue=$_progressValue");
      });
      // 호출할 함수 코드 작성
    });
  }

  void pausePeriodicRefresh() {
    if(timer != null) {
      timer!.cancel();
      //timer = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch(state) {
      case AppLifecycleState.resumed:
        print("*** ProcessDistribute:AppLifecycleState.resumed");
        _reqHousingBoxList();
        //startPeriodicRefresh();
        break;
      case AppLifecycleState.inactive:
      // TODO: Handle this case.
        print("*** ProcessDistribute:AppLifecycleState.inactive");
        break;
      case AppLifecycleState.paused:
      // TODO: Handle this case.
        print("*** ProcessDistribute:AppLifecycleState.paused");
        pausePeriodicRefresh();
        break;
      case AppLifecycleState.detached:
      // TODO: Handle this case.
        print("*** ProcessDistribute:AppLifecycleState.detached");
        break;
    }
  }

  bool _bWaiting = false;
  void _showProgress(bool bShow) {
    setState(() {
      _bWaiting = bShow;
    });
  }

  Future <bool> onWillPop() async {
    return true;
    //return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("배분처리"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black, size: 32,),
                onPressed: () {
                  //boxList = [];
                  _reqHousingBoxList();
                }),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-ProcessDistribute-key',
        onWillPop:onWillPop,
        validateMessage: "박스 바코드를 스캔하세요.",
        waiting: false,
        useCamera: true,
        validate: _checkValidate,
        onScan: (barcode) async {
          onScaned(barcode);
          //await _doProcessPox(barcode);
        },

        child: Container(
          color: Colors.white,
          //padding: EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              LinearProgressIndicator(
                minHeight: 1,
                backgroundColor: Colors.white,
                color: Colors.black,
                value: _progressValue,
                //semanticsLabel: 'Linear progress indicator',
              ),
              _renderTitle(),
              Expanded(
                child: Stack(
                children: [
                  Positioned(
                      child: Column(
                          children: [
                            Expanded(child: _renderBoxList()),
                          ]
                      )
                  ),
                  Positioned(
                      child: Visibility(
                        visible: _bWaiting,
                          child:Container(
                            color: const Color(0x00000000),
                              child:const Center(
                                child: CircularProgressIndicator()
                              ),
                          )
                      )
                  )
                ],
              ),),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showColorInfo() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 5),
      child: Row(
        children: [
          const Text("완료: ", style: ItemBkN12,),
          Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
                color: STD_OK
            ),
          ),

          const SizedBox(width: 10,),

          const Text("진행: ", style: ItemBkN12,),
          Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
                color: STD_DIFF
            ),
          ),

          const SizedBox(width: 10,),
          const Text("대기: ", style: ItemBkN12,),
          Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
                color: STD_READY
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderTitle() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10,5,10,5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            )),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _itemRow(1,"입고일자:", widget.workDay, false),
          _itemRow(1,"입고수량:", "${_boxList.length}", true),
          const SizedBox(height: 5,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _showColorInfo(),
              const Spacer(),
              const Text("진행상태:", style:ItemG1N12),
              const SizedBox(width: 3,),
              Text("$_finishedBoxCount / ${_boxList.length}", style: ItemBkB14,)
            ],
          )
        ],
      ),
    );
  }


  Widget _itemRow(int maxLines, String label, String value, bool bHilite) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: 56,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                letterSpacing: -1.5,
                height: 1.1,
                color: Colors.grey,
              ),
            )
        ),
        Expanded(
          child: Text(value,
            maxLines: maxLines, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: (bHilite) ? FontWeight.bold : FontWeight.normal,
              letterSpacing: -1.8,
              height: 1.2,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  double mainAxisExtent = 60;
  Widget _renderBoxList() {
    int crossAxisCount = 4;
    //double mainAxisExtent = 60;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 8;
      mainAxisExtent = 60;
    } else if(rt<1.55) {
      crossAxisCount = 8;
      mainAxisExtent = 60;
    } else if(rt<2.42) {
      crossAxisCount = 5;
      mainAxisExtent = 60;
    } else if(rt<2.42) {     // 갤럭시 폴더
      crossAxisCount = 4;
      mainAxisExtent = 60;
    } else if(rt<2.70) {
      crossAxisCount = 3;
      mainAxisExtent = 60;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _boxList.length%crossAxisCount;
    if(diff>0) {
      dumyCount = crossAxisCount + crossAxisCount - diff;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(2,0,2,0),
      child: GridView.builder(
          controller: _controller,
          shrinkWrap: false,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent:mainAxisExtent,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemCount: _boxList.length+dumyCount,
          itemBuilder: (context, int index) {
            // return (index<_boxList.length)
            // ? _boxItem(index, _boxList[index])
            // : Container();

            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index<_boxList.length)
                    ? _boxItem(index, _boxList[index])
                    : Container()
            );
          }),
    );
  }

  Widget _boxItem(int index, ItemHBox item) {
    Color statusColor = STD_READY;
    if(item.finishCount>0) {
      statusColor = STD_OK;
      if(item.finishCount != item.totalCount) {
        statusColor = STD_ING;
      }
    }

    return GestureDetector(
      onTap: () {
        for (var element in _boxList) {element.hasFocus=false;}
        setState(() {
          item.hasFocus = true;
        });
        _doProcessPox(false, index, item.sBoxNo);
      },

      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: (item.hasFocus)? Colors.pink : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(3),
            color: statusColor,
        ),
        child: Stack(
          children: [
            Positioned(
                child:Container(
                  alignment: Alignment.center,
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.sBoxNo,
                          style: ItemBkB14),
                      Text("${item.finishCount}/${item.totalCount}",
                        style: ItemBkN14,),
                    ],
                  )
                )
            ),
            Positioned(
                top:0, left: 0,
                child: Visibility(
                    visible: (item.finishCount>0),
                    child: const Icon(Icons.check, size: 18, color: Colors.black,)
                )
            ),
          ],
        )
      ),
    );
  }

  bool _checkValidate(String boxCode) {
    //boxCode = "0001";
    /*
    if (kDebugMode) {
      print("_checkValidate():barcode=$boxCode");
    }
    //String boxCode = int.parse(barcode).toString();
    int index = _boxList.indexWhere((element) => element.sBoxNo == boxCode);
    return (index>=0);
    */
    return true;
  }

  int _finishedBoxCount = 0;
  int procRate = 0;

  void _checkComplete() {
    _finishedBoxCount = 0;
    for (var element in _boxList) {
      if(element.finishCount>=0 && element.totalCount == element.finishCount) {
        _finishedBoxCount++;
      }
    }

    procRate = ((_finishedBoxCount as double)/_boxList.length * 100) as int;
  }

  Future <void> onScaned(String boxCode) async {
    //boxCode = "0100";
    //String boxCode = int.parse(barcode).toString();

    for (var element in _boxList) {element.hasFocus=false;}
    int index = _boxList.indexWhere((element) => element.sBoxNo == boxCode);
    if(index>=0) {
      setState(() {
        _boxList[index].hasFocus = true;
      });

      //_controller.jumpTo(index*mainAxisExtent);
      //Future.delayed(const Duration(milliseconds: 300), () async {
        _doProcessPox(true, index, boxCode);
      //});
    } else {
      showToastMessage("입고 리스트에 등록된 박스가 아닙니다.");
    }
  }

  Future<void> _doProcessPox(bool bSeekIndex, final int index, String boxCode) async {
    pausePeriodicRefresh();
    List<ItemWBoxInGoods>? list = await _reqHousingBoxItems(boxCode);
    await Navigator.push(
      context,
      Transition(
          child: ProcessDistributeBoxGoods(
            boxBarcode: boxCode,
            workDay: widget.workDay,
            listItemWBoxInGoods: list,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT
      ),
    );
    await _reqHousingBoxList();
    _currPeriodicSec = 0;
    startPeriodicRefresh();
    if (bSeekIndex) {
      await _controller.scrollToIndex(index,
        duration: const Duration(milliseconds: 1),
        preferPosition: AutoScrollPosition.begin,
      );
      setState(() {
        _boxList[index].hasFocus = true;
      });
    }

  }

  // 입고일에 처리할 박스 리스트 정보를 가져온다
  Future <void> _reqHousingBoxList()  async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/housingBoxlist",
        params: {"dWarehousing":widget.workDay},
        onResult: (dynamic data) {
          if(data['data'] != null) {
            if (data['data'] is List) {
              _boxList = ItemHBox.fromSnapshot(data['data']);
            }
            else {
              _boxList = ItemHBox.fromSnapshot([data['data']]);
            }
            _checkComplete();
          }

          if(_boxList.isEmpty) {
            showToastMessage("데이터가 없습니다.");
            //Navigator.pop(context);
          }
        },
        onError: (String error){}
    );
    _currPeriodicSec = 0;
    _progressValue = 0;
    _showProgress(false);
  }

  // 박스안에 담긴 상품의 배분정보 리스트 정보를 가져온다
  Future<List<ItemWBoxInGoods>?> _reqHousingBoxItems(String boxBarcode) async {
    List<ItemWBoxInGoods>? list = [];
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/housingBoxInfo",
        params: {"dWarehousing": widget.workDay, "sBoxNo": boxBarcode},
        onError: (String error) {},
        onResult: (dynamic data) {
          if (data['data'] != null) {
            var item = data['data'];
            if (item is List) {
              list = ItemWBoxInGoods.fromSnapshot(item);
            } else {
              list = ItemWBoxInGoods.fromSnapshot([item]);
            }
          }
        },
    );
    _showProgress(false);
    return list;
  }

}
