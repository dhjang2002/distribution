import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/selectGoods.dart';
import 'package:distribution/home/order/orderGoods.dart';
import 'package:distribution/models/kItemCart.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:distribution/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';


class CartGoods extends StatefulWidget {
  final int lStoreID;
  const CartGoods({
    Key? key,
    required this.lStoreID,
  }) : super(key: key);

  @override
  State<CartGoods> createState() => _CartGoodsState();
}

class _CartGoodsState extends State<CartGoods> {
  List<ItemCart> _cartList = [];

  bool _bCheckAll = false;
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() {
      _reqCartInfo();
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
          title: const Text("장바구니"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back, size: 28,),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: [
            Visibility(
              visible: _cartList.isNotEmpty,
              child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 26,
                  ),
                  onPressed: () {
                    _reqCartRemove();
                  }),
            ),
          ],
        ),
        body: ModalProgressHUD(
            inAsyncCall: _isInAsyncCall,
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                  color: Colors.grey[300],
                  height: double.infinity,
                  child: _renderBody()),
            )
        )
    );
  }

  Widget _renderBody() {
    //final double picHeight = MediaQuery.of(context).size.width * 0.7;
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          child: Opacity(
              opacity: (_cartList.isNotEmpty) ? 1.0 : 0.7,
              child: Container(
            padding: const EdgeInsets.all(10),
            height: 60,
            color: Colors.grey[300],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      if(_cartList.isNotEmpty) {
                        //if(!_bCheckAll) {
                        for (var element in _cartList) {
                          element.bCheck = !_bCheckAll;
                        }
                        //}
                        setState(() {
                          _bCheckAll = !_bCheckAll;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.transparent,
                      child: Icon(
                        (_bCheckAll)
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: (_bCheckAll) ? Colors.red : Colors.black,
                      ),
                    )),
                const Text(
                  "전체선택",
                  style: ItemBkN16,
                ),
                const Spacer(),
                SizedBox(
                    height: 60,
                    //padding: const EdgeInsets.only(right: 3),
                    child: OutlinedButton(
                      onPressed: () async {
                        _reqItemRemove();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.black,
                        side: const BorderSide(width: 1.0, color: ColorG4),
                      ),
                      child: const Text(
                        "선택 삭제",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )),
              ],
            ),
          )),
        ),
        Positioned(
            child: Container(
          margin: const EdgeInsets.only(bottom: 56, top: 60),
          color: Colors.grey[50],
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                    visible: _cartList.isEmpty,
                    child: const SizedBox(
                      //color: Colors.amber,
                      height: 400,
                      child: Center(
                          child: Text(
                        "등록된 상품이 없습니다.",
                        style: ItemG1N18,
                      )),
                    )),
                Visibility(
                    visible: _cartList.isNotEmpty,
                    child: ListView.builder(
                        itemCount: _cartList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return _itemGoods(_cartList[index]);
                        })),
              ],
            ),
          ),
        )),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            children: [
              Expanded(
                  flex: 1,
                  child: SizedBox(
                      height: 60,
                      //padding: const EdgeInsets.only(right: 3),
                      child: OutlinedButton(
                        onPressed: () async {
                          await _doSelectGoods();
                          setState(() {});
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.black,
                          side: const BorderSide(width: 1.0, color: ColorG4),
                        ),
                        child: const Text(
                          "상품 추가",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ))),
              Expanded(
                  flex: 1,
                  child: SizedBox(
                      height: 60,
                      child: OutlinedButton(
                        onPressed: (_cartList.isNotEmpty)? () async {
                          _reqStoreOrder();
                        } : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: Colors.red,
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey,
                          side: const BorderSide(width: 1.0, color: ColorG4),
                        ),
                        child: const Text(
                          "주문하기",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )))
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemGoods(ItemCart info) {
    return GestureDetector(
      onTap: () async {
        ItemCart goods = await _showPushGoods(info.lGoodsID, info.lCount, true);
        if (goods.lCount != info.lCount) {
          goods.lBasketID = info.lBasketID;
          _reqItemModify(goods);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 3),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () {
                  setState(() {
                    info.bCheck = !info.bCheck;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.transparent,
                  child: Icon(
                    (info.bCheck)
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: (info.bCheck) ? Colors.red : Colors.black,
                  ),
                )),
            Expanded(
              child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(info.lGoodsID.toString(),
                              style: ItemBkN15,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis)),
                      Container(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(info.sGoodsName,
                              style: ItemBkB15,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis)),
                      Container(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "수량: ",
                                style: ItemBkN16,
                              ),
                              Text(
                                info.lCount.toString(),
                                style: ItemBkB16,
                              ),
                              const Spacer(),
                              // const Text(
                              //   "가격: ",
                              //   style: ItemBkN16,
                              // ),
                              Text(
                                "${numberFormat(info.lPrice*info.lCount)}원",
                                style: ItemBkB16,
                              ),
                            ],
                          )),
                      Divider(height: 1,)
                    ],
                  )
              ),
            )
          ],
        ),
      ),
    );
  }

  Future <void> _doSelectGoods() async {
    var result = await Navigator.push(
        context,
        Transition(
            child: SelectGoods(isMulti: false),
            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));

    if (result != null) {
      ItemGoodsList item = result[0];
      var cartItem = await _showPushGoods(item.lGoodsId!, 1, false);
      _reqItemAdd(cartItem);
    }
  }

  Future <ItemCart> _showPushGoods(int lGoodsId, int qty, bool isUpdate) async {
    return await Navigator.push(
        context,
        Transition(
            child: OrderGoods(
              lGoodsId: lGoodsId,
              qty: qty,
              isUpdate: isUpdate,
            ),
            transitionEffect: TransitionEffect.RIGHT_TO_LEFT)
    );
  }

  Future <void> _reqCartInfo() async {
    _showProgress(true);
    _cartList = [];
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/cartInfo",
        params: {
          //"lStoreID": widget.lStoreID.toString()
        },
        onResult: (dynamic data) {
          if (data['status'] == "success" && data['data'] != null) {
            var content = data['data'];
            _cartList = ItemCart.fromSnapshot(content);
            setState(() {});
          }
          _showProgress(false);
        },
        onError: (String error) {
          _showProgress(false);
        }
    );
  }

  Future <void> _reqItemModify(ItemCart item) async {
    _showProgress(true);
    _cartList = [];
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/cartUpdate",
        params: {"id": item.lBasketID, "qty":item.lCount},
        onResult: (dynamic data) {
          _showProgress(false);
          if (data['status'] == "success") {
            _reqCartInfo();
            //setState(() {});
          }
        },
        onError: (String error) {
          _showProgress(false);
        }
    );
  }

  Future <void> _reqItemRemove() async {
    //showToastMessage("장바구니 항목 삭제.");
    List<String> keyList = [];
    for (var element in _cartList) {
      if (element.bCheck) {
        keyList.add(element.lBasketID);
      }
    }

    if(keyList.isEmpty) {
      showToastMessage("삭제할 상품을 선택하세요.");
      return;
    }
    
    _showProgress(true);
    _cartList = [];
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/cartRemove",
        params: {
          "id":keyList},
        onResult: (dynamic data) {
          _showProgress(false);
          if (data['status'] == "success") {
            showToastMessage("처리되었습니다.");
            _reqCartInfo();
          }
        },
        onError: (String error) {
          _showProgress(false);
        }
    );
  }

  Future <void> _reqItemAdd(ItemCart item) async {
    /*
    "{
    ""lStoreId"" : ""743"",
    ""lGoodsId"" : ""152581"",
    ""lEmployeeId"" : ""337"",
    ""qty"" : ""2"",
    ""sGoodsName"": ""산요 GT-R 슈펴100m 4호 16lb""
}"
     */
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/cartAdd",
        params: {
          //"lStoreID": widget.lStoreID.toString(), 
          "sGoodsName":item.sGoodsName,
          "lGoodsId":item.lGoodsID,
          "qty":item.lCount,
          "lPrice":item.lPrice,
        },
        onResult: (dynamic data) {
          _showProgress(false);
          if (data['status'] == "success") {
            _reqCartInfo();
          }
        },
        onError: (String error) {
          _showProgress(false);
        }
    );
    
  }

  Future <void> _reqCartRemove() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/cartDelete",
        params: {},
        onResult: (dynamic data) {
          _showProgress(false);
          showToastMessage("장바구니 상품이 삭제되었습니다.");
          if (data['status'] == "success") {
            _reqCartInfo();
          }
        },
        onError: (String error) {
          _showProgress(false);
        }
    );
  }

  Future <void> _reqStoreOrder() async {

    if(_cartList.isEmpty) {
      showToastMessage("주문할 상품을 추가해주세요.");
    }

    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/insertOrder",
        params: {},
        onResult: (dynamic data) {
          _showProgress(false);
          if (data['status'] == "success") {
            showToastMessage("상품 주문이 완료되었습니다.");
            Navigator.pop(context);
          }else {
            showToastMessage(data['message']);
          }
        },
        onError: (String error) {
          _showProgress(false);
        }
    );

  }
}
