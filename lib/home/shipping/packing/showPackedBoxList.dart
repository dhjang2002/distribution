// ignore_for_file: non_constant_identifier_names

import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/shipping/packing/showPackedGoodsList.dart';
import 'package:distribution/models/kItemPackBox.dart';
import 'package:distribution/models/kItemPick.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:transition/transition.dart';

class ShowPackedBoxList extends StatefulWidget {
  final String title;
  final String workDate;
  final ItemPick itemPick;
  const ShowPackedBoxList({
      Key? key,
      required this.title,
      required this.workDate,
      required this.itemPick,
  }) : super(key: key);

  @override
  State<ShowPackedBoxList> createState() => _ShowPackedBoxListState();
}

class _ShowPackedBoxListState extends State<ShowPackedBoxList> {
  List<ItemPackBox> _packList = [];
  late AutoScrollController _controller;
  late SessionData _session;

  String _sBoxStore = "";
  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _controller = AutoScrollController();
    Future.microtask(() {
      String sDateCode = widget.workDate.replaceAll("-", "").substring(2);
      _sBoxStore = "$sDateCode-${widget.itemPick.sStoreCode}";
      _reqData();
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
        title: Text(widget.title),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
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
                  _reqData();
                }),
          ),
          // home
          Visibility(
            visible: false,
            child: IconButton(
                icon: const Icon(
                  Icons.home,
                  color: Colors.black,
                  size: 32,
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-ShowPackedBoxList-key',
        validateMessage: "상품의 바코드를 스캔하세요.",
        waiting: _isInAsyncCall,
        onWillPop: onWillPop,
        allowPop: false,//_isComplete,
        useCamera: true,
        validate: _checkValidate,
        onScan: (barcode) {
          //onScaned(barcode);
        },
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _renderTitle(),
              // 2. 메시지
              Visibility(
                  visible: _packList.isEmpty,
                  child:Container(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            children: const [
                              Text("이 거래처로 포장된 상품이 없습니다.",
                                style: ItemBkN14,),
                            ],
                          )

                      ),
                    ),
                  )
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      child: Visibility(
                        visible: true,//_packList.isNotEmpty,
                          child:Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: _renderBoxList()
                                ),
                              ],
                            )
                          )
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

  Widget _renderTitle() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10,5,10,5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            )),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _itemRow(1, "거  래  처:", widget.itemPick.sCustomerName, false),
          _itemRow(1, "처리상태", widget.itemPick.sState, false),
          _itemRow(1, "출하코드", _sBoxStore, false),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Text("박스수량:", style:ItemG1N12),
              const SizedBox(width: 3,),
              Text("${_packList.length}", style: ItemBkB14,)
            ],
          )
        ],
      ),
    );
  }

  Widget _renderBoxList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 80;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 3;
      mainAxisExtent = 80;
    } else if(rt<1.55) {
      crossAxisCount = 3;
      mainAxisExtent = 80;
    } else if(rt<2.45) {
      crossAxisCount = 2;
      mainAxisExtent = 80;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 84;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _packList.length%crossAxisCount;
    if(diff>0) {
      dumyCount = crossAxisCount + crossAxisCount - diff;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(2, 2, 2, 0),
      child: GridView.builder(
          controller: _controller,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemCount: _packList.length+dumyCount,
          itemBuilder: (context, int index) {
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index<_packList.length)
                    ? _ItemInfo(_packList[index]) : Container()
            );
          }),
    );
  }

  Widget _ItemInfo(ItemPackBox item) {
    return GestureDetector(
        onTap: () async {
          for (var element in _packList) {
            element.bSelect = false;
          }
          item.bSelect = !item.bSelect;
          setState(() {});
          //_showGoods(item.sBoxNo);
        },
        child: Container(
          margin:  const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: (item.bSelect) ? Colors.pink : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          child: Stack(
            children: [
              Positioned(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacer(),
                        _itemRow(1, "거  래  처:", item.sCustomerName, false),
                        _itemRow(1, "상품수량:", "${item.lTotalGoodsCount}", true),
                        _itemRow(1, "박스번호:", item.sBoxSeq, false),
                        Spacer(),
                      ],
                    )
                  )
              ),
              Positioned(
                  top: 0,
                  right: 5,
                  child: Visibility(
                    visible: item.bSelect,
                    child: GestureDetector(
                      child: IconButton(
                          onPressed: (){
                            _showGoods(item);
                          },
                          padding: EdgeInsets.zero,
                          constraints:const BoxConstraints(),
                          icon: const Icon(Icons.navigate_next, color: Colors.pink, size:32)
                      ),
                    ),
                  )
              ),

            ],
          )
        ));
  }

  Widget _itemRow(int maxLines, String label, String value, bool bHilite) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: 56,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                letterSpacing: -1.0,
                height: 1.2,
                color: Colors.grey,
              ),
            )
        ),
        Expanded(
          child: Text(value,
            maxLines: maxLines, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: (bHilite) ? FontWeight.bold : FontWeight.normal,
              letterSpacing: -1.5,
              height: 1.2,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  bool _checkValidate(String barcode) {
    return true;
  }

  Future <bool> onWillPop() async {
    return true;
  }

  /*
  Future <void> onScaned(String barcode) async {
    _clearFocus();
    int index = _packList.indexWhere((element) => element.sBoxNo == barcode);
    if (index >= 0) {
      _packList[index].hasFocus = true;
      _controller.scrollToIndex(index);
      setState(() {});
    } else {
      _boxNo = barcode;
      if(await _reqCheckBoxCode(_boxNo)==true) {
        _showGoods(_boxNo);
      }
    }
  }
  */

  Future <void> _reqData() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/listStorePacking",
        params: {
          "sBoxStore":_sBoxStore,
          "sCustomerName" : widget.itemPick.sCustomerName,
        },
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (kDebugMode) {
            print(response.toString());
          }

          if (response['status'] == "success") {
            var content = response['data'];
            if (content != null) {
              if (content is List) {
                _packList = ItemPackBox.fromSnapshot(content);
              } else {
                _packList = ItemPackBox.fromSnapshot([content]);
              }
            }
          }
        },
        onError: (String error) {});
    _showProgress(false);
  }

  Future <void> _showGoods(ItemPackBox item) async {
    String title = "박스내 상품 목록";
    await Navigator.push(context,
        Transition(
            child: ShowPackedGoodsList(
              title: title,
              sBoxSeq: item.sBoxSeq,
              sCustomerName: item.sCustomerName,
            ),
            transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
    _reqData();
  }
}
