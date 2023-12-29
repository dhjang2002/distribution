// ignore_for_file: file_names

import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/searchForm.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/display/goodsDisplay.dart';
import 'package:distribution/home/goods/info/goodsDetail.dart';
import 'package:distribution/home/goods/price/priceDetail.dart';
import 'package:distribution/home/goods/price/showCompeteList.dart';
import 'package:distribution/home/move/moveStock.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class SearchGoods extends StatefulWidget {
  final String title;
  final String target;
  const SearchGoods({Key? key,
    required this.target,
    required this.title
  }) : super(key: key);

  @override
  State<SearchGoods> createState() => _SearchGoodsState();
}

class _SearchGoodsState extends State<SearchGoods> {
  bool _bEnableSearch = true;
  String _findValue = "";
  List<ItemGoodsList> _itemList = [];

  String _initKeyword = "";
  bool _bHasListCompetePrice = false;
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    if (_session.Setting?.UseTestMode=="YES") {
      setState(() {
        _initKeyword = "낚시대";
      });
    }

    Future.microtask(() {
      if(widget.target=="PRICE") {
        _reqCompetePrice();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isInAsyncCall = false;
  void _showProgress(bool bShow) {
    setState(() {
      _isInAsyncCall = bShow;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          // 검색
          Visibility(
            visible: true,
            child: IconButton(
                icon: (_bEnableSearch)
                    ? const Icon(
                        Icons.search_off,
                        size: 28,
                      )
                    : const Icon(
                        Icons.manage_search,
                        size: 28,
                      ),
                onPressed: () {
                  setState(() {
                    _bEnableSearch = !_bEnableSearch;
                  });
                }),
          ),
          Visibility(
            visible: (widget.target=="PRICE" && _bHasListCompetePrice),
            child: IconButton(
                icon: const Icon(
                  Icons.list_rounded,
                  size: 28,
                ),
                onPressed: () {
                  _showCompeteList();
                }),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-FindGoods-key',
        waiting: _isInAsyncCall,
        allowPop: true,
        useCamera: true,
        // validate: (String barcode) {
        //   return true;
        // },
        onScan: (barcode) async {
          await _reqGoodsListByBarcode(barcode);
        },

        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // 1. search bar
              Visibility(
                visible: _bEnableSearch,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: SearchForm(
                          readOnly: false,
                          valueText: _initKeyword,
                          suffixIcon: const Icon(
                            Icons.search_outlined,
                            color: Colors.black,
                            size: 28,
                          ),
                          hintText: '상품명 또는 상품바코드(취소 뒷 6자리)',
                          onCreated: (TextEditingController controller) {
                            //_findTextEditingController = controller;
                          },
                          onChange: (String value) {
                            _findValue = value;
                          },
                          onSummit: (String value) {
                            _findValue = value;
                            _reqGoodsListByKeyword(_findValue);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    // Guide message
                    Positioned(
                        child: Container(
                          height: double.infinity,
                          color: Colors.grey[100],
                          padding: const EdgeInsets.all(20),
                          child: const Center(
                            child: Text("상품명을 입력하거나 바코드를 스캔하세요.",
                              style: ItemBkN16,),
                          ),
                        )),

                    // goods list
                    Positioned(
                        child: Visibility(
                      visible: _itemList.isNotEmpty,
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(5,5,5,3),
                                child:Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                  const Text("검색결과", style: ItemBkN16,),
                                  Text(" (${_itemList.length})", style: ItemBkB14,)
                                ],)),
                            const Divider(height: 10, color: Colors.black,),
                            Expanded(
                                child: CustomScrollView(
                              slivers: [
                                _renderGoodList(),
                              ],
                            )),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverList _renderGoodList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: _itemList.length,
        (BuildContext context, int index) {
          return _goodsItem(_itemList[index]);
        },
      ),
    );
  }

  Widget _goodsItem(ItemGoodsList item) {
    return GestureDetector(
      onTap: () async {
        _showDetail(item);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(item.lGoodsId!.toString(), style: ItemBkN15),
            Text(item.sBarcode!, style: ItemBkN15),
            Text(item.sGoodsName!, style: ItemBkB15,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDetail(ItemGoodsList item) async {
    Widget showTarget = GoodsDetail(lGoodsId: item.lGoodsId!);
    switch(widget.target) {
      case "SEARCH":
        showTarget = GoodsDetail(lGoodsId: item.lGoodsId!);
        break;
      case "STOCK":
        showTarget = MoveStock(lGoodsId: item.lGoodsId!);
        break;
      case "PRICE":
        showTarget = PriceDetail(lGoodsId: item.lGoodsId!);
        break;
      case "DISPLAY":
        showTarget = GoodsDisplay(lGoodsId: item.lGoodsId!);
        break;
      // case "ORDER":
      //   showTarget = OrderGoods(lGoodsId: item.lGoodsId!);
      //   break;
    }

    var result = await Navigator.push(
        context,
        Transition(
            child: showTarget,
            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
    if (result != null && result) {
      setState(() {});
    }
  }

  Future<void> _reqGoodsListByBarcode(String barcode) async {
    _showProgress(true);
    /*
    {"sBarcode":'4969363235039', 'sKeyword' : "바코드 뒤 6자리, 상품명", "lPageNo" : "1", "lRowNo" : "100" }
     */
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/goodsList",
        params: {"sBarcode": barcode, "lPageNo" : "1", "lRowNo" : "100"},
        onResult: (dynamic data) {
          _showProgress(false);

          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

          if (data['data'] != null) {
            var item = data['data'];
            if (item is List) {
              _itemList = ItemGoodsList.fromSnapshot(item);
            } else {
              _itemList = ItemGoodsList.fromSnapshot([item]);
            }

            if (_itemList.isEmpty) {
              showToastMessage("매칭되는 상품이 없습니다.");
              return;
            }

            if (_itemList.length == 1) {
              _showDetail(_itemList[0]);
            }
          }
        },
        onError: (String error) {
          _showProgress(false);
        });
  }

  Future<void> _reqGoodsListByKeyword(String keyword) async {
    if (keyword.length < 3) {
      showSnackbar(context, "검색어는 최소 2자이상 입력하세요.");
      return;
    }
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/goodsList",
        params: {"sKeyword": keyword, "lPageNo" : "1", "lRowNo" : "100"},
        onResult: (dynamic data) {
          // if (kDebugMode) {
          //   var logger = Logger();
          //   logger.d(data);
          // }

          if (data['data'] != null) {
            var item = data['data'];
            if (item is List) {
              _itemList = ItemGoodsList.fromSnapshot(item);
            } else {
              _itemList = ItemGoodsList.fromSnapshot([item]);
            }

            if (_itemList.isEmpty) {
              showToastMessage("매칭되는 상품이 없습니다.");
              //return;
            }

            if (_itemList.length == 1) {
              _showDetail(_itemList[0]);
            }
          }
          _showProgress(false);
        },
        onError: (String error) {
          _showProgress(false);
        });
  }

  Future<void> _reqCompetePrice() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/listCompetePrice",
        params: {"lPageNo" : "1", "lRowNo" : "25"},
        onResult: (dynamic data) {
          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

          if (data['data'] != null) {
            List item = data['data'];
            if(item.isNotEmpty) {
              _bHasListCompetePrice = true;
            }
          }
          _showProgress(false);
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

  Future<void> _showCompeteList() async {
    await Navigator.push(
        context,
        Transition(
            child: const ShowCompeteList(),
            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
  }
}
