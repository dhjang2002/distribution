// ignore_for_file: non_constant_identifier_names, file_names
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/warehousing/confirm/listPackedBoxInGoods.dart';
import 'package:distribution/models/klistConfirmPacking.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:transition/transition.dart';

class ListPackedBoxInfo extends StatefulWidget {
  const ListPackedBoxInfo({Key? key,
  }) : super(key: key);

  @override
  State<ListPackedBoxInfo> createState() => _ListPackedBoxInfoState();
}

class _ListPackedBoxInfoState extends State<ListPackedBoxInfo> {
  late AutoScrollController _controller;

  String workDay = "";
  late SessionData _session;
  List<ListConfirmPacking> _itemList = [];
  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _controller = AutoScrollController();
    Future.microtask(() async {
      _reqPackedBoxList();
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

  Future <bool> onWillPop() async {
    return true;
    //return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("입고내역"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(Icons.refresh, size: 32,),
                onPressed: () {
                  _reqPackedBoxList();
                  //_reqHousingBoxList();
                }
            ),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-ListWareHousing-key',
        onWillPop:onWillPop,
        validateMessage: "박스 바코드를 스캔하세요.",
        waiting: false,
        useCamera: false,
        validate: _checkValidate,
        onScan: (barcode) async {
          onScaned(barcode);
        },

        child: Container(
          color: Colors.white,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned(
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned(
                                child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(10,10,10,5),
                                        child: Row(
                                          children: [
                                            Text(_session.Stroe!.sName, style:ItemBkB14),
                                            const Spacer(),
                                            const Text("입고수량: ", style:ItemG1N14),
                                            Text("${_itemList.length} ", style:ItemBkB14),
                                          ],
                                        ),
                                      ),
                                      //const Divider(height: 10, color: Colors.black,),
                                      Expanded(child: _renderBoxList()),
                                    ]
                                )
                            ),
                          ],
                        ),
                      ),
                  ],
                    ),
              ),
              Positioned(
                  child: Visibility(
                      visible: _bWaiting,
                      child: Container(
                        color: const Color(0x1f000000),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderBoxList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 110;
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
      crossAxisCount = 2;
      mainAxisExtent = 80;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _itemList.length%crossAxisCount;
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
          itemCount: _itemList.length+dumyCount,
          itemBuilder: (context, int index) {
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index<_itemList.length)
                    ? _ItemInfo(_itemList[index]) : Container()
            );
            //return _boxItem(index, _goodsList[index]);
          }),
    );
  }

  Widget _ItemInfo(ListConfirmPacking item) {
    return GestureDetector(
      onTap: () {
          _showGoodsList(item);
      },

      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(5),
            color: (item.fState == STATUS_PACK_SCONFIRM) ?  Colors.white : Colors.white,
        ),
        child:Opacity(
        opacity: 1.0,
            child:Stack(
              children: [
                Positioned(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Column(
                        children: [
                          const Spacer(),
                          SizedBox(height: 5,),
                          _itemRow(1, "박스번호:", item.sBoxNo, true),
                          _itemRow(1, "출하번호:", item.sBoxSeq, false),
                          _itemRow(1, "상품정보:", "${item.lGoodsKind} "
                              " (${item.lTotalGoodsCount})", true),
                          const Spacer(),
                        ],
                      ),
                    )
                ),
                Positioned(
                  top: 2, right: 2,
                    child:SizedBox(
                        width: 50,
                        height: 22,
                        child: OutlinedButton(
                          onPressed: () async {
                            _showGoodsList(item);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                                width: 1.0,
                                color: (item.fState < STATUS_PACK_SCONFIRM)
                                    ? Colors.pink : Colors.grey
                            ),
                          ),
                          child: Text(
                            item.sState,
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: -0.5,
                              color: (item.fState < STATUS_PACK_SCONFIRM)
                                  ? Colors.pink : Colors.grey,

                            ),
                          ),
                        )
                    ),
                ),
              ],
            )
        )
      ),
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
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                letterSpacing: -1.5,
                height: 1.2,
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

  Future <void> onScaned(String barcode) async {}

  Future<void> _showGoodsList(ListConfirmPacking item) async {
    await Navigator.push(context,
      Transition(
          child: ListPackedBoxInGoods(
            master:item,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    _reqPackedBoxList();
  }

  int _lConfirmCount = 0;
  void _checkComplete() {
    _lConfirmCount = 0;
    _itemList.forEach((element) {
      if(element.fState==STATUS_PACK_SCONFIRM) {
        _lConfirmCount++;
      }
    });
  }

  // 포장된 박스 리스트 정보를 가져온다
  Future <void> _reqPackedBoxList()  async {
    _showProgress(true);
    _itemList = [];
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/listConfirmPacking",
        params: {}, // "dPackingConfirmDateTime":workDay
        onError: (String error){},
        onResult: (dynamic data) {
          if(data['data'] != null) {
            if (data['data'] is List) {
              _itemList = ListConfirmPacking.fromSnapshot(data['data']);
            }
            else {
              _itemList = ListConfirmPacking.fromSnapshot([data['data']]);
            }
          }
          if(_itemList.isEmpty) {
            showToastMessage("데이터가 없습니다.");
          }
        },
    );
    _checkComplete();
    _showProgress(false);
  }
}
