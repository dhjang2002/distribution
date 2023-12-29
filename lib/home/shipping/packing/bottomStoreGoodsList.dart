// ignore_for_file: non_constant_identifier_names
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kItemPack.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Color _colorGrayBack = Color(0xFFF4F4F4);

class StoreGoodsList extends StatefulWidget {
  final List<String> idsList;
  final String sBoxSeq;
  final Function(bool bOK, List<ItemPack> items) onClose;
  const StoreGoodsList({
    Key? key,
    required this.sBoxSeq,
    required this.idsList,
    required this.onClose,
  }) : super(key: key);

  @override
  State<StoreGoodsList> createState() => _StoreGoodsListState();
}

class _StoreGoodsListState extends State<StoreGoodsList> {
  List<ItemPack> _packItems = [];
  late SessionData _session;

  int _totalCheckedGoods = 0;
  int _totalCheckedGoodsSum = 0;

  bool _bWait = false;
  bool _bCheckAll = false;

  void _showProgress(bool flag) {
    setState(() {
      _bWait = flag;
    });
  }

  int _totalPackItems = 0;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() {
      _reqListStoreGoodsAll();
    });
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final szHeight = MediaQuery.of(context).size.height * 0.90;
    return Scaffold(
      backgroundColor: _colorGrayBack,
      appBar: AppBar(
        elevation: 0.5,
        title: const Text("상품목록"),
        automaticallyImplyLeading: false,
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 32,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  widget.onClose(false, _packItems);
                }),
          ),
        ],
      ),
      body:Container(
        height: szHeight,
          color: Colors.white,
          child: Stack(
            children: [
              Positioned(
                //left: 0, top: 0, right: 0, bottom: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            _bCheckAll = !_bCheckAll;
                            _totalCheckedGoods = 0;
                            for (var element in _packItems) {
                              element.checked = _bCheckAll;
                              if(element.checked) {
                                _totalCheckedGoods++;
                              }
                            }
                            _updateCheckCount();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10,10,10,10),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Icon((_bCheckAll) ?
                                      Icons.check_box: Icons.check_box_outline_blank,
                                        color: Colors.pink,),
                                      const Text(" 전체선택"),
                                      const SizedBox(width: 10,),
                                      Visibility(
                                        visible: _totalCheckedGoods>0,
                                        child: Text("$_totalCheckedGoods ($_totalCheckedGoodsSum)",
                                          style: ItemBkB14,),
                                      )
                                    ],
                                  ),
                                  const Spacer(),
                                  Text("상품수량: ${_packItems.length} ($_totalPackItems)", style: ItemBkN14,)
                                ],
                              ),
                            ],
                          ),
                        )
                      ),
                      const Divider(height: 1,),
                      Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 56),
                              child:ListView.builder(
                              itemCount: _packItems.length,
                              itemBuilder: (context, index) {
                                return _itemGoods(_packItems[index]);
                              })
                          )
                      ),
                    ],
                )
              ),
              Positioned(
                bottom: 0,left: 0,right: 0,
                  child: SizedBox(
                    child:ButtonSingle(
                        visible: true,
                        isBottomPading: true,
                        isBottomSide: true,
                        text: "상품추가",
                        enable: _totalCheckedGoods>0,
                        onClick: () {
                          Navigator.pop(context);
                          widget.onClose(true, _packItems);
                        }),
                  )
              ),
              Positioned(
                  child: Visibility(
                    visible: _bWait,
                    child: Container(
                      color: const Color(0x1f000000),
                      width: double.infinity,
                      height: double.infinity,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  )
              ),
            ],
          )
      ),
    );
  }

  Widget _itemGoods(ItemPack item) {
    int value = item.lTotalPickingCount - item.lTotalPackingCount;
    String sPackingCount = "$value";
    Color? backgroundColor = Colors.white;
    return GestureDetector(
        onTap: (){
        setState(() {
          item.checked = !item.checked;
          _updateCheckCount();
        });
      },
      child:Container(
      margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.fromLTRB(5,5,5,5),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
            color: backgroundColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.transparent,
                child: Icon((item.checked) ?
                    Icons.check_box :
                    Icons.check_box_outline_blank,
                  color: (item.checked) ? Colors.pink : Colors.black,
                ),
              ),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _itemRow("바  코  드:", item.sBarcode, false),
                      _itemRow("상  품  명:", item.sGoodsName, false),
                      _itemRow("출고수량:", sPackingCount, true),
                          //" / ${item.lTotalPickingCount}", true),
                    ],
                  )
              ),
            ],
          ),
        )
    );
  }

  Widget _itemRow(String label, String value, bool bHilite) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: 56,
            child: Text(
              label,
              style: ItemG1N12,
            )),
        Expanded(
          child: Text(value,
            maxLines: 1,overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14,
              fontWeight: (bHilite) ? FontWeight.bold : FontWeight.normal,
              letterSpacing: -1.5,
              height: 1.1,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }


  void _updateCheckCount() {
    _totalCheckedGoods = 0;
    _totalCheckedGoodsSum = 0;
    for (var element in _packItems) {
      if(element.checked) {
        _totalCheckedGoods++;
        int count = element.lTotalPickingCount - element.lTotalPackingCount;
        if(count>0) {
          _totalCheckedGoodsSum += count;
        }
      }
    }
  }

  Future <void> _reqListStoreGoodsAll() async {
    _totalPackItems = 0;
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/listCustomerGoods",
        params: {
          "Ids":   widget.idsList,
          "sBoxSeq":widget.sBoxSeq,
        },
        onError: (String error) {},
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            var content = response['data'];
            if (content != null) {
              if (content is List) {
                _packItems = ItemPack.fromSnapshot(content);
              } else {
                _packItems = ItemPack.fromSnapshot([content]);
              }

              for (var element in _packItems) {
                int count = element.lTotalPickingCount - element.lTotalPackingCount;
                if(count>0) {
                  _totalPackItems += count;
                }
              }
              setState(() {});
            }
          }
        },
    );
    _showProgress(false);
  }
}

Future<void> bottomStoreGoodList({
  required BuildContext context,
  required String sBoxSeq,
  required List<String> idsList,
  required Function(bool bOK, List<ItemPack> items) onResult}) {
  double viewHeight = MediaQuery.of(context).size.height * 0.90;
  return showModalBottomSheet(
    context: context,
    enableDrag: false,
    isScrollControlled: true,
    useRootNavigator: false,
    isDismissible: true,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: SizedBox(
          height: viewHeight,
          child: StoreGoodsList(
            idsList: idsList,
            sBoxSeq:sBoxSeq,
            onClose: (bool bOK, List<ItemPack> items) {
              onResult(bOK, items);
            },
          ),
        ),
      );
    },
  );
}