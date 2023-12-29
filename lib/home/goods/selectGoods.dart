// ignore_for_file: file_names, must_be_immutable
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/searchForm.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class SelectGoods extends StatefulWidget {
  final bool isMulti;
  bool? isPopup;
  final Function(bool bOK, List<ItemGoodsList>? result)? onResult;
  SelectGoods({Key? key,
    required this.isMulti,
    this.isPopup = false,
    this.onResult,
  }) : super(key: key);

  @override
  State<SelectGoods> createState() => _SelectGoodsState();
}

class _SelectGoodsState extends State<SelectGoods> {
  bool _bEnableSearch = true;
  String _findValue = "";
  String _initKeyword = "";
  List<ItemGoodsList> _itemList = [];
  List<ItemGoodsList> _selectList = [];

  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    if (_session.Setting?.UseTestMode=="YES") {
      setState(() {
        _initKeyword = "낚시대";
      });
    }
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
      appBar: (!widget.isPopup!) ? AppBar(
        title: const Text("상품선택"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              if(widget.onResult != null) {
                widget.onResult!(false, []);
              }
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
        ],
      ) : null,
      body: TakaBarcodeBuilder(
        scanKey: 'taka-SelectGoods-key',
        waiting: _isInAsyncCall,
        allowPop: true,
        useCamera: true,//!widget.isPopup!,
        onScan: (barcode) async {
          await _reqGoodsListByBarcode(barcode);
        },
        onButtonEbanle: (_selectList.isNotEmpty),
        onButtonText: "선택완료",
        onButton: () {
          Navigator.pop(context, _selectList);
          if(widget.onResult != null) {
            widget.onResult!(true, _selectList);
          }

        },
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // 1. search bar
              Visibility(
                visible: _bEnableSearch,
                child: Container(
                  padding: (widget.isPopup! )
                      ? const EdgeInsets.fromLTRB(10, 42, 10, 10)
                      : const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                          hintText: '상품명 / 상품바코드 (뒤 6자리)',
                          onCreated: (controller) {},
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
                              style: ItemG1N18,),
                          ),
                        )
                    ),

                    // goods list
                    Positioned(
                        child: Visibility(
                          visible: _itemList.isNotEmpty,
                          child: Container(
                            color: Colors.grey[100],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10,5,10,5),
                                    child:Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text("검색결과: ", style: ItemG1N12,),
                                        Text("${_itemList.length} ", style: ItemBkB12,),
                                        const Spacer(),
                                        const Text("선택: ", style: ItemG1N12,),
                                        Text("${_selectList.length}  ", style: ItemBkB14,),
                                    ],
                                  )
                                ),
                                //const Divider(height: 10, color: Colors.black,),
                                Expanded(
                                    child: CustomScrollView(
                                  slivers: [
                                    _renderGoodList(),
                                  ],
                                )),
                              ],
                            ),
                          ),
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
        if(!widget.isMulti) {
          for (var element in _itemList) {
            element.isSelect = false;
          }
        }
        setState(() {
          item.isSelect = !item.isSelect;
          _refreshSelect();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.fromLTRB(10,10,10,10),
        color: (item.isSelect) ? Colors.amber : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.sBarcode!, style: ItemBkN12),
            Text(item.sGoodsName!, style: ItemBkN14,),
            //Divider(height: 15, color: Colors.grey,)
          ],
        ),
      ),
    );
  }

  void _refreshSelect() {
    _selectList = [];
    for (var element in _itemList) {
      if(element.isSelect) {
        _selectList.add(element);
      }
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
        onError: (String error) {},
        onResult: (dynamic data) {
          _showProgress(false);

          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

          if (data['data'] != null) {
            _itemList = ItemGoodsList.fromSnapshot(data['data']);
            if (_itemList.isEmpty) {
              showToastMessage("매칭되는 상품이 없습니다.");
              return;
            }
            if (_itemList.length == 1) {
              _selectList = [];
              _selectList.add(_itemList[0]);
              if(widget.onResult != null) {
                widget.onResult!(true, _selectList);
              }
              //Navigator.pop(context, _selectList);
            }
          }
        },
    );
    _showProgress(false);
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
        onError: (String error) {},
        onResult: (dynamic data) {
          if (data['data'] != null) {
            _itemList = ItemGoodsList.fromSnapshot(data['data']);
            if (_itemList.isEmpty) {
              showToastMessage("매칭되는 상품이 없습니다.");
            }

            if (_itemList.length == 1) {
              _selectList = [];
              _selectList.add(_itemList[0]);
              if(widget.onResult != null) {
                widget.onResult!(true, _selectList);
              }
              //Navigator.pop(context, _selectList);
            }
          }
        },
    );
    _showProgress(false);
  }
}

Future<void> showPopGoodsSelect({
  required BuildContext context,
  bool? isMulti = false,
  double? heightRate = 0.8,
  Function(bool bOK, List<ItemGoodsList>? result)? onResult}) {

  //double rt = 0.70;
  double viewHeight;
  if(heightRate != null) {
    if(heightRate>0.9) {
      heightRate = 0.7;
    }
    if(heightRate<0.3) {
      heightRate = 0.3;
    }
  }

  viewHeight = MediaQuery.of(context).size.height * heightRate!;

  return showModalBottomSheet(
    context: context,
    enableDrag: false,
    isScrollControlled: true,
    useRootNavigator: false,
    isDismissible: true,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async {
          if(onResult != null) {
            onResult(false, []);
          }
          return true;
        },
        child: SizedBox(
            height: viewHeight,
            child: Stack(
              children: [
                Positioned(
                    child: Container(
                      //color: Colors.black,
                      child: SelectGoods(
                        isMulti: isMulti!,
                        isPopup: true,
                        onResult: (bool bOK, List<ItemGoodsList>? result) {
                          if(onResult != null) {
                            onResult(bOK, result);
                          }
                        },
                      ),
                    )
                ),
                Positioned(
                    top:0, left:0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        if(onResult != null) {
                          onResult(false, null);
                        }
                        Navigator.pop(context);
                      },
                    )
                ),
              ],
            )
        ),
      );
    },
  );
}