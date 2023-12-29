// ignore_for_file: file_names, non_constant_identifier_names

import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/searchForm.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/cardGoods.dart';
import 'package:distribution/home/stock/popItemSelect.dart';
import 'package:distribution/home/warehousing/distribute/processDistributeBoxGoods.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/models/kitemBoxInGoods.dart';
import 'package:distribution/models/kitemWhGoods.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:transition/transition.dart';

class FindWarehousingGoods extends StatefulWidget {
  final String workDay;
  const FindWarehousingGoods({Key? key, required this.workDay}) : super(key: key);

  @override
  State<FindWarehousingGoods> createState() => _FindWarehousingGoodsState();
}

class _FindWarehousingGoodsState extends State<FindWarehousingGoods> {

  final AutoScrollController _controller = AutoScrollController();
  late SessionData _session;
  List<ItemWhGoods> _goodsList = [];
  String _barcode = "";
  String _sGoodsName = "";
  String _sGoodsBarcode = "";
  int    _lGoodId = 0;
  String _sInputCode = "";
  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() {
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
        title: const Text("단품조회"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          // home
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 30,
                ),
                onPressed: () {
                  _reqSearchGoods();
                  //Navigator.of(context).popUntil((route) => route.isFirst);
                }),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-MoveGoodsBox-key',
        waiting: _isInAsyncCall,
        allowPop: true,
        useCamera: true,
        onScan: (barcode) async {
          setState((){
            _barcode = barcode;
          });
          _reqSearchGoods();
        },
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(5,5,5,5),
                //color: Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // const SizedBox(width: 3,),
                        // const Text("상품 바코드:", style: ItemBkN14,),
                        const Spacer(),
                        const Text("입고일자:  ", style: ItemG1N14,),
                        Text(widget.workDay, style: ItemBkB14),
                        const SizedBox(width: 5,)
                      ]
                    ),
                    const SizedBox(height: 15),
                    //const SizedBox(height: 5,),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child:Container(
                                padding:const EdgeInsets.fromLTRB(5, 0, 2, 2),
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
                                  hintText: '바코드(5자 이상)',
                                  onCreated: (controller) {},
                                  onChange: (value){
                                    _sInputCode = value.trim();
                                  },
                                  onSummit: (String value) {
                                    _sInputCode = value.trim();
                                    _onSearch(_sInputCode);
                                  },
                                ),
                              ),
                          ),
                          Container(
                              //margin:
                              //const EdgeInsets.only(left: 0),
                              height: 47,
                              width: 100,
                              padding:
                              const EdgeInsets.only(right: 3),
                              child: OutlinedButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  _onSearch(_sInputCode);
                                  //_reqSearchGoods();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.black,
                                  side: const BorderSide(
                                      width: 1.0, color: ColorG4),
                                ),
                                child: const Text(
                                  "조회",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                          ),
                        ]),
                  ],
                ),
              ),
              Visibility(
                  visible: _goodsList.isNotEmpty,
                  child:Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(3,5,3,0),
                      //color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CardGoods(
                            padding: const EdgeInsets.fromLTRB(5, 15, 5, 10),
                            lGoodsId: _lGoodId,
                            sGoodsName: _sGoodsName,
                            sBarcode: _sGoodsBarcode,
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                            color: Colors.grey[200],
                            child: Row(
                              children: [
                                const Text("검색결과:", style: ItemG1N14,),
                                const Spacer(),
                                const Text("조회수:", style: ItemG1N14,),
                                Text("${_goodsList.length}",
                                  style: ItemBkB14,maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                //SizedBox(width: 5,),
                              ],
                            ),
                          ),

                          const SizedBox(height: 5,),
                          Expanded(child: _renderGoodsList()),
                        ],
                      ),
                    ),
                  )
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
      crossAxisCount = 5;
      mainAxisExtent = 70;
    } else if(rt<1.55) {
      crossAxisCount = 5;
      mainAxisExtent = 70;
    } else if(rt<2.42) {
      crossAxisCount = 3;
      mainAxisExtent = 70;
    } else if(rt<2.70) {
      crossAxisCount = 2;
      mainAxisExtent = 70;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _goodsList.length%crossAxisCount;
    if(diff>0) {
      dumyCount = crossAxisCount + crossAxisCount - diff;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: GridView.builder(
          controller: _controller,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing:  1,
            crossAxisSpacing: 2,
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

  Widget _ItemInfo(int index, ItemWhGoods item) {
    // Color statusColor = Colors.white;
    // if(item.lConfirmCount>0) {
    //   statusColor = Color(0xFFE0E0E0);
    //   if(item.lConfirmCount != item.lGoodsCount) {
    //     statusColor = Colors.amber;
    //   }
    // }
    // else {
    //   statusColor = Colors.white;
    // }
    String sStoreName = item.sStoreName;
    if(sStoreName=="(주)한국다까미야") {
      sStoreName = "본사";
    }
    return GestureDetector(
      onTap: (){
        for (var element in _goodsList) {element.hasFocus=false;}
        setState(() {
          item.hasFocus = true;
        });
        _doProcessPox(item.sBoxNo);
      },
      child: Container(
          //margin: const EdgeInsets.fromLTRB(1,1,1,1),
          //padding: const EdgeInsets.fromLTRB(5,5,5,5),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: (item.hasFocus)? Colors.pink : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(sStoreName, style: ItemBkN14,),
              Text(item.sBoxNo, style: ItemBkN14,),
              Text("(${item.lConfirmCount}/${item.lGoodsCount})", style: ItemBkB12),
            ],
          )
      ),
    );
  }




  Future<void> _doProcessPox(String boxCode) async {
    List<ItemWBoxInGoods>? list = await _reqHousingBoxItems(boxCode);

    await Navigator.push(
      context,
      Transition(
          child: ProcessDistributeBoxGoods(
            boxBarcode:boxCode,
            workDay: widget.workDay,
            listItemWBoxInGoods: list,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT
      ),
    );
  }

  Future<void> _onSearch(String barcode) async {
    if(barcode.length<5) {
      showToastMessage("5자 이상 입력해주세요.");
      return;
    }

    _sGoodsName = "";
    _goodsList = [];
    List<ItemGoodsList> goodsList = await _reqGoodsListByBarcode(barcode);
    if(goodsList.isNotEmpty) {
      if(goodsList.length == 1) {
        _barcode = goodsList[0].sBarcode!;
        _reqSearchGoods();
      } else {
        List<SelectItem> items = [];
        for (var element in goodsList) {
          items.add(SelectItem(
              sName: element.sGoodsName!, lGoodsId: element.lGoodsId, sBarcode: element.sBarcode!));
        }
        showItemsSelect(context: context, items: items,
            onResult: (bool bOk, int index) {
              if(bOk) {
                _barcode = goodsList[index].sBarcode!;
                _reqSearchGoods();
              }
            }
        );
      }
    }
  }

  Future <void> _reqSearchGoods() async {
    //_barcode = "4960652136952";
    if(_barcode.isEmpty) {
      setState(() {
        _goodsList = [];
      });
      return;
    }
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/scanHousingGoodsInfo",
        params: {"sBarcode": _barcode, "dWarehousing": widget.workDay},
        onError: (String error) {},
        onResult: (dynamic response) {
          // if (kDebugMode) {
          //   var logger = Logger();
          //   logger.d(response);
          // }
          if(response['status']=="success") {
            dynamic content = response['data'];
            if (content != null) {
              _goodsList = ItemWhGoods.fromSnapshot(content);
              if(_goodsList.isNotEmpty) {
                _sGoodsName = _goodsList[0].sGoodsName;
                //_sGoodsBarcode = _goodsList[0].sBarcode;
                //_lGoodId = _goodsList[0].lGoodsId;
              }
              else {
                showToastMessage("해상 상품이 없습니다.");
              }
            }
          } else {
            showToastMessage(response['message']);
          }
        },
    );
    _showProgress(false);
  }

  Future<List<ItemGoodsList>> _reqGoodsListByBarcode(String barcode) async {
    List<ItemGoodsList> list = [];
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
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

  // 박스안에 담긴 상품의 배분정보 리스트 정보를 가져온다
  Future<List<ItemWBoxInGoods>?> _reqHousingBoxItems(String boxBarcode) async {
    List<ItemWBoxInGoods>? list = [];
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/housingBoxInfo",
        params: {"dWarehousing": widget.workDay, "sBoxNo": boxBarcode},
        onError: (String error) {},
        onResult: (dynamic data) {
          //_showProgress(false);
          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

          if (data['data'] != null) {
            var item = data['data'];
            if (item is List) {
              list = ItemWBoxInGoods.fromSnapshot(item);
            } else {
              list = ItemWBoxInGoods.fromSnapshot([item]);
            }
          }
        },

    );

    _showProgress(false);

    return list;
  }

}
