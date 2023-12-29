// ignore_for_file: non_constant_identifier_names

import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/shipping/packing/showPackedGoodsList.dart';
import 'package:distribution/home/shipping/packing/workPackingGoods.dart';
import 'package:distribution/models/kItemPackBox.dart';
import 'package:distribution/models/kItemPick.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:transition/transition.dart';

class WorkPackingBoxInfo extends StatefulWidget {
  final String title;
  final String workDate;
  final List<ItemPick> itemPickList;
  final bool bWorkLock;
  const WorkPackingBoxInfo({
      Key? key,
      required this.title,
      required this.workDate,
      required this.itemPickList,
      required this.bWorkLock,
  }) : super(key: key);

  @override
  State<WorkPackingBoxInfo> createState() => _WorkPackingBoxInfoState();
}

class _WorkPackingBoxInfoState extends State<WorkPackingBoxInfo> {
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Navigator.pop(_scaffoldKey.currentState!.context);
  String _shipingKey = "";
  String _boxNo = "";
  String _sBoxStore = "";
  List<ItemPackBox> _packList = [];
  late AutoScrollController _controller;

  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _controller = AutoScrollController();

    Future.microtask(() {
      _shipingKey = makeShipingKey();
      String sDateCode = widget.workDate.replaceAll("-", "").substring(2);
      _sBoxStore = "$sDateCode-${widget.itemPickList[0].sStoreCode}";
      _reqPackingList();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String makeShipingKey() {
    String key = "";
    if(widget.itemPickList.length<2) {
      return "${widget.itemPickList[0].lShippingID}";
    } else {
      for (var element in widget.itemPickList) {
        if(key.isNotEmpty) {
          key = "${key}_";
        }
        key = "$key${element.lShippingID}";
      }
    }
    return key;
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
        title: Text(widget.title),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 32,),
            onPressed: () async {
              if(_packList.isEmpty) {
                await _reqDelStore();
                await _reqConfirmPacking();
              }
              Navigator.pop(context);
            }),
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 32,
                ),
                onPressed: () {
                  _reqPackingList();
                }),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-PackBoxInfo-key',
        validateMessage: "상품의 바코드를 스캔하세요.",
        waiting: false,//_isInAsyncCall,
        onWillPop: onWillPop,
        allowPop: false,//_isComplete,
        useCamera: !widget.bWorkLock,
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
                    // 내용
                    Positioned(
                      child: Visibility(
                        visible: true,
                          child:Container(
                            padding: const EdgeInsets.only(bottom: 78),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. 타이틀 정보
                                _renderTitle(),

                                // 2. 메시지 &
                                Visibility(
                                    visible: _packList.isEmpty,
                                    child:Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Center(
                                        child: Container(
                                            height: 200,
                                            width: double.infinity,
                                            color: Colors.white,
                                            child: Column(
                                              children: const [
                                                Text("포장박스의 바코드를 스캔하거나 신규 번호를 생성하세요.",
                                                  style: ItemBkN14,),
                                              ],
                                            )

                                        ),
                                      ),
                                    )
                                ),

                                // 3. 작업내용
                                Visibility(
                                    visible: _packList.isNotEmpty,
                                    child: Expanded(child: _renderBoxList())
                                )
                              ],
                            )
                          )
                      ),
                    ),

                    // 버튼
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
                                  text: '작업 삭제',
                                  isBottomPading: true,
                                  isBottomSide: true,
                                  enableColor: Colors.amber,
                                  enableTextColor: Colors.black,
                                  onClick: () async {
                                    if(_packList.isEmpty) {
                                      await _reqDelStore();
                                      Navigator.pop(context);
                                      return;
                                    }

                                    showYesNoDialogBox(
                                        context: context,
                                        title: "삭제 확인",
                                        message: "주의: 거래처의 모든 포장 내역이 삭제됩니다."
                                            "\n\n작업 내역을 삭제하시겠습니까?",
                                        onResult: (bOK) async {
                                          if(bOK) {
                                            await _reqDelStore();
                                            Navigator.pop(context);
                                          }
                                        }
                                    );
                                  },
                                ),),
                              const SizedBox(width: 1,),
                              Expanded(
                                flex: 7,
                                child: ButtonSingle(
                                  text: '거래처 포장완료',
                                  isBottomPading: true,
                                  isBottomSide: true,
                                  enable: _packList.isNotEmpty,
                                  visible: true,
                                  onClick: () async {
                                    showYesNoDialogBox(
                                        height: 240,
                                        context: context,
                                        title: "확인",
                                        message: "거래처"
                                            "의 모든 상품이 담겼습니까?",
                                        onResult: (bool isOK) async {
                                          if(isOK) {
                                            await _reqConfirmPacking();
                                            Navigator.pop(context);
                                          }
                                        }
                                    );
                                  },
                                ),
                              )
                            ],
                          )
                      ),
                    ),

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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderTitle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 2,
            )),
      ),
      child: Stack(
        children: [
          Positioned(
            child: Container(
                padding: const EdgeInsets.fromLTRB(10,10,10,5),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _itemRow(1,"거  래  처:", widget.itemPickList[0].sCustomerName, false),
                    _itemRow(1,"출하번호:", widget.itemPickList[0].sShippingNo, false),
                    const SizedBox(height: 5,),
                    _itemRow(1,"박스수량:", "${_packList.length}", true),
                  ],
                )
            ),
          ),
          Positioned(
            bottom:0, right: 5,
            child: Visibility(
                visible: true,
                child: SizedBox(
                    height: 36,
                    child:OutlinedButton(
                      onPressed: () async {
                        await _reqGetBoxCode();
                        if(await _reqCheckBoxCode(_boxNo)) {
                          _doBoxing(_boxNo);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.black,
                        side: const BorderSide(
                            width: 1.0, color: ColorG4),
                      ),
                      child: const Text(
                        "박스번호 만들기",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderBoxList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 80;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 3;
      mainAxisExtent = 80;
    } else if(rt<1.55) {
      crossAxisCount = 3;
      mainAxisExtent = 80;
    } else if(rt<2.42) {
      crossAxisCount = 2;
      mainAxisExtent = 80;
    } else if(rt<2.70) {
      crossAxisCount = 2;
      mainAxisExtent = 84;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _packList.length%crossAxisCount;
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
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemCount: _packList.length+dumyCount,
          itemBuilder: (context, int index) {
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index<_packList.length)
                    ? _ItemInfo(_packList[index]) : Container()
            );
            //return _boxItem(index, _goodsList[index]);
          }),
    );
  }

  Widget _ItemInfo(ItemPackBox item) {
    return GestureDetector(
        onTap: () async {
          for (var element in _packList) {
            element.bSelect = false;
          }
          item.bSelect = !item.bSelect;
          setState(() {});
        },
        child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: (item.bSelect) ? Colors.pink : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(5),
            color: (item.fState != STATUS_PACK_END) ? STD_DIFF : Colors.white,
          ),
          child: Stack(
            children: [
              Positioned(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        _itemRow(1, "박스번호:",    item.sBoxNo, false),
                        _itemRow(1, "거  래  처:", item.sCustomerName, false),
                        _itemRow(1, "상품수량:", "${item.lTotalGoodsCount}", true),
                        const Spacer(),
                      ],
                    )
                  )
              ),

              Positioned(
                  top:3, right: 3,
                  child: Visibility(
                    visible: item.bSelect,
                    child:Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              _doBoxing(item.sBoxNo);
                              /*
                              if(item.fState==STATUS_PACK_START) {
                                _doBoxing(item.sBoxNo);
                              } else {
                                _showBoxInGoods(item);
                              }
                               */
                            },
                            padding: EdgeInsets.zero, // 패딩 설정
                            constraints: const BoxConstraints(),
                            icon: Icon( (item.fState == STATUS_PACK_END)
                                ? Icons.edit
                                : Icons.info_outline,
                                color: Colors.black, size: 18)
                        ),
                        const SizedBox(width: 5),
                        IconButton(
                            onPressed: (){
                              showYesNoDialogBox(
                                  context: context,
                                  title: "확인",
                                  message: "선택한 포장박스를 삭제하시겠습니까?",
                                  onResult: (bOK){
                                    if(bOK) {
                                      _reqDelBox(item);
                                    }
                                  });
                            },
                            padding: EdgeInsets.zero, // 패딩 설정
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close,
                                color: Colors.red,size: 22)
                        ),
                      ],
                    )
                  )
              ),
            ],
          )
        ));
  }

  Widget _itemRow(int maxLines, String label, String value, bool bHilite) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: 52,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                letterSpacing: -1.2,
                height: 1.2,
                color: Colors.grey,
              ),
            )
        ),
        Expanded(
          child: Text(value,
            maxLines: maxLines, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
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

  void _clearFocus() {
    for (var element in _packList) {
      element.hasFocus = false;
    }
  }

  bool _checkValidate(String barcode) {
    // int index = items.indexWhere((element) => element.sBarcode == barcode);
    // return (index >= 0);
    return true;
  }

  Future <bool> onWillPop() async {
    return false;
  }

  Future <void> onScaned(String barcode) async {
    _clearFocus();
    int index = _packList.indexWhere((element) => element.sBoxSeq == barcode);
    if (index >= 0) {
      _packList[index].hasFocus = true;
      _controller.scrollToIndex(index);
      setState(() {});
    } else {
      _boxNo = barcode;
      if(await _reqCheckBoxCode(_boxNo)==true) {
        _doBoxing(_boxNo);
      }
    }
  }

  Future <void> _reqPackingList() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/listStorePacking",
        params: {
          "sShippingKey":_shipingKey,
          "sBoxStore":_sBoxStore,
          "sCustomerName" : widget.itemPickList[0].sCustomerName,
          },
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (kDebugMode) {
            print(response.toString());
          }

          if (response['status'] == "success") {
            var content = response['data'];
            if (content != null) {
              if (content is List) {
                _packList = ItemPackBox.fromSnapshot(content);
              } else {
                _packList = ItemPackBox.fromSnapshot([content]);
              }
            }
          }

          if(widget.bWorkLock && _packList.isEmpty) {
            _showProgress(false);
            Navigator.pop(context, true);
          }
        },
        onError: (String error) {});
    _showProgress(false);
  }

  Future <void> _reqGetBoxCode() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/getBoxNo",
        params: {"dtDate": widget.workDate},
        onResult: (dynamic response) {
          //_showProgress(false);

          if (kDebugMode) {
            print(response.toString());
          }

          // {status: success, message: , data: 0001}
          if (response['status'] == "success") {
            _boxNo = response['data'];

          }
        },
        onError: (String error) {

        }
    );
    _showProgress(false);
  }

  Future <bool> _reqCheckBoxCode(String sBoxNo) async {
    _showProgress(true);
    bool rtn = false;
    // {"sBoxNo": "0001", "dShipping": "2022-11-29"}
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/checkBoxNo",
        params: {"dShipping": widget.workDate, "sBoxNo": sBoxNo},
        onResult: (dynamic response) {
          //_showProgress(false);

          if (kDebugMode) {
            print(response.toString());
          }

          // {status: success, message: , data: 0001}
          if (response['status'] == "success" && int.parse(response['data'].toString())==1) {
              rtn = true;
          }
          else {
            showToastMessage("사용할 수 없는 박스번호 입니다.");
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);

    //print("_reqCheckBoxCode(sBoxNo:$sBoxNo)=>$rtn");
    return rtn;
  }

  Future <void> _doBoxing( String sBoxNo) async {
    String title = "상품포장";
    await Navigator.push(context,
      Transition(
          child: WorkPackingGoods(
            title: title,
            workDate: widget.workDate,
            sBoxNo: sBoxNo,
            itemPickList: widget.itemPickList,
            sShipingKey:_shipingKey,
            bWorkLock: false,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    _reqPackingList();
  }

  Future <void> _reqConfirmPacking() async {
    List<String> idsList = [];
    for (var element in widget.itemPickList) {
      idsList.add(element.lShippingID.toString());
    }
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/confirmStorePacking",
        params: {
          //"sBoxSeq":packItem.sBoxSeq,
          "Ids":idsList
        },
        onResult: (dynamic params) async {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
          }
        },
        onError: (String error) {}
    );
  }

  Future<void> _reqDelBox(ItemPackBox item) async {
    List<String> idsList = [];
    for (var element in widget.itemPickList) {
      idsList.add(element.lShippingID.toString());
    }

    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/deletePackingBox",
        params: {"Ids":idsList,
          "fState": item.fState,  //패킹상태
          "sBoxSeq":item.sBoxSeq
        },
      onError: (String error) {},
        onResult: (dynamic response) {
          if (response['status'] == "success") {
            _reqPackingList();
          }
          else {
            showToastMessage(response['message']);
          }
        },

    );
    _showProgress(false);
  }

  Future<void> _reqDelStore() async {
    List<String> idsList = [];
    for (var element in widget.itemPickList) {
      idsList.add(element.lShippingID.toString());
    }

    List<String> sSeqList = [];
    for (var element in _packList) {
      sSeqList.add(element.sBoxSeq);
    }

    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/deletePackingStore",
        params: {
          "Ids" : idsList,
          "sBoxSeq": sSeqList
        },
        onError: (String error) {},
        onResult: (dynamic response) {
          if (response['status'] == "success") {
            _reqPackingList();
          } else {
            showToastMessage(response['message']);
          }
        },
    );
    _showProgress(false);
  }

  void _showBoxInGoods(ItemPackBox item) {
      String title = "박스내 상품 목록";
      Navigator.push(context,
      Transition(
          child: ShowPackedGoodsList(
            title: title,
            sBoxSeq: item.sBoxSeq,
            sCustomerName: item.sCustomerName,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }
}
