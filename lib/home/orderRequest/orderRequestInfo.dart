import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dateForm.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/orderRequest/orderModifyQty.dart';
import 'package:distribution/models/kItemRequestConfig.dart';
import 'package:distribution/models/kItemRequestGoods.dart';
import 'package:distribution/models/kItemRequestMaster.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:distribution/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class OrderRequestInfo extends StatefulWidget {
  final ItemRequestConfig config;
  final ItemRequestMaster master;
  const OrderRequestInfo({
    Key? key,
    required this.config,
    required this.master,
  }) : super(key: key);

  @override
  State<OrderRequestInfo> createState() => _OrderRequestInfoState();
}

class _OrderRequestInfoState extends State<OrderRequestInfo> {
  List<ItemRequestGoods> _goodsList = [];
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() async {
      _reqRequestList();
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

  int _totalPriceA = 0;
  int _totalPriceB = 0;
  void _computePriceTotal() {
    for (var element in _goodsList) {
      _totalPriceA = _totalPriceA + element.mPriceA*element.lConfirmedCount;
      _totalPriceB = _totalPriceB + element.mPriceB*element.lConfirmedCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("입고요청서"),
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
                    _reqRequestList();
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
            )));
  }

  Widget _renderBody() {
    return Stack(
      children: [
        Positioned(
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 1. header
                    _partHeader(),
                    // 2. goods
                    _partBody(),
                    //_partSummary(),
                    // 3. tail
                    _partTail()
                  ],
                )
            )
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ButtonSingle(
              visible: true,
              text: '발주 확인',
              enable: (widget.master.fRequestState==0),
              onClick: () {
                _reqRequestConfirm();
              }
          ),
        ),
      ],
    );
  }

  Widget _partHeader() {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset("assets/intro/intro_logo.png",
                    height: 70, fit: BoxFit.fitHeight),
                Text(
                  " 입고요청서",
                  style: ItemBkB24,
                ),
                Spacer(),
                Text(
                  "발주일자: ",
                  style: ItemBkN14,
                ),
                Text(
                  "${DateForm.getYDayStamp(widget.master.dtRequested)}",
                  style: ItemBkN16,
                ),
              ],
            ),
            //SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _labelItem("발주담당:", widget.master.sEmployeeName),
                        _labelItem("Tel:", widget.config.sPhone),
                        _labelItem("Fax:", widget.config.sFax),
                        _labelItem("카톡ID:", widget.config.sKaKao),
                        _labelItem("E-Mail:", widget.config.sEmail),
                      ],
                    )),
                Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _labelItem("업  체  명:", _session.Stroe!.sName),
                        _labelItem("담  당  자:", _session.User!.sName!),
                        _labelItem("발주방법:", ""),
                      ],
                    )),
              ],
            ),
          ],
        ));
  }

  Widget _labelItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: ItemG1N12,
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
    );
  }

  Widget _partBody() {

    return Container(
      padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text("상품목록:"),
              Spacer(),
              Text("카운트: "),
              Text("${_goodsList.length}  ", style: ItemBkB16,),
            ],
          ),
          SizedBox(height: 5,),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _goodsList.length+1,
              itemBuilder: (context, index) {
                if(index>=_goodsList.length)
                  return _partSummary();
                return _itemInfo(index + 1, _goodsList[index]);
              }
          ),
        ],
      ),
    );
  }

  Widget _partSummary() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top:3),
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Divider(height: 20,),
          Row(
            children: [
              Text("합계", style: ItemBkB18,),
              Spacer(),
              Text("${numberFormat(_totalPriceA)}원 (VAT별도)", style: ItemBkB18,),
            ],
          ),

        ],
      ),
    );
  }

  Widget _partTail() {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.config.tComment1}",
              style: ItemBkN14,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "${widget.config.tComment2}",
              style: ItemBkN14,
            ),
          ],
        ));
  }

  bool _validate() {
    bool flag = true;
    for (var element in _goodsList) {
      if(element.fConfirm == 0)
        {
          flag = false;
          break;
        }
    }
    return flag;
  }

  Widget _itemInfo(int no, ItemRequestGoods item) {
    return Container(
      color: (item.fConfirm==0) ? Colors.white : Colors.grey[50],
      margin: EdgeInsets.only(top: 1),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _reqItem("NO", "$no"),
                  _reqItem("상  품  명:", item.sGoodsName),
                  _reqItem("매입단가:", "${numberFormat(item.mPriceA)}원 (VAT별도) "
                      " /  ${numberFormat(item.mPriceB)}원"),
                  _reqItem("발주수량:", "${numberFormat(item.lGoodsCount)}"),
                  _reqItem("납품수량:", "${numberFormat(item.lConfirmedCount)}"),
                ],
              )),
          Expanded(
              flex: 2,
              child:Visibility(
                visible: widget.master.fRequestState==0,
                  child: Container(
                    height: 36,
                    padding: EdgeInsets.only(left: 5),
                    child: OutlinedButton(
                      onPressed: () async {
                        await _doModify(item);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                            width: 1.0,
                            color: Colors.black
                        ),
                      ),
                      child: Text(
                        (item.fConfirm==0) ? "변경" : "확인",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ),
          ),
        ],
      ),
    );
  }

  Future <ItemRequestGoods?> _doModify(ItemRequestGoods item) async {
    var info = await Navigator.push(
      context,
      Transition(
          child: OrderModifyQty(
            item: item,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
    //return info;
    _reqRequestList();
  }

  Widget _reqItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: ItemG1N12,
          ),
        ),
        Expanded(
            child: Text(
              value,
                style:TextStyle(fontSize: 14,
                  fontWeight: FontWeight.normal,
                  letterSpacing: -1.8,
                  height: 1.2,
                  color: Colors.black,
                ),
            )
        ),
      ],
    );
  }

  Future <bool> _updateQtyAll() async {
    bool flag = false;
    List<Map> qtyList = [];
    for (var element in _goodsList) {
      qtyList.add({
        "lDeliveryRequestDetailId": element.lDeliveryRequestDetailID,
        "lConfirmedCount": element.lConfirmedCount,
        "sMemo": element.sMemo
      });
    }

    //_showProgress(true);
    // {"lDeliveryRequestDetailId" : "1233", "lConfirmedCount": "1", "sMemo": "메모입니다."}
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/updateDeliveryRequest",
        params: { "requestDatas":qtyList},
        onResult: (dynamic response) {
          // if (kDebugMode) {
          //   print(response.toString());
          // }
          if (response['status'] == "success") {
            flag = true;
          } else {
            showToastMessage(response['message']);
          }
        },
        onError: (String error) {}
    );
    //_showProgress(false);
    return flag;
  }

  Future<void> _reqRequestList() async {
    _goodsList = [];
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/listDeliveryRequestDetails",
        params: {
          "lDeliveryRequestId": widget.master.lDeliveryRequestID,
        },
        onResult: (dynamic response) {
          // Map<String, dynamic> response = params;
          // if (kDebugMode) {
          //   print(response.toString());
          // }

          if (response['status'] == "success") {
            var content = response['data'];
            if (content != null) {
              if (content is List) {
                _goodsList = ItemRequestGoods.fromSnapshot(content);
              } else {
                _goodsList = ItemRequestGoods.fromSnapshot([content]);
              }
              _computePriceTotal();
            }
          } else {
            showToastMessage(response['message']);
          }
        },
        onError: (String error) {});
    _showProgress(false);
  }

  Future<void> _reqRequestConfirm() async {

    bool flag = _validate();
    if(!flag) {
      showToastMessage("상품별 납품수량을 확인해주세요.");
      return;
    }

    // bool flag = await _updateQtyAll();
    // if(!flag) {
    //   showToastMessage("입고요청 처리 오류!");
    // }

    _showProgress(true);
    // {"lDeliveryRequestId" : "1233", "fRequestState" : " (0입고요청, 1납품확인, 2입고처리) "}
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/updateDeliveryRequestStatus",
        params: {
          "lDeliveryRequestId" : widget.master.lDeliveryRequestID,
          "fRequestState" : "1"
        },
        onResult: (dynamic response) {
          if (kDebugMode) {
            var logger = Logger();
            logger.d(response);
          }
          if (response['status'] == "success") {
            showToastMessage("처리되었습니다.");
            Navigator.pop(context);
          }
        },
        onError: (String error) {});
    _showProgress(false);
  }
}
