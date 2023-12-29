// ignore_for_file: non_constant_identifier_names, must_be_immutable, file_names
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/stock/popItemSelect.dart';
import 'package:distribution/home/warehousing/distribute/processDistributeBoxGoodsQty.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/models/kitemBoxInGoods.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProcessDistributeBoxGoods extends StatefulWidget {
  final String workDay;
  final String boxBarcode;
  List<ItemWBoxInGoods>? listItemWBoxInGoods;
  ProcessDistributeBoxGoods({
        Key? key,
        required this.boxBarcode,
        required this.workDay,
        this.listItemWBoxInGoods,
    }) : super(key: key);

  @override
  State<ProcessDistributeBoxGoods> createState() =>
      _ProcessDistributeBoxGoodsState();
}

class _ProcessDistributeBoxGoodsState extends State<ProcessDistributeBoxGoods> {
  List<ItemWBoxInGoods> _itemList = [];
  final ScrollController _listScrollController = ScrollController();

  String title = "";
  bool _isComplete = false;
  bool _bDirty = false;
  int _fConfirmCount = 0;

  bool _bReady = false;
  //bool _bSkipPage = false;
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() async {
      _reqHousingBoxItems();
      setState(() {
        _bReady = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    //_controller.dispose();
    _listScrollController.dispose();
    //_listScrollController.jumpTo(0);
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
        title: const Text("입고배분 - 박스"),
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
                  _reqHousingBoxItems();
                }
            ),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-ProcessDistributeBoxGoods-key',
        validateMessage: "상품의 바코드를 스캔하세요.",
        waiting: false,
        allowPop: false,//_isComplete,
        useCamera: true,
        validate: _checkValidate,
        onWillPop: onWillPop,
        onScan: (barcode) {
          onScaned(barcode);
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if(!_bReady) {
      return Container(
        //color: Colors.amber,
      );
    }
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _renderTitle(),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 56),
                      //color: Colors.amber,
                      child: Column(children: [
                        Expanded(child: _renderBoxList()),

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
                      text: '확인',
                      isBottomPading: true,
                      enable: _isComplete,
                      visible: true,
                      isBottomSide: true,
                      onClick: () {
                        if(_bDirty) {
                          showToastMessage("배분 작업이 완료되었습니다.");
                        }
                        Navigator.pop(context, true);
                      },
                    ),
                  ),
                ),

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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future <bool> onWillPop() async {
    return true;
  }

  Widget _showColorInfo() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
      child: Row(
        children: [
          const Text("완료: ", style: ItemBkN12,),
          Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
                color: STD_OK
            ),
          ),

          const SizedBox(width: 10,),

          const Text("오차: ", style: ItemBkN12,),
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

          const SizedBox(width: 10,),
          const Text("대기: ", style: ItemBkN12,),
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

  Widget _renderTitle() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10,5,10,5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            )),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _itemRow(1,"입고일자:", widget.workDay, true),
          _itemRow(1,"박스번호:", widget.boxBarcode, true),
          const SizedBox(height: 5,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _showColorInfo(),
              const Spacer(),
              const Text("진행상태:", style:ItemG1N12),
              const SizedBox(width: 3,),
              Text("$_fConfirmCount / ${_itemList.length}", style: ItemBkB14,)
            ],
          )
        ],
      ),
    );
  }

  double mainAxisExtent = 200;
  Widget _renderBoxList() {
    int crossAxisCount = 1;
    mainAxisExtent = 200;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 2;
      mainAxisExtent = 80;
    } else if(rt<1.55) {
      crossAxisCount = 2;
      mainAxisExtent = 80;//104;
    } else if(rt<2.42) {
      crossAxisCount = 1;
      mainAxisExtent = 74;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 80;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _itemList.length%crossAxisCount;
    if(diff>0) {
      dumyCount = crossAxisCount + crossAxisCount - diff;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(2, 2, 2, 0),
      child: GridView.builder(
          controller: _listScrollController,//_controller,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            //childAspectRatio: childAspectRatio,
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: 1,
            crossAxisSpacing: 2,
          ),
          itemCount: _itemList.length+dumyCount,
          itemBuilder: (context, int index) {
            return (index < _itemList.length)
                ?_ItemInfo(index, _itemList[index]) : Container();
            /*
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index < _itemList.length)
                    ?_ItemInfo(index, _itemList[index]) : Container()
            );
             */
            //return _boxItem(index, _goodsList[index]);
          }),
    );
  }

  Widget _ItemInfo(int index, ItemWBoxInGoods item) {
    String sCount = "";
    Color bgColor = STD_READY;
    if(item.lConfirmCount!>=0) {
      bgColor = STD_DIFF;
      sCount = "${item.lGoodsCount}  /  ${item.lConfirmCount}";
      if(item.lGoodsCount == item.lConfirmCount) {
        bgColor = STD_OK;
      }
    } else {
      sCount = "${item.lGoodsCount}  /  미배분";
      bgColor = STD_READY;
    }

    return GestureDetector(
        onTap: () async {
          //await _showDistributeGoodsQty(item);
          await _showPopupDistributeGoodsQty(_itemList[index]);
        },
        child: Container(
          margin: const EdgeInsets.only(top:1),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: (item.hasFocus) ? Colors.pink : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(3),
            color: bgColor,
            //color: (item.status!) ? Colors.grey[300] : Colors.white
          ),
          child: Stack(
            children: [
              Positioned(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 8, 5, 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _itemRow(1, "바  코  드:", "${item.sBarcode}", false),
                        _itemRow(1, "상  품  명:", "${item.sGoodsName}", false),
                        const Spacer(),
                        // const Divider(height: 1, color: Colors.grey),
                        // const Spacer(),
                        _itemRow(1, "입고/확인:", sCount, true),
                      ],
                    ),
                  )

              ),
              // Positioned(
              //   top:0, left: 3,
              //     child: Visibility(
              //       visible: item.lConfirmCount!>=0,
              //         child:Row(
              //           children: const [
              //             Icon(Icons.check, color: Colors.black,)
              //           ],
              //         )
              //     )
              // ),
            ],
          ),
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
                height: 1.1,
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
              height: 1.1,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  bool _checkValidate(String barcode) {
    // // barcode = "4573236188645";
    // // print("_checkValidate()::barcode=>$barcode<");
    // int index = _itemList.indexWhere((element) {
    //   //print("element.sBarcode = >${element.sBarcode}<");
    //   return (element.sBarcode == barcode);
    // });
    // return (index >= 0);
    return true;
  }

  void _checkComplete() {
    _isComplete = true;
    _fConfirmCount = 0;
    for (var element in _itemList) {
      if (element.lConfirmCount == -1) {
        _isComplete = false;
      } else {
        _fConfirmCount++;
      }
    }
  }

  Future <ItemGoodsList?> findGoods(String barcode) async {
    List<ItemGoodsList> goodsList = await _reqGoodsListByBarcode(barcode);
    if(goodsList.isEmpty) {
      showOkDialogBox(
          context: context,
          title: "바코드: $barcode",
          message: "바코드에 매칭되는 상품이 없습니다."
      );
      return null;
    }

    if(goodsList.length==1) {
      return goodsList[0];
    }

    List<SelectItem> items = [];
    for (var element in goodsList) {
      items.add(SelectItem(
          sName: element.sGoodsName!, lGoodsId: element.lGoodsId, sBarcode: element.sBarcode!));
    }

    int index = -1;
    await showItemsSelect(context: context, items: items,
        onResult: (bool bOk, int inx) {
          if (bOk) {
            index = inx;
          }
        }
    );
    return (index>=0) ? goodsList[index] : null;
  }

  Future<void> onScaned(String barcode) async {

    //barcode = "8806385335858";
    ItemGoodsList? goodsItem = await findGoods(barcode);
    if(goodsItem==null) {
      return;
    }

    int index = -1;
    barcode = goodsItem.sBarcode!;
    for(int n=0; n<_itemList.length; n++) {
      if(_itemList[n].sBarcode==barcode ||
          (barcode.length>=10 && _itemList[n].sBarcode!.contains(barcode))){
        index = n;
        break;
      }
    }

    if (index >= 0) {
      int lConfirmCount = _itemList[index].lConfirmCount!;
      if(lConfirmCount<1) {
        //await _showDistributeGoodsQty(items[index]);
        await _showPopupDistributeGoodsQty(_itemList[index]);
      }
      else
      {

        _listScrollController.jumpTo(index*mainAxisExtent);
        //_controller.scrollToIndex(index);
        setState(() {});

        showYesNoDialogBox(
            context: context,
            height: 240,
            title: "확인",
            message: "배분작업이 완료된 상품입니다"
                "\n배분작업을 다시 하시겠습니까?",
            onResult: (bOK) async {
              if(bOK) {
                //_showDistributeGoodsQty(items[index]);
                _showPopupDistributeGoodsQty(_itemList[index]);
              }
            }
          );
        }
    }
    else {
      showOkDialogBox(context: context,
          title: "확인",
          height:240,
          message: "barcode: $barcode\n배분 리스트에 없는 상품입니다."
      );
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

  Future<void> _showPopupDistributeGoodsQty(ItemWBoxInGoods item) async {
    await showBottomDistributeBoxGoodsQty(
        context: context,
        workDay: widget.workDay,
        boxNo: widget.boxBarcode,
        item: item,
        onResult: (bool bOK) {
          _bDirty = true;
          _reqHousingBoxItems();
          /*
          if(_bSkipPage) {
            Navigator.pop(context);
          }
          else {
            _reqHousingBoxItems();
          }
           */
        }
    );
  }

  // 박스안에 담긴 상품의 배분정보 리스트 정보를 가져온다
  Future<void> _reqHousingBoxItems() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/housingBoxInfo",
        params: {"dWarehousing": widget.workDay, "sBoxNo": widget.boxBarcode},
        onError: (String error) {},
        onResult: (dynamic data) {
          if (data['data'] != null) {
            var item = data['data'];
            if (item is List) {
              _itemList = ItemWBoxInGoods.fromSnapshot(item);
            } else {
              _itemList = ItemWBoxInGoods.fromSnapshot([item]);
            }
            _checkComplete();
          }
        },
    );
    _showProgress(false);
  }

}
