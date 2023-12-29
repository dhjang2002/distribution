
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/inputFormTouchClear.dart';
import 'package:distribution/common/cardPhotoItem.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kGoodsFiles.dart';
import 'package:distribution/models/kInfoGoods.dart';
import 'package:distribution/models/kItemCart.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:distribution/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class ItemOrderGoods {
  String sGoodsName;
  int lGoodsId;
  int qty;
  int price;
  int totalPrice;
  TextEditingController? controller;
  ItemOrderGoods({
    this.sGoodsName = "",
    this.lGoodsId = 0,
    this.qty = 0,
    this.price = 0,
    this.totalPrice = 0,
    this.controller,
  });

  void updateTotalPrice() {
    totalPrice = price * qty;
  }
}

class OrderGoods extends StatefulWidget {
  final int lGoodsId;
  final int qty;
  final bool isUpdate;
  const OrderGoods({
    Key? key,
    required this.lGoodsId,
    required this.qty,
    required this.isUpdate,
  }) : super(key: key);

  @override
  State<OrderGoods> createState() => _OrderGoodsState();
}

class _OrderGoodsState extends State<OrderGoods> {
  bool _isOpenOrder = true;
  InfoGoods _info = InfoGoods();
  final List<CardPhotoItem> _photoList = [];

  ItemOrderGoods _orderInfo = ItemOrderGoods();
  String _storeName = "";

  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _storeName = _session.Stroe!.sName;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("상품정보"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back, size: 28,),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: [
            Visibility(
              visible: false,
              child: IconButton(
                  icon: const Icon(
                    Icons.photo,
                    size: 26,
                  ),
                  onPressed: () {}),
            ),
          ],
        ),
        body: ModalProgressHUD(
          inAsyncCall: _isInAsyncCall,
          child: Container(color: Colors.white, child: _renderBody()),
        ));
  }

  Widget _renderBody() {
    final double picHeight = MediaQuery.of(context).size.width * 0.7;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
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

        // 2. 상품정보-일반
        Container(
          margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const Text(
                "상품정보",
                style: ItemBkB18,
              ),
              const SizedBox(height: 10,),
              //_itemRow("상품매장:",  _storeName),
              _itemRow("상 품 명:", _info.sName),
              _itemRow("바 코 드:", _info.sBarcode),
              _itemRow("상품구분:", _info.sGoodsType),
              _itemRow("판매상태:", _info.sState),
              _itemRow("판매가격:", numberFormat(_orderInfo.price)),
              _itemRow("재고현황:", (_info.rMainStock>0) ? "O" : "X"),
              //_itemRow("재고현황:", numberFormat(_info.rMainStock)),
            ],
          ),
        ),

        const SizedBox(height: 10,),

        // 4. 상품주문
        Visibility(
          visible: _isOpenOrder,
            child: Container(
          margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.amber,),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children:  const [
                  Text("장바구니", style: ItemBkB18,),
                  Spacer(),
                ],
              ),

              const Divider(height: 20,),

              //const SizedBox(height: 10,),
              _cardOrder(),

              const SizedBox(height: 10,),
              Visibility(
                  visible: _isOpenOrder,
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                      height: 55,
                      width: double.infinity,
                      padding: const EdgeInsets.only(right: 3),
                      child:OutlinedButton(
                        onPressed: () async {
                          if(_orderInfo.qty<1) {
                            showToastMessage("상품 수량을 입력해주세요.");
                            return;
                          }
                          ItemCart item = ItemCart(
                              sGoodsName: _orderInfo.sGoodsName,
                              lCount: _orderInfo.qty,
                              lGoodsID: _orderInfo.lGoodsId,
                              lPrice: _orderInfo.price
                          );
                          Navigator.pop(context, item);
                        },

                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.black,
                          side: const BorderSide(width: 1.0, color: ColorG4),
                        ),
                        child: Text(
                          (!widget.isUpdate)? "상품 추가" : "확인",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                  )
              ),
            ],
          ),
        ),
        ),

        Visibility(
            visible: !_isOpenOrder,
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                height: 55,
                width: double.infinity,
                padding: const EdgeInsets.only(right: 3),
                child:OutlinedButton(
                  onPressed: () async {
                    setState((){
                      _isOpenOrder = true;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.black,
                    side: const BorderSide(width: 1.0, color: ColorG4),
                  ),
                  child: const Text(
                    "주문하기",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ))),
        const SizedBox(height: 350,)
      ],
    )));
  }

  Widget _cardOrder() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
      color: Colors.white,
      child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 1),
                    color: Colors.white,
                    child: IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                      icon: const Icon(Icons.remove, color: Colors.black),
                      onPressed: () {
                        if(_orderInfo.qty>0) {
                          _orderInfo.qty--;
                          _orderInfo.updateTotalPrice();
                          setState(() {
                            _orderInfo.controller!.text = _orderInfo.qty.toString();
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(
                      width: 100,
                      child: InputFormTouchClear(
                          readOnly: false,
                          disable: false,
                          onControl: (TextEditingController controller) {
                            _orderInfo.controller = controller;
                          },
                          contentPadding: const EdgeInsets.all(5),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          valueText: _orderInfo.qty.toString(),
                          textStyle: ItemBkB20,
                          hintStyle: ItemG1N20,
                          hintText: '',
                          onChange: (String value) {
                            String qty = value.trim();
                            if(qty.isNotEmpty) {
                              _orderInfo.qty = int.parse(qty);
                              _orderInfo.updateTotalPrice();
                              setState(() {

                              });
                            }
                          }
                      )
                  ),

                  Container(
                    margin: const EdgeInsets.only(left: 1),
                    color: Colors.white,
                    child: IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () {
                        //if(_orderInfo.qty<_info.rMainStock)
                        {
                          setState(() {
                            _orderInfo.qty++;
                            _orderInfo.updateTotalPrice();
                            _orderInfo.controller!.text =
                                _orderInfo.qty.toString();
                          });
                        }
                      },
                    ),
                  ),
                  const Spacer(),
                  //const Text("가격:", style: ItemBkN16),
                  Text("${numberFormat(_orderInfo.totalPrice)}원", style: ItemBkB16),
                  const SizedBox(width: 10),
                ],
              ),
    );
  }

  Widget _itemRow(String label, String value) {
    return Container(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: ItemG1N15,
                )),
            Expanded(
              flex: 8,
              child: Text(
                value,
                style: ItemBkN15,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ));
  }

  Future<void> _requestGoodsInfo() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/goodsInfo",
        params: {"lGoodsId": widget.lGoodsId.toString()},
        onResult: (dynamic data) async {
          _showProgress(false);
          if (data['data'][0] != null) {
            var content = data['data'][0];
            _info = InfoGoods.fromJson(content);
            _info.computeSalesPrice();
            _setPictInfoAddUrl(_info.picInfo!);
            _orderInfo.lGoodsId = widget.lGoodsId;
            _orderInfo.qty = widget.qty;
            _orderInfo.sGoodsName = _info.sName;
            await _requestGoodsPrice();
            _orderInfo.updateTotalPrice();
            print("_orderInfo.price = ${_orderInfo.price}");
            setState(() {});
          }
        },
        onError: (String error) {
          _showProgress(false);
        }
    );
  }

  Future <void> _requestGoodsPrice() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/infoGoodsPrice",
        params: {"lGoodsId": widget.lGoodsId.toString()},
        onResult: (dynamic response) {
          // {"status":"success","message":"","data":{"price":32614}}
          print(response);
          if (response['status'] == "success") {
            var data = response['data'];
            _orderInfo.price = (data['price']!=null) ? int.parse(data['price'].toString()) : 0;
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

  void _setPictInfoAddUrl(GoodsFiles picInfo) {
    _photoList.clear();
    if (picInfo.sVideo.isNotEmpty) {
      _photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo.sVideo}", type: "v"));
    }

    if (picInfo.sMainPicture.isNotEmpty) {
      _photoList.add(
          CardPhotoItem(url: "$URL_IMAGE/${picInfo.sMainPicture}", type: "p"));
    }

    if (picInfo.sSubPic1.isNotEmpty) {
      _photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo.sSubPic1}", type: "p"));
    }

    if (picInfo.sSubPic2.isNotEmpty) {
      _photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo.sSubPic2}", type: "p"));
    }

    if (picInfo.sSubPic3.isNotEmpty) {
      _photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo.sSubPic3}", type: "p"));
    }

    if (picInfo.sSubPic4.isNotEmpty) {
      _photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo.sSubPic4}", type: "p"));
    }
  }


}
