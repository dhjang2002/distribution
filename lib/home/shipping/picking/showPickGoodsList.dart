// ignore_for_file: non_constant_identifier_names

import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/goodsDetail.dart';
import 'package:distribution/models/kItemPick.dart';
import 'package:distribution/models/kItemPickConfirm.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ShowPickedGoodsList extends StatefulWidget {
  final String workDate;
  final ItemPick pick;
  const ShowPickedGoodsList({
      Key? key,
      required this.workDate,
      required this.pick,
  }) : super(key: key);

  @override
  State<ShowPickedGoodsList> createState() => _ShowPickedGoodsListState();
}

class _ShowPickedGoodsListState extends State<ShowPickedGoodsList> {
  List<ItemPickConfirm> _pickList = [];
  late AutoScrollController _controller;

  String title = "";

  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _controller = AutoScrollController();
    Future.microtask(() {
      _reqData();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
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
        title: const Text("픽업상품 내역"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              Navigator.pop(context, false);
            }
        ),
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
                  size: 32,
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-PickDetail-key',
        validateMessage: "상품의 바코드를 스캔하세요.",
        waiting: false,
        onWillPop: onWillPop,
        allowPop: false,//_isComplete,
        useCamera: false,
        validate: _checkValidate,
        onScan: (barcode) {
          onScaned(barcode);
        },

        child: Stack(
          children: [
            Positioned(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [

                    // 1. 타이틀 정보
                    _renderTitle(),

                    // 2. 메시지
                    Visibility(
                        visible: _pickList.isEmpty,
                        child:Container(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.white,
                                child: Column(
                                  children: const [
                                    Text("이 피킹된 상품이 없습니다.",
                                      style: ItemBkN14,),
                                  ],
                                )

                            ),
                          ),
                        )
                    ),

                    // 3. 상품리스트
                    Expanded(child: _renderPickList()),
                  ],
                ),
              ),
            ),
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

  int _totalPickedCount = 0;
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
          _itemRow(1,"출고번호", widget.pick.sShippingNo, true),
          _itemRow(1,"출고정보:", "${widget.pick.sCustomerName}"
              " / ${widget.pick.sCustomerTel}", false),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Text("상품수량:", style:ItemG1N12),
              const SizedBox(width: 3,),
              Text("${_pickList.length} ($_totalPickedCount)", style: ItemBkB14,)
            ],
          )
        ],
      ),
    );
  }

  Widget _renderPickList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 120;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 2;
      mainAxisExtent = 90;
    } else if(rt<1.55) {
      crossAxisCount = 2;
      mainAxisExtent = 90;
    } else if(rt<2.42) {
      crossAxisCount = 1;
      mainAxisExtent = 90;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 90;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _pickList.length%crossAxisCount;
    if(diff>0) {
      dumyCount = crossAxisCount + crossAxisCount - diff;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 1),
      child: GridView.builder(
          controller: _controller,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemCount: _pickList.length+dumyCount,
          itemBuilder: (context, int index) {
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index<_pickList.length)
                    ? _ItemInfo(index, _pickList[index]) : Container()
            );
          }),
    );
  }

  Widget _ItemInfo(int index, ItemPickConfirm item) {
    Color bgColor = Colors.white;
    if(item.fState != 0) {
      // 요청/확인 값이 다른경우
      if(item.lGoodsCount != item.lPickingCount) {
        bgColor = Colors.amber.shade50;
      }
      else {
        bgColor = Colors.white;//Colors.grey.shade100;
      }
    }
    return GestureDetector(
        onTap: () async {
          FocusScope.of(context).unfocus();
          _clearFocus();
          _clearTarget();
          setState(() {
            item.hasFocus = true;
          });
        },
        child: Container(
            margin: const EdgeInsets.fromLTRB(0,2,2,0),
            child: Stack(
              children: [
                Positioned(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5,5,5,5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: (item.hasFocus)? Colors.pink : Colors.grey,
                        ),
                        color: bgColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _itemRow(1, "거래처명:", "${item.sShippingNo} / ${item.sStoreName}",
                              false),
                          _itemRow(1, "바  코  드:", item.sBarcode, false),
                          _itemRow(1, "상품이름:", item.sGoodsName, false),
                          _itemRow(1, "확인/요청:", "${item.lPickingCount} / ${item.lGoodsCount}",
                              true),
                        ],
                      ),
                    )
                ),
                Positioned(
                    right:5, top: 3,
                    child: Visibility(
                        visible: item.hasFocus,
                        child:Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: (){
                                  showPopGoodsDetail(
                                      context: context,
                                      lGoodsId: item.lGoodsId);
                                },
                                padding: const EdgeInsets.all(5),
                                constraints:const BoxConstraints(),
                                icon: const Icon(Icons.info_outline,
                                    color: Colors.black, size:24)
                            ),
                          ],
                        )
                    )
                ),
              ],
            )
        )
    );
  }

  Widget _itemRow(int maxLines, String label, String value, bool bHilite) {
    return Row(
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
                letterSpacing: -1.6,
                height: 1.1,
                color: Colors.grey,
              ),
            )
        ),
        Expanded(
          child: Text(value,
            maxLines: maxLines, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: (bHilite) ? FontWeight.bold : FontWeight.normal,
              letterSpacing: -1.8,
              height: 1.15,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void _clearFocus() {
    for (var element in _pickList) {
      element.hasFocus = false;
    }
  }

  void _clearTarget() {
    for (var element in _pickList) {
      element.isTarget = false;
    }
  }

  bool _checkValidate(String barcode) {
    // int index = items.indexWhere((element) => element.sBarcode == barcode);
    // return (index >= 0);
    return false;
  }


  Future <bool> onWillPop() async {
    return true;
  }

  Future<void> onScaned(String barcode) async {
    //barcode = "4994942201167";
    //_clearTarget();
    _clearFocus();
    for (var element in _pickList) {
      if (element.sBarcode == barcode) {
        element.isTarget = true;
      } else {
        element.isTarget = false;
      }
    }

    int index = _pickList.indexWhere((element) => element.sBarcode == barcode);
    if (index >= 0) {
      _pickList[index].hasFocus = true;
      _controller.scrollToIndex(index);
      setState(() {});
    }
  }

  Future <void> _reqData() async {
    _totalPickedCount = 0;
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/shippingGoodsList",
        params: {
          //"dShipping": widget.workDate,
          //"fState": STATUS_PICK_END,
          "Ids":[widget.pick.lShippingID]
        },
        onError: (String error) {},
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            var content = response['data'];
            if (content != null) {
              if (content is List) {
                _pickList = ItemPickConfirm.fromSnapshot(content);
              } else {
                _pickList = ItemPickConfirm.fromSnapshot([content]);
              }
              _pickList.forEach((element) {
                if(element.lPickingCount>0) {
                  _totalPickedCount += element.lPickingCount;
                }
              });
            }
          } else {
            showToastMessage(response['message']);
          }
        },
    );
    _showProgress(false);
  }
}
