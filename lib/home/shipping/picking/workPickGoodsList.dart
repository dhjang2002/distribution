// ignore_for_file: non_constant_identifier_names

import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/goodsDetail.dart';
import 'package:distribution/home/shipping/picking/bottomPickingGoodsList.dart';
import 'package:distribution/models/kItemPick.dart';
import 'package:distribution/models/kItemPickConfirm.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class WorkPickGoodsList extends StatefulWidget {
  final String workDate;
  final List<ItemPick> pickList;
  const WorkPickGoodsList({
      Key? key,
      required this.workDate,
      required this.pickList,
  }) : super(key: key);

  @override
  State<WorkPickGoodsList> createState() => _WorkPickGoodsListState();
}

class _WorkPickGoodsListState extends State<WorkPickGoodsList> {
  List<ItemPickConfirm> _pickConfirmList = [];
  late AutoScrollController _controller;

  String title = "";
  int  _lComplete = 0;
  bool _isComplete = false;

  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _controller = AutoScrollController();
    Future.microtask(() async {
      // 상태 변경: 작업중.
      await _reqSetWorker(widget.pickList, STATUS_PICK_START);
      await _reqData();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
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
        title: const Text("상품픽킹"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () async {
              if(_lComplete<1) {
                await _reqSetWorker(widget.pickList, STATUS_PICK_READY);
              }
              Navigator.pop(context);
            }
        ),
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 32,
                ),
                onPressed: () {
                  _bPopStatus = false;
                  _reqData();
                }),
          ),
          // home
          Visibility(
            visible: false,
            child: IconButton(
                icon: const Icon(
                  Icons.home,
                  size: 32,
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-PickWorking-key',
        validateMessage: "출고대상 상품이 아닙니다.",
        waiting: false,
        onWillPop: onWillPop,
        allowPop: false,//_isComplete,
        useCamera: true,
        validate: _checkValidate,
        onScan: (barcode) {
          onScaned(barcode);
        },

        child: Container(
          color: Colors.white,
          child: Column(
            children: [

              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      child: Container(
                          padding: const EdgeInsets.only(bottom: 58),
                          child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("출고일자: ", style: ItemG1N12),
                                      Text(widget.workDate, style: ItemBkN14),
                                      const Spacer(),
                                      const Text("진행상태: ", style: ItemG1N12),
                                      Text("$_lComplete/${_pickConfirmList.length} ",
                                          style: ItemBkN14),
                                    ],
                                  ),
                                ),
                                // const Divider(
                                //   height: 1,
                                //   color: Colors.black,
                                // ),
                                Container(
                                  //color: Colors.grey[100],
                                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                  child: Row(
                                    children: [
                                      const Text("   *길게 누르기(Long Tap): 그룹선택", style: ItemG1N12,),
                                      const Spacer(),
                                      _showColorInfo(),
                                    ],
                                  ),
                                ),
                                Expanded(child: _renderPickList()),
                              ]
                          )
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ButtonSingle(
                              text: '작업삭제',
                              isBottomPading: true,
                              isBottomSide: true,
                              enableColor: Colors.amber,
                              enableTextColor: Colors.black,
                              onClick: () async {
                                _doCancel();
                              },
                            ),),
                            const SizedBox(width: 1,),
                            Expanded(
                              flex: 7,
                              child: ButtonSingle(
                              text: '피킹완료 ($_lComplete/${_pickConfirmList.length})',
                              isBottomPading: true,
                              isBottomSide: true,
                              enable: _isComplete,
                              visible: true,
                              onClick: () async {
                                await _reqSetPickStatus(STATUS_PICK_END);
                                showToastMessage("완료목록에 추가되었습니다.");
                                Navigator.pop(context, _isComplete);
                                // showYesNoDialogBox(
                                //     context: context,
                                //     title: "확인",
                                //     message: "피킹 작업을 완료할까요?",
                                //     onResult: (bOK) async {
                                //       if(bOK) {
                                //         await _reqSetPickStatus(STATUS_PICK_END);
                                //         Navigator.pop(context, _isComplete);
                                //       }
                                //     });
                                },
                            ),)
                          ],
                        )
                      ),
                    ),

                    // wait progress...
                    Positioned(
                        child: Visibility(
                            visible: _bWaiting,
                            child:Container(
                              color: const Color(0x1f000000),
                              child:const Center(
                                  child: CircularProgressIndicator()
                              ),
                            )
                        )
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showColorInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
          const Text("오차: ", style: ItemBkN12,),
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

  Widget _renderPickList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 160;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 2;
      mainAxisExtent = 120;
    } else if(rt<1.55) {
      crossAxisCount = 2;
      mainAxisExtent = 120;
    } else if(rt<2.42) {
      crossAxisCount = 1;
      mainAxisExtent = 120;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 120;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _pickConfirmList.length%crossAxisCount;
    if(diff>0) {
      dumyCount = crossAxisCount + crossAxisCount - diff;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 1),
      child: GridView.builder(
          controller: _controller,
          // shrinkWrap: true,
          // physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemCount: _pickConfirmList.length+dumyCount,
          itemBuilder: (context, int index) {
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index<_pickConfirmList.length)
                    ?_ItemInfo(index, _pickConfirmList[index]) : Container()
            );
          }),
    );
  }

  Widget _ItemInfo(int index, ItemPickConfirm item) {

    String sPickingCount = "피킹전";
    if(item.lPickingEmpId>0) {
      sPickingCount = item.lPickingCount.toString();
    }
    Color bgColor = STD_READY;
    if(item.fState != 0) {
      // 요청/확인 값이 다른경우
      if(item.lGoodsCount != item.lPickingCount) {
        bgColor = STD_DIFF;
      }
      else {
        bgColor = STD_OK;
      }
    }

    return GestureDetector(
      onTap: () async {
        _clearScan();
        _clearFocus();
        _clearSelect();
        setState(() {
          item.hasFocus = true;
        });
      },

      onLongPress: () {
        HapticFeedback.lightImpact();
        for (var element in _pickConfirmList) {
          if (item.lGoodsId==element.lGoodsId) {
            element.bScaned  = true;
            element.hasFocus = true;
          }
          else {
            element.bScaned  = false;
            element.hasFocus = false;
          }
        }
        item.bScaned = true;
        item.hasFocus = true;
        setState(() {});
      },
      child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: (item.bScaned) ? Colors.blueAccent : Colors.grey,
            ),
            color: bgColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              Positioned(
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    padding: const EdgeInsets.fromLTRB(5,0,5,0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: (item.hasFocus) ? Colors.pink : Colors.white,
                      ),
                      color: bgColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        // 1. 발송처
                        _itemRow(1, "거래처명:", "${item.sShippingNo} / ${item.sStoreName}", false),
                        _itemRow(1, "바  코  드:", item.sBarcode, false),
                        _itemRow(1, "상품이름:", item.sGoodsName, false),
                        _itemRow(1, "재고수량:", item.rNowStock.toString(), false),
                        _itemRow(1, "상품위치:", item.sLotNo, true),

                        _itemRow(1, "출고/요청:",
                            "$sPickingCount / ${item.lGoodsCount}", true),
                        const Spacer(),
                      ],
                    ),
                )
              ),

              Positioned(
                  right:5, top: 5,
                  child: Visibility(
                      visible: item.hasFocus,
                      child:Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: (){
                                showPopGoodsDetail(
                                    context: context,
                                    lGoodsId: item.lGoodsId);
                              },
                              padding: EdgeInsets.zero,
                              constraints:const BoxConstraints(),
                              icon: const Icon(Icons.info_outline, color: Colors.black, size:24)
                          ),
                        ],
                      )
                  )
              ),

              Positioned(
                bottom: 5,right: 5,
                  child:Visibility(
                    visible: item.hasFocus,
                    child:SizedBox(
                      height: 34,
                      width: 64,
                      child: OutlinedButton(
                        onPressed: () {
                          onEdit(item);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.fromLTRB(10,8,10,8),
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.black,
                          side: const BorderSide(width: 1.0, color: ColorG4),
                        ),
                        child: Text( (item.fState == 0) ? "피킹" : "변경",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      )
                    )
                  )
              )
            ],
          )
      ),
    );
  }

  Widget _itemRow(int maxLines, String label, String value, bool bHilite) {
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
                letterSpacing: -1.6,
                height: 1.1,
                color: Colors.black,
              ),
            )
        ),
        Expanded(
          child: Text(value,
            maxLines: maxLines, overflow: TextOverflow.ellipsis,
            //textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 13,
              fontWeight: (bHilite) ? FontWeight.bold : FontWeight.normal,
              letterSpacing: -1.8,
              height: 1.1,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void _clearFocus() {
    for (var element in _pickConfirmList) {
      element.hasFocus = false;
    }
  }

  void _clearSelect() {
    for (var element in _pickConfirmList) {
      element.bSelect = false;
    }
  }

  void _clearScan() {
    for (var element in _pickConfirmList) {
      element.bScaned = false;
    }
  }

  void _checkComplete() {
    _isComplete = true;
    _lComplete = 0;
    for (var element in _pickConfirmList) {
      if (element.fState != 0) {
        _lComplete++;
      }
      else
      {
          _isComplete = false;
      }
    }
  }

  Future <bool> onWillPop() async {
    return false;
  }

  bool _checkValidate(String barcode) {
    return true;
  }

  Future <void> _doCancel() async {
    if(_lComplete<1) {
      await _reqSetWorker(widget.pickList, STATUS_PICK_READY);
      Navigator.pop(context, false);
      return;
    }

    showYesNoDialogBox(
        context: context,
        title: "확인",
        message: "추가한 피킹 상품이 모두 삭제됩니다."
            "\n삭제 하시겠습니까?",
        onResult: (bYes) async {
          if (bYes) {
            await _reqSetPickStatus(STATUS_PICK_READY);
            await _reqSetWorker(widget.pickList, STATUS_PICK_READY);
            Navigator.pop(context, false);
          }
        }
    );
  }

  bool _bPopStatus = false;
  Future<void> onEdit(ItemPickConfirm item) async {
    print("**************************************** [$_bPopStatus]");
    if(_bPopStatus) {
      return;
    }

    List<ItemPickConfirm> items = [];
    for (var element in _pickConfirmList) {
      if(element.hasFocus) {
        items.add(element);
      }
    }

    if(items.isEmpty) {
      return;
    }

    _bPopStatus = true;
    PopPickingGoodsList(
        context: context,
        items: items,
        onResult: (bool bOK, List<ItemPickConfirm> result) async {
          if(bOK) {
            List<ItemPickConfirm> list = [];
            for (var element in result) {
              if(element.bSelect) {
                list.add(element);
              }
            }
            await _updateConfirm(list);
            await _reqData();
          }
          _bPopStatus = false;
        }
    );
  }

  Future<void> onScaned(String barcode) async {

    print("--------------------------------------------------------");
    print("barcode=$barcode");
    print("--------------------------------------------------------");
    if(_bPopStatus) {
      return;
    }

    _bPopStatus = true;

    _clearSelect();
    _clearFocus();
    _clearScan();

    List<ItemPickConfirm> scanList = [];
    int index = -1;
    int n = 0;
    for (var element in _pickConfirmList) {
      if(element.sBarcode==barcode || element.sBarcode.endsWith(barcode)) {
        _pickConfirmList[n].bScaned = true;
        scanList.add(element);
        if(index<0) {
          index = n;
        }
      } else {
        _pickConfirmList[n].bScaned = false;
      }
      n++;
    }

    if(scanList.isEmpty) {
      _bPopStatus = false;
      showToastMessage("대상 상품이 아닙니다.");
      return;
    }

    setState(() {});


    await _controller.scrollToIndex(index,
        duration: const Duration(microseconds: 100),
        preferPosition: AutoScrollPosition.begin);

    PopPickingGoodsList(context: context, items: scanList,
        onResult: (bool bOK, List<ItemPickConfirm> result) async {
          _bPopStatus = false;
            if(bOK) {
              List<ItemPickConfirm> list = [];
              for (var element in result) {
                if(element.bSelect) {
                  list.add(element);
                }
              }
              await _updateConfirm(list);
              await _reqData();
            }
        }
    );
  }

  Future <void> _reqData() async {
    List<String> idsList = [];
    for (var element in widget.pickList) {
      idsList.add(element.lShippingID.toString());
    }

    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/shippingGoodsList",
        params: {
          "Ids": idsList
        },
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            var content = response['data'];
            if (content != null) {
              if (content is List) {
                _pickConfirmList = ItemPickConfirm.fromSnapshot(content);
              } else {
                _pickConfirmList = ItemPickConfirm.fromSnapshot([content]);
              }
              _checkComplete();
            }
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

  // 거래처 작업 상태를 변경한다.
  Future <void> _reqSetWorker(List<ItemPick> pickList, int fState) async {
    List<String> idsList = [];
    for (var element in pickList) {
      if (element.bSelect) {
        idsList.add(element.lShippingID.toString());
      }
    }

    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/updateShippingWorker",
        params: {"Ids": idsList, "fState": fState},
        onResult: (dynamic response) {
          if (kDebugMode) {
            print(response.toString());
          }
          if (response['status'] == "success") {}
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

  // 개별 상품의 출하수량 업데이트.
  Future <void> _updateConfirm(List<ItemPickConfirm> items) async {
    //_showProgress(true);
    List<Map<String, dynamic>> confirmList = [];
    for (var element in items) {
      confirmList.add({
        "lShippingDetailId": element.lShippingDetailID,
        "lConfirmCount":element.lPickingCount});
    }
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session:  _session,
        method: "taka/updateConfirmCount",
        params: {
          "confirmList": confirmList
          // "lShippingDetailId": item.lShippingDetailID,
          // "lConfirmCount":item.lPickingCount
        },
        onResult: (dynamic params) async {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            await _reqData();
            setState(() {
              _checkComplete();
            });
            //showToastMessage("처리되었습니다.", prevCancel:true);
          }
        },
        onError: (String error) {}
    );
    //_showProgress(false);
  }

  // 작업상태 변경 : 0,1,2
  Future <void> _reqSetPickStatus(int fState) async {
    List<String> idsList = [];
    for (var element in widget.pickList) {
        idsList.add(element.lShippingID.toString());
    }
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/updateShippingStatus",
        params: {"Ids": idsList, "fState":fState},
        onResult: (dynamic response) {
          _showProgress(false);

          if (kDebugMode) {
            print(response.toString());
          }

          if (response['status'] == "success") {
          }
          else {
            showToastMessage(response['message']);
          }
        },
        onError: (String error) {
          _showProgress(false);
        }
    );
  }


}
