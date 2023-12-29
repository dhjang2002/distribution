// ignore_for_file: non_constant_identifier_names, file_names
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/stock/popItemSelect.dart';
import 'package:distribution/home/warehousing/confirm/goodsConfirm.dart';
import 'package:distribution/models/kItemConfirmGoods.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/models/klistConfirmPacking.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ListPackedBoxInGoods extends StatefulWidget {
  final ListConfirmPacking master;
  const ListPackedBoxInGoods(
      {Key? key,
        required this.master})
      : super(key: key);

  @override
  State<ListPackedBoxInGoods> createState() =>
      _ListPackedBoxInGoodsState();
}

class _ListPackedBoxInGoodsState extends State<ListPackedBoxInGoods> {
  List<ItemConfirmGoods> _goodsList = [];
  late TextEditingController controller = TextEditingController();
  late AutoScrollController _controller;

  String title = "";

  late SessionData _session;

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
        title: const Text("입고상품 내역"),
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
        scanKey: 'taka-ListWareHousingGoods-key',
        validateMessage: "상품의 바코드를 스캔하세요.",
        onWillPop:  () async {
          return (widget.master.fState == STATUS_PACK_SCONFIRM);
        },
        waiting: false,
        allowPop: true,
        useCamera: true,
        validate: _checkValidate,
        onScan: (barcode) {
          onScaned(barcode);
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
                          padding: const EdgeInsets.only(bottom: 58),
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
                                                Text(widget.master.sBoxSeq, style: ItemBkB14,),
                                                const Spacer(),
                                                Visibility(
                                                    visible: widget.master.fState>=STATUS_PACK_SCONFIRM,
                                                    child: const Icon(Icons.check,
                                                      color: Colors.pink,)
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
                                                Text("${_goodsList.length} ", style: ItemBkB14),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(child: _renderGoodsList()),
                                  ]
                              )
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white,
                        child: ButtonSingle(
                          enable: (_lConfirmCount==_goodsList.length),
                          text: '입고 확인',
                          isBottomPading: true,
                          isBottomSide: true,
                          onClick: () {
                            if(widget.master.fState==STATUS_PACK_MOVE) {
                              showYesNoDialogBox(context: context,
                                  title: "확인",
                                  message: "해당 물품의 입고 내역을 승인하시겠습니까?",
                                  onResult: (bOK){
                                    if(bOK) {
                                      _reqConfirmOk();
                                    }
                                  });
                            }
                            else {
                              Navigator.pop(context);
                            }
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
    double mainAxisExtent = 110;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 4;
      mainAxisExtent = 90;
    } else if(rt<1.55) {
      crossAxisCount = 3;
      mainAxisExtent = 90;
    } else if(rt<2.42) {
      crossAxisCount = 2;
      mainAxisExtent = 88;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 90;
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
        onTap: () {
          for (var element in _goodsList) {
            element.hasFocus = false;
          }

          setState(() {
            item.hasFocus = true;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: (item.hasFocus) ? Colors.pink : Colors.grey,
            ),
            //borderRadius: BorderRadius.circular(1),
            color: (item.fState>=STATUS_PACK_SCONFIRM) ? STD_OK : Colors.white,
            //color: (item.status!) ? Colors.grey[300] : Colors.white
          ),

          child: Stack(
            children: [
              Positioned(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Column(
                      children: [
                        const Spacer(),
                        _itemRow(1, "바  코  드:", item.sBarcode, false),
                        _itemRow(1, "상  품  명:", item.sGoodsName, false),
                        _itemRow(1, "상품수량:", "${item.lPackingCount}", true),
                        _itemRow(1, "상품위치:", "${item.sLotNo} / ${item.sLotMemo}", true),
                        const SizedBox(height: 5,),
                        const Spacer(),
                      ],
                    ),
                  ),
              ),
              /*
              Positioned(
                right: 5, top:0,
                  child: Visibility(
                      visible: item.hasFocus,
                      child: IconButton(
                        padding: const EdgeInsets.all(3),
                        constraints:const BoxConstraints(),
                        onPressed: () {
                          showPopGoodsDetail(context: context, lGoodsId: item.lGoodsId);
                        },
                        icon: const Icon(Icons.info_outline),
                      )
                  ),
              ),
              */
              Positioned(
                bottom: 1, right: 1,
                child: Visibility(
                  visible: item.hasFocus,// && item.fState <STATUS_PACK_SCONFIRM,
                  child:SizedBox(
                      width: 64,
                      height: 26,
                      child: OutlinedButton(
                        onPressed: () async {
                          _showGoodsConfirm(item);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          // foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          side: const BorderSide(
                            width: 1.0,
                            // color: (item.fState < STATUS_PACK_SCONFIRM)
                            //     ? Colors.pink : Colors.grey
                          ),
                        ),
                        child: Text(
                          (item.fState < STATUS_PACK_SCONFIRM) ? "입고 확인" : "정보 확인",
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white
                            // color: (item.fState < STATUS_PACK_SCONFIRM)
                            //     ? Colors.pink : Colors.grey,

                          ),
                        ),
                      )
                ),

                ),
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
                color: Colors.black,
              ),
            )
        ),
        Expanded(
          child: Text(value,
            maxLines: maxLines, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
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
      _showGoodsConfirm(_goodsList[index]);
    } else {
      showToastMessage("해당 상품이 없습니다.");
    }
  }

  Future <void> _showGoodsConfirm(ItemConfirmGoods item) async {
    showPopGoodsConfirm(
        context: context,
        item: item,
        onResult: (bOK){
          if(bOK) {
            //showToastMessage("처리 되었습니다.");
            _reqPackingGoods();
          }
        }
    );
  }

  Future<void> onScaned(String barcode) async {
    //barcode = "19699";
    List<ItemGoodsList> list = await _reqGoodsListByBarcode(barcode);
    if(list.isEmpty) {
      showToastMessage("입고목록에 없는 상품입니다.");
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

  int _lConfirmCount = 0;
  void _checkComplete() {
    _lConfirmCount = 0;
    for (var element in _goodsList) {
      if(element.fState==STATUS_PACK_SCONFIRM) {
        _lConfirmCount++;
      }
    }
  }

  // 박스안에 담긴 상품의 배분정보 리스트 정보를 가져온다
  Future<void> _reqPackingGoods() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/listPackingGoods",
        params: {"sBoxSeq": widget.master.sBoxSeq},
        onError: (String error) {},
        onResult: (dynamic data) {
          if (data['data'] != null) {
            var item = data['data'];
            if (item is List) {
              _goodsList = ItemConfirmGoods.fromSnapshot(item);
            } else {
              _goodsList = ItemConfirmGoods.fromSnapshot([item]);
            }
            if(_goodsList.isNotEmpty) {
              widget.master.fState = _goodsList[0].fState;
            }
          }
        },
    );
    _checkComplete();
    _showProgress(false);
  }

  Future<void> _reqConfirmOk() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/updatePackingConfirm",
        params:
        {
          "sBoxSeq": widget.master.sBoxSeq,
        },
        onError: (String error) {},
        onResult: (dynamic data) {
          if(data['status']=="success") {
            showToastMessage("처리 되었습니다.");
            Navigator.pop(context);
          } else {
            showToastMessage(data['message']);
          }
        },
    );
    _showProgress(false);
  }

}
