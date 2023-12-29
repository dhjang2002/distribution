// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, file_names
import 'package:distribution/common/CardStatus.dart';
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/menuBarTab.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/shipping/packing/listPackedGoodsInfo.dart';
import 'package:distribution/home/shipping/packing/workPackingBoxInfo.dart';
import 'package:distribution/home/shipping/packing/showPackedBoxList.dart';
import 'package:distribution/models/kItemPick.dart';
import 'package:distribution/models/klistConfirmPacking.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:transition/transition.dart';

class PackMaster extends StatefulWidget {
  const PackMaster({Key? key}) : super(key: key);

  @override
  State<PackMaster> createState() => _PackMasterState();
}

class _PackMasterState extends State<PackMaster> {
  final AutoScrollController _controller = AutoScrollController();
  int _workIndex = 0;
  int _selCount  = 0;
  int _itemCount = 0;
  List<ItemPick> _pickedList = [];
  List<ListConfirmPacking> _packedList = [];
  late SessionData _session;

  String _toDay = "";
  String _sBoxSeqToday = "";

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _toDay = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _sBoxSeqToday = _toDay.replaceAll("-", "").substring(2,8);

    Future.microtask(() {
      _reqPickedList();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _bWait = false;
  void _showProgress(bool bShow) {
    setState(() {
      _bWait = bShow;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("상품포장"),
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
                    Icons.refresh,
                    size: 26,
                  ),
                  onPressed: () {
                    if(_workIndex == 0 ) {
                      _reqPickedList();
                    }
                    else {
                      _reqPackedList();
                    }
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
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
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

          const SizedBox(width: 5,),

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

          const SizedBox(width: 5,),
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

  Widget _renderBody() {
    return Stack(
      children: [
        Positioned(
            child: Container(
              margin: (_workIndex == 0 )
                  ? const EdgeInsets.only(bottom: 64)
                  : const EdgeInsets.only(bottom: 0),
              color: Colors.white,
              child: Column(
                children: [
                  MenuBarTab(
                    barHeight: 46,
                    items: const ["포장작업", "포장완료"],
                    initChoice: _workIndex,
                    onChange: (int index) {
                      setState(() {
                        _workIndex = index;
                      });
                      if(_workIndex==1) {
                        _reqPackedList();
                      } else {
                        _reqPickedList();
                      }
                    },
                  ),
                  Container(
                      padding: const EdgeInsets.fromLTRB(10,10,10,5),
                      color: Colors.grey[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            "출고일자:  ",
                            style: ItemG1N12,
                          ),
                          Text(
                            _toDay,
                            style: ItemBkN14,
                          ),
                          const Spacer(),
                          const Text(
                            "출하수량:  ",
                            style: ItemG1N12,
                          ),
                          Text(
                            "$_itemCount",
                            style: ItemBkB14,
                          ),
                        ],
                      )
                  ),

                  Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        const Text("   *길게 누르기(Long Tap): 그룹선택", style: ItemG1N12,),
                        const Spacer(),
                        _showColorInfo(),
                      ],
                    ),
                  ),

                  const Divider(height: 1,),
                  Expanded(
                    child: _renderJobList(),
                  ),
                ],
              ),
            )
        ),

        Positioned(
          bottom: 0,left:0, right: 0,
          child: Visibility(
            visible: _workIndex == 0,
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  Visibility(
                    visible: true,
                    child: ButtonSingle(
                        visible: true,
                        enable: _selCount>0,
                        isBottomSide: true,
                        isBottomPading: true,
                        text:  '포장 하기',
                        onClick: () async {
                          ItemPick selItem = ItemPick();
                          for (var element in _pickedList) {
                            if(element.bSelect) {
                              selItem = element;
                              break;
                            }
                          }

                          if(_workIndex==1) {
                            _showPacking(selItem);
                          } else {
                            _doPacking();
                          }
                        }),
                  ),
                ],
              ),
            ),
          )
        ),
        Positioned(
          top:48,bottom: 0, left:0, right: 0,
            child: Visibility(
                visible: _bWait,
                child:Container(
                  color: const Color(0x10000000),
                  child:const Center(
                      child: CircularProgressIndicator()
                  ),
                )
            )
        ),
      ],
    );
  }

  Widget _renderJobList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 80;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 4;
      mainAxisExtent = 80;
    } else if(rt<1.55) {
      crossAxisCount = 4;
      mainAxisExtent = 80;
    } else if(rt<2.45) {
      crossAxisCount = 2;
      mainAxisExtent = 80;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 80;
    }

    setState(() {
      _itemCount =(_workIndex==1) ? _packedList.length: _pickedList.length;
    });

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _itemCount%crossAxisCount;
    if(diff>0) {
      dumyCount = crossAxisCount + crossAxisCount - diff;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(2, 5, 2, 0),
      child: GridView.builder(
          controller: _controller,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: 1,
            crossAxisSpacing: 2,
          ),
          itemCount: _itemCount+dumyCount,
          itemBuilder: (context, int index) {
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index>=_itemCount) ? Container()
                    : (( _workIndex == 1)
                      ? _packedItemInfo(index, _packedList[index])
                      : _workItemInfo(index, _pickedList[index])
                      ),
            );
          }),
    );
  }

  bool isMargable(ItemPick tapItem) {
    ItemPick? target;
    for (var element in _pickedList) {
      if(element.bSelect) {
        target = element;
        break;
      }
    }

    if(target != null) {
      if(tapItem.sStoreCode != tapItem.sStoreCode) {
        return false;
      }
      if(tapItem.sStoreCode != "6001" && target.sCustomerName == tapItem.sCustomerName) {
        return true;
      }
    }
    return false;
  }

  Widget _workItemInfo(int index, ItemPick item) {
    Color StateColor = STD_READY;
    if(item.fState==STATUS_PACK_END) {
      StateColor = STD_OK;
    } else if(item.fState==STATUS_PACK_START) {
      StateColor = STD_DIFF;
    }

    return GestureDetector(
      onTap: () {
        // 1. 다른 작업자가 진행중인 작업.
        if(item.fState==STATUS_PACK_START) {
           if(item.sEmployeeName != _session.User!.sName) {
             item.bSelect = false;
             setState(() {});
             return;
           }
        }

          //  bool bselect = !item.bSelect;
          //  if(_selCount>0 && bselect) {
          //    isMargable(item);
          //  }
          //
          // _selCount = 0;
          // for (var element in _pickedList) {
          //   if(element.fState==STATUS_PACK_START && element.sEmployeeName == item.sEmployeeName) {
          //     element.bSelect = bselect;
          //     if(bselect) {
          //       _selCount++;
          //     }
          //   }
          // }

        {
          if(!item.bSelect && _selCount>0) {
            if(isMargable(item)) {
              item.bSelect = true;
            }
          } else {
            item.bSelect = !item.bSelect;
          }
        }
        _selCount = 0;
        for (var element in _pickedList) {
          if(element.bSelect) {
            _selCount++;
          }
        }
        setState(() {});
      },

      onLongPress: (){
        // 1. 다른 작업자가 진행중인 작업.
        if(item.fState==STATUS_PACK_START) {
          if(item.sEmployeeName != _session.User!.sName) {
            item.bSelect = false;
            setState(() {});
            return;
          }
        }

        if (item.sStoreCode == "6001") {
          for (var element in _pickedList) {
            element.bSelect = false;
          }
          item.bSelect = true;
          _selCount = 1;
          setState(() {});
          return;
        }

        HapticFeedback.lightImpact();

        for (var element in _pickedList) {
          if(element.fState==STATUS_PACK_START) {
            if(element.sEmployeeName == _session.User!.sName) {
              element.bSelect = true;
            }
          }
          else
          {
            if (item.sCustomerName == element.sCustomerName) {
              element.bSelect = true;
              _selCount++;
            }
            else {
              element.bSelect = false;
            }
          }
        }

        setState(() {});
      },

      child: Container(
        margin: const EdgeInsets.only(bottom:1),
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
                  padding: const EdgeInsets.fromLTRB(5,0,5,0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      _itemRow(1, "거  래  처:", item.sCustomerName, false),
                      _itemRow(1, "출고번호:", item.sShippingNo.toString(), false),
                      _itemRow(1, "상품정보:", "${item.lKindGoodsCount}  ("
                          "${item.lTotalPickingCount-item.lTotalPackingCount})", false),
                      const Spacer(),
                    ],
                  ),
                )
            ),

            Positioned(
              top: 0,
              right: 0,
              child: Visibility(
                visible: true,//item.fState == 0,
                child: Icon(
                  (item.bSelect)
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 24,
                  color: (item.bSelect) ? Colors.pink : Colors.black,
                ),
              ),
            ),
            Positioned(
                bottom: 2,
                right: 2,
                child: Visibility(
                  visible: item.fState == STATUS_PACK_START,//_workIndex == 1 && item.bSelect,
                  child: CardStatus(
                    padding: const EdgeInsets.fromLTRB(7, 3, 7, 5),
                    margin: const EdgeInsets.all(0),
                    child: Text(item.sEmployeeName, style: ItemBkN11,)),
                )
            ),
          ],
        )
      ),
    );
  }

  Widget _packedItemInfo(int index, ListConfirmPacking item) {
    Color cStatus = Colors.black;
    if(item.fState>=STATUS_PACK_MCONFIRM) {     // 승인완료
      cStatus = Colors.grey;
    } else if(item.fState>STATUS_PACK_END) {    // 출하완료
      cStatus = Colors.pink;
    }else if(item.fState>=STATUS_PACK_END) {    // 포장완료
      cStatus = Colors.black;
    }
    return GestureDetector(
      onTap: () {
        _showGoodsPackedList(item);
      },

      child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(5),
            color: STD_READY,
            //(item.fState == STATUS_PACK_SCONFIRM) ?  Colors.white : Colors.white,
          ),
          child:Opacity(
              opacity: 1.0,
              child:Stack(
                children: [
                  Positioned(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Column(
                          children: [
                            const Spacer(),
                            _itemRow(1, "거  래  처:", item.sCustomerName, false),
                            _itemRow(1, "상품정보:","${item.lGoodsKind} "
                                "(${item.lTotalGoodsCount})", true),
                            _itemRow(1, "출하번호:", item.sBoxSeq, false),
                            const Spacer(),
                          ],
                        ),
                      )
                  ),
                  Positioned(
                    top: 1, right: 1,
                    child:SizedBox(
                        width: 50,
                        height: 24,
                        child: OutlinedButton(
                          onPressed: () async {
                            _showGoodsPackedList(item);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                                width: 1.0,
                                color: Colors.grey
                            ),
                          ),
                          child: Text(
                            item.sState,
                            style: TextStyle(
                              fontSize: 10,
                              color: cStatus,
                            ),
                          ),
                        )
                    ),
                  ),
                ],
              )
          )
      ),
    );
  }

  Widget _itemRow(int maxLine, String label, String value, bool bHilite) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: 50,
            child: Text(
              label,
              maxLines: 1,overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                letterSpacing: -1.5,
                height: 1.2,
                color: Colors.black,
              ),
            )
        ),
        Expanded(
          child: Text(value,
            maxLines: maxLine, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
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

  Future<void> _showGoodsPackedList(ListConfirmPacking item) async {
    await Navigator.push(context,
      Transition(
          child: listPackedGoodsInfo(
            master:item,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
    //_reqPackedBoxList();
  }

  List<ItemPick> _getSelected() {
    List<ItemPick> list = [];
    for (var element in _pickedList) {
      if(element.bSelect) {
        list.add(element);
      }
    }
    return list;
  }

  Future <void> _doPacking() async {
    List<ItemPick> itemPickList = _getSelected();
    if(itemPickList.isEmpty) {
      showToastMessage("포장할 거래처를 선택하세요.");
      return;
    }

    if(_workIndex == 0) {
      bool bOk = await _reqSetPack(itemPickList);
      if(!bOk) {
        _reqPickedList();
        return;
      }
    }

    await Navigator.push(context,
      Transition(
          child: WorkPackingBoxInfo(
          title: (_workIndex == 0) ? "상품포장":"상품확인",
          workDate: _toDay,
          itemPickList: itemPickList,
          bWorkLock: (_workIndex == 1),
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    // 다른 사용자가 변경한 데이터도 반영하기위해 무조건 갱신한다.
    await _reqPickedList();
  }

  Future <void> _showPacking(ItemPick item) async {
    await Navigator.push(context,
      Transition(
          child: ShowPackedBoxList(
            title: "거래처 박스 목록",
            workDate: _toDay,
            itemPick: item,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    // 다른 사용자가 변경한 데이터도 반영하기위해 무조건 갱신한다.
    _reqPickedList();
  }

  Future <void> _reqPickedList() async {
    _selCount = 0;
    _pickedList = [];
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/listPackingStore",
        params: {
          "dShipping": _toDay,
          "fState":[STATUS_PACK_READY, STATUS_PACK_START]
        },
        onError: (String error) {},
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            var content = response['data'];
            if (content != null) {
              _pickedList = [];
              List<ItemPick> list = [];
              if (content is List) {
                list = ItemPick.fromSnapshot(content);
              } else {
                list = ItemPick.fromSnapshot([content]);
              }

              if(_workIndex == 1) {
                for (var element in list) {
                  if(element.sEmployeeName ==_session.User!.sName) {
                    _pickedList.add(element);
                  }
                }
              }
              else {
                _pickedList.addAll(list);
              }
            }
          }
        },
    );
    _itemCount = _pickedList.length;
    _showProgress(false);
  }

  // 포장된 박스 리스트 정보를 가져온다
  Future <void> _reqPackedList()  async {
    _packedList = [];
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/listPackingFinish",
        params: {"sBoxSeq" : _sBoxSeqToday },
        onError: (String error){},
        onResult: (dynamic data) {
          if(data['data'] != null) {
            if (data['data'] is List) {
              _packedList = ListConfirmPacking.fromSnapshot(data['data']);
            }
            else {
              _packedList = ListConfirmPacking.fromSnapshot([data['data']]);
            }
          }

          if(_packedList.isEmpty) {
            showToastMessage("데이터가 없습니다.");
            //Navigator.pop(context);
          }
        },
    );
    _itemCount = _packedList.length;
    _showProgress(false);
  }

  Future <bool> _reqSetPack(List<ItemPick> itemPickList) async {
    bool bOK = false;
    List<String> idsList = [];
    for (var element in itemPickList) {
      if(element.bSelect) {
        idsList.add(element.lShippingID.toString());
      }
    }

    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/updatePackingSelect",
        params: {"Ids": idsList, "fState":STATUS_PACK_START},
        onError: (String error) {},
        onResult: (dynamic response) {
          if (response['status'] == "success") {
            bOK = true;
          }
          else {
            showToastMessage(response['message']);
          }
        },

    );
    _showProgress(false);
    return bOK;
  }
}
