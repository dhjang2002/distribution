import 'package:distribution/common/dateForm.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/orderRequest/orderRequestInfo.dart';
import 'package:distribution/models/kItemRequestConfig.dart';
import 'package:distribution/models/kItemRequestMaster.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class OrderRequestList extends StatefulWidget {
  const OrderRequestList({Key? key}) : super(key: key);

  @override
  State<OrderRequestList> createState() => _OrderRequestListState();
}

class _OrderRequestListState extends State<OrderRequestList> {

  ItemRequestConfig _config = ItemRequestConfig();
  List<ItemRequestMaster> _reqList = [];
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() async {
      await _reqRequestConfig();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("입고요청 내역"),
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
                  }
              ),
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
    if(_reqList.isEmpty) {
      return Center(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.fromLTRB(10,50,10,50),
          color: Colors.white,
          child: Center(
            child:Text("데이터가 없습니다.", style: ItemG1N20),
          ),
        ),
      );
    }

    return Container(
      child: ListView.builder(
        itemCount: _reqList.length,
          itemBuilder: (context, index ) {
        return _itemInfo(_reqList[index]);
      }),
    );
  }

  Widget _itemInfo(ItemRequestMaster item ) {
    String sMessage = "발주처리";
    if(item.fRequestState==0) {
      sMessage = "입고요청서에 회신해주세요.";
    }
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top:1),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("입고요청서", style: ItemBkB18,),
                  SizedBox(height: 5,),
                  Text("발주일자: ${DateForm.getYDayStamp(item.dtRequested)}"),
                  SizedBox(height: 5,),
                  Text(sMessage,
                      style: (item.fRequestState==0) ? ItemR1B14 : ItemG1N14),
                ],
              )
          ),

          Expanded(
            flex: 3,
              child:SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () async {
                      _showDetail(item);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          width: 1.0,
                          color: (item.fRequestState==0) ? Colors.pink : Colors.grey
                      ),
                    ),
                    child: Text(
                      "${item.sRequestState}",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
              )
          ),
        ],
      ),
    );
  }

  Future <void> _reqRequestList() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/listDeliveryRequest",
        params: {
          "lPageNo": "1", "lRowNo": "100",
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
                _reqList = ItemRequestMaster.fromSnapshot(content);
              } else {
                _reqList = ItemRequestMaster.fromSnapshot([content]);
              }
            }
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

  Future <void> _reqRequestConfig() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/infoDeliveryEnv",
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

  Future<void> _showDetail(ItemRequestMaster item) async {
    await Navigator.push(
      context,
      Transition(
          child: OrderRequestInfo(
              config: _config,
              master: item),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    _reqRequestList();
  }
}
