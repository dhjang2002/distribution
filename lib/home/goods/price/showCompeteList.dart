// ignore_for_file: non_constant_identifier_names

import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kItemCompetePrice.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ShowCompeteList extends StatefulWidget {
  const ShowCompeteList({
    Key? key,
  }) : super(key: key);

  @override
  State<ShowCompeteList> createState() => _ShowCompeteListState();
}

class _ShowCompeteListState extends State<ShowCompeteList> {
  List<ItemCompetePrice> _goodsList = [];
  late AutoScrollController _controller;

  String title = "";
  bool _hasMore = true;
  final int lRowPerPage = 25;
  int lPageNo = 1;
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _controller = AutoScrollController();
    Future.microtask(() {
      _reqGoodList(lPageNo);
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
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
        title: const Text("경합가격-처리내역"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              Navigator.pop(context, false);
            }),
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 32,
                ),
                onPressed: () {
                  lPageNo = 1;
                  _reqGoodList(lPageNo);
                }),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-ShowCompeteList-key',
        validateMessage: "상품의 바코드를 스캔하세요.",
        waiting: _isInAsyncCall,
        onWillPop: onWillPop,
        allowPop: true, //_isComplete,
        useCamera: false,
        validate: _checkValidate,
        onScan: (barcode) {
          onScaned(barcode);
        },

        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      child: Container(
                          padding: const EdgeInsets.only(bottom: 64),
                          child: Column(children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_session.Stroe!.sName,
                                      style: ItemBkB18),
                                  const Spacer(),
                                  const Text("카운트: ", style: ItemBkN16),
                                  Text("${_goodsList.length} ",
                                      style: ItemBkB18),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 1,
                              color: Colors.black,
                            ),
                            Expanded(child: _renderGoodsList()),
                          ])),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white,
                        child: ButtonSingle(
                          text: '더보기',
                          isBottomPading: true,
                          enable: _hasMore,
                          visible: true,
                          onClick: () async {
                            lPageNo++;
                            _reqGoodList(lPageNo);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderGoodsList() {
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5),
      color: Colors.white,
      child: ListView.builder(
          controller: _controller,
          itemCount: _goodsList.length + 1,
          itemBuilder: (context, int index) {
            if (index == _goodsList.length) {
              return Container(
                height: 80,
              );
            }
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: _ItemInfo(_goodsList[index]));
          }),
    );
  }

  Widget _ItemInfo(ItemCompetePrice item) {
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
    return GestureDetector(
        onTap: () async {
          FocusScope.of(context).unfocus();
          _clearFocus();
          setState(() {
            item.hasFocus = true;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: (item.hasFocus) ? Colors.red : Colors.grey,
            ),
            color: Colors.white,
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _itemRow("승인상태:", item.sState, true),
                _itemRow("상품코드:", "${item.lGoodsID}", false),
                _itemRow("상품이름:", item.sGoodsName, false),
                _itemRow("판매가격:", item.mBeforePrice.toString(), false),
                _itemRow("요청가격:", item.mAfterPrice.toString(), false),
                _itemRow("승인가격:", item.mApprovedPrice.toString(), true),
                _itemRow("요청메모:", request, false),
                Visibility(
                  visible: reply.isNotEmpty,
                    child: _itemRow("요청회신:", reply, true),
                ),
              ]),
        ));
  }

  Widget _itemRow(String label, String value, bool bHilite) {
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
                style: (bHilite) ? ItemBkB16 : ItemBkN16,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ));
  }

  void _clearFocus() {
    for (var element in _goodsList) {
      element.hasFocus = false;
    }
  }

  void _clearTarget() {
    for (var element in _goodsList) {
      element.isTarget = false;
    }
  }

  bool _checkValidate(String barcode) {
    return true;
  }

  Future<bool> onWillPop() async {
    return true;
  }

  Future<void> onScaned(String barcode) async {
    // _clearFocus();
    //
    // int index = _goodsList.indexWhere((element) => element.sBarcode == barcode);
    // if (index >= 0) {
    //   _goodsList[index].hasFocus = true;
    //   _controller.scrollToIndex(index);
    //   setState(() {});
    // }
  }

  Future<void> _reqGoodList(int pageNo) async {
    if(pageNo==1) {
      _goodsList = [];
    }
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/listCompetePrice",
        params: {"lPageNo" : pageNo, "lRowNo" : lRowPerPage},
        onResult: (dynamic response) {
          if (kDebugMode) {
            var logger = Logger();
            logger.d(response);
          }
          var content = response['data'];
          if (content != null) {
            List <ItemCompetePrice> items = [];
            if (content is List) {
              items = ItemCompetePrice.fromSnapshot(content);
            } else {
              items = ItemCompetePrice.fromSnapshot([content]);
            }
            if(items.length<lRowPerPage) {
              _hasMore = false;
            }
            _goodsList.addAll(items);
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

}
