// ignore_for_file: non_constant_identifier_names

import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/cardTabbar.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/kItemGoodsCategory.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/goodsDetail.dart';
import 'package:distribution/home/goods/selectGoods.dart';
import 'package:distribution/home/stock/popGoodsScaned.dart';
import 'package:distribution/home/stock/popGoodsSelect.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/models/kItemStockGoodsInfo.dart';
import 'package:distribution/models/kItemStockMissGoods.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class WorkMissScanGoods extends StatefulWidget {
  final String workDay;
  const WorkMissScanGoods({
    Key? key,
    required this.workDay,
  }) : super(key: key);

  @override
  State<WorkMissScanGoods> createState() => _WorkMissScanGoodsState();
}

class _WorkMissScanGoodsState extends State<WorkMissScanGoods> {
  List<ItemStockMissGoods> _goodsList = [];
  List<ItemGoodsCategory> _goodCategory = [
    ItemGoodsCategory(sName: "전체", sCode: "00")
  ];

  late AutoScrollController _controller;

  String title = "";
  bool _hasMore = true;
  final int lRowPerPage = 50;

  int lPageNo = 1;
  int totalMissGoods = 0;
  bool bIsOpenedSearchBar = false;

  String _category = "";
  String _sBarcode = "";
  String _sKeyword = "";
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _controller = AutoScrollController();
    Future.microtask(() async {
      await _reqGoodCategory();
      lPageNo = 1;
      _sBarcode = "";
      _sKeyword = "";
      await _reqGoodList();
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
        title: const Text("재고실사-누락상품"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              Navigator.pop(context, false);
            }),
        actions: [

          Visibility(
            visible: true,
            child: IconButton(
                icon: Icon(
                  (bIsOpenedSearchBar) ? Icons.search_off : Icons.search,
                  size: 32,
                ),
                onPressed: () {
                  _doSelectGoods();
                }
            ),
          ),
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 32,
                ),
                onPressed: () {
                  //lPageNo = 1;
                  _sKeyword = "";
                  _sBarcode = "";
                  _reqGoodList();
                }
            ),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-WorkMissScanGoods-key',
        validateMessage: "상품의 바코드를 스캔하세요.",
        waiting: false,
        onWillPop: onWillPop,
        allowPop: false, //_isComplete,
        useCamera: false,
        validate: _checkValidate,
        onScan: (barcode) {
          //onScaned(barcode);
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
                          padding: (_hasMore)
                              ? const EdgeInsets.only(bottom: 57)
                              : const EdgeInsets.only(bottom: 0),
                          child: Column(
                              children: [
                                /*
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
                                */
                                // 카테고리
                                Container(
                                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                    color:Colors.white,
                                    child:CardTabbar(
                                      items: _goodCategory,//widget.category,
                                      onChange: (item) {
                                        _category = item.sCode;
                                        lPageNo = 1;
                                        _sKeyword = "";
                                        _sBarcode = "";
                                        _reqGoodList();
                                      },
                                    )
                                ),

                                // 검색결과
                                Container(
                                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Text(_session.Stroe!.sName,
                                      //     style: ItemBkB18),
                                      const Spacer(),
                                      const Text("상품수 :  ", style: ItemG1N12),
                                      Text("${_goodsList.length} / $totalMissGoods",
                                          style: ItemBkB14),
                                    ],
                                  ),
                                ),

                                const Divider(
                                  height: 1,
                                  color: Colors.black,
                                ),

                                Expanded(child: _renderGoodsList()),
                          ])
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white,
                        child: ButtonSingle(
                          text: '더보기',
                          isBottomPading: true,
                          isBottomSide: true,
                          enable: true,
                          visible: _hasMore,
                          onClick: () async {
                            lPageNo++;
                            _reqGoodList();
                          },
                        ),
                      ),
                    ),

                    Positioned(
                        child: Visibility(
                            visible: _bWaiting,
                            child: Container(
                              color: const Color(0x1f000000),
                              child: const Center(child: CircularProgressIndicator()),
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

  Widget _renderGoodsList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 200;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 2;
      mainAxisExtent = 74;
    } else if(rt<1.55) {
      crossAxisCount = 2;
      mainAxisExtent = 74;
    } else if(rt<2.42) {
      crossAxisCount = 1;
      mainAxisExtent = 78;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 78;
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

  Widget _ItemInfo(int index, ItemStockMissGoods item) {
    String desc = "${item.rNowStock}";
    if(item.sLotNo.isNotEmpty) {
      desc += " / ${item.sLotNo}";
    }
    if(item.sLotMemo.isNotEmpty) {
      desc += " (${item.sLotMemo})";
    }
    return GestureDetector(
        onTap: () async {
          FocusScope.of(context).unfocus();
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
              color: (item.hasFocus) ? Colors.red : Colors.grey,
            ),
            color: Colors.white,
          ),
          child: Stack(
            children: [
              Positioned(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5,5,5,5),
                  child:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        _itemRow(1, "바  코  드:", item.sBarcode, false),
                        _itemRow(1, "상품이름:", item.sName, false),
                        _itemRow(1, "재고/위치:", desc, true),
                        const Spacer(),
                      ]),
                ),
              ),
              Positioned(
                  top: 2,right: 2, left:0,
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
                                      heightRate: 0.8,
                                      context: context,
                                      lGoodsId: item.lGoodsId);
                                },
                                padding: EdgeInsets.zero,
                                constraints:const BoxConstraints(),
                                icon: const Icon(Icons.info_outline, color: Colors.black, size:18)
                            ),
                            const SizedBox(width: 8,),
                            IconButton(
                                onPressed: (){
                                  onScaned(item.sBarcode, item.lGoodsId);
                                },
                                padding: EdgeInsets.zero, // 패딩 설정
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.edit, size:16, color: Colors.black,)
                            ),
                            const SizedBox(width: 8,),
                            IconButton(
                                onPressed: (){
                                  showYesNoDialogBox(
                                      context: context,
                                      height: 220,
                                      title: "확인",
                                      message: "미스캔 상품에서 제외하시겠습니까 ?",
                                      onResult: (bOk){
                                        if(bOk) {
                                          _reqUpdateMissingGoods(item);
                                        }
                                      }
                                  );
                                },
                                padding: EdgeInsets.zero, // 패딩 설정
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.close, size:22, color: Colors.red,)
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

  bool _checkValidate(String barcode) {
    return true;
  }

  Future<bool> onWillPop() async {
    return true;
  }

  Future <void> _doSelectGoods() async {
    setState((){
      bIsOpenedSearchBar = true;
    });


    showPopGoodsSelect(
        context: context,
        isMulti:false,
        onResult: (bool bOK, List<ItemGoodsList>? result) async {
          setState((){
            bIsOpenedSearchBar = false;
          });

          if(!bOK) {
            return;
          }

          ItemGoodsList goods =  result![0];
          _category = "";
          _sKeyword = "";
          lPageNo = 1;
          _sBarcode = goods.sBarcode!;
          await _reqGoodList();
          if(_goodsList.isEmpty) {
            showToastMessage("해당 상품은 실사누락 상품이 아닙니다.");
          }
        }
    );
  }

  Future<void> onScaned(String barcode, int lGoodsId) async {
    if(lGoodsId<1) {
      _clearFocus();
    }

    if(barcode.length<10) {
      showToastMessage("상품 바코드를 스캔하세요");
      return;
    }

    List<ItemStockGoodsInfo> items = await _reqGoodInfo(barcode);
    if(items.isEmpty) {
      showToastMessage("해당 상품이 존재하지 않습니다.");
      return;
    }

    int goodIndex = -1;
    // 편집모드
    if(lGoodsId > 0) {
      if(items.length==1) {
        goodIndex = 0;
      }
      else {
        goodIndex = items.indexWhere((element){
          return element.lGoodsId==lGoodsId;
        });
      }

      if(goodIndex >= 0) {
        await showBottomScaned(
          context: context,
          isScanned: true,
          isManager: false,
          sLot1: "",
          sLot2: "",
          sLot3: "",
          info: items[goodIndex],
          onResult: (bool bDirty, String sLot3) {
            if(bDirty) {
              _reqGoodList();
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
              if (bDirty) {
                int findIndex = _goodsList.indexWhere((element){
                  return element.lGoodsId==item.lGoodsId;
                });
                if(findIndex>=0) {
                  _controller.scrollToIndex(findIndex);
                  _goodsList[findIndex].hasFocus = true;
                  setState(() {});
                } else {
                  showToastMessage("해당 상품이 없습니다.");
                }
              }
            }
        );
      }
      else {
        int findIndex = _goodsList.indexWhere((element){
          return element.lGoodsId==items[0].lGoodsId;
        });

        if(findIndex>=0) {
          _controller.scrollToIndex(findIndex);
          _goodsList[findIndex].hasFocus = true;
          setState(() {});
        } else {
          showToastMessage("해당 상품이 없습니다.");
        }
      }
    }
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

  /*
  // 실사 상품 조회
  Future<List <ItemStockMissGoods>> _reqSelectGoods(int lGoodsId) async {
    List <ItemStockMissGoods> items = [];
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/listInspectMissGoods",
        params: {"lGoodId":lGoodsId},
        onError: (String error) {},
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            var content = response['data'];
            if (content != null) {
              items = ItemStockMissGoods.fromSnapshot(content);
            }
          }
        },
    );
    _showProgress(false);
    return items;
  }
  */

  // 실사 데이터 조회
  Future<void> _reqGoodList() async {
    _showProgress(true);
    Map<String, dynamic> param = {
      "lPageNo": lPageNo,
      "lRowNo": lRowPerPage,
      "category":_category,
    };

    if(_sBarcode.isNotEmpty) {
      lPageNo = 1;
      param.addAll({"sBarcode":_sBarcode,});
    }
    if(_sKeyword.isNotEmpty) {
      lPageNo = 1;
      param.addAll({"sKeyword":_sKeyword,});
    }

    if(lPageNo==1) {
      _hasMore = true;
      _goodsList = [];
    }
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/listInspectMissGoods",
        params: param,
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            if(lPageNo==1 && response['totalCount'] != null) {
              totalMissGoods = int.parse(response['totalCount'].toString().trim());
            }
            var content = response['data'];
            if (content != null) {
              List <ItemStockMissGoods> items = [];
              if (content is List) {
                items = ItemStockMissGoods.fromSnapshot(content);
              } else {
                items = ItemStockMissGoods.fromSnapshot([content]);
              }
              if(items.length<lRowPerPage) {
                _hasMore = false;
              }
              _goodsList.addAll(items);
            }
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

  Future<void> _reqUpdateMissingGoods(ItemStockMissGoods item) async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/updateMissingGoods",
        params: { "lGoodsId" : item.lGoodsId },
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            setState(() {
              totalMissGoods -= 1;
              _goodsList.remove(item);
              showToastMessage("처리되었습니다.");
            });
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

  Future <void> _reqGoodCategory() async {
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "point/listCategory",
        params: {
          //"lPageNo": "1",  "lRowNo" : "4"
        },
        onResult: (dynamic data) {

          if (data['status'] == "success") {
            _goodCategory = ItemGoodsCategory.fromSnapshot(data['data']);
            _goodCategory.insert(0, ItemGoodsCategory(sName: "전체", sCode: ""));
            setState(() {

            });
          }
        },
        onError: (String error) {},
    );
  }

}
