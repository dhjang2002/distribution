import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/goodsDetail.dart';
import 'package:distribution/home/goods/tempList/dlgEditGoodsMemo.dart';
import 'package:distribution/home/stock/popItemSelect.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/models/kItemTempDetail.dart';
import 'package:distribution/models/kItemTempMaster.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class TempDetailList extends StatefulWidget {
  final ItemTempMaster master;
  const TempDetailList({
    Key? key,
    required this.master
  }) : super(key: key);

  @override
  State<TempDetailList> createState() => _TempDetailListState();
}

class _TempDetailListState extends State<TempDetailList> {
  //final ScrollController _scrollController = ScrollController();
  final AutoScrollController _listController = AutoScrollController();

  List<ItemTempDetail> _itemList = [];
  late SessionData _session;
  bool _bMoreData = false;
  final bool _bLockEdit = false;
  int lPageNo = 1;
  int _totalCount = 0;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() {
      _reqListTempGoods();
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
        title: const Text("임시저장 목록"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              Navigator.pop(context);
            }
        ),
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 28,
                ),
                onPressed: () {
                  lPageNo = 1;
                  _itemList = [];
                  _reqListTempGoods();
                }),
          ),
          Visibility(
            visible: !_bLockEdit,
            child: IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 24,
                ),
                onPressed: () {
                  showYesNoDialogBox(
                      context: context,
                      title: "삭제 확인",
                      message: "이 카테고리에 저장된 모든 데이터가 삭제됩니다."
                          "\n삭제하시겠습니까?",
                      onResult: (bOK){
                        if(bOK) {
                          _deleteAllItem();
                        }
                      });
                }),
          ),
          Visibility(
            visible: _bLockEdit,
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 20,
                ),
                onPressed: () {
                  lPageNo = 1;
                  _itemList = [];
                  _bMoreData = true;
                  _reqListTempGoods();
                }),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-GoodsDetail-key',
        waiting: false,
        allowPop: true,
        useCamera: true,
        onScan: (barcode) async {
        _onScan(barcode);
        },
        child: _renderBody(),
      )
    );
  }

  Widget _renderBody() {
    return Stack(
      children: [
        Positioned(
            child: Column(
              children: [
                _renderTitle(),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 0),
                          child:ListView.builder(
                              controller:_listController,//_scrollController,
                              itemCount: _itemList.length+1,
                              itemBuilder: (context, index){
                                if(index<_itemList.length) {
                                  return _itemInfo(index, _itemList[index]);
                                }
                                else {
                                  return Container(height: 48,);
                                }
                              }
                          )
                          /*
                          child: Scrollbar(
                              //controller: _scrollController,
                              thumbVisibility: true,
                              thickness: 5,
                              radius: const Radius.circular(8.0),
                              child:ListView.builder(
                                  controller:_listController,//_scrollController,
                                  itemCount: _itemList.length+1,
                                  itemBuilder: (context, index){
                                    if(index<_itemList.length) {
                                      return _itemInfo(index, _itemList[index]);
                                    }
                                    else {
                                      return Container(height: 48,);
                                    }
                                  }
                              )
                          ),
                          */
                        ),
                      ),
                      /*
                      Positioned(
                          bottom: 0, left: 0, right: 0,
                          child:SizedBox(
                            //height: 100,
                            child: Row(
                              children: [
                                ButtonSingle(
                                    visible: true,
                                    isBottomPading: true,
                                    isBottomSide: true,
                                    text: "더보기",
                                    enable: _bMoreData,
                                    onClick: () {
                                      lPageNo++;
                                      _reqList();
                                    }),
                              ],
                            ),
                          )
                      ),
                      */
                      Align(
                          alignment: AlignmentDirectional.center, // <-- SEE HERE
                          child:Visibility(
                            visible: _isInAsyncCall,
                            child:Container(
                              width: 32,
                              height: 32,
                              color: Colors.transparent,
                              child: const CircularProgressIndicator(),
                            ),
                          )
                      ),
                    ],
                  ),
                ),
              ],
            )
        ),
      ],
    );
  }

  Widget _renderTitle() {
    String sMemo = widget.master.sMemo;
    if(sMemo.isEmpty) {
      sMemo = "미정의";
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(10,10,10,10),
      color: Colors.grey[200],
      child: Row(
        children: [
          //const Text("카테고리: ", style: ItemBkN16,),
          Text("[${widget.master.lOrder}] ", style: ItemBkB14,),
          Text(sMemo, style: (widget.master.sMemo.isEmpty) ? ItemG1N14 : ItemBkB14),
          const Spacer(),
          const Text("수량: ", style:ItemBkN12),
          //Text("${_itemList.length} / $_totalCount", style: ItemBkB12,),
          Text("${_itemList.length}", style: ItemBkB12,),
        ],
      ),
    );
  }

  Widget _itemInfo(int index, ItemTempDetail item) {
    return AutoScrollTag(
        key: ValueKey(index),
        controller: _listController,
        index: index,
        child:GestureDetector(
          onTap: () {
          for (var element in _itemList) {
            element.bSelect = false;
          }

          setState(() {
            item.bSelect = true;
          });
        },
          child: Stack(
          children: [
            Positioned(
                child:Container(
                    margin: const EdgeInsets.fromLTRB(3,3,3,0),
                    padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                            color: (item.bSelect)? Colors.pink : Colors.grey,
                            width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("바코드: ", style: ItemG1N12,),
                          Text(item.sBarcode, style: ItemBkN14,),
                        ],
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("상품명: ", style: ItemG1N12,),
                          Expanded(
                              child: Text(item.sName,
                              style: ItemBkN14,
                              maxLines: 5, overflow:
                              TextOverflow.ellipsis,
                            )
                          ),
                        ],
                      ),

                      const Text("수량(메모): ", style: ItemG1N12,),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(20, 5, 5, 5),
                        padding: const EdgeInsets.all(10),
                        color: Colors.amber[50],
                        child: Text(item.sMemo, style: ItemBkB14,),
                      ),
                    ],
                  )
                )
            ),

            Positioned(
              top:5, right: 10,
                child: Visibility(
                    visible: item.bSelect,
                    child: SizedBox(
                      width: 120,
                        child:Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.info_outline,
                                color: Colors.black, size: 20,),
                              padding: const EdgeInsets.all(5),
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                showPopGoodsDetail(
                                    context: context,
                                    lGoodsId: item.lGoodsId
                                );
                              },
                            ),

                            //SizedBox(width: 3,),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18,),
                              padding: const EdgeInsets.all(5),
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _updateMemo(item);
                              },
                            ),

                            //SizedBox(width: 3,),
                            IconButton(
                              icon: const Icon(Icons.close,
                                color: Colors.pink, size: 24,),
                              padding: const EdgeInsets.all(5),
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                showYesNoDialogBox(
                                    context: context,
                                    title: "확인",
                                    message: "이 상품을 삭제하시겠습니까?",
                                    onResult: (bOK){
                                      if(bOK) {
                                        _deleteItem(item);
                                      }
                                    });
                              },
                            )
                          ],

                        )
                    )
                )
            ),
          ],
        ),
      )
    );
  }


  Future <void> _updateMemo(final ItemTempDetail item) async {
    ItemGoodsList goods = ItemGoodsList();
    goods.sGoodsName = item.sName;
    goods.sBarcode   = item.sBarcode;
    goods.lGoodsId   = item.lGoodsId;
    DlgEditGoodsMemo(
        context: context,
        goods: goods,
        label: "수량/메모:",
        value: item.sMemo,
        onResult: (bool bOk, String value){
          if(bOk) {
            item.sMemo = value;
            _addGoodsItem(goods, value, "변경되었습니다.");
          }
        });
  }

  /*
  Future <void> _doSelectGoods() async {
    showPopGoodsSelect(
        context: context,
        isMulti:false,
        onResult: (bool bOK, List<ItemGoodsList>? result){
          if(!bOK) {
            return;
          }

          int index = 0;
          DlgEditGoodsMemo(
              context: context,
              goods: result![index],
              label: "수량/메모:",
              value: "",
              onResult: (bool bOk, String value){
                if(bOk) {
                  _itemList = [];
                  lPageNo = 1;
                  _addGoodsItem(result[index], value, "상품이 추가되었습니다.");
                }
              }
          );
        }
    );
  }
  */

  Future <void> _onScan(String barcode) async {
    List<ItemGoodsList> list = await _reqGoodsListByBarcode(barcode);

    if(list.isEmpty) {
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
              _doEditMemo(list[index]);
            }
          }
      );
    }
    else {
      _doEditMemo(list[index]);
    }
  }

  void _doEditMemo(ItemGoodsList itemGoods) {
    String currValue = "";
    int index = _itemList.indexWhere((element) {
      return element.lGoodsId == itemGoods.lGoodsId;
    });

    if(index>=0) {
      currValue = _itemList[index].sMemo;
      _itemList.forEach((element) {
        element.bSelect = false;
      });
      _itemList[index].bSelect = true;
      _listController.scrollToIndex(index);
      //_scrollController.jumpTo(index*100);
    }

    DlgEditGoodsMemo(
        context: context,
        goods: itemGoods,
        label: "수량/메모:",
        value: currValue,
        onResult: (bool bOk, String value) {
          if (bOk) {
            _itemList = [];
            lPageNo = 1;
            _addGoodsItem(itemGoods, value, "상품이 추가되었습니다.");
          }
        }
    );
  }

  Future <void> _reqListTempGoods() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/listTempGoodsDetail",
        params: {"lMasterId":widget.master.lMasterID.toString(),
          "lPageNo": lPageNo,
          "lRowNo": "10000"
        },
        onError: (String error) {},
        onResult: (dynamic data) {
          if (data['status'] == "success") {
            _totalCount = 0;
            if (data['totalCount'] != null) {
              _totalCount = int.parse(data['totalCount'].toString().trim());
            }

            var content = data['data'];
            if (content != null) {
              var items = ItemTempDetail.fromSnapshot(content);
              if (items.isNotEmpty) {
                _itemList.addAll(items);
                if (items.length < 25) {
                  _bMoreData = false;
                } else {
                  _bMoreData = true;
                }
              }
            }
          }
        },
    );
    _showProgress(false);
  }


  Future <void> _addGoodsItem(ItemGoodsList item, String sMemo, String mesg) async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/insertGoodsTempDetail",
        params: {
          "lMasterId": widget.master.lMasterID,
          "sMemo":sMemo,
          "lGoodsId":item.lGoodsId
        },
        onResult: (dynamic data) {
          // if (kDebugMode) {
          //   var logger = Logger();
          //   logger.d(data);
          // }

          if (data['status']== "success") {
            showToastMessage(mesg);
            _reqListTempGoods();
          }
          else {
            showToastMessage(data['message']);
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

  Future<void> _deleteItem(ItemTempDetail item) async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/deleteTempGoodsDetail",
        params: {"lDetailId":item.lDetailId},
        onResult: (dynamic data) {
          // if (kDebugMode) {
          //   var logger = Logger();
          //   logger.d(data);
          // }

          if (data['status'] == "success") {
            setState(() {
              _itemList.remove(item);
            });
            showToastMessage("삭제되었습니다.");
          }
        },
        onError: (String error) {}
    );
   _showProgress(false);
  }

  Future<void> _deleteAllItem() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/deleteTempGoodsDetail",
        params: {"lMasterId":widget.master.lMasterID},
        onResult: (dynamic data) {
          // if (kDebugMode) {
          //   var logger = Logger();
          //   logger.d(data);
          // }

          if (data['status'] == "success") {
            showToastMessage("삭제되었습니다.");
            _itemList = [];
            lPageNo = 1;
            _reqListTempGoods();
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

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

}
