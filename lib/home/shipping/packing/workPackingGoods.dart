// ignore_for_file: non_constant_identifier_names, file_names

import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/goodsDetail.dart';
import 'package:distribution/home/shipping/packing/dlgPackingGoodsSingle.dart';
import 'package:distribution/home/shipping/packing/bottomStoreGoodsList.dart';
import 'package:distribution/home/stock/popItemSelect.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/models/kItemPack.dart';
import 'package:distribution/models/kItemPackGoods.dart';
import 'package:distribution/models/kItemPackedGoods.dart';
import 'package:distribution/models/kItemPick.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class WorkPackingGoods extends StatefulWidget {
  final String title;
  final List<ItemPick> itemPickList;
  final String workDate;
  final String sBoxNo;
  final bool bWorkLock;
  final String sShipingKey;
  const WorkPackingGoods({
      Key? key,
      required this.title,
      required this.workDate,
      required this.itemPickList,
      required this.sBoxNo,
      required this.bWorkLock,
      required this.sShipingKey,
  }) : super(key: key);

  @override
  State<WorkPackingGoods> createState() => _WorkPackingGoodsState();
}

class _WorkPackingGoodsState extends State<WorkPackingGoods> {
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Navigator.pop(_scaffoldKey.currentState!.context);
  List<ItemPackedGoods> _packedGoodsList = [];
  late AutoScrollController _controller;

  bool _bAllowEdit = true;
  late SessionData _session;

  final List<String> _idsList = [];
  String _sBoxSeq = "";
  int _totalPackedGoods = 0;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _controller = AutoScrollController();
    _bAllowEdit = !widget.bWorkLock;
    Future.microtask(() {
      for (var element in widget.itemPickList) {
        _idsList.add(element.lShippingID.toString());
      }

      String sDateCode = widget.workDate.replaceAll("-", "").substring(2);
      _sBoxSeq = "$sDateCode-${widget.itemPickList[0].sStoreCode}-${widget.sBoxNo}";
      _reqData();
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
    String contactInfo = widget.itemPickList[0].sCustomerName;
    if(contactInfo.isNotEmpty && widget.itemPickList[0].sCustomerTel.isNotEmpty) {
      contactInfo = "${widget.itemPickList[0].sCustomerName} / "
          "${widget.itemPickList[0].sCustomerTel}";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 32,),
            onPressed: () {
              Navigator.pop(context, false);
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
                  _reqData();
                }),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-PackGoodsInfo-key',
        validateMessage: "상품의 바코드를 스캔하세요.",
        waiting: false,
        onWillPop: onWillPop,
        allowPop: true,
        useCamera: true,
        validate: _checkValidate,
        onScan: (barcode) {
          _onScaned(barcode);
        },

        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    child: Visibility(
                      visible: true,
                        child: Container(
                          //margin: EdgeInsets.only(bottom: 100),
                          color: Colors.white,
                          child: Column(
                            children: [
                              // 1. 타이틀 정보
                              _renderTitle(),

                              // 2. 메시지
                              Visibility(
                                  visible: _packedGoodsList.isEmpty,
                                  child:Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Center(
                                      child: Container(
                                          height: 200,
                                          width: double.infinity,
                                          color: Colors.white,
                                          child: Column(
                                            children: const [
                                              Text("상품 바코드를 스캔하세요.",
                                                style: ItemBkN14,),
                                            ],
                                          )

                                      ),
                                    ),
                                  )
                              ),

                              // 3.작업내용
                              Visibility(
                                  visible: _packedGoodsList.isNotEmpty,
                                  child:Expanded(
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          child: _renderGoodsList()
                                        ),
                                      ],
                                    ),
                                  )
                              ),
                            ],
                          ),
                        ),
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
                                text: '박스삭제',
                                isBottomPading: true,
                                isBottomSide: true,
                                enableColor: Colors.amber,
                                enableTextColor: Colors.black,
                                onClick: () async {
                                  if(_packedGoodsList.isNotEmpty) {
                                        showYesNoDialogBox(
                                            context: context,
                                            title: "삭제확인",
                                            message: "현재 박스에 담긴 모든 상품이 삭제됩니다."
                                                "\n삭제하시겠습니까?",
                                            onResult: (bOk) async {
                                              if(bOk) {
                                                await _reqDelBox();
                                                //Navigator.pop(context);
                                                Navigator.pop(context);
                                              }
                                            });

                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                              ),),
                            const SizedBox(width: 1,),
                            Expanded(
                              flex: 7,
                              child: ButtonSingle(
                                text: "박스 포장완료",
                                isBottomPading: true,
                                isBottomSide: true,
                                enable: _packedGoodsList.isNotEmpty,
                                visible: true,
                                onClick: () async {
                                  await _reqConfirmBox();
                                  //Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                              ),
                            )
                          ],
                        )
                    ),
                  ),
                  // wait progress...
                  Positioned(
                      top:48,bottom: 0, left:0, right: 0,
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
                      _itemRow(1,"박스번호:", widget.sBoxNo, true),
                      _itemRow(1,"거  래  처:", widget.itemPickList[0].sCustomerName,false),
                      const SizedBox(height: 10,),
                      _itemRow(1,"상품수량:", "${_packedGoodsList.length} ($_totalPackedGoods)", true)
                    ],
                  )
              ),
          ),
          Positioned(
            top:5, right: 5,
            child: Visibility(
              visible: !widget.bWorkLock && _bAllowEdit,
              child: Container(
                  height: 28,
                  margin: const EdgeInsets.only(bottom: 5),
                  child:OutlinedButton(
                    onPressed: () async {
                      _showAllGoods();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side: const BorderSide(width: 1.0,
                          color: Colors.pink),
                    ),
                    child: const Text(
                      "상품조회", style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,),
                    ),
                  )
              )
          ),),
        ],
      ),
    );
  }

  Widget _renderGoodsList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 110;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 2;
      mainAxisExtent = 72;
    } else if(rt<1.55) {
      crossAxisCount = 2;
      mainAxisExtent = 72;
    } else if(rt<2.42) {
      crossAxisCount = 1;
      mainAxisExtent = 76;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 76;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _packedGoodsList.length%crossAxisCount;
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
          itemCount: _packedGoodsList.length+dumyCount,
          itemBuilder: (context, int index) {
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index<_packedGoodsList.length)
                    ? _ItemInfo(_packedGoodsList[index]) : Container()
            );
            //return _boxItem(index, _goodsList[index]);
          }),
    );
  }

  Widget _ItemInfo(ItemPackedGoods item) {
    return GestureDetector(
        onTap: () async {
          if(_bAllowEdit)
          {
            FocusScope.of(context).unfocus();
            _clearFocus();
            setState(() {
              item.hasFocus = true;
            });
          }
        },
        child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: (item.hasFocus) ? Colors.pink : Colors.grey,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              Positioned(
                child:Container(
                  padding: const EdgeInsets.fromLTRB(5,5,3,5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      _itemRow(1, "바  코  드:", item.sBarcode, false),
                      _itemRow(1, "상품이름:", item.sGoodsName, false),
                      _itemRow(1, "상품수량:", "${item.lPackingCount}", true),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 3,right: 3, left:0,
                  child: Visibility(
                      visible: item.hasFocus,
                      child:Container(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            const Spacer(),
                            // info
                            IconButton(
                                onPressed: (){
                                  showPopGoodsDetail(
                                      context: context,
                                      lGoodsId: item.lGoodsId);
                                },
                                padding: EdgeInsets.zero,
                                constraints:const BoxConstraints(),
                                icon: const Icon(Icons.info_outline,
                                    color: Colors.black, size:18)
                            ),
                            const SizedBox(width: 8,),
                            // edit
                            IconButton(
                                onPressed: (){
                                  _onEdit(item);
                                },
                                padding: EdgeInsets.zero, // 패딩 설정
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.edit, size:16,
                                  color: Colors.black,)
                            ),
                            const SizedBox(width: 8,),
                            // delete
                            IconButton(
                                onPressed: (){
                                  showYesNoDialogBox(
                                      context: context,
                                      height: 200,
                                      title: "삭제확인",
                                      message: "이 상품을 삭제하시겠습니까?",
                                      onResult: (bool isOk){
                                        if(isOk) {
                                          _removeGoods(item);
                                        }
                                      }
                                  );
                                },
                                padding: EdgeInsets.zero, // 패딩 설정
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.close, size:22, color: Colors.red,)
                            ),
                            //const SizedBox(width: 5,),
                          ],
                        ),
                      )
                  )
              ),
            ],
          )
        )
    );
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
                letterSpacing: -1.5,
                height: 1.2,
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

  void _clearFocus() {
    for (var element in _packedGoodsList) {
      element.hasFocus = false;
    }
  }

  Future <bool> onWillPop() async {
    return false;
  }

  bool _checkValidate(String barcode) {
    return true;
  }

  bool _bPopStatus = false;
  Future <void> _onEdit(final ItemPackedGoods item) async {
    if(_bPopStatus) {
      return;
    }

    _bPopStatus = true;
    ItemPackGoods? goods = await _reqPackingGoods(item.lGoodsId);
    if(goods==null) {
      showToastMessage("패킹 대상 상품이 아닙니다.");
      _bPopStatus = false;
      return;
    }

    ItemPack itemPack = ItemPack(
      lGoodsId: goods.lGoodsId,
      sGoodsName: goods.sGoodsName,
      sBarcode: goods.sBarcode,
      lTotalGoodsCount:     item.lPackingCount,
      lTotalPickingCount:   goods.lTotalPickingCount,
      lTotalPackingCount:   goods.lTotalPackingCount,
      lCurrentPackingCount: goods.lTotalCurrentPackingCount,
    );

    // Navigator.pop(_scaffoldKey.currentState!.context);
    DlgPackingGoodsSingle(
        context: context,
        item: itemPack,
        isNew: false,
        onResult: (bool bDirty, ItemPack? value) async {
          _bPopStatus = bDirty;
          if(bDirty) {
            bool result = await _addToBox(true, value!);
            if (result) {
              await _reqData();
              int index = _packedGoodsList.indexWhere((element) =>
              element.sBarcode == value.sBarcode);
              if (index >= 0) {
                setState(() {
                  _packedGoodsList[index].hasFocus = true;
                });
                await _controller.scrollToIndex(index,
                    duration: const Duration(microseconds: 100),
                    preferPosition: AutoScrollPosition.begin);
              }
            }
            _bPopStatus = false;
          }
        }
    );
  }

  Future <void> selectGoods(int lGoodsId) async {
    _clearFocus();
    ItemPackGoods? goods = await _reqPackingGoods(lGoodsId);
    if(goods==null) {
      showToastMessage("패킹 대상 상품이 아닙니다.");
      return;
    }

    int index = _packedGoodsList.indexWhere((element) => element.lGoodsId == lGoodsId);
    if(index>=0) {
      setState(() {
        _packedGoodsList[index].hasFocus = true;
      });

      await _controller.scrollToIndex(index,
          duration: const Duration(microseconds: 100),
          preferPosition: AutoScrollPosition.begin);
    }

    ItemPack item = ItemPack(
      lGoodsId: goods.lGoodsId,
      sGoodsName: goods.sGoodsName,
      sBarcode: goods.sBarcode,
      lTotalGoodsCount:     goods.lTotalPickingCount-goods.lTotalPackingCount,
      lTotalPickingCount:   goods.lTotalPickingCount,
      lTotalPackingCount:   goods.lTotalPackingCount,
      lCurrentPackingCount: goods.lTotalCurrentPackingCount,
    );

    if(item.lTotalGoodsCount<1) {
      showToastMessage("포장이 완료된 상품입니다.");
      return;
    }

    if(index>=0) {
      showToastMessage("이미 추가된 상품입니다.");
      return;
    }

    _bPopStatus = true;
    DlgPackingGoodsSingle(
        context: context,
        item: item,
        isNew: index<0,
        onResult: (bool bDirty, ItemPack? value) async {
          _bPopStatus = bDirty;
          if (bDirty) {
            bool result = await _addToBox(true, value!);
            if (result) {
              await _reqData();
              int index = _packedGoodsList.indexWhere((element) =>
              element.sBarcode == value.sBarcode);
              if (index >= 0) {
                setState(() {
                  _packedGoodsList[index].hasFocus = true;
                });
                await _controller.scrollToIndex(index,
                    duration: const Duration(microseconds: 100),
                    preferPosition: AutoScrollPosition.begin);
              }
            }
            _bPopStatus = false;
          }
        }
    );
  }

  Future<void> _onScaned(String barcode) async {
    //barcode = "80407";
    if(_bPopStatus) {
      return;
    }

    List<ItemGoodsList> list = await _reqGoodsListByBarcode(barcode);
    if(list.isEmpty) {
      return;
    }

    int index = 0;
    if(list.length==1) {
      selectGoods(list[index].lGoodsId!);
      return;
    }

    List<SelectItem> items = [];
    for (var element in list) {
      items.add(SelectItem(
          sName: element.sGoodsName!,
          lGoodsId: element.lGoodsId,
          sBarcode: element.sBarcode!)
      );
    }

    showItemsSelect(
        context: context,
        items: items,
        onResult: (bool bOk, int index) {
          if(bOk) {
            selectGoods(list[index].lGoodsId!);
          }
        }
    );
  }

  Future <ItemPackGoods?> _reqPackingGoods(int lGoodsId) async {
    ItemPackGoods? goods;
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/infoPackingGoodsId",
        params: {
          "Ids": _idsList,
          "lGoodsId":lGoodsId,
        },
        onError: (String error) {},
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            var content = response['data'];
            List<ItemPackGoods> list = [];
            if (content != null) {
              if (content is List) {
                list = ItemPackGoods.fromSnapshot(content);
              } else {
                list = ItemPackGoods.fromSnapshot([content]);
              }
              if(list.isNotEmpty) {
                goods = list[0];
              }
            }
          }
        },
    );
    _showProgress(false);
    return goods;
  }

  Future <void> _reqData() async {
    _totalPackedGoods = 0;
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/listPackingGoods",
        params: {
          "sBoxSeq":_sBoxSeq,
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
                _packedGoodsList = ItemPackedGoods.fromSnapshot(content);
              } else {
                _packedGoodsList = ItemPackedGoods.fromSnapshot([content]);
              }

              for (var element in _packedGoodsList) {
                if(element.lPackingCount>0) {
                  _totalPackedGoods += element.lPackingCount;
                }
              }

            }
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

  Future <bool> _addToBox(bool bflag, ItemPack item) async {
    bool flag = false;
    if(bflag) {
      _showProgress(true);
    }
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/insertPackingGoods",
        params: {
          "Ids":_idsList,
          "sShippingKey":widget.sShipingKey,
          "sBoxSeq":_sBoxSeq,
          "sBoxNo": widget.sBoxNo,
          "lGoodsId":item.lGoodsId,
          "lGoodsCount":item.lTotalGoodsCount
        },
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            flag = true;
          } else {
            showToastMessage(response['message'].toString());
          }
        },
        onError: (String error) {}
    );
    if(bflag) {
      _showProgress(false);
    }

    return flag;
  }

  Future <void> _addToBoxArray(List<ItemPack> list) async {

    _showProgress(true);

    List<Map> goodsList = [];
    for (var element in list) {
      if(element.checked) {
        goodsList.add({
          "lGoodsId":element.lGoodsId,
          "lGoodsCount":element.lTotalPickingCount - element.lTotalPackingCount
          //element.lTotalPickingCount-element.lCurrentPackingCount
        });
      }
    }

    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/insertPackingArrayGoods",
        params: {
          "Ids":_idsList,
          "sShippingKey":widget.sShipingKey,
          "sBoxSeq":_sBoxSeq,
          "sBoxNo": widget.sBoxNo,
          "items":goodsList
        },
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
          } else {
            showToastMessage(response['message'].toString());
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);

  }

  Future<void> _reqDelBox() async {
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
        "fState": STATUS_PACK_START,  //패킹상태
        "sBoxSeq":_sBoxSeq
      },
      onError: (String error) {},
      onResult: (dynamic response) {
        if (response['status'] == "success") {
          _reqData();
        }
        else {
          showToastMessage(response['message']);
        }
      },

    );
    _showProgress(false);
  }

  Future <void> _removeGoods(final ItemPackedGoods item) async {
    _showProgress(true);
    List<String> idsList = [];
    for (var element in widget.itemPickList) {
      idsList.add(element.lShippingID.toString());
    }

    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/deletePacking",
        params: {
          "Ids":idsList,
          "lPackingId":item.lPackingID,
        },
        onResult: (dynamic params) async {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            await _reqData();
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

  Future<void> _showAllGoods() async {
    bottomStoreGoodList(
        context: context,
        sBoxSeq: _sBoxSeq,
        idsList: _idsList,
        onResult: (bool bOK, List<ItemPack> items) async {
          if(bOK) {
            for (var element in items) {
              element.lTotalGoodsCount = element.lTotalPickingCount;
            }
            await _addToBoxArray(items);
            await _reqData();
            setState((){
            });
          }
        },
    );
  }

  Future <void> _reqConfirmBox() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/confirmPacking",
        params: {
          "sBoxSeq":_sBoxSeq,
          "Ids":_idsList
        },
        onResult: (dynamic params) async {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            await _reqData();
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

  Future<List<ItemGoodsList>> _reqGoodsListByBarcode(String barcode) async {
    _showProgress(true);
    List<ItemGoodsList> list = [];
    await Remote.apiPost(
      context: context,
      session: _session,
      lStoreId: _session.getAccessStore(),
      method: "taka/goodsList",
      params: {"sBarcode": barcode, "lPageNo" : "1", "lRowNo" : "100"},
      onError: (String error) {},
      onResult: (dynamic data) {
        if (data['data'] != null) {
          var item = data['data'];
          if (item is List) {
            list = ItemGoodsList.fromSnapshot(item);
          } else {
            list = ItemGoodsList.fromSnapshot([item]);
          }
          if (list.isEmpty) {
            showToastMessage("매칭되는 상품이 없습니다.");
          }
        }
      },
    );
    _showProgress(false);
    return list;
  }

}
