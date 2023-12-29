// ignore_for_file: non_constant_identifier_names

import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/home/stock/popItemSelect.dart';
import 'package:distribution/models/kItemCompetePrice.dart';
import 'package:distribution/common/inputForm.dart';
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/cardPhotoItem.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kInfoGoods.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/models/kItemPrice.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:distribution/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PriceDetail extends StatefulWidget {
  final int lGoodsId;
  const PriceDetail({Key? key,
    required this.lGoodsId,
  }) : super(key: key);

  @override
  State<PriceDetail> createState() => _PriceDetailState();
}

class _PriceDetailState extends State<PriceDetail> {
  late TextEditingController? salePrice_controller;
  late TextEditingController? reqPrice_controller;
  late TextEditingController? comment_controller;

  InfoGoods _info = InfoGoods();
  List<CardPhotoItem> _photoList = [];
  List <ItemCompetePrice> compList = [];
  int _reqPrice = 0;
  String _reqComment = "";

  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _lGoodsId = widget.lGoodsId;
    Future.microtask(() async {
      await _requestGoodsInfo();
      await _reqCompateData(true);
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
        appBar: AppBar(
          title: const Text("가격변경"),
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
                    size: 28,
                  ),
                  onPressed: () async {
                    await _requestGoodsInfo();
                    await _reqCompateData(false);
                  }),
            ),
          ],
        ),
        body: TakaBarcodeBuilder(
          scanKey: 'taka-PriceDetail-key',
          onWillPop: () async {return false;},
          waiting: false,
          allowPop: true,
          useCamera: true,
          onScan: (barcode) async {
          _onScan(barcode);
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
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
            ),
          )
        )
    );
  }


  Widget _renderBody() {
    final double picHeight = MediaQuery.of(context).size.width * 0.65;
    ItemCompetePrice item = ItemCompetePrice();
    if(compList.isNotEmpty) {
      item = compList[0];
    }
    String request = item.sReasonMemo;
    String reply = "";
    if(request.isNotEmpty) {
      List memo = request.split("{");
      if(memo.length>1) {
        reply = memo[1];
        reply = reply.replaceAll("}", "");
        request = memo[0];
      }
    }

    return Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. 상품정보 - 사진
                      Visibility(
                          visible: true,
                          child: Container(
                            height: picHeight,
                            width: double.infinity,
                            color: Colors.black,
                            child: CardPhotos(
                              items: _photoList,
                            ),
                          )
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
                                        const Text("상품정보", style: ItemBkB16,),
                                        const SizedBox(height: 10,),
                                        _itemRow(1, "바  코  드:", _info.sBarcode, false),
                                        _itemRow(2,"상  품  명:", _info.sName,false ),
                                        _itemRow(1, "상품구분:", _info.sGoodsType, false),
                                        _itemRow(1, "판매상태:", _info.sState, false),
                                        _itemRow(1, "판매가격:",
                                            "${numberFormat(_info.mSalesPrice)}원", true),

                                        _itemRow(1, "재고상태:",
                                            numberFormat(_info.rStoreStock), false),
                                        Visibility(
                                            visible: true,
                                            child: _itemRow(1, "상품위치:", _info.sLot, false)
                                        ),
                                        Visibility(
                                            visible: _info.sLotMemo.isNotEmpty,
                                            child: const Text("진열메모:", style: ItemG1N12)
                                        ),
                                        Visibility(
                                            visible: _info.sLotMemo.isNotEmpty,
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
                          ],
                        )
                        ,
                      ),

                      _itemPrice(),

                      // 가격변경 요청
                      Container(
                        margin: const EdgeInsets.only(
                            left: 5, top:10, right: 5, bottom: 20),
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // 판매가
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Expanded(
                                      flex: 5,
                                      child: Text(
                                        "현재 판매가:",
                                        style: ItemG1N14,
                                      )),
                                  Expanded(
                                    flex: 5,
                                    child: InputForm(
                                        onlyDigit: true,
                                        readOnly: true,
                                        disable: false,
                                        keyboardType: TextInputType.number,
                                        valueText: numberFormat(_info.mSalesPrice),
                                        hintText: '',
                                        textStyle: ItemBkB16,
                                        onControl: (controller){
                                          salePrice_controller = controller;
                                        },
                                        onChange: (String value) {}),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Expanded(
                                      flex: 5,
                                      child: Text(
                                        "변경 요청가:",
                                        style: ItemG1N14,
                                      )),
                                  Expanded(
                                    flex: 5,
                                    child: InputForm(
                                        onlyDigit: true,
                                        readOnly: false,
                                        disable: false,
                                        keyboardType: TextInputType.number,
                                        valueText: _reqPrice.toString(),
                                        hintText: '',
                                        textStyle: ItemBkB16,
                                        onControl: (controller){
                                          reqPrice_controller = controller;
                                        },
                                        onChange: (String value) {
                                          if(int.tryParse(value) != null) {
                                            _reqPrice = int.parse(value);
                                          }
                                          // else {
                                          //   reqPrice_controller!.text = _reqPrice.toString();
                                          // }
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                                padding: const EdgeInsets.fromLTRB(10,10,10,0),
                                child: const Text(
                                  "요청사유:",
                                  style: ItemG1N14,
                                )),
                            Container(
                                margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                                child: InputForm(
                                    onlyDigit: false,
                                    readOnly: false,
                                    disable: false,
                                  contentPadding:const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    keyboardType: TextInputType.text,
                                    maxLines: 10,
                                    minLines: 5,
                                    valueText: _reqComment,
                                    hintText: '변경요청 사유를 입력하세요',
                                    textAlign: TextAlign.start,
                                    textStyle: ItemBkN16,
                                    hintStyle: ItemG1N16,
                                    onControl: (controller) {
                                      comment_controller = controller;
                                    },
                                    onChange: (String value) {
                                      _reqComment = value.toString().trim();
                                    },
                                )
                            ),
                          ],
                        ),
                      ),

                      // 처리상태
                      Visibility(
                          visible: compList.isNotEmpty,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
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
                                Row(
                                  children: [
                                    const Text("처리이력", style: ItemBkB16),
                                    const Spacer(),
                                    Text(item.dtRequest, style: ItemBkB16),
                                  ],
                                ),

                                const SizedBox(height: 10,),
                                _itemRow(1, "승인상태:", item.sState, true),
                                //_itemRow("신청일자:", item.dtRequest),
                                _itemRow(1, "판매가격:", item.mBeforePrice.toString(), false),
                                _itemRow(1, "요청가격:", item.mAfterPrice.toString(), false),
                                _itemRow(1, "승인가격:", item.mApprovedPrice.toString(), true),
                                _itemRow(5, "요청메모:", request, false),
                                Visibility(
                                  visible: reply.isNotEmpty,
                                  child: _itemRow(5, "요청회신:", reply, false),
                                ),
                              ],
                            ),
                          )
                      ),
                      SizedBox(height: 80,),
                    ],
                  ),
              )
            ),
            SizedBox(
              child: Row(
                children: [
                  ButtonSingle(
                      visible: true,
                      text: '변경요청',
                      enable: _reqComment.isNotEmpty && _reqPrice>0,
                      isBottomSide: true,
                      onClick: () {
                        _askSave();
                      }),
                ],
              ),
            )
          ],
        ));
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
                          fontSize: 14,
                          fontWeight: (bBold) ?  FontWeight.bold : FontWeight.normal,
                          letterSpacing: -1.6,
                          height: 1.2,
                          color: Colors.black,
                        ),
                        maxLines: maxLines,
                        overflow: TextOverflow.ellipsis,
                      ))
              ),
            ),
          ],
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
      mainAxisExtent = 20;
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
                                  fontWeight: (item.isPrice)
                                      ? FontWeight.bold : FontWeight.normal,
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

  void _askSave() {
    if (_reqPrice<1) {
      showToastMessage("상품 가격을 입력하세요.");
      return;
    }

    if (_reqComment.isEmpty) {
      showToastMessage("사유를 입력하세요.");
      return;
    }

    showYesNoDialogBox(
        context: context,
        height: 220,
        title: "확인",
        message: "상품의 판매가 변경을 요청하시겠습니까?",
        onResult: (isOK) {
          if (isOK) {
            _reqSave();
          }
        });
  }

  Future<void> _reqSave() async {
    _showProgress(true);
    await Remote.apiPost(
      context: context,
      session: _session,
      lStoreId: _session.getMyStore(),
      method: "taka/insertCompetePrice",
      params: {
        "lGoodsId": _lGoodsId,
        "mBeforePrice": _info.mSalesPrice,
        "mAfterPrice":_reqPrice,
        "sReasonMemo": _reqComment
      },
      onError: (String error) {},
      onResult: (dynamic data) async {
        if (data['status'] == "success") {
          showToastMessage("처리 되었습니다.");
          await _reqCompateData(false);
          //Navigator.pop(context, true);
        }
      },
    );
    _showProgress(false);
  }

  Future<void> _reqCompateData(bool bNotify) async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/listCompetePrice",
        params: {"lPageNo" : "1", "lRowNo" : "1", "lGoodsId":_lGoodsId},
        onError: (String error) {},
        onResult: (dynamic response) {
          var content = response['data'];
          if (content != null) {
            if (content is List) {
              compList = ItemCompetePrice.fromSnapshot(content);
            } else {
              compList = ItemCompetePrice.fromSnapshot([content]);
            }

            if(bNotify && compList.isNotEmpty) {
              showToastMessage("경합가격 변경요청 이력이 있습니다."
                  "\n승인상태를 확인하고 처리해주세요.");
            }
          }
        },
    );
    _showProgress(false);
  }

  Future<void> _requestGoodsInfo() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/goodsInfo",
        params: {"lGoodsId": _lGoodsId},
        onError: (String error) {},
        onResult: (dynamic data) {
          if (data['data'][0] != null) {
            var content = data['data'][0];
            _info = InfoGoods.fromJson(content);
            _priceList = _info.getPriceInfo();
            _photoList = _info.getPictInfoAddUrl(false);
            reqPrice_controller!.text = "";
            comment_controller!.text = "";
            _reqComment = "";
            if(salePrice_controller != null) {
              salePrice_controller!.text = numberFormat(_info.mSalesPrice);
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
          Future.microtask(() async {
            await _requestGoodsInfo();
            await _reqCompateData(true);
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
                Future.microtask(() async {
                  await _requestGoodsInfo();
                  await _reqCompateData(true);
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
}
