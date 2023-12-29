
// ignore_for_file: must_be_immutable

import 'package:distribution/common/cardPhotoItem.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/display/cardEditSlot.dart';
import 'package:distribution/home/stock/popItemSelect.dart';
import 'package:distribution/models/kInfoGoods.dart';
import 'package:distribution/models/kItemConfirmGoods.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/models/kItemPrice.dart';
import 'package:distribution/models/kItemStock.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:distribution/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class GoodsConfirm extends StatefulWidget {
  final ItemConfirmGoods item;
  bool? hidePickEdit;
  bool? isPopup;
  final Function(bool bOk)? onResult;
  GoodsConfirm({
    Key? key,
    required this.item,
    this.hidePickEdit = false,
    this.isPopup = false,
    this.onResult
  }) : super(key: key);

  @override
  State<GoodsConfirm> createState() => _GoodsConfirmState();
}

class _GoodsConfirmState extends State<GoodsConfirm> {
  InfoGoods _info = InfoGoods();
  List<CardPhotoItem> _photoList = [];

  int _totalStock = 0;
  List<ItemStock> stockList = [];

  bool _bShowDisplayEdit = false;
  late SessionData _session;

  ItemSlot sLotInfo = ItemSlot();

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _lGoodsId = widget.item.lGoodsId;
    Future.microtask(() {
      _requestGoodsInfo();
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

  Future <bool> _onWillPop() async {
    if (_bShowDisplayEdit) {
      setState(() {
        _bShowDisplayEdit = false;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (!widget.isPopup!) ? AppBar(
          title: const Text("상품위치"),
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
                    size: 30,
                  ),
                  onPressed: () {
                    _requestGoodsInfo();
                  }),
            ),
          ],
        ) : null,
        body: TakaBarcodeBuilder(
          scanKey: 'taka-GoodsConfirm-key',
          waiting: false,
          allowPop: true,
          useCamera: !widget.isPopup!,
          onScan: (barcode) async {
          _onScan(barcode);
          },
          child: WillPopScope(
                  onWillPop: _onWillPop,
                  child: ModalProgressHUD(
                    inAsyncCall: _isInAsyncCall,
                    child: Container(
                        color: Colors.white,
                        child: _renderBody()
                    ),
                  )
              )
        )
    );
  }

  Widget _infoGoods() {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const Text("상품정보", style: ItemBkB15,),
          const SizedBox(height: 10,),
          _itemRow(1, "바  코  드:", _info.sBarcode, false),
          _itemRow(2, "상  품  명:", _info.sName,false ),
          _itemRow(1, "상품구분:", _info.sGoodsType, false),
          _itemRow(1, "판매상태:", _info.sState, false),
          _itemRow(1, "판매가격:", "${numberFormat(_info.mSalesPrice)}원", true),
          _itemRow(1, "재고상태:", numberFormat(_info.rStoreStock), false),
        ],
      ),
    );
  }

  Widget _infoConfirm() {
    return Container(
        margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Colors.pink,
        ),
        borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("입고수량", style: ItemBkB15,),
                const Spacer(),
                Text("${widget.item.lPackingCount}", style: ItemBkB24),
                const SizedBox(width: 25,),
              ],
            ),

            Visibility(
              visible: widget.item.fState<STATUS_PACK_SCONFIRM,
                child: const Divider(height: 10, color: Colors.grey)),

            Row(
              children: [
                const Spacer(),
                Visibility(
                  visible: widget.item.fState <STATUS_PACK_SCONFIRM,
                  child:SizedBox(
                      width: 70,
                      height: 28,
                      child: OutlinedButton(
                        onPressed: () async {
                          _reqConfirmGoodsOk(widget.item);
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
                        child: const Text(
                          "입고 확인",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white
                            // color: (item.fState < STATUS_PACK_SCONFIRM)
                            //     ? Colors.pink : Colors.grey,

                          ),
                        ),
                      )
                  ),

                )
              ],
            )
          ],
        )
    );
  }

  Widget _infoDisplay() {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Colors.grey,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const Text("상품위치", style: ItemBkB15,),
          const SizedBox(height: 5,),
          const Divider(height: 1, color: Colors.grey,),
          const SizedBox(height: 5,),

          // 진열위치 - 변경버튼
          Visibility(
              visible: !_bShowDisplayEdit,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 주위치+편집 버튼
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child:Row(
                          children: [
                            Text(
                              sLotInfo.sLot,
                              style: ItemBkB24,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Visibility(
                                visible: !_bShowDisplayEdit,
                                child: SizedBox(
                                    width: 70,
                                    height: 28,
                                    child: TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      _bShowDisplayEdit = !_bShowDisplayEdit;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero,
                                    // foregroundColor: Colors.white,
                                    //backgroundColor: Colors.black,
                                    // side: BorderSide(
                                    //   width: 1.0,
                                    //   // color: (item.fState < STATUS_PACK_SCONFIRM)
                                    //   //     ? Colors.pink : Colors.grey
                                    // ),
                                  ),
                                  child: const Text("위치 변경",
                                    style: TextStyle(fontSize:12, color: Colors.blueAccent),),
                                )
                            ))
                          ],
                        ),

                      ),
                    ],
                  ),
                  Visibility(
                      visible: sLotInfo.sLotMemo.isNotEmpty,
                      child: const Text("진열메모:", style: ItemG1N14)
                  ),
                  Visibility(
                      visible: sLotInfo.sLotMemo.isNotEmpty,
                      child: Container(
                        width: double.infinity,
                        //height: 100,
                        margin: const EdgeInsets.only(top:5),
                        padding: const EdgeInsets.all(10),
                        color: Colors.grey[50],
                        child: Text(
                          sLotInfo.sLotMemo,
                          style: ItemBkN18,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                  ),
                ],
              )
          ),

          // 편집박스
          Visibility(
              visible: _bShowDisplayEdit,
              child: Container(
                  margin: const EdgeInsets.only(top:10),
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: CardEditSlot(
                    sLotInfo: sLotInfo,
                    onSave: (bool isSave) async {
                      if(isSave) {
                        await _requestSaveSlot();
                      }
                      else {
                        setState((){
                          _bShowDisplayEdit = false;
                        });
                      }
                    },
                  )
              )),
        ],
      )
    );
  }

  Widget _renderBody() {
    final double picHeight = MediaQuery.of(context).size.width * 0.65;
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 상품정보 - 사진
            Container(
              height: picHeight,
              width: double.infinity,
              color: Colors.black,
              child: CardPhotos(
                items: _photoList,
              ),
            ),

            _infoConfirm(),
            // 3. 상품위치
            _infoDisplay(),

            // 2. 상품정보-일반
            _infoGoods(),

            // 4. 상품정보-재고현황
            _infoStock(),

            // 가격정보
            _itemPrice(),

            const SizedBox(height: 150,),
          ],
        )
    );
  }

  // 2. 상품정보-재고현황
  Widget _infoStock() {
    int crossAxisCount = 1;
    double mainAxisExtent = 200;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 6;
      mainAxisExtent = 20;
    } else if(rt<1.55) {
      crossAxisCount = 6;
      mainAxisExtent = 20;
    } else if(rt<2.42) {
      crossAxisCount = 4;
      mainAxisExtent = 20;
    } else if(rt<2.70) {
      crossAxisCount = 3;
      mainAxisExtent = 20;
    }

    return Visibility(
        visible: true,
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("재고현황 (${numberFormat(_totalStock)})", style: ItemBkB15,),
              const Divider(height: 15, color: Colors.grey,),
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent:mainAxisExtent,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 5,
                  ),
                  itemCount: stockList.length,
                  itemBuilder: (context, int index) {
                    ItemStock item = stockList[index];
                    String sStoreName = item.sStoreName;
                    if(sStoreName=="(주)한국다까미야") {
                      sStoreName = "본사";
                    }
                    return Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          Text("$sStoreName:", style: ItemBkN12,),
                          const Spacer(),
                          Text(numberFormat(item.rStoreStock), style: ItemBkB14,),
                          const SizedBox(width: 10,)
                        ],
                      ),
                    );
                  }),
            ],
          ),
        )
    );
  }

  // 2. 상품정보-가격
  List<ItemPrice> _priceList = [];
  Widget _itemPrice() {
    int crossAxisCount = 1;
    double mainAxisExtent = 200;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 4;
      mainAxisExtent = 20;
    } else if(rt<1.55) {
      crossAxisCount = 4;
      mainAxisExtent = 20;
    } else if(rt<2.42) {
      crossAxisCount = 2;
      mainAxisExtent = 22;
    } else if(rt<2.70) {
      crossAxisCount = 2;
      mainAxisExtent = 20;
    }

    String storeName = _session.Stroe!.sName;
    if(storeName=="(주)한국다까미야") {
      storeName = "본사";
    }

    return Visibility(
        visible: true,
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
          padding: const EdgeInsets.fromLTRB(10,10,10,10),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //${numberFormat(_info.mSalesPrice)}원
              Row(
                children: [
                  const Text("가격정보", style: ItemBkB15,),
                  const Spacer(),
                  Text(" $storeName", style: ItemBkN15,),
                ],
              ),

              const SizedBox(height: 5,),
              const Divider(height: 1, color: Colors.grey,),
              const SizedBox(height: 5,),
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent:mainAxisExtent,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 5,
                  ),
                  itemCount: _priceList.length,
                  itemBuilder: (context, int index) {
                    ItemPrice item = _priceList[index];
                    return Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          Text("${item.sName}:", style: ItemG1N12,),
                          Expanded(
                            child: Container(
                              alignment: Alignment.topRight,
                              child: Text(item.sPrice,
                                maxLines: 2,overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14,
                                  fontWeight: (item.isPrice) ? FontWeight.bold : FontWeight.normal,
                                  letterSpacing: -1.5,
                                  height: 1.2,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
              ),
            ],
          ),
        )
    );
  }

  Widget _itemRow(int maxLines, String label, String value, bool bBold) {
    return Container(
        padding: const EdgeInsets.only( top: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 50,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    letterSpacing: -1.0,
                    height: 1.2,
                    color: Colors.grey,
                  ),
                )),
            Expanded(
              child:GestureDetector(
                  onTap: () {
                  },
                  child: Container(
                      color: Colors.transparent,
                      child:Text(
                        value,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: (bBold) ?  FontWeight.bold : FontWeight.normal,
                          letterSpacing: -0.8,
                          height: 1.2,
                          color: Colors.black,
                        ),
                        maxLines: maxLines,
                        overflow: TextOverflow.ellipsis,
                      )
                  )
              ),
            ),
          ],
        ));
  }

  Future <void> _requestSaveSlot() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/updateLotNo",
        params: {
          "lGoodsId": _lGoodsId,
          "sLotNo":sLotInfo.sLot,
          "sLotMemo":sLotInfo.sLotMemo
        },
        onError: (String error) {},
        onResult: (dynamic data) {
          if (data['status'] == "success") {
            showToastMessage("변경되었습니다.");
            setState(() {
              _bShowDisplayEdit = false;
            });
          } else {
            showToastMessage("처리중 오류가 발생하였습니다.");
          }
        },
    );
    _showProgress(false);
  }

  Future <void> _requestGoodsInfo() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/goodsInfo",
        params: {"lGoodsId": _lGoodsId },
        onError: (String error) {},
        onResult: (dynamic data) {
          if (data['data'][0] != null) {
            var content = data['data'][0];
            _info = InfoGoods.fromJson(content);
            _photoList = _info.getPictInfoAddUrl(false);
            _priceList = _info.getPriceInfo();
            sLotInfo.sLot     = _info.sLot;
            sLotInfo.sLotMemo = _info.sLotMemo;
            _requestGoodsStock();
          }
        },
    );
    _showProgress(false);
  }

  Future <void> _requestGoodsStock() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/goodsStockInfo",
        params: {"lGoodsId": _lGoodsId },
        onError: (String error) {},
        onResult: (dynamic data) {
          if (data['data'] != null) {
            var content = data['data'];
            stockList = ItemStock.fromSnapshot(content);
            _totalStock = 0;
            for (var element in stockList) {
              _totalStock = _totalStock + element.rStoreStock;
            }
          }
        },
    );
    _showProgress(false);
  }

  int _lGoodsId = 0;
  Future<void> _onScan(String barcode) async {
    //print("barcode=$barcode");
    List<ItemGoodsList> goodsList = await _reqGoodsListByBarcode(barcode);
    if(goodsList.isNotEmpty) {
      if(goodsList.length == 1) {
        int index = 0;
        if(_lGoodsId != goodsList[index].lGoodsId!) {
          _lGoodsId = goodsList[index].lGoodsId!;
          Future.microtask(() {
            _requestGoodsInfo();
          });
        }
      } else {
        List<SelectItem> items = [];
        for (var element in goodsList) {
          items.add(SelectItem(
              sName: element.sGoodsName!, lGoodsId: element.lGoodsId, sBarcode: element.sBarcode!));
        }
        showItemsSelect(context: context, items: items,
            onResult: (bool bOk, int index) {
              if (bOk && (_lGoodsId != goodsList[index].lGoodsId!)) {
                _lGoodsId = goodsList[0].lGoodsId!;
                Future.microtask(() {
                  _requestGoodsInfo();
                });
              }
            }
        );
      }
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

  Future<void> _reqConfirmGoodsOk(ItemConfirmGoods item) async {
    // showToastMessage("처리 되었습니다.");
    // if(widget.onResult != null) {
    //   widget.onResult!(true);
    // }
    // Navigator.pop(context);
    // return;

    _showProgress(true);
    await Remote.apiPost(
      context: context,
      session:  _session,
      lStoreId: _session.getMyStore(),
      method: "taka/updatePackingGoodsConfirm",
      params:
      {
        "lPackingId": item.lPackingID,
      },
      onError: (String error) {},
      onResult: (dynamic data) {
        if(data['status']=="success") {
          showToastMessage("처리 되었습니다.");
          if(widget.onResult != null) {
            widget.onResult!(true);
          }
          Navigator.pop(context);
        } else {
          showToastMessage(data['message']);
        }
      },
    );
    _showProgress(false);
  }
}

Future<void> showPopGoodsConfirm({
  required BuildContext context,
  required ItemConfirmGoods item,
  bool? hidePickEdit,
  double? heightRate = 0.9,
  Function(bool bOK)? onResult}) {

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
        onWillPop: () async => true,
        child: SizedBox(
            height: viewHeight,
            child: Stack(
              children: [
                Positioned(
                    child: Container(
                      color: Colors.black,
                      child: GoodsConfirm(
                        item: item,
                        isPopup: true,
                        hidePickEdit: true,
                        onResult: (bool bOK) {
                          if(onResult != null) {
                            onResult(bOK);
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