// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/cardCheckBox.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/shipping/picking/showPickGoodsList.dart';
import 'package:distribution/home/shipping/picking/workPickGoodsList.dart';
import 'package:distribution/models/kItemPick.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:distribution/utils/calendarDaySelect.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:transition/transition.dart';

class WorkPickMain extends StatefulWidget {
  const WorkPickMain({Key? key}) : super(key: key);

  @override
  State<WorkPickMain> createState() => _WorkPickMainState();
}

class _WorkPickMainState extends State<WorkPickMain> {
  final AutoScrollController _controller = AutoScrollController();
  int _selCount  = 0;
  int _pickFinishCount = 0;
  List<ItemPick> _pickList = [];
  late SessionData _session;
  bool _bActBtn = false;
  bool _bCheckAll = false;
  bool _bCheckAllContent = true;
  String _workDay = "";

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() {
      Future.microtask(() async {
        await _daySelect(true);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _bWaiting = false;
  void _showProgress(bool bShow) {
    setState(() {
      _bWaiting = bShow;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("상품피킹"),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 28,),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: [
            Visibility(
              visible: true,
              child: IconButton(
                  icon: const Icon(
                    Icons.calendar_month,
                    size: 20,
                  ),
                  onPressed: () {
                    _daySelect(false);
                  }),
            ),

            Visibility(
              visible: true,
              child: IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    size: 26,
                  ),
                  onPressed: () {
                    setState((){
                      _bCheckAll = false;
                    });
                    _reqPickingData();
                  }),
            ),

            Visibility(
              visible: modeIsDeveloper,//_session.Setting!.UseTestMode == "YES",
              child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 24,
                  ),
                  onPressed: () {
                    _testClear();
                  }),
            ),
          ],
        ),
        body: ModalProgressHUD(
            inAsyncCall: false,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                  color: Colors.grey[300],
                  height: double.infinity,
                  child: _renderBody()),
            )
        )
    );
  }

  Widget _showColorInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("완료: ", style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.5, height: 1.0,
          color: Colors.black,
        ),),
        Container(
          width: 11, height: 11,
          decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey,
              ),
              color: STD_OK
          ),
        ),

        const SizedBox(width: 5,),

        const Text("진행: ", style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.5, height: 1.0,
          color: Colors.black,
        ),),
        Container(
          width: 11, height: 11,
          decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey,
              ),
              color: STD_DIFF
          ),
        ),

        const SizedBox(width: 5,),
        const Text("대기: ", style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.5, height: 1.0,
          color: Colors.black,
        ),),
        Container(
          width: 11, height: 11,
          decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey,
              ),
              color: STD_READY
          ),
        ),
      ],
    );
  }

  Widget _renderBody() {
    return GestureDetector(
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              Positioned(
                left: 0, right: 0, top: 0, bottom: 0,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 70),
                    //color: Colors.amber,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            padding: const EdgeInsets.fromLTRB(5,5,10,5),
                            color: Colors.grey[100],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                    onPressed: (){
                                      _daySelect(false);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                        Icons.calendar_month, size:16)
                                ),
                                Text(_workDay, style: ItemBkB14,),
                                Spacer(),
                                const Text("진행: ", style: ItemG1N12,),
                                Text(
                                  "$_pickFinishCount/${_pickList.length}",
                                  style: ItemBkB14,
                                ),
                                //const SizedBox(width: 5,),
                              ],
                            )
                        ),

                        Container(
                          padding: const EdgeInsets.fromLTRB(5, 2, 5, 3),
                          color: Colors.grey[100],
                          child: Row(
                            children: [

                              // 전체선택
                              CardCheckbox(
                                visible: true,//_pickList.isNotEmpty,
                                text:"전체선택",
                                initStatus: _bCheckAll,
                                onChange: (bool value) {
                                  _bCheckAll = value;
                                  for (var element in _pickList) {
                                    element.bSelect = _bCheckAll
                                        && element.fState == STATUS_PICK_READY;
                                  }
                                  _updateSelect(true);
                                },
                              ),

                              CardCheckbox(
                                visible: true,//_pickList.isNotEmpty,
                                text:"완료내역",
                                checkIconColor:Colors.greenAccent,
                                initStatus: _bCheckAllContent,
                                onChange: (bool value) {
                                  _bCheckAllContent = value;
                                  _reqPickingData();
                                },
                              ),
                              const Spacer(),
                              _showColorInfo(),
                            ],
                          ),
                        ),

                        const Divider(
                          height: 1,
                          color: Colors.black,
                        ),

                        Expanded(
                          child: _renderJobList(),
                        ),
                      ],
                    ),
                  )
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Visibility(
                  visible: true,
                  child:SizedBox(
                    height: 64,
                    child: Row(
                      children: [
                        Visibility(
                          visible: true,
                          child: Expanded(
                            flex: 6,
                            child: Container(
                              //alignment: Alignment.center,
                              width: double.infinity,
                              margin: const EdgeInsets.only(top:1),
                              padding: const EdgeInsets.only(left:5, right: 5),
                              decoration: BoxDecoration(
                                //borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Spacer(),
                                      RichText(
                                          maxLines:1,
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.normal,
                                                letterSpacing: -1.5,
                                                color: Colors.black,
                                              ),
                                              children: [
                                                const TextSpan(text: '선택: ',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.black, )
                                                ),
                                                TextSpan(text: '$_totalCountStore',
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.pink)
                                                ),
                                                const TextSpan(text: '  상품수: ',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.normal,
                                                        color: Colors.black)
                                                ),
                                                TextSpan(text: '$_totalKindGoods',
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.pink)
                                                ),
                                                const TextSpan(text: '  총수량: ',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.normal,
                                                        color: Colors.black)
                                                ),
                                                TextSpan(text: '$_totalCountGoods',
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.pink)
                                                ),
                                              ]
                                          )
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ],
                              ),
                            )
                        ),),
                        Expanded(
                            flex: 4,
                            child: Visibility(
                              visible:true,
                              child: ButtonSingle(
                                  visible: true,
                                  isBottomSide: true,
                                  isBottomPading: true,
                                  text: '상품 피킹',
                                  enable: (_bActBtn || _selCount > 0),
                                  onClick: () async {
                                    _doPicking();
                                  }),
                            )),
                      ],
                    ),
                  )
                ),
              ),

              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Visibility(
                      visible: _bWaiting,
                      child:Container(
                        color: const Color(0x10000000),
                        child:const Center(
                            child: CircularProgressIndicator()
                        ),
                      )
                  )
              ),
            ],
          ),
        )
    );
  }

  int _totalCountStore = 0;
  int _totalKindGoods = 0;
  int _totalCountGoods = 0;
  void _updateSelect(bool bState){
    _totalCountStore = 0;
    _totalKindGoods  = 0;
    _totalCountGoods = 0;
    _pickFinishCount = 0;
    _selCount = 0;
    for (var element in _pickList) {
      if(element.fState>STATUS_PICK_START) {
        _pickFinishCount++;
      }
      if(element.bSelect) {
        _selCount++;
        _totalCountStore++;
        _totalKindGoods  += element.lKindGoodsCount;
        _totalCountGoods += element.lTotalGoodsCount;
      }
    }

    if(bState) {
      setState(() {
      });
    }
  }

  Widget _renderJobList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 80;
    final double rt = getMainAxis(context);
    if (rt < 1.18) {
      crossAxisCount = 4;
      mainAxisExtent = 90;
    } else if (rt < 1.55) {
      crossAxisCount = 4;
      mainAxisExtent = 90;
    } else if (rt < 2.20) {
      crossAxisCount = 2;
      mainAxisExtent = 90;
    } else if (rt < 2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 94;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _pickList.length%crossAxisCount;
    if(diff>0) {
      dumyCount = crossAxisCount + crossAxisCount - diff;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(2, 2, 2, 0),
      child: GridView.builder(
          controller: _controller,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: 1,
            crossAxisSpacing: 2,
          ),
          itemCount: _pickList.length+dumyCount,
          itemBuilder: (context, int index) {
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index<_pickList.length)
                    ? _ItemInfo(index, _pickList[index]): Container()
            );
          }),
    );
  }

  Widget _ItemInfo(int index, ItemPick item) {
    Color StateColor = STD_READY;
    if(item.fState>=STATUS_PICK_END) {
      StateColor = STD_OK;
    } else if(item.fState==STATUS_PICK_START) {
      StateColor = STD_DIFF;
    }

    return GestureDetector(
      onTap: () {
        // 1. 다른 작업자가 진행중인 작업.
        if(item.fState==STATUS_PICK_START && item.sEmployeeName != _session.User!.sName) {
          item.bSelect = false;
          return;
        }

        if(item.fState>=STATUS_PICK_END) {
          item.bSelect = false;
          return;
        }

        //_selCount = 0;
        item.bSelect = !item.bSelect;
        // for (var element in _pickList) {
        //   if (element.bSelect) _selCount++;
        // }
        _updateSelect(true);
      },

      child: Container(
          margin: const EdgeInsets.only(bottom: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: StateColor,
            border: Border.all(
              width: 2,
              color: (item.bSelect) ? Colors.pink : Colors.grey,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                  child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _itemRow("거  래  처:", item.sCustomerName, false),
                          _itemRow("출하연번:", item.sShippingNo, false),
                          _itemRow(
                              "출하요청:",
                              "${item.lKindGoodsCount} "
                                  "(${item.lTotalGoodsCount})",
                              true),
                          _itemRow("작  업  자:", item.sEmployeeName, false),
                        ],
                      )
                  )
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Visibility(
                  visible: item.fState == 0,
                  child: Icon(
                    (item.bSelect)
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 24,
                    color: (item.bSelect) ? Colors.pink : Colors.grey,
                  ),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Visibility(
                  visible: item.fState>=STATUS_PICK_END,
                    child:SizedBox(
                        width: 50,
                        height: 22,
                        child: OutlinedButton(
                          onPressed: () async {
                            _doShowDetail(item);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            foregroundColor: Colors.white,
                            backgroundColor: (item.fState<STATUS_PACK_END)
                                ? STD_READY : Colors.white,
                            side: const BorderSide(
                                width: 1.0,
                                color: Colors.black
                              // color: (item.fState < STATUS_PACK_SCONFIRM)
                              //     ? Colors.pink : Colors.grey
                            ),
                          ),
                          child: Text(
                            item.sState,
                            style: TextStyle(
                                fontSize: 9,
                              //  color: Colors.black
                              color: (item.fState == STATUS_PICK_END)
                                  ? Colors.black : Colors.pink,

                            ),
                          ),
                        )
                    )
                ),
              ),
            ],
          )
      ),
    );
  }

  Widget _itemRow(String label, String value, bool bHilite) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: 50,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                letterSpacing: -1.5,
                height: 1.2,
                color: Colors.black,
              ),
            )),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: (bHilite) ? FontWeight.bold : FontWeight.normal,
              letterSpacing: -1.5,
              height: 1.2,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _doShowDetail(ItemPick item) async {
    await Navigator.push(
      context,
      Transition(
          child: ShowPickedGoodsList(
            workDate: _workDay,
            pick: item,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
    _reqPickingData();
  }

  List<ItemPick> _getSelectPickList() {
    List<ItemPick> list = [];
    for (var element in _pickList) {
      if(element.bSelect) {
        list.add(element);
      }
    }
    return list;
  }

  Future<void> _doPicking() async {
    List<ItemPick> selectList = _getSelectPickList();
    if(selectList.isEmpty) {
      showToastMessage("거래처를 선택하세요.");
      return;
    }

   await Navigator.push(
      context,
      Transition(
          child: WorkPickGoodsList(
            workDate: _workDay,
            pickList: _getSelectPickList(),
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
    _bCheckAll = false;
    _reqPickingData();
  }

  Future<void> _reqPickingData() async {
    _selCount = 0;
    _bActBtn = false;

    _showProgress(true);

    List<int> stateList = [];
    if(_bCheckAllContent) {
      stateList = [
        STATUS_PICK_READY,
        STATUS_PICK_START,
        STATUS_PICK_END,
        STATUS_PACK_START,
        STATUS_PACK_END,
      ];//, STATUS_PICK_END];
    }
    else {
      stateList = [
        STATUS_PICK_READY,
        STATUS_PICK_START,
        // STATUS_PACK_END,
        // STATUS_PACK_MOVE,
        // STATUS_PACK_SCONFIRM,
        // STATUS_PACK_MCONFIRM,
        ];
     }

    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/shippingStoreList",
        params: {
          "dShipping": _workDay,
          "fState": stateList
        },
        onError: (String error) {},
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            var content = response['data'];
            if (content != null) {
              //List<ItemPick> list = [];
              if (content is List) {
                _pickList = ItemPick.fromSnapshot(content);
              } else {
                _pickList = ItemPick.fromSnapshot([content]);
              }
              _updateSelect(false);
            }
          } else {
            showToastMessage(response['message']);
          }
        },
    );
    _showProgress(false);
  }

  Future<void> _testClear() async {
    List<String> idsList = [];
    for (var element in _pickList) {
      if (element.bSelect) {
        idsList.add(element.lShippingID.toString());
      }
    }
    _showProgress(true);
    /*
    { "lEmployeeId" : "1", "Ids" : ["1","2"]  //lShippingID }
     */

    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/resetShipping",
        params: {},
        onResult: (dynamic response) {
          _showProgress(false);
          if (kDebugMode) {
            print(response.toString());
          }
          if (response['status'] == "success") {
            _reqPickingData();
          }
        },
        onError: (String error) {
          _showProgress(false);
        });
  }

  Future<void> _daySelect(final bool bStart) async {
    var result = await Navigator.push(context,
      Transition(child: CalendarDaySelect(
        target: "shipping",
        seletedDay: _workDay,
      ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if(result != null && result.toString().isNotEmpty) {
      _bCheckAllContent = true;
      _workDay = result;
      _reqPickingData();
      return;
    }
    else {
      if(bStart) {
        Navigator.pop(context);
      }
    }
  }
}
