// ignore_for_file: non_constant_identifier_names, camel_case_types, file_names

import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/goodsDetail.dart';
import 'package:distribution/home/stock/popItemSelect.dart';
import 'package:distribution/models/kItemConfirmGoods.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/models/klistConfirmPacking.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class listPackedGoodsInfo extends StatefulWidget {
  final ListConfirmPacking master;
  const listPackedGoodsInfo(
      {Key? key,
        required this.master})
      : super(key: key);

  @override
  State<listPackedGoodsInfo> createState() =>
      _listPackedGoodsInfoState();
}

class _listPackedGoodsInfoState extends State<listPackedGoodsInfo> {
  List<ItemConfirmGoods> _goodsList = [];
  late TextEditingController controller = TextEditingController();
  late AutoScrollController _controller;

  String title = "";

  late SessionData _session;
  int _totalGoodsCount = 0;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _controller = AutoScrollController();
    Future.microtask(() {
      _reqPackingGoods();
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
        title: const Text("패킹상품 내역"),
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
                  size: 32,
                ),
                onPressed: () {
                  _reqPackingGoods();
                }
            ),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-listPackedGoodsInfo-key',
        validateMessage: "상품의 바코드를 스캔하세요.",
        onWillPop:  () async {
          return true;
        },
        waiting: false,
        allowPop: false,
        useCamera: true,
        validate: _checkValidate,
        onScan: (barcode) {
          onScaned(barcode);
        },
        child: Stack(
          children: [
            Positioned(
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
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                                  color: Colors.grey[100],
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 8, 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(widget.master.sBoxSeq,
                                              //" / ${widget.master.sCustomerName}",
                                              style: ItemBkB14,
                                            ),
                                            const Spacer(),
                                            Visibility(
                                                visible: widget.master.fState>=STATUS_PACK_SCONFIRM,
                                                child: const Icon(Icons.check, color: Colors.pink,)
                                            ),
                                            Text(widget.master.sState,
                                              style: ItemBkB14,),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Visibility(
                                                visible:widget.master.fState==STATUS_PACK_MOVE,
                                                child: const Text("입고된 상품의 종류 및 수량을 확인하여 주세요.",
                                                    style: ItemR1N12)
                                            ),
                                            const Spacer(),
                                            const Text("상품수: ", style: ItemBkN14),
                                            Text("${_goodsList.length} ($_totalGoodsCount)", style: ItemBkB14),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: _renderGoodsList()),
                              ]
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
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
    );
  }

  Widget _renderGoodsList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 110;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 2;
      mainAxisExtent = 80;
    } else if(rt<1.55) {
      crossAxisCount = 2;
      mainAxisExtent = 80;
    } else if(rt<2.45) {
      crossAxisCount = 1;
      mainAxisExtent = 80;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 80;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _goodsList.length%crossAxisCount;
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
          itemCount: _goodsList.length+dumyCount,
          itemBuilder: (context, int index) {
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index<_goodsList.length)
                    ? _ItemInfo(_goodsList[index]) : Container()
            );
            //return _boxItem(index, _goodsList[index]);
          }),
    );
  }

  Widget _ItemInfo(ItemConfirmGoods item) {
    return GestureDetector(
        onTap: () async {
        },
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: (item.hasFocus) ? Colors.pink : Colors.grey,
            ),
            //borderRadius: BorderRadius.circular(1),
            color: (item.isChecked) ? Colors.grey[300] : Colors.white,
            //color: (item.status!) ? Colors.grey[300] : Colors.white
          ),

          child: Stack(
            children: [
              Positioned(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Column(
                      children: [
                        Spacer(),
                        _itemRow(1, "바  코  드:", item.sBarcode, false),
                        _itemRow(1, "상  품  명:", item.sGoodsName, false),
                        _itemRow(1, "상품수량:", "${item.lPackingCount}", true),
                        Spacer(),
                      ],
                    ),
                  ),
              ),
              Positioned(
                right: 5, top:5,
                  child: IconButton(
                    padding: const EdgeInsets.all(3),
                    constraints:const BoxConstraints(),
                    onPressed: () {
                      showPopGoodsDetail(context: context, lGoodsId: item.lGoodsId);
                    },
                    icon: const Icon(Icons.info_outline),
                  )
              ),
            ],
          ),
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

  bool _checkValidate(String barcode) {
    return true;
  }

  void _gotoGoodsPosition(int lGoodsId) {
    for (var element in _goodsList) {
      if (element.lGoodsId == lGoodsId) {
        element.hasFocus = true;
        element.isChecked = false;
      } else {
        element.hasFocus = false;
        element.isChecked = false;
      }
    }

    int index = _goodsList.indexWhere((element) => element.lGoodsId == lGoodsId);
    if (index >= 0) {
      _controller.scrollToIndex(index);
      setState(() {});
    } else {
      showToastMessage("해당 상품이 없습니다.");
    }

  }

  Future<void> onScaned(String barcode) async {
    List<ItemGoodsList> list = await _reqGoodsListByBarcode(barcode);
    if(list.isEmpty) {
      showToastMessage("등록된 상품이 아닙니다.");
      return;
    }

    int index = 0;
    if(list.length>1) {
      List<SelectItem> items = [];
      for (var element in list) {
        items.add(SelectItem(
            sName: element.sGoodsName!,
            lGoodsId: element.lGoodsId,
            sBarcode: element.sBarcode!)
        );
      }
      showItemsSelect(context: context, items: items,
          onResult: (bool bOk, int index) {
            if(bOk) {
              _gotoGoodsPosition(items[index].lGoodsId!);
            }
          }
      );
    }
    else {
      _gotoGoodsPosition(list[index].lGoodsId!);
    }
  }
  // 해당 바코드의 상품정보를 조회한다.
  Future<List<ItemGoodsList>> _reqGoodsListByBarcode(String barcode) async {
    _showProgress(true);
    List<ItemGoodsList> list = [];
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
  Future<void> _reqPackingGoods() async {
    _totalGoodsCount = 0;
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/listPackingGoods",
        params: {"sBoxSeq": widget.master.sBoxSeq},
        onResult: (dynamic data) {
          if (data['data'] != null) {
            var item = data['data'];
            if (item is List) {
              _goodsList = ItemConfirmGoods.fromSnapshot(item);
            } else {
              _goodsList = ItemConfirmGoods.fromSnapshot([item]);
            }

            _goodsList.forEach((element) {
              if(element.lPackingCount>0) {
                _totalGoodsCount += element.lPackingCount;
              }
            });
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }
}
