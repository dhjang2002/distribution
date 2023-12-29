import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/selectGoods.dart';
import 'package:distribution/home/order/orderDetail.dart';
import 'package:distribution/home/order/orderGoods.dart';
import 'package:distribution/models/kItemCart.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/models/kItemOrderList.dart';
import 'package:distribution/models/kItemRequestConfig.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class OrderList extends StatefulWidget {
  final int lStoreID;
  const OrderList({
    Key? key,
    required this.lStoreID,
  }) : super(key: key);

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List<ItemOrderList> _cartList = [];


  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() {
      _reqOrderList();
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
          title: const Text("주문내역"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back, size: 28,),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: [
            Visibility(
              visible: true,
              child: IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    size: 26,
                  ),
                  onPressed: () {
                    _reqOrderList();
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
    return Stack(
      children: [
        Positioned(
            child: Container(
          //margin: const EdgeInsets.only(bottom: 56, top: 60),
          color: Colors.grey[50],
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                    visible: _cartList.isEmpty,
                    child: const SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: Center(
                          child: Text(
                        "주문내역이 없습니다."
                            "\n앱에서 주문한 내역만 표시됩니다.",
                        style: ItemG1N20,
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
                        }
                    )
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _itemGoods(ItemOrderList info) {
    return GestureDetector(
      onTap: () async {
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 3),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex:8,
              child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 5),
                          child: Row(
                            children: [
                              // Text("주문서", style: ItemBkN18),
                              // Spacer(),
                              Text(" (${info.sOrderState})", style: (info.fOrderState==0) ? ItemBkN15 : ItemR1B15),
                            ],
                          ),
                      ),
                      Container(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(info.sDtOrdered.toString(),
                              style: ItemBkB18,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis)
                      ),
                    ],
                  )
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: IconButton(
                  icon:Icon(
                    Icons.navigate_next_outlined,
                    size: 32),
                  onPressed: (){
                    _showOrderDetail(info);
                  },
              )
              )
            ),
          ],
        ),
      ),
    );
  }

  Future <void> _showOrderDetail(ItemOrderList item) async {
    var result = await Navigator.push(
        context,
        Transition(
            child: OrderDetail(item: item),
            transitionEffect: TransitionEffect.RIGHT_TO_LEFT)
    );
  }

  Future <void> _reqOrderList() async {
    _showProgress(true);
    _cartList = [];
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/listOrder",
        params: {
        },
        onResult: (dynamic data) {
          if (data['status'] == "success" && data['data'] != null) {
            var content = data['data'];
            _cartList = ItemOrderList.fromSnapshot(content);
            setState(() {});
          }
          _showProgress(false);
        },
        onError: (String error) {
          _showProgress(false);
        }
    );
  }
}
