// ignore_for_file: non_constant_identifier_names

import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/searchForm.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/goodsDetail.dart';
import 'package:distribution/home/stock/popGoodsScaned.dart';
import 'package:distribution/home/stock/popGoodsSelect.dart';
import 'package:distribution/models/kItemStockGoods.dart';
import 'package:distribution/models/kItemStockGoodsInfo.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class WorkBasicScanGoods extends StatefulWidget {
  final String sLot1;
  final String sLot2;
  const WorkBasicScanGoods({
      Key? key,
    required this.sLot1,
    required this.sLot2,
  }) : super(key: key);

  @override
  State<WorkBasicScanGoods> createState() => _WorkBasicScanGoodsState();
}

class _WorkBasicScanGoodsState extends State<WorkBasicScanGoods> {
  List<ItemStockGoods> _goodsList = [];

  late AutoScrollController _controller;

  String title = "";
  final bool _bShowAddView = false;

  String _lastsLot3 = "01";
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _controller = AutoScrollController();
    Future.microtask(() {
      _reqGoodList();
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
        title: const Text("재고실사"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              if(_bShowAddView) {
                showToastMessage("현재 작업을 완료하세요.");
                return;
              }
              Navigator.pop(context, false);
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
                  _bShowPop = false;
                  if(_bShowAddView) {
                    showToastMessage("현재 작업을 완료하세요.");
                    return;
                  }
                  _reqGoodList();
                }),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-WorkScanGoods-key',
        validateMessage: "상품의 바코드를 스캔하세요.",
        waiting: false,
        onWillPop: onWillPop,
        allowPop: false,//_isComplete,
        useCamera: !_bShowAddView,
        validate: _checkValidate,
        onScan: (barcode) {
          onScaned(barcode, 0);
        },

        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      child:
                      Column(
                          children: [
                            // 바코드 입력 검색 창
                            Container(
                              padding:const EdgeInsets.fromLTRB(5, 5, 5, 10),
                              child: SearchForm(
                                readOnly: false,
                                keyboardType:TextInputType.number,
                                valueText: "",
                                suffixIcon: const Icon(
                                  Icons.search_outlined,
                                  color: Colors.grey,
                                  size: 28,
                                ),
                                prefixIcon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                  size: 26,
                                ),
                                hintText: '상품 바코드',
                                onCreated: (controller) {},
                                onSummit: (String value) {
                                  String barcode = value.trim();
                                  if(barcode.length>4) {
                                    onScaned(barcode, 0);
                                  } else {
                                    showToastMessage("5자 이상 입력해주세요.");
                                  }
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("타나번호: ${widget.sLot1}-${widget.sLot2}", style: ItemBkB18),
                                  const Spacer(),
                                  const Text("상품수: ", style: ItemG1N14),
                                  Text("${_goodsList.length} ",
                                      style: ItemBkB14),
                                ],
                              ),
                            ),

                            Expanded(child: _renderPickList()),
                          ]
                      )
                    ),
                    Positioned(
                        child: Visibility(
                            visible: _bWaiting,
                            child: Container(
                              color: const Color(0x1f000000),
                              child: const Center(child: CircularProgressIndicator()),
                            )))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderPickList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 120;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 2;
      mainAxisExtent = 90;
    } else if(rt<1.55) {
      crossAxisCount = 2;
      mainAxisExtent = 90;
    } else if(rt<2.42) {
      crossAxisCount = 1;
      mainAxisExtent = 90;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 120;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _goodsList.length%crossAxisCount;
    if(diff>0) {
      dumyCount = crossAxisCount + crossAxisCount - diff;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: GridView.builder(
          controller: _controller,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            //childAspectRatio: childAspectRatio,
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: 0,
            crossAxisSpacing: 1,
          ),
          itemCount: _goodsList.length+dumyCount,
          itemBuilder: (context, int index) {
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index<_goodsList.length)
                    ? _ItemInfo(index, _goodsList[index]) : Container()
            );
            //return _boxItem(index, _goodsList[index]);
          }),
    );
  }

  Widget _ItemInfo(int index, ItemStockGoods item) {
    String sLots = "${item.sLot1}-${item.sLot2}-${item.sLot3}";
    if(item.sMemo.isNotEmpty) {
      sLots += ", 위치메모: ${item.sMemo}";
    }
    Color? backgroundColor = Colors.white;
    String gapStock = item.rGapStock.toString();
    TextStyle gapStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      letterSpacing: -1.0, height: 1.2,
      color: Colors.black,
    );
    if(item.rGapStock<0) {
      //backgroundColor = Colors.red[50];
      gapStock = "( ${item.rGapStock} )";
      gapStyle = const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: -1.8,
        height: 1.2,
        color: Colors.red,
      );
    } else if(item.rGapStock>0) {
      gapStock = "( +${item.rGapStock} )";
      gapStyle = const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: -1.8,
        height: 1.2,
        color: Colors.blue,
      );
      //backgroundColor = Colors.blue[100];
    } else {
      gapStock = "";
    }
    Color hiliteColor = Colors.grey;
    if(item.isTarget) {
      hiliteColor = Colors.black;
    }
    if(item.hasFocus) {
      hiliteColor = Colors.pink;
    }
    return GestureDetector(
        onTap: () async {
          FocusScope.of(context).unfocus();
          if(_bShowAddView) {
            return;
          }
          _clearFocus();
          setState(() {
            item.hasFocus = true;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(0,1,0,0),
          padding: const EdgeInsets.fromLTRB(5,5,5,5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              width: 2,
              color: hiliteColor,
            ),
            color: backgroundColor,
          ),
          child: Stack(
            children: [
              Positioned(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  _itemRow(1, "바  코  드:", item.sBarcode, false),
                  _itemRow(1, "상품이름:", item.sGoodsName, false),
                  _itemRow(1, "상품위치:", sLots, true),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                          width: 50,
                          child: Text("상품재고:",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              letterSpacing: -1.5,
                              height: 1.1,
                              color: Colors.grey,
                            ),)
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Text(item.rVirtualStock.toString(),
                              style:const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1.8,
                                height: 1.2,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 5),
                            Text(gapStock,
                              style:gapStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              )),
              Positioned(
                  top: 0,right: 5, left:0,
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
                                      heightRate: 0.8,
                                      lGoodsId: item.lGoodsId);
                                },
                                padding: EdgeInsets.zero,
                                constraints:const BoxConstraints(),
                                icon: const Icon(Icons.info_outline,
                                    color: Colors.black, size:18)
                            ),
                            const SizedBox(width: 10),
                            // edit
                            IconButton(
                                onPressed: (){
                                  onScaned(item.sBarcode, item.lGoodsId);
                                },
                                padding: EdgeInsets.zero, // 패딩 설정
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.edit, size:16, color: Colors.black,)
                            ),
                            const SizedBox(width: 10),
                            // delete
                            IconButton(
                                onPressed: (){
                                  showYesNoDialogBox(
                                      context: context,
                                      height: 220,
                                      title: "확인",
                                      message: "재고실사 내역을 삭제하시겠습니까?",
                                      onResult: (bOk){
                                        if(bOk) {
                                          _reqRemove(item);
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
          ,
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
    for (var element in _goodsList) {
      element.hasFocus = false;
    }
  }

  // void _clearTarget() {
  //   for (var element in _goodsList) {
  //     element.isTarget = false;
  //   }
  // }

  bool _checkValidate(String barcode) {
    // int index = items.indexWhere((element) => element.sBarcode == barcode);
    // return (index >= 0);
    return true;
  }

  Future <bool> onWillPop() async {
    return true;
  }

  bool _bShowPop = false;
  Future<void> onScaned(String barcode, int lGoodsId) async {

    //print("******************* onScaned()::barcode=%barcode, lGoodsId=$lGoodsId");

    if(_bShowPop) {
      return;
    }

    _bShowPop = true;
    //barcode = "4969363038999";
    if(barcode.length<5) {
      showToastMessage("상품 바코드를 스캔하세요");
      _bShowPop = false;
      return;
    }

    List<ItemStockGoodsInfo> goodsList = await _reqGoodInfo(barcode);
    if(goodsList.isEmpty) {
      showToastMessage("해당 상품이 존재하지 않습니다.");
      _bShowPop = false;
      return;
    }

    int inx = -1;
    if(goodsList.length==1) {
      inx = 0;
    }
    else {
      inx = goodsList.indexWhere((element){
        return element.lGoodsId==lGoodsId;
      });
    }


    if(inx >=0 ) {
      ItemStockGoodsInfo info = goodsList[inx];
      await showBottomScaned(
        context: context,
        isScanned: true,
        isManager: false,
        sLot1: widget.sLot1,
        sLot2: widget.sLot2,
        sLot3: _lastsLot3,
        info: info,
        onResult: (bool bDirty, String lastsLot3) async {
          //print("--------------- bDirty:${bDirty}, inx=$inx");
          _bShowPop = false;
          _lastsLot3 = lastsLot3;
          if(bDirty) {
            await _reqGoodList();
          } else {
            _clearFocus();
          }

          int index = _goodsList.indexWhere((element){
            return element.lGoodsId==info.lGoodsId;
          });

          await _controller.scrollToIndex(index,
              duration: const Duration(microseconds: 100),
              preferPosition: AutoScrollPosition.begin);

          if(index>=0) {
            setState(() {
              _goodsList[index].hasFocus = true;
            });
          }
        },
      );
    }
    else
    {
        showGoodsSelect(
            context: context,
            title: '상품선택:$barcode',
            items: goodsList,
            onResult: (bool bDirty, ItemStockGoodsInfo item) async {
              _bShowPop = false;
              if (bDirty) {
                await showBottomScaned(
                  context: context,
                  isScanned: true,
                  isManager: false,
                  sLot1: widget.sLot1,
                  sLot2: widget.sLot2,
                  sLot3: _lastsLot3,
                  info: item,
                  onResult: (bool bDirty, String lastsLot3) async {
                    _lastsLot3 = lastsLot3;
                    if (bDirty) {
                      await _reqGoodList();
                      setState(() {
                        _goodsList[0].hasFocus = true;
                      });
                    }
                  },
                );
              }
            }
        );
    }
    _bShowPop = false;
  }

  // 바코드 스캔한 상품정보 조회
  Future <List<ItemStockGoodsInfo>> _reqGoodInfo(String sBarcode) async {
    List<ItemStockGoodsInfo> items = [];
    _showProgress(true);
    await Remote.apiPost(
      context: context,
      lStoreId: _session.getAccessStore(),
      session: _session,
      method: "taka/infoInspectGoods",
      params: {"sBarcode" : sBarcode},
      onError: (String error) {},
      onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            if(response['data']['goodsData'] != null) {
              if (kDebugMode) {
                var logger = Logger();
                logger.d(response);
              }
              int lStockInspectID = (response['data']['lStockInspectID'] != null)
                  ? int.parse(response['data']['lStockInspectID'].toString().trim()) : 0;
              items = ItemStockGoodsInfo.fromSnapshot(response['data']['goodsData']);
              for (var element in items) {
                if(element.lStockInspectID==0) {
                  element.lStockInspectID = lStockInspectID;
                }
              }
            }
          }
        },
    );
    _showProgress(false);
    return items;
  }

  // 실사 데이터 조회
  Future <void> _reqGoodList() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/listInspectLotsGoods",
        params: {"sLot1" : widget.sLot1, "sLot2": widget.sLot2},
        onError: (String error) {},
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            var content = response['data'];
            if (content != null) {
              if (content is List) {
                _goodsList = ItemStockGoods.fromSnapshot(content);
              } else {
                _goodsList = ItemStockGoods.fromSnapshot([content]);
              }
            }
          }
        },
    );
    _showProgress(false);
  }

  // 재고실사 데이터 삭제
  Future <void> _reqRemove(ItemStockGoods item) async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/deleteInspect",
        params: {"lStockInspectDetailID" : item.lStockInspectDetailID},
        onError: (String error) {},
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            setState(() {
              _goodsList.remove(item);
            });
          }
        },
    );
    _showProgress(false);
  }
}
