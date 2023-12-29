
// ignore_for_file: non_constant_identifier_names

import 'package:distribution/common/inputForm.dart';
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/cardGoods.dart';
import 'package:distribution/home/move/bottomSelectStore.dart';
import 'package:distribution/models/kItemDistDataQty.dart';
import 'package:distribution/models/kItemStock.dart';
import 'package:distribution/models/kitemBoxInGoods.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class ProcessDistributeBoxGoodsQty extends StatefulWidget {
  // 상품코드, 상품명, 제조사, 상품Key
  final String workDay;
  final String boxNo;
  final ItemWBoxInGoods item;
  final Function(bool bOK)? onResult;
  final bool?  isPopupStage;

  const ProcessDistributeBoxGoodsQty({Key? key,
    required this.workDay,
    required this.boxNo,
    required this.item,
    this.onResult,
    this.isPopupStage = false,
  }) : super(key: key);

  @override
  State<ProcessDistributeBoxGoodsQty> createState() => _ProcessDistributeBoxGoodsQtyState();
}

class _ProcessDistributeBoxGoodsQtyState extends State<ProcessDistributeBoxGoodsQty> {
  late TextEditingController _qty_controller;
  List<ItemDistDataQty> _itemDistQtyList = [];
  List<ItemStock> _stockList = [];
  List<ItemStock> _storeMenuList = [];
  bool _isLockJob = false; // 관리자 승인여부 체크
  String title = "";

  int _sumConfirmCount = 0;
  int _sumGoodsCount = 0;
  String _sSumCount = "";
  String _sErrText = "";

  int lWarehousingID = 0;
  bool _bReady = false;
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.delayed(const Duration(milliseconds: 250), () async {
      _updateCountInfo();
      await _reqFirstProcess();
      await _reqInfoGoodsStock();
      _bReady = true;
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
      appBar:AppBar(
        title: const Text("상품배분"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              if(widget.onResult != null) {
                widget.onResult!(false);
              }
              Navigator.pop(context);
            }),
        actions: [
          // home
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(Icons.refresh, size: 32,),
                onPressed: () {
                  _reqFirstProcess();
                  //Navigator.of(context).popUntil((route) => route.isFirst);
                }),
          ),
        ],
      ),
      body:GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: _renderBody(),
          )
    );
  }

  Widget _renderBody() {
    if(!_bReady) {
      return Container(
        color: Colors.white,
      );
    }

    return Stack(
      children: [
        Positioned(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상태 메시지
                    Container(
                        padding: const EdgeInsets.fromLTRB(10,5,12,5),
                        child: Row(
                          children: [
                            const Spacer(),
                            Visibility(
                                visible: _isLockJob,
                                child: const Icon(Icons.check, color: Colors.pink,)
                            ),
                            Visibility(
                                visible: true,
                                child: Text(
                                    _isLockJob ? "승인완료" : "",
                                    style: ItemBkB15)),
                          ],
                        )
                    ),

                    // 상품정보
                    Container(
                      margin: const EdgeInsets.only(left: 5, right: 5, top:0, bottom: 5),
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 2,
                          color: Colors.grey,
                        ),
                      ),

                      child: CardGoods(
                        padding: const EdgeInsets.fromLTRB(5, 15, 5, 10),
                        lGoodsId: widget.item.lGoodsID!,
                        sGoodsName: widget.item.sGoodsName!,
                        sBarcode: widget.item.sBarcode!,
                      ),
                    ),

                    // 배분처리
                    Container(
                      margin: const EdgeInsets.only(left: 5, right: 5, top:5),
                      padding: const EdgeInsets.fromLTRB(0,15,0,10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 2,
                          color: (_isLockJob) ? Colors.pink :Colors.grey,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 타이틀
                          Container(
                            padding: const EdgeInsets.fromLTRB(10,0,5,5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("입고배분", style: ItemBkB15),
                                const Spacer(),
                                const Text("입고/배분:   ", style: ItemG1N15),
                                SizedBox(
                                  //margin: const EdgeInsets.only(right: 10),
                                  width: 100,
                                  child: InputForm(
                                    onlyDigit: true,
                                    readOnly: true,
                                    disable: false,
                                    //contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 10),
                                    keyboardType:TextInputType.text,
                                    valueText: _sSumCount,
                                    textStyle: ItemBkB15,
                                    hintText: '',
                                    onChange: (String value) {},
                                    onControl: (qtyController) {
                                      _qty_controller = qtyController;
                                    },
                                  ),

                                ),
                                //Text("${widget.item.lScanCount}", style: ItemBkB16,),
                                const SizedBox(width: 5,),
                              ],
                            ),
                          ),

                          // 매장/입고수량/배분수량
                          Container(
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            padding: const EdgeInsets.fromLTRB(0,0,0,10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: Colors.grey,
                              ),
                            ),
                            child: Column(
                              children: [
                                _itemHeader(),
                                ListView.builder(
                                    itemCount:_itemDistQtyList.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return _itemView(_itemDistQtyList[index]);
                                    }
                                ),
                              ],
                            ),
                          ),

                          // 배분매장 추가
                          Visibility(
                              visible: !_isLockJob,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    const Text("배분매장", style: ItemBkB14,),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, size: 28,),
                                      onPressed: (){
                                        //FocusScope.of(context).unfocus();
                                        _updateStoreMenuList();
                                        if(_storeMenuList.isEmpty) {
                                          showToastMessage("추가할 매장이 없습니다.");
                                          return;
                                        }

                                        BottomStoreSelect(context: context,
                                            items: _storeMenuList,
                                            onResult: (List<ItemStock> list) {
                                              for (var element in list) {
                                                _itemDistQtyList.add(ItemDistDataQty(
                                                  lWarehousingDetailID: 0,
                                                  lStoreId: element.lStoreID,
                                                  sStoreName: element.sStoreName,
                                                  lGoodsCount: 0,
                                                  lConfirmCount: 0,
                                                  fConfirm: 0
                                                ));
                                              }
                                              setState(() {});
                                            }
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                          ),
                          // 오류 메시지
                          Visibility(
                              visible: _sErrText.isNotEmpty,
                              child: Container(
                                margin: const EdgeInsets.only(top:5),
                                padding: const EdgeInsets.all(10),
                                child: Text(_sErrText,
                                  style: (_sumConfirmCount>_sumGoodsCount)
                                      ? ItemR1B15 : ItemR1B15,
                                  maxLines: 3,),
                              )
                          ),
                        ],
                      ),
                    ),

                    // 저장버튼
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 50),
                      child: Row(
                        children: [
                          const Spacer(),
                          SizedBox(
                            width: 140,
                            child: ButtonSingle(
                                visible: true,
                                isBottomPading: false,
                                text: '저장하기',
                                enable: !_isLockJob,
                                onClick: () {
                                  _reqSaveQty();
                                }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
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
    );
  }

  Widget _itemView(ItemDistDataQty item) {
    String sStoreName = item.sStoreName;
    if(sStoreName=="(주)한국다까미야") {
      sStoreName = "본사";
    }
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: Row(
        children: [
          Expanded(flex:4,
              child: Text(sStoreName,
                maxLines: 1,
                style: ItemBkN15,)
          ),
          Expanded(flex:3,
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              child: InputForm(
                  onlyDigit: true,
                  readOnly: true,
                  disable: false,
                  keyboardType:TextInputType.number,
                  valueText: item.lGoodsCount.toString(),
                  textStyle: ItemBkB16,
                  hintText: '',
                  onChange: (String value) {
                  }
              ),
            ),
          ),
          Expanded(flex:3,
            child: Container(
              margin: const EdgeInsets.only(left:10),
              child: InputForm(
                  onlyDigit: true,
                  readOnly: _isLockJob,
                  disable: false,
                  keyboardType:TextInputType.number,
                  valueText: item.lConfirmCount.toString(),
                  hintText: '',
                  textStyle: ItemBkB16,
                  onControl: (controller){
                    item.controller = controller;
                  },
                  onChange: (String value) {
                    String sQty = value.toString().trim();
                    if(int.tryParse(sQty) != null) {
                      item.lConfirmCount = int.parse(sQty);
                    }
                    _updateCountInfo();
                    setState(() {
                      _qty_controller.text = _sSumCount;
                    });
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const Border(
          bottom: BorderSide( // POINT
            color: Colors.grey,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: const [
          Expanded(flex:4, child: Text("매장", style: ItemBkN14,)),
          Expanded(flex:3, child: Center(child: Text("입고요청", style: ItemBkN14,))),
          Expanded(flex:3, child: Center(child: Text("배분수량", style: ItemBkN14,))),
        ],
      ),
    );
  }

  void _updateCountInfo() {
    _sumConfirmCount = 0;
    _sumGoodsCount   = 0;
    for (var element in _itemDistQtyList) {
      _sumConfirmCount = _sumConfirmCount + element.lConfirmCount;
      _sumGoodsCount   = _sumGoodsCount   + element.lGoodsCount;
    }
    _sSumCount = "$_sumGoodsCount / $_sumConfirmCount";

    _sErrText = "";
    if(_isLockJob) {
      _sErrText = "입고배분이 완료된 상품입니다.";
    } else {
      if(_sumConfirmCount>_sumGoodsCount) {
        _sErrText = "배분 총수량은 입고 총수량 보다 많을수 없습니다.";
      } else if(_sumConfirmCount<_sumGoodsCount) {
        _sErrText = "입고 VS 배분 수량이 일치하지 않습니다.";
      }
    }
  }

  void _checkConfirmStatus() {
    for (var element in _itemDistQtyList) {
      if(element.fConfirm != 0) {
        _isLockJob = true;
        break;
      }
    }
  }

  void _updateStoreMenuList() {
    _storeMenuList = [];
    for (var element in _stockList) {
      _storeMenuList.add(element);
    }

    for (var stock in _stockList) {
      for (var moveStock in _itemDistQtyList) {
        if (moveStock.sStoreName == stock.sStoreName) {
          _storeMenuList.remove(stock);
          break;
        }
      }
    }
  }

  Future <void> _reqInfoGoodsStock() async {
    _showProgress(true);
    await Remote.apiPost(
      context: context,
      session: _session,
      lStoreId: _session.getAccessStore(),
      method: "taka/goodsStockInfo",
      params: {"lGoodsId": widget.item.lGoodsID},
      onError: (String error) {},
      onResult: (dynamic data) {
        if (data['data'] != null) {
          var content = data['data'];
          _stockList = ItemStock.fromSnapshot(content);
          for (var element in _stockList) {
            if(element.sStoreName=="(주)한국다까미야") {
              element.sStoreName = "본사";
            }
          }
        }
      },
    );
    _showProgress(false);
  }

  Future <void> _reqFirstProcess() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/housingGoodsInfo",
        params: {
          "dWarehousing":widget.workDay,
          "sBoxNo":widget.boxNo,
          "lGoodsID":widget.item.lGoodsID
        },
        onError: (String error){},
        onResult: (dynamic jdata) {
          //if(jdata['status']=="success2")
          {

            if (jdata['data']['infos'] != null) {
              _bReady = true;
              var item = jdata['data']['infos'];
              if (item is List) {
                _itemDistQtyList = ItemDistDataQty.fromSnapshot(item);
              }
              else {
                _itemDistQtyList = ItemDistDataQty.fromSnapshot([item]);
              }
              for (var element in _itemDistQtyList) {
                if(element.sStoreName=="(주)한국다까미야") {
                  element.sStoreName = "본사";
                }
              }

              if(_itemDistQtyList.isNotEmpty) {
                lWarehousingID = _itemDistQtyList[0].lWarehousingID;
              }
            }
          }
          _checkConfirmStatus();
          _updateCountInfo();
        },
    );
    _showProgress(false);
  }

  Future<void> _reqSaveQty() async {
    // step 1 상품의 매장별 재고를 업데이트 한다(증가).
    if(_itemDistQtyList.isEmpty) {
      showToastMessage("배분할 상품이 없습니다.");
      return;
    }

    int sumCount = 0;
    int sumConfirm = 0;
    for (var element in _itemDistQtyList) {
      sumCount   += element.lGoodsCount;
      sumConfirm += element.lConfirmCount;
      //print("${element.lGoodsCount!} <> ${element.lConfirmCount!}");
    }


    if(sumConfirm  > sumCount) {
      showToastMessage("입고수량 보다 배분수량 더 많습니다.");
      return;
    }

    List<Map<String,dynamic>> dataList = [];
    for (var element in _itemDistQtyList) {
      Map<String,dynamic> data = element.toMap();
      data.addAll({"lWarehousingID":lWarehousingID,
        "lGoodsID" : widget.item.lGoodsID,
        "sBoxNo" : widget.boxNo});
      dataList.add(data);
    }

    Map<String,dynamic> request = {"data":dataList};
    if (kDebugMode) {
      var logger = Logger();
      logger.d(request);
    }

    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/housingGoodsSave",
        params: request,
        onError: (String error){},
        onResult: (dynamic result) {
          if(result['status'] != null) {
            if (result['status'] == "success") {
              //widget.item.isChecked = true;
              Navigator.pop(context, true);
              if(widget.onResult != null) {
                widget.onResult!(true);
              }
            }
          }
        },
    );
    _showProgress(false);
  }
}

Future<void> showBottomDistributeBoxGoodsQty({
  required BuildContext context,
  required String workDay,
  required String boxNo,
  required ItemWBoxInGoods item,
  required Function(bool bOK) onResult}) {
  double viewHeight = MediaQuery.of(context).size.height * 0.9;
  return showModalBottomSheet(
    context: context,
    enableDrag: false,
    isScrollControlled: true,
    useRootNavigator: true,
    isDismissible: false,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          onResult(false);
          return true;
        },
        child: SizedBox(
          height: viewHeight,
          child: ProcessDistributeBoxGoodsQty(
            workDay:workDay,
            boxNo:boxNo,
            item:item,
            onResult: (bool bOK) {
              onResult(bOK);
            },
          ),
        ),
      );
    },
  );
}
