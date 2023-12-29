// ignore_for_file: must_be_immutable, file_names

import 'dart:async';
import 'package:distribution/common/cardDescriptionImage.dart';
import 'package:distribution/common/cardPhotoItem.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/editMallId.dart';
import 'package:distribution/home/goods/uploadGoodsMultimedia.dart';
import 'package:distribution/home/stock/popItemSelect.dart';
import 'package:distribution/models/kInfoGoods.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/models/kItemPrice.dart';
import 'package:distribution/models/kItemStock.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:distribution/utils/Launcher.dart';
import 'package:distribution/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';
import 'package:url_launcher/url_launcher.dart';

class GoodsDetail extends StatefulWidget {
  final int lGoodsId;
  bool? hidePickEdit;
  bool? isPopup;
  final Function(bool bOk)? onResult;
  GoodsDetail({
    Key? key,
    required this.lGoodsId,
    this.hidePickEdit = false,
    this.isPopup = false,
    this.onResult
  }) : super(key: key);

  @override
  State<GoodsDetail> createState() => _GoodsDetailState();
}

class _GoodsDetailState extends State<GoodsDetail> {
  InfoGoods _info = InfoGoods();
  List<CardPhotoItem> _photoList = [];

  int _totalStock = 0;
  List<ItemStock> stockList = [];

  bool isStockOwner = false;
  String stockStatus = "X";

  late SessionData _session;

  bool _bReady = false;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _lGoodsId = widget.lGoodsId;
    isStockOwner = (_session.StoreKind == "HD" || _session.StoreKind == "SB");

    Future.microtask(() async {
      await _requestGoodsInfo();
    });
    super.initState();
  }


  @override
  void dispose() {
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
      appBar: (!widget.isPopup!) ? AppBar(
        title: const Text("상품정보"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          Visibility(
            visible: !widget.hidePickEdit! &&
                (_session.StoreKind == "HD" || _session.StoreKind == "SB"),
            child: IconButton(
                icon: const Icon(
                  Icons.photo,
                  size: 24,
                ),
                onPressed: () {
                  _showEditPhotos();
                }),
          ),

          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 28,
                ),
                onPressed: () {
                  _requestGoodsInfo();
                }),
          ),
        ],
      ) : null,
      body: TakaBarcodeBuilder(
          scanKey: 'taka-GoodsDetail-key',
          onWillPop: () async {return false;},
          waiting: false,
          allowPop: true,
          useCamera: !widget.isPopup!,
          onScan: (barcode) async {
          _onScan(barcode);
          },
          child: Stack(
                children: [
                  Positioned(child: _renderBody()),
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
                  ),
                ],
              )
      ),
    );
  }

  Widget _renderBody() {
    final double picHeight = MediaQuery.of(context).size.width * 0.8;
    String sSlot = _info.sLot;
    if(_info.sLot.length==6) {
      sSlot = "${_info.sLot.substring(0,2)}-"
          "${_info.sLot.substring(2,4)}-"
          "${_info.sLot.substring(4,6)}";
    }
    if(_info.sLotMemo.isNotEmpty) {
      sSlot = sSlot + " , ${_info.sLotMemo}";
    }

    return Stack(
      children: [
        Positioned(
            child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 상품정보 - 사진
                    SizedBox(
                      height: picHeight,
                      width: double.infinity,
                      child: (_bReady) ? CardPhotos(
                        items: _photoList,
                      ) : Container(),
                    ),

                    // 1. 상품정보-일반
                    Container(
                        margin: const EdgeInsets.fromLTRB(5, 3, 5, 0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                                child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child:ListView(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      children: [
                                        Row(
                                          children: [
                                            const Text("상품정보", style: ItemBkB16,),
                                            //SizedBox(width: 10,),
                                            // Visibility(
                                            //     visible: isStockOwner,
                                            //     child: Text("  :  $sSlot", style: ItemBkB16,)
                                            // ),
                                          ],
                                        ),

                                        const SizedBox(height: 10,),
                                        _itemLink("상  품  명:", _info.sName, _info.sMallGoodsId),
                                        _itemRow("바  코  드:", _info.sBarcode, false, false),
                                        //_itemRow("상품코드:", _info., false, false),
                                        _itemRow("상품구분:", _info.sGoodsType, false, false),
                                        _itemRow("판매상태:", _info.sState, false, false),
                                        _itemRow("판매가격:", "${numberFormat(_info.mSalesPrice)}원",
                                            true, false),

                                        _itemRow("재고상태:",
                                            (isStockOwner)
                                                ? numberFormat(_info.rStoreStock)
                                                : stockStatus, true, false),
                                        Visibility(
                                            visible: isStockOwner,
                                            child: _itemRow("상품위치:", sSlot, true, false)
                                        ),
                                        // Visibility(
                                        //     visible: isStockOwner && _info.sLotMemo.isNotEmpty,
                                        //     child: const Text("진열메모:", style: ItemG1N12)
                                        // ),
                                        Visibility(
                                            visible: isStockOwner && _info.sLotMemo.isNotEmpty,
                                            child: Container(
                                              width: double.infinity,
                                              //height: 100,
                                              margin: const EdgeInsets.only(top:5),
                                              padding: const EdgeInsets.all(10),
                                              color: Colors.grey[50],
                                              child: Text(
                                                _info.sLotMemo,
                                                style: ItemBkN16,
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                        ),
                                      ],
                                    )
                                )
                            ),

                            Positioned(
                              top:5, right: 5,
                              child:Visibility(
                                visible: !widget.hidePickEdit! &&
                                    (_session.StoreKind == "HD" || _session.StoreKind == "SB"),
                                child: SizedBox(
                                    height: 36,
                                    width: 90,
                                    child:OutlinedButton(
                                      onPressed: () async {
                                        FocusScope.of(context).unfocus();
                                        _showEditMallId();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: Colors.black,
                                        side: const BorderSide(width: 1.0, color: ColorG4),
                                      ),
                                      child: const Text("링크 편집",
                                        style: TextStyle(color: Colors.white, fontSize: 12,),
                                      ),
                                    )
                                ),
                              ),
                            ),

                            Positioned(
                                bottom:15, right: 5,
                                child: Visibility(
                                    visible: (_info.sMallGoodsId.isNotEmpty && !widget.isPopup!),
                                    child: FloatingActionButton.extended(
                                      onPressed: () {
                                        _goLink(_info.sMallGoodsId);
                                      },
                                      label: const Text("주문하기", style: TextStyle(fontSize: 13),),
                                    )
                                )
                            ),

                            // Positioned(
                            //     child: Visibility(
                            //       child: Container(),
                            //     )
                            // ),
                          ],
                        )
                    ),

                    // 가격정보
                    Visibility(
                        visible: isStockOwner,
                        child: _itemPrice()
                    ),

                    // 2. 상품정보-재고현황
                    Visibility(
                        visible: isStockOwner,
                        child: _itemStock()
                    ),

                    /*
            Visibility(
              visible: !widget.isPopup!,
                child: Container(
                  //margin: EdgeInsets.only(top:80),
                  padding: EdgeInsets.all(5),
                  height: _info.descriptionImageHeight,
                  child: CardDescriptionImage(
                    imageUrl: _info.descriptionImageUrl,
                    //height: _descriptionImageHeight,
                    onScale: (scale) {
                      print("onZoom():scale=$scale");
                      setState(() {
                        //_descriptionImageHeight = _descriptionImageHeight * scale;
                      });
                    },
                  ),
                )
            ),
            */
                    Visibility(
                        visible: !widget.isPopup! && _info.descriptionImageUrl.isNotEmpty,
                        child: Container(
                          height: _info.descriptionImageHeight,
                          //height: MediaQuery.of(context).size.width*2,
                          child: CardImageWebview(
                            imageUrl: _info.descriptionImageUrl,
                          ),
                        )
                    ),
                    //const SizedBox(height: 100,)
                  ],
                )
            ),
        ),
        Positioned(
            child: Visibility(
              visible: _info.descriptionImageUrl.isNotEmpty,
              child: Container(
                child: CardImageWebview(
                  imageUrl: _info.descriptionImageUrl,
                ),
              ),
            )
        ),
      ],
    );
  }

  // 2. 상품정보-재고현황
  Widget _itemStock() {
    int crossAxisCount = 1;
    double mainAxisExtent = 200;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 6;
      mainAxisExtent = 22;
    } else if(rt<1.55) {
      crossAxisCount = 6;
      mainAxisExtent = 22;
    } else if(rt<2.42) {
      crossAxisCount = 4;
      mainAxisExtent = 22;
    } else if(rt<2.70) {
      crossAxisCount = 3;
      mainAxisExtent = 22;
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
              Text("재고현황 (${numberFormat(_totalStock)})", style: ItemBkB16,),
              //SizedBox(height: 5,),
              const Divider(height: 10, color: Colors.grey,),
              //SizedBox(height: 5,),
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
                          Text(numberFormat(item.rStoreStock), style: ItemBkB15,),
                          const SizedBox(width: 5,)
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ));
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
                  const Text("가격정보", style: ItemBkB16,),
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

  Widget _itemLink(String label, String value, String linkId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: 60,
            child: Text(
              label,
              style: ItemG1N12,
            )
        ),
        Expanded(
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: () {
                    if(linkId.isNotEmpty) {
                      _goLink(linkId);
                    }
                  },
                  child: Container(
                      color: Colors.transparent,
                      child:Text(
                        value,
                        style: (linkId.isNotEmpty) ? ItemBuN15 : ItemBkN15,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      )
                  )
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemRow(String label, String value, bool bBold, bool bLink) {
    TextStyle style = ItemBkN15;

    if(bBold) {
      style = ItemBkB15;
    }

    if(bLink) {
      style = ItemBuN15;
    }

    return Container(
        padding: const EdgeInsets.only( top: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 60,
                child: Text(
                  label,
                  style: ItemG1N12,
                )),
            Expanded(
              child:GestureDetector(
                onTap: () {
                  if(bLink && value.isNotEmpty) {
                    _goLink(value);
                  }
                },
              child: Container(
                color: Colors.transparent,
                  child:Text(
                    value,
                    style: style,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
              ))
              ),
            ),
          ],
        ));
  }

  Future<void> _showEditPhotos() async {
    var result = await Navigator.push(
        context,
        Transition(
            child: UploadGoodsMultimedia(
                lGoodsId: _lGoodsId, barcode: _info.sBarcode),
            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));

    if (result != null && result == true) {
      // setState(() {
      //   _requestFiles(_lGoodsId);
      // });
    _requestGoodsInfo();
    }
  }

  Future<void> _showEditMallId() async {
    var result = await Navigator.push(
        context,
        Transition(
            child: EditMallId(lGoodsId: _lGoodsId, info: _info),
            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));

    if (result != null && result == true) {
      _requestGoodsInfo();
      // setState(() {
      //   _requestFiles(_lGoodsId);
      // });
    }
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
                _lGoodsId = goodsList[index].lGoodsId!;
                Future.microtask(() {
                  _requestGoodsInfo();
                });
              }
            }
        );
      }
    }
  }

  void _goLink(String linkId) {
    String url = "$URL_MALL/$linkId";
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    //showUrl(url);
  }

  Future <void> _requestGoodsStock() async {
    _showProgress(true);
    await Remote.apiPost(
      context: context,
      session: _session,
      lStoreId: _session.getAccessStore(),
      method: "taka/goodsStockInfo",
      params: {"lGoodsId": _lGoodsId.toString()},
      onError: (String error) {},
      onResult: (dynamic data) {

        if (data['data'] != null) {
          var content = data['data'];
          stockList = ItemStock.fromSnapshot(content);
          _totalStock = 0;
          for (var element in stockList) {
            _totalStock = _totalStock + element.rStoreStock;

            // 본사 제고 상태 반영
            if (element.lStoreID == 1) {
              stockStatus = (element.rStoreStock > 0) ? "O" : "X";
            }
          }
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
      params: {"lGoodsId": _lGoodsId},
      onError: (String error) {},
      onResult: (dynamic data) async {
        _bReady = true;
        if (data['data'][0] != null) {
          var content = data['data'][0];
          _info = InfoGoods.fromJson(content);
          _priceList = _info.getPriceInfo();
          _photoList = _info.getPictInfoAddUrl(!widget.isPopup!);
          if(!widget.isPopup!) {
            await _info.setDescriptionImage(context);
            // _descriptionImageUrl    = "https://wms.point-i.co.kr/files/S4573236195117.jpg";
            // _descriptionImageHeight = await computeImageHeight(context, _descriptionImageUrl);
          }
          _requestGoodsStock();
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

Future<void> showPopGoodsDetail({
  required BuildContext context,
  required int lGoodsId,
  bool? hidePickEdit,
  double? heightRate = 0.8,
  Function(bool bOK)? onResult}) {

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
                      child: GoodsDetail(
                        lGoodsId: lGoodsId,
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