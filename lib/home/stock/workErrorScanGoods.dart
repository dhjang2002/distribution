// ignore_for_file: non_constant_identifier_names, file_names
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

class WorkErrorScanGoods extends StatefulWidget {
  final String workDay;
  const WorkErrorScanGoods({
      Key? key,
    required this.workDay,
  }) : super(key: key);

  @override
  State<WorkErrorScanGoods> createState() => _WorkErrorScanGoodsState();
}

class _WorkErrorScanGoodsState extends State<WorkErrorScanGoods> {
  List<ItemStockGoods> _stockgoodsList = [];

  late AutoScrollController _controller;

  String title = "";
  final bool _bShowAddView = false;
  String _selectFilter = "전체";
  final List<String> _filterList = <String>[
    "전체",
    "확인 내역",
    "미확인 내역",
  ];

  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _controller = AutoScrollController();
    Future.microtask(() {
      _reqStockGoodsList();
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
        title: const Text("재고실사-오차확인"),
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
                  _reqStockGoodsList();
                }),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-WorkErrorScanGoods-key',
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
                      child: Column(
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
                                  }
                                  else {
                                    showToastMessage("5자 이상 입력하세요.");
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
                                  Text(_session.Stroe!.sName, style: ItemBkN15),
                                  const Spacer(),
                                  const Text("상품수: ", style: ItemG1N14),
                                  Text("${_stockgoodsList.length} ",
                                      style: ItemBkB14),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _showColorInfo(),
                                Spacer(),
                                DropdownButton(
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal),
                                  dropdownColor: Colors.white,
                                  value: _selectFilter,
                                  items: _filterList.map((String value) {
                                    return DropdownMenuItem<String>(
                                        value: value, child: Text(value));
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      if (_selectFilter != value) {
                                        _selectFilter = value!;
                                        _reqStockGoodsList();
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),

                            Expanded(child: _renderPickList()),
                          ]
                      ),
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

  Widget _showColorInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: [
          const Text("확인필요: ", style: ItemBkN12,),
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

          const SizedBox(width: 15,),
          const Text("관리자 확인: ", style: ItemBkN12,),
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
    double mainAxisExtent = 120;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 2;
      mainAxisExtent = 94;
    } else if(rt<1.55) {
      crossAxisCount = 2;
      mainAxisExtent = 94;
    } else if(rt<2.42) {
      crossAxisCount = 1;
      mainAxisExtent = 94;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 94;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _stockgoodsList.length%crossAxisCount;
    if(diff>0) {
      dumyCount = crossAxisCount + crossAxisCount - diff;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: GridView.builder(
          controller: _controller,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent:mainAxisExtent,
            mainAxisSpacing: 0,
            crossAxisSpacing: 1,
          ),
          itemCount: _stockgoodsList.length+dumyCount,
          itemBuilder: (context, int index) {
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index<_stockgoodsList.length)
                    ? _ItemInfo(index, _stockgoodsList[index]) : Container()
            );
            //return _boxItem(index, _goodsList[index]);
          }),
    );
  }

  Widget _ItemInfo(int index, ItemStockGoods item) {
    String sLots = "${item.sLot1}-${item.sLot2}-${item.sLot3}";
    if(item.sMemo.isNotEmpty) {
      sLots += ", ${item.sMemo}";
    }

    //Color? backgroundColor = Colors.white;
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              width: 2,
              color: hiliteColor,
            ),
            color: (item.sIsErrorConfirm==1) ? STD_READY: STD_ING
          ),
          child: Stack(
            children: [
              Positioned(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5,5,5,5),
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
                  ),
                ),
              ),

              Positioned(
                  top: 0,right: 5, left:0,
                  child: Visibility(
                      visible: item.hasFocus,
                      child:Container(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            const Spacer(),
                            IconButton(
                                onPressed: (){
                                  showPopGoodsDetail(
                                      context: context,
                                      heightRate: 0.8,
                                      lGoodsId: item.lGoodsId);
                                },
                                padding: EdgeInsets.zero,
                                constraints:const BoxConstraints(),
                                icon: const Icon(Icons.info_outline, color: Colors.black, size:18)
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                                onPressed: (){
                                  onScaned(item.sBarcode, item.lGoodsId);
                                },
                                padding: EdgeInsets.zero, // 패딩 설정
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.edit, size:16, color: Colors.black,)
                            ),
                          ],
                        ),
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
                letterSpacing: -1.5,
                height: 1.2,
                color: Colors.black,
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
    for (var element in _stockgoodsList) {
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
    if(_bShowPop) {
      return;
    }

    _clearFocus();

    _bShowPop = true;
    if(barcode.length<5) {
      showToastMessage("상품 바코드를 스캔하세요");
      _bShowPop = false;
      return;
    }

    List<ItemStockGoodsInfo> items = await _reqGoodInfo(barcode);
    if(items.isEmpty) {
      showToastMessage("해당 상품이 존재하지 않습니다.");
      _bShowPop = false;
      return;
    }

    int inx = -1;
    if(lGoodsId != 0) {
      if(items.length==1) {
        inx = 0;
      }
      else {
        inx = items.indexWhere((element){
          return element.lGoodsId==lGoodsId;
        });
      }

      if(inx >= 0) {
        ItemStockGoodsInfo info = items[inx];
        await showBottomScaned(
          context: context,
          isScanned: true,
          isManager: true,
          sLot1: "",
          sLot2: "",
          sLot3: "",
          info: info,
          onResult: (bool bDirty, String sLot3) async {
            _bShowPop = false;
            if(bDirty) {
              await _reqStockGoodsList();
            } else {
              _clearFocus();
            }

            int index = _stockgoodsList.indexWhere((element){
              return element.lGoodsId==info.lGoodsId;
            });

            await _controller.scrollToIndex(index,
                duration: const Duration(microseconds: 100),
                preferPosition: AutoScrollPosition.begin);

            if(index>=0) {
              setState(() {
                _stockgoodsList[index].hasFocus = true;
              });
            }

          },
        );
      }
    }
    // 스캔모드
    else
    {
      if(items.length>1) {
        showGoodsSelect(
            context: context,
            title: '상품선택:$barcode',
            items: items,
            onResult: (bool bDirty, ItemStockGoodsInfo item) async {
              _bShowPop = false;
              if (bDirty) {
                int findIndex = _stockgoodsList.indexWhere((element){
                  return element.lGoodsId==item.lGoodsId;
                });
                if(findIndex>=0) {
                  _controller.scrollToIndex(findIndex);
                  _stockgoodsList[findIndex].hasFocus = true;
                  setState(() {});
                } else {
                  showToastMessage("해당 상품이 없습니다.");
                }
              }
            }
        );
      }
      else {
        int findIndex = _stockgoodsList.indexWhere((element){
          return element.lGoodsId==items[0].lGoodsId;
        });

        if(findIndex>=0) {
          _controller.scrollToIndex(findIndex);
          _stockgoodsList[findIndex].hasFocus = true;
          setState(() {});
        } else {
          showToastMessage("해당 상품이 없습니다.");
        }
      }
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
        onError: (String error) {
          _showProgress(false);
        }
    );
    _showProgress(false);
    return items;
  }

  // 실사 데이터 조회
  Future <void> _reqStockGoodsList() async {
    String target = "all"; // "all","error","confirm"
    if(_selectFilter == "전체") {
      target = "all";
    } else if(_selectFilter == "확인 내역") {
      target = "confirm";
    } else {
      target = "error";
    }

    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/listInspectErrorGoods",
        params: {"target":target},
        onError: (String error) {},
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            var content = response['data'];
            if (content != null) {
              if (content is List) {
                _stockgoodsList = ItemStockGoods.fromSnapshot(content);
              } else {
                _stockgoodsList = ItemStockGoods.fromSnapshot([content]);
              }
            }
          }
        },
    );
    _showProgress(false);
  }
}
