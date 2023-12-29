
// ignore_for_file: file_names

import 'package:distribution/common/dateForm.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kItemOrder.dart';
import 'package:distribution/models/kItemOrderInfo.dart';
import 'package:distribution/models/kItemOrderList.dart';
import 'package:distribution/models/kItemRequestConfig.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:distribution/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class OrderDetail extends StatefulWidget {
  final ItemOrderList item;
  const OrderDetail({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  ItemOrderInfo _info = ItemOrderInfo();
  ItemRequestConfig _config = ItemRequestConfig();
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() async {
      await _reqRequestConfig();
      await _reqOrderInfo();
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
          centerTitle: true,
          title: Row(
            children: [
              Image.asset("assets/intro/intro_logo.png",
                  height: 64, fit: BoxFit.fitHeight),
              const Text(
                " 주문서",
                style: ItemBkB20,
              ),
            ],
          ),
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
                    size: 26,
                  ),
                  onPressed: () {
                    _reqOrderInfo();
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
              color: Colors.white,
              height: double.infinity,
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                        visible: _info.items.isNotEmpty,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1,),
                            _partHeader(),
                            _itemGoodsTitle(),
                            ListView.builder(
                                itemCount: _info.items.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return _itemGoods(index, _info.items[index]);
                                }
                             ),
                            const Divider(),
                            _partSummary(),
                            _partTail(),
                          ],
                        )
                    ),
                  ],
                ),
              ),
          )
        ),
      ],
    );
  }

  Widget _partHeader() {
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _labelItem("업  체  명:", _session.Stroe!.sName),
                          _labelItem("주  문  자:", _session.User!.sName!),
                          _labelItem("연  락  처:", _session.User!.sMobile!),
                          _labelItem("상  품  수:", _info.items.length.toString()),
                        ],
                      )),
                  Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _labelItem("처리상태:", _info.sOrderState),
                          _labelItem("주문일자:", DateForm.cvtDateStamp(_info.sDtOrdered)),
                          _labelItem("담  당  자:", _config.sName),
                          _labelItem("연  락  처:", _config.sPhone),
                        ],
                      )),
                ],
              ),
            ),
          ],
        )
    );
  }

  Widget _labelItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.only(bottom:3),
        child:Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              letterSpacing: -1.2, height: 1.2,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
            child: Text(
                value,
                style:TextStyle(fontSize: 14,
                  fontWeight: (value=="승인") ? FontWeight.bold : FontWeight.normal,
                  letterSpacing: -1.5,
                  height: 1.2,
                  color: (value=="승인") ? Colors.red : Colors.black,
                )
            )),
      ],
    ));
  }

  Widget _itemGoodsTitle() {
    return Container(
      margin: const EdgeInsets.only(top:10),
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      color: Colors.grey[100],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
              flex: 4,
              child: Text("상품명", style: ItemG1N14)),
          Expanded(
              flex: 2,
              child: Container(
                  alignment: Alignment.centerRight,
                  child: const Text("단가", style: ItemG1N14)
              )
          ),
          Expanded(
              flex: 2,
              child: Container(
                  alignment: Alignment.centerRight,
                  child: const Text("수량", style: ItemG1N14)
              )
          ),
          Expanded(
              flex: 2,
              child: Container(
                  alignment: Alignment.centerRight,
                  child: const Text("금액", style: ItemG1N14)
              )
          ),
        ],
      ),
    );
  }

  Widget _itemGoods(int index, ItemOrder info) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              flex: 4,
              child: Text(info.sGoodsName,
                  style:const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.normal,
                    letterSpacing: -1.8,
                    height: 1.2,
                    color: Colors.black,
                  )
              )
          ),
          Expanded(
              flex: 2,
              child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(numberFormat(info.mPrice),
                      style: ItemBkB15)
              )
          ),
          Expanded(
              flex: 2,
              child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(numberFormat(info.lGoodsCount),
                      style: ItemBkB15)
              )
          ),
          Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.centerRight,
                  child: Text(numberFormat(info.mPrice*info.lGoodsCount),
                      style: ItemBkB15)
              )
          ),
        ],
      ),
    );
  }

  Widget _partSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("합계", style: ItemBkB18,),
              const Spacer(),
              Text("${numberFormat(_info.totalPrice)}원 (VAT별도)", style: ItemBkB18,),
            ],
          ),
        ],
      ),
    );
  }

  Widget _partTail() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top:50),
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_config.tComment1,
              style: ItemBkN14,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              _config.tComment2,
              style: ItemBkN14,
              textAlign: TextAlign.justify,
            ),
          ],
        ));
  }

  Future <void> _reqOrderInfo() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/infoOrder",
        params: {"lWholeSaleOrderId": widget.item.lWholeSaleOrderID},
        onResult: (dynamic data) {
          if (data['status'] == "success" && data['data'] != null) {
            _info = ItemOrderInfo.fromJson(data['data']);
            setState(() {});
          }
          _showProgress(false);
        },
        onError: (String error) {
          _showProgress(false);
        }
    );
  }

  Future <void> _reqRequestConfig() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/infoWholeSaleOrderEnv",
        params: {},
        onResult: (dynamic response) {

          // if (kDebugMode) {
          //   var logger = Logger();
          //   logger.d(response);
          // }
          if (response['status'] == "success") {
            _config = ItemRequestConfig.fromJson(response['data']);
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

}
