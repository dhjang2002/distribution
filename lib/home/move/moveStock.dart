import 'package:distribution/common/dateForm.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/inputFormTouchClear.dart';
import 'package:distribution/common/cardPhotoItem.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/move/bottomSelectStore.dart';
import 'package:distribution/home/stock/popItemSelect.dart';
import 'package:distribution/models/kInfoGoods.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/models/kItemStock.dart';
import 'package:distribution/models/kItemStockMove.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:distribution/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemMoveStock {
  ItemStock? stock;
  bool isMyStore;
  String value;
  TextEditingController? valueController;
  String memo;
  TextEditingController? memoController;
  bool clearLock;
  ItemMoveStock({
    this.stock,
    this.value = "",
    this.memo = "재고이동",
    this.valueController,
    this.memoController,
    this.isMyStore = false,
    this.clearLock = false,
  });
}

class MoveStock extends StatefulWidget {
  final int lGoodsId;
  const MoveStock({
    Key? key,
    required this.lGoodsId,
  }) : super(key: key);

  @override
  State<MoveStock> createState() => _MoveStockState();
}

class _MoveStockState extends State<MoveStock> {
  int _lGoodsId = 0;
  InfoGoods _info = InfoGoods();
  //late TextEditingController? valueController;
  late final ScrollController _controller = ScrollController();
  List<CardPhotoItem> _photoList = [];

  int _totalStock = 0;
  List<ItemStock> _stockList = [];
  List<ItemStock> _stockMenu = [];
  List<ItemMoveStock> _moveStockList = [];
  List<ItemMoveStock> _baseStockList = [];
  //final ItemMoveStock _baseStock = ItemMoveStock();
  int _moveDataSum = 0;
  List<ItemStockMove> _moveLogList = [];
  String _storeName = "";

  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _storeName = _session.Stroe!.sName;
    if(_storeName=="(주)한국다까미야") {
      _storeName = "본사";
    }

    _lGoodsId = widget.lGoodsId;
    Future.microtask(() async {
      await _reqInfoGoods();
      await _reqInfoGoodsStock();
      await _reqListStockMoveLog();
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
          title: const Text("재고이동"),
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
                  onPressed: () async {
                    _stockList = [];
                    _stockMenu = [];
                    _moveStockList = [];
                    await _reqInfoGoods();
                    await _reqInfoGoodsStock();
                    await _reqListStockMoveLog();
                  }),
            ),
          ],
        ),
        body: TakaBarcodeBuilder(
          scanKey: 'taka-MoveStock-key',
          onWillPop: () async {return false;},
          waiting: false,
          allowPop: true,
          useCamera: true,
          onScan: (barcode) async {
            _onScan(barcode);
          },
          child: Stack(
          children: [
            Positioned(child: _renderBody()),
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
        )
    );
  }

  Widget _renderBody() {
    final double picHeight = MediaQuery.of(context).size.width * 0.7;
    String sStock = "${_info.rStoreStock}";
    if(_moveDataSum!=0) {
      sStock = "${_info.rStoreStock}  ( $_moveDataSum )";
    }

    String sMemo = _info.sLot;
    if(_info.sLotMemo.isNotEmpty) {
      sMemo = "${_info.sLot}, ${_info.sLotMemo}";
    }
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        controller: _controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 상품정보 - 사진
          Container(
            height: picHeight,
            width: double.infinity,
            color: Colors.black,
            child: CardPhotos(
              items: _photoList,
            ),
          ),

          // 2. 상품정보-일반
          Container(
            margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const Text(
                  "상품정보",
                  style: ItemBkB15,
                ),
                const SizedBox(
                  height: 10,
                ),
                _itemRow(1, "바  코  드:", _info.sBarcode, false),
                _itemRow(2, "상  품  명:", _info.sName, false),
                _itemRow(1, "상품위치:", sMemo, false),
                _itemRow(1, "상품재고:", sStock, true),
              ],
            ),
          ),

          // 3. 재고현황
          Visibility(
              visible: true,
              child: _infoStock()
          ),

          // 4. 이동재고 현황
          Visibility(
              visible: true,
              child: _infoMoveLog()
          ),

          // 5. 재고증감
          Container(
            margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
            padding: const EdgeInsets.fromLTRB(10,10,10,10),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: (_moveStockList.isEmpty) ? Colors.pink : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "재고증감",
                      style: ItemBkB15,
                    ),
                    const Spacer(),
                    Text(
                      _storeName,
                      style: ItemBkB15,
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _baseStockList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _itemMoveStore(true, _baseStockList[index]);
                  },
                ),
                //_itemMoveStore(true, _baseStock),
                Container(
                  margin: const EdgeInsets.only(top:5),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible:_baseStockList.isNotEmpty && (_baseStockList[0].value.isEmpty || _baseStockList[0].value.trim()=="0"),
                        child:const Text("재고증감 수량을 입력하세요.", style: ItemG1N14,),),
                      const Spacer(),
                      Container(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                              width: 80,
                              height: 36,
                              child: OutlinedButton(
                                onPressed:_baseStockList.isNotEmpty && (_baseStockList[0].value.isEmpty || _baseStockList[0].value.trim()=="0") ? null
                                    : () async
                                {
                                  _reqAddUpdateStock();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black,
                                  disabledForegroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.grey,

                                  side: const BorderSide(width: 1.0, color: ColorG4),
                                ),
                                child: const Text(
                                  "증감요청",
                                  style: TextStyle( fontSize: 12,
                                    color: Colors.white,
                                  ),
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

          // 6. 재고이동
          Container(
            margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
            padding: const EdgeInsets.fromLTRB(10,0,10,10),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: (_moveStockList.isNotEmpty) ? Colors.pink : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  //color: Colors.grey,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      // int totalHomeQty = _moveDataSum + _info.rStoreStock;
                      RichText(
                          text: TextSpan(
                              style: ItemBkN16,
                              children: [
                                const TextSpan(text: '재고이동 ',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                                ),
                                const TextSpan(text: ' ( 가능수량 : ',
                                    style: TextStyle(fontWeight: FontWeight.normal,
                                        color: Colors.grey)
                                ),
                                TextSpan(text: '${_moveDataSum + _info.rStoreStock}',
                                    style: const TextStyle(fontWeight: FontWeight.bold)
                                ),
                                const TextSpan(text: ' )',
                                    style: TextStyle(fontWeight: FontWeight.normal,
                                        color: Colors.grey)
                                ),
                              ])
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add_circle, size: 32,),
                        onPressed: (){
                          BottomStoreSelect(context: context,
                              items: _stockMenu,
                              onResult: (list) {
                                FocusScope.of(context).unfocus();
                                if(list.isNotEmpty) {
                                  for (var element in _moveStockList) {
                                    element.clearLock = true;
                                  }
                                  Future.microtask(() {
                                    for (var element in list) {
                                      _buildMoveMenu(element.sStoreName, false);
                                    }

                                    _updateMoveStock();
                                    for (var element in _moveStockList) {
                                      element.clearLock = false;
                                    }
                                    setState(() {});

                                    _controller.animateTo(
                                        _controller.position.maxScrollExtent,
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeInOut
                                    );
                                  });
                                }
                              }
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Visibility(
                  visible: _moveStockList.isEmpty,
                    child: const Text("재고를 이동시킬 지점을 추가하세요.", style: ItemG1N14,)
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _moveStockList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _itemMoveStore(false, _moveStockList[index]);
                  },
                ),
                Visibility(
                    visible: _moveStockList.isNotEmpty,
                    child: Container(
                      margin: const EdgeInsets.only(top:10),
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                          width: 80,
                          height: 36,
                          child: OutlinedButton(
                            onPressed: _baseStockList.isNotEmpty && !(_baseStockList[0].value.isEmpty || _baseStockList[0].value.trim()=="0")
                                ? null : () async {
                              await _reqAddMoveStock();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black,
                              disabledForegroundColor: Colors.black,
                              disabledBackgroundColor: Colors.grey,
                              side: const BorderSide(width: 1.0, color: ColorG4),
                            ),
                            child: const Text(
                              "이동요청",
                              style: TextStyle( fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          )
                      )
                    )
                ),
              ],
            ),
        ),

        const SizedBox(
          height: 150,
        )
      ],
    )));
  }

  Widget _infoStock() {
    int crossAxisCount = 1;
    double mainAxisExtent = 200;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 6;
      mainAxisExtent = 20;
    } else if(rt<1.55) {
      crossAxisCount = 6;
      mainAxisExtent = 20;
    } else if(rt<2.42) {
      crossAxisCount = 4;
      mainAxisExtent = 20;
    } else if(rt<2.70) {
      crossAxisCount = 3;
      mainAxisExtent = 20;
    }

    return Visibility(
        visible: true,
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("재고현황 (${numberFormat(_totalStock)})", style: ItemBkB15,),
              const Divider(height: 10, color: Colors.grey,),
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent:mainAxisExtent,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 5,
                  ),
                  itemCount: _stockList.length,
                  itemBuilder: (context, int index) {
                    ItemStock item = _stockList[index];
                    String sStoreName = item.sStoreName;
                    if(sStoreName=="(주)한국다까미야") {
                      sStoreName = "본사";
                    }
                    return Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          Text("$sStoreName:", style: ItemG1N12,),
                          const Spacer(),
                          Text(numberFormat(item.rStoreStock), style: ItemBkB12,),
                          const SizedBox(width: 5,)
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ));
  }

  Widget _infoMoveLog() {
    int crossAxisCount = 1;
    double mainAxisExtent = 200;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 2;
      mainAxisExtent = 32;
    } else if(rt<1.55) {
      crossAxisCount = 2;
      mainAxisExtent = 32;
    } else if(rt<2.42) {
      crossAxisCount = 1;
      mainAxisExtent = 32;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 32;
    }

    return Visibility(
        visible: _moveLogList.isNotEmpty,
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text("이동재고 현황 ($_moveDataSum)", style: ItemBkB15,),
                      const Spacer(),
                      Text(_storeName, style: ItemBkB15,),
                    ],
                  ),
              ),

               //${numberFormat(_totalStock)}
              const Divider(height: 5, color: Colors.grey,),

              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent:mainAxisExtent,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 0,
                  ),
                  itemCount: _moveLogList.length,
                  itemBuilder: (context, int index) {
                    ItemStockMove item = _moveLogList[index];
                    String sStoreName = item.sTargetStoreName;
                    if(sStoreName=="(주)한국다까미야") {
                      sStoreName = "본사";
                    }

                    String baseStore = _session.Stroe!.sName;
                    if(baseStore=="(주)한국다까미야") {
                      baseStore = "본사";
                    }

                    String sDesc = "$baseStore->$sStoreName";
                    if(baseStore==sStoreName) {
                      sDesc = baseStore;
                    }

                    String sDate = DateForm.getYMonthDay(item.sRegDate);
                    return Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.clear, color: Colors.red, size: 18),
                                onPressed: () async {
                                  showYesNoDialogBox(
                                    height: 220,
                                      context: context,
                                      title: "확인",
                                      message: "미승인 재고이동 데이터를 삭제할까요?",
                                      onResult: (bOk){
                                        if(bOk) {
                                          _reqDelStockMove(item);
                                        }
                                      });
                                },
                              )
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(sDesc,
                              style: ItemG1N12,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            //width: 120,
                            child: Text(item.sMemo,
                              style: ItemBkN12,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          //const Spacer(),
                          SizedBox(
                            width: 20,
                            child: Text(numberFormat(item.rMoveStock),
                              style: ItemBkB12,
                              maxLines: 1,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 70,
                            child: Text(sDate,
                              style: ItemG1N12,
                              maxLines: 1,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ));
  }

  Widget _itemMoveStore(bool isBaseStock, final ItemMoveStock item) {
    if(item.stock==null) {
      return Container();
    }
    String sStoreName = item.stock!.sStoreName;
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                  width: 100,
                  child: Text(
                    sStoreName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ItemBkN14,
                  )
              ),

              Expanded(
                flex: 1,
                child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 1),
                          color: (isBaseStock) ? Colors.red : Colors.grey,
                          child: IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: () {
                              if(isBaseStock) {
                                String value = item.value.trim();
                                value = value.replaceAll(" ", "");
                                value = value.replaceAll("-", "");
                                value = value.replaceAll("+", "");
                                value = value.replaceAll(".", "");
                                if (value.isNotEmpty && value != "0") {
                                  item.valueController!.text = "-$value";
                                } else {
                                  item.valueController!.text = "";
                                }
                                item.value = item.valueController!.text;
                              }
                            },
                          ),
                        ),

                        SizedBox(
                            width: 60,
                            child: InputFormTouchClear(
                                //selectAll: true,
                                readOnly: false,
                                disable: false,
                                clearLock: item.clearLock,
                                onControl: (controller) {
                                  item.valueController = controller;
                                },
                                contentPadding: const EdgeInsets.all(5),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                valueText: item.value,
                                textStyle: ItemBkB15,
                                hintStyle: ItemG1N15,
                                hintText: '',
                                onChange: (String value) {
                                  item.value = value.trim();
                                  // item.controller!.text = item.value;
                                  if (kDebugMode) {
                                    print("onChange():item.value:${item.value}");
                                  }
                                }
                            )
                        ),

                        Container(
                          margin: const EdgeInsets.only(left: 1),
                          color: Colors.blue,
                          child: IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              String value = item.value.trim();
                              value = value.replaceAll(" ", "");
                              value = value.replaceAll("-", "");
                              value = value.replaceAll("+", "");
                              value = value.replaceAll(".", "");
                              if(value.isNotEmpty && value != "0") {
                                item.valueController!.text = "+$value";
                              } else {
                                item.valueController!.text = "";
                              }
                              item.value = item.valueController!.text;
                            },
                          ),
                        ),

                        //const SizedBox(width: 10,),
                        const Spacer(),
                        Visibility(
                            visible: !isBaseStock,
                            child: SizedBox(
                                width: 52, height: 30,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    if (!item.isMyStore) {
                                      setState(() {
                                        _moveStockList.remove(item);
                                        _updateMoveStock();
                                      });
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(width: 1.0, color: Colors.red),
                                  ),
                                  child: const Text("삭제",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 10),
                                  ),
                                ))
                        )
                      ],
                    )
                ),
              ),
              //const SizedBox(width: 120,),
            ],
          ),
          const SizedBox(height: 10,),
          Row(
            children: [
              const SizedBox(width: 100,),
              SizedBox(
                  width: 180,
                  child: InputFormTouchClear(
                      selectAll: true,
                      readOnly: false,
                      disable: false,
                      clearLock: true,
                      onControl: (controller) {
                        item.memoController = controller;
                      },
                      contentPadding: const EdgeInsets.fromLTRB(10,10,10,10),
                      textAlign: TextAlign.justify,
                      keyboardType: TextInputType.text,
                      valueText: item.memo,
                      textStyle: ItemBkN14,
                      hintStyle: ItemG1N14,
                      hintText: '요청사유',
                      onChange: (String value) {
                        item.memo = value.trim();
                        // item.memoController!.text = item.memo;
                        if (kDebugMode) {
                          print("onChange():item.memo:${item.memo}");
                        }
                      }
                  )
              ),
            ],
          ),
          const Divider(height: 10,),
        ],
      ),
    );
  }

  Widget _itemRow(int maxLines, String label, String value, bool bHilite) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
            width: 52,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                letterSpacing: -1.0,
                height: 1.5,
                color: Colors.grey,
              ),
            )
        ),
        Expanded(
          child: Text(value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: (bHilite) ? FontWeight.bold : FontWeight.normal,
              letterSpacing: -1.6,
              height: 1.5,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void _buildMoveMenu(String storeName, bool isMyStore) {
    for (var stock in _stockList) {
      if (stock.sStoreName == storeName) {
        _moveStockList.add(
            ItemMoveStock(stock: stock, value: "", isMyStore: isMyStore));
      }
    }
  }

  void _setBaseStore() {
    // print("_setBaseStore($_storeName):");
    // print(_stockList.toString());
    _baseStockList = [];
    for (var stock in _stockList) {
      if (stock.sStoreName == _storeName) {
        _baseStockList.add(ItemMoveStock(
          stock: stock,
          value: "",
          memo: "재고증감",
          isMyStore: true
        ));
        break;
      }
    }
  }

  void _updateMoveStock() {
    _stockMenu = [];
    for (var element in _stockList) {
      if(element.sStoreName != _storeName) {
        _stockMenu.add(element);
      }
    }
    //_stockMenu.addAll(_stockList);
    for (var stock in _stockList) {
      for (var moveStock in _moveStockList) {
        if (moveStock.stock!.sStoreName == stock.sStoreName) {
          _stockMenu.remove(stock);
          break;
        }
      }
    }
  }

  void _updateMoveDataSum() {
    _moveDataSum = 0;
    for (var element in _moveLogList) {
      if(element.lTargetStoreId != _session.lStoreID) {
        _moveDataSum -= element.rMoveStock;
      }
      else
      {
        _moveDataSum += element.rMoveStock;
      }
    }
  }

  Future <void> _reqAddMoveStock()  async {
    int totalHomeQty = _moveDataSum + _info.rStoreStock;
    List<Map<String,dynamic>> request = [];
    for (var element in _moveStockList) {
      String moveValue = element.value.replaceAll("+", "");
      if(moveValue.isNotEmpty) {
        int qty = int.parse(element.value);
        if(!element.isMyStore) {
          totalHomeQty = totalHomeQty - qty;
          if(totalHomeQty<0) {
            showToastMessage("재고 수량이 부족합니다.");
            return;
          }
        }
        if(qty != 0) {
          request.add(
          {
              "targetStoreId": element.stock!.lStoreID,
              "rMoveStock": moveValue,
              "sMemo": element.memo,//"재고이동"
          });
        }
      }
    }

    if(request.isEmpty) {
      showToastMessage("이동할 데이터가 없습니다.");
      return;
    }

    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/moveStock",
        params: {
          "lGoodsId": _lGoodsId,
          "mOrderPrice":_info.mSalesPrice,
          "lBeforeStock":_info.rStoreStock,
          "Requests": request
        },
        onError: (String error) {},
        onResult: (dynamic data) {
          if (data['status'] == "success") {
            setState(() {
              _moveStockList = [];
            });
            _updateMoveStock();
            _reqListStockMoveLog();
            showToastMessage("처리 되었습니다.");
          }
        },
    );
    _showProgress(false);
  }

  Future <void> _reqAddUpdateStock()  async {
    List<Map<String,dynamic>> request = [];

    String moveValue = _baseStockList[0].value.replaceAll("+", "");
    if(moveValue.isNotEmpty) {
      int qty = int.parse(moveValue);
      if(qty != 0) {
        int currentStock = _moveDataSum + _totalStock;
        if(currentStock+qty >= 0) {
          request.add(
              {
                "targetStoreId": _baseStockList[0].stock!.lStoreID,
                "rMoveStock": _baseStockList[0].value,
                "sMemo": _baseStockList[0].memo
              });
        }
      }
    }

    if(request.isEmpty) {
      showToastMessage("재고 수량이 부족합니다.");
      return;
    }

    if(_baseStockList[0].valueController != null) {
      _baseStockList[0].valueController!.text = "";
    }
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/moveStock",
        params: {
          "lGoodsId": _lGoodsId,
          "mOrderPrice":_info.mSalesPrice,
          "lBeforeStock":_info.rStoreStock,
          "Requests": request
        },
        onError: (String error) {},
        onResult: (dynamic data) {
          _showProgress(false);
          if (data['status'] == "success") {
            _baseStockList[0].value = "";
            _updateMoveStock();
            _reqListStockMoveLog();
            showToastMessage("처리 되었습니다.");
            //Navigator.pop(context);
          }
        },
    );
    _showProgress(false);
  }

  Future <void> _reqDelStockMove(ItemStockMove item) async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/deleteStockMoveLog",
        params: {
          "lStockMoveLogId": item.lStockMoveLogId,
        },
        onError: (String error) {},
        onResult: (dynamic data) async {
          if (data['status'] == "success") {
            showToastMessage("처리되었습니다.");
            await _reqListStockMoveLog();
          } else {
            showToastMessage(data['message']);
          }
        },
    );
    _showProgress(false);
  }

  Future <void> _reqInfoGoods()  async {
    _showProgress(true);
    /*
    { "lGoodsId": "147227", "lStoreId": "1" }
     */
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/goodsInfo",
        params: {"lGoodsId": _lGoodsId},
        onError: (String error) {},
        onResult: (dynamic data) {
          if (data['data'][0] != null) {
            var content = data['data'][0];
            _info = InfoGoods.fromJson(content);
            _info.computeSalesPrice();
            _photoList = _info.getPictInfoAddUrl(false);
          }
        },
    );
    _showProgress(false);
  }

  Future <void> _reqInfoGoodsStock() async {
    _baseStockList = [];
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/goodsStockInfo",
        params: {"lGoodsId": _lGoodsId},
        onError: (String error) {},
        onResult: (dynamic data) {
          if (data['data'] != null) {
            var content = data['data'];
            _stockList = ItemStock.fromSnapshot(content);
            _totalStock = 0;
            for (var element in _stockList) {
              _totalStock = _totalStock + element.rStoreStock;
            }
            _setBaseStore();
            _updateMoveStock();
            setState(() {});
          }
        },
    );
    _showProgress(false);
  }

  Future <void> _reqListStockMoveLog() async {
    _moveLogList = [];
    _moveDataSum  = 0;
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/listDisallowStockGoods",
        params: {
          "lGoodsId": _lGoodsId,
        },

        onResult: (dynamic data) {
          _showProgress(false);

          if (data['status'] == "success") {
            if (data['data'] != null) {
              var content = data['data'];
              _moveLogList = ItemStockMove.fromSnapshot(content);
              _updateMoveDataSum();
            }
          }
        },
        onError: (String error) {
          _showProgress(false);
        });
  }

  Future<void> _onScan(String barcode) async {
    //print("barcode=$barcode");
    List<ItemGoodsList> goodsList = await _reqGoodsListByBarcode(barcode);
    if(goodsList.isNotEmpty) {
      if(goodsList.length == 1) {
        int index = 0;
        if(_lGoodsId != goodsList[index].lGoodsId!) {
          _lGoodsId = goodsList[index].lGoodsId!;
          _stockList = [];
          _stockMenu = [];
          _moveStockList = [];
          Future.microtask(() async {
            await _reqInfoGoods();
            await _reqInfoGoodsStock();
            await _reqListStockMoveLog();
          });
        }
      } else {
        List<SelectItem> items = [];
        for (var element in goodsList) {
          items.add(SelectItem(
              sName: element.sGoodsName!, lGoodsId: element.lGoodsId, sBarcode: element.sBarcode!));
        }
        showItemsSelect(context: context, items: items,
            onResult: (bool bOk, int index) {
              if (bOk && (_lGoodsId != goodsList[index].lGoodsId!)) {
                  _lGoodsId = goodsList[index].lGoodsId!;
                  Future.microtask(() async {
                    await _reqInfoGoods();
                    await _reqInfoGoodsStock();
                    await _reqListStockMoveLog();
                  });
                }
            }
        );
      }
    }
  }

  Future<List<ItemGoodsList>> _reqGoodsListByBarcode(String barcode) async {
    List<ItemGoodsList> list = [];
    _showProgress(true);
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
