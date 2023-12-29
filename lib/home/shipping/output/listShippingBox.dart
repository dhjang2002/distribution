// ignore_for_file: non_constant_identifier_names, file_names
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/shipping/output/listShippingGoods.dart';
import 'package:distribution/models/klistConfirmPacking.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:distribution/utils/calendarDaySelect.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:transition/transition.dart';

class ListShippingBox extends StatefulWidget {
  const ListShippingBox({
    Key? key,
  }) : super(key: key);

  @override
  State<ListShippingBox> createState() => _ListShippingBoxState();
}

class _ListShippingBoxState extends State<ListShippingBox> {
  late AutoScrollController _controller;

  String workDay     = "";
  String sDateBoxSeq = "";
  late SessionData _session;
  List<ListConfirmPacking> _itemList = [];
  bool _hasMore = false;
  int lPageNo = 1;
  int lRowPerPage = 50;
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
        title: const Text("출하내역"),
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
                  Icons.calendar_month,
                  size: 24,
                ),
                onPressed: () {
                  _daySelect(false);
                }),
          ),

          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(Icons.refresh, size: 28,),
                onPressed: () {
                  lPageNo=1;
                  _reqPackedBoxList();
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
          child: Column(
            children: [
              Expanded(
                child: Stack(
                children: [
                  Positioned(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 58),
                        child: Column(
                            children: [
                              Container(
                                  padding: const EdgeInsets.fromLTRB(5,5,10,5),
                                  color: Colors.grey[100],
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                          onPressed: (){
                                            _daySelect(false);
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(
                                              Icons.calendar_month, size:16)
                                      ),
                                      Text(
                                          (workDay.isNotEmpty) ? workDay : "전체",
                                          style:ItemBkB14),
                                      const Spacer(),
                                      const Text("진행: ", style: ItemG1N12,),
                                      Text("${_itemList.length} ", style:ItemBkB14),
                                      //const SizedBox(width: 5,),
                                    ],
                                  )
                              ),

                              Expanded(child: _renderGoodsList()),
                            ]
                        ),
                      )
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
                        isBottomSide: true,
                        enable: _hasMore,
                        visible: true,
                        onClick: () async {
                          lPageNo++;
                          _reqPackedBoxList();
                        },
                      ),
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
              ),),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderGoodsList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 94;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 3;
      mainAxisExtent = 80;
    } else if(rt<1.55) {
      crossAxisCount = 2;
      mainAxisExtent = 80;
    } else if(rt<2.45) {
      crossAxisCount = 2;
      mainAxisExtent = 80;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 74;
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
    Color cStatus = Colors.black;
    if(item.fState>=STATUS_PACK_MCONFIRM) {    // 승인완료
      cStatus = Colors.grey;
    } else if(item.fState>STATUS_PACK_END) {    // 출하완료
      cStatus = Colors.pink;
    }else if(item.fState>=STATUS_PACK_END) {    // 포장완료
      cStatus = Colors.black;
    }
    return GestureDetector(
      onTap: () {
        _showGoods(item);
      },
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(3),
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
                          _itemRow(1, "거래처명:", item.sCustomerName,true),
                          _itemRow(1, "출하번호:", item.sBoxSeq, false),
                          _itemRow(1, "상품정보:", "${item.lGoodsKind} "
                              "(${item.lTotalGoodsCount})", false),
                          const Spacer(),
                        ],
                      ),
                    )
                ),
                Positioned(
                  top: 2, right: 2,
                    child:SizedBox(
                        width: 50,
                        height: 24,
                        child: OutlinedButton(
                          onPressed: () async {
                            _showGoods(item);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                                width: 1.0,
                                color: Colors.grey
                            ),
                          ),
                          child: Text(
                            item.sState,
                            style: TextStyle(
                              fontSize: 10,
                              color: cStatus,

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

  Future <void> onScaned(String barcode) async {

  }

  Future <void> _showGoods(ListConfirmPacking item) async {
    String title = "상품 목록";
    await Navigator.push(context,
      Transition(
          child: ListShippingGoods(
            title: title,
            sBoxSeq: item.sBoxSeq,
            sCustomerName: item.sCustomerName,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }

  // 포장된 박스 리스트 정보를 가져온다
  // 출하데이터 조회
  // - 모든 출하 데이터, 박스연번 order desc and 고객이름 asc, paging, size 100
  Future <void> _reqPackedBoxList()  async {
    _showProgress(true);
    Map<String,dynamic> req = {};
    if(sDateBoxSeq.isNotEmpty) {
      req = {"sDateBoxSeq":sDateBoxSeq, "lPageNo": lPageNo, "lRowNo": lRowPerPage, };
    }
    else {
      req = {"lPageNo": lPageNo, "lRowNo": lRowPerPage};
    }
    _hasMore = false;
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/listPackingHistory",
        params: req,
        onResult: (dynamic data) {
          var content = data['data'];
          if(content != null) {
            List <ListConfirmPacking> items = [];
            items = ListConfirmPacking.fromSnapshot(content);
            if(items.length>=lRowPerPage) {
              _hasMore = true;
            }
            if(lPageNo<2) {
              _itemList = items;
            } else {
              _itemList.addAll(items);
            }
          }
        },
        onError: (String error){}
    );
    _showProgress(false);
  }

  Future<void> _daySelect(final bool bStart) async {
    var result = await Navigator.push(context,
      Transition(child: CalendarDaySelect(
        target: "packing",
        seletedDay: workDay,
      ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if(result != null && result.toString().isNotEmpty) {
      workDay = result;
      sDateBoxSeq = workDay.replaceAll("-", "").substring(2,8);
    }
    else {
      workDay = "";
      sDateBoxSeq = "";
    }

    lPageNo=1;
    _reqPackedBoxList();
  }

}
