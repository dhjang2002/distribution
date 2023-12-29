// ignore_for_file: non_constant_identifier_names, file_names
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/goodsDetail.dart';
import 'package:distribution/models/kItemPackedGoods.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ListShippingGoods extends StatefulWidget {
  final String title;
  final String sBoxSeq;
  final String sCustomerName;
  const ListShippingGoods({
      Key? key,
      required this.title,
      required this.sBoxSeq,
      required this.sCustomerName,
  }) : super(key: key);

  @override
  State<ListShippingGoods> createState() => _ListShippingGoodsState();
}

class _ListShippingGoodsState extends State<ListShippingGoods> {
  List<ItemPackedGoods> _packedGoodsList = [];
  late AutoScrollController _controller;

  int _totalPackedGoods = 0;
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
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-PackGoodsInfo-key',
        validateMessage: "상품의 바코드를 스캔하세요.",
        waiting: _isInAsyncCall,
        onWillPop: onWillPop,
        allowPop: false,//_isComplete,
        useCamera: false,
        validate: _checkValidate,
        onScan: (barcode) {
          onScaned(barcode);
        },

        child: Container(
          color: Colors.white,
          //margin: EdgeInsets.only(top:400),
          child: Column(
            children: [
              _renderTitle(),
              // 2. 메시지
              Visibility(
                  visible: _packedGoodsList.isEmpty,
                  child:Container(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            children: const [
                              Text("이 박스에 포장된 상품이 없습니다.",
                                style: ItemBkN14,),
                            ],
                          )

                      ),
                    ),
                  )
              ),

              // 3. 상품내용
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      child: Visibility(
                        visible: _packedGoodsList.isNotEmpty,
                        child:_renderGoodsList()
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
          _itemRow(1,"거  래  처:", widget.sCustomerName, false),
          _itemRow(1,"박스번호", widget.sBoxSeq, false),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Text("상품수량:", style:ItemG1N12),
              const SizedBox(width: 3,),
              Text("${_packedGoodsList.length} ($_totalPackedGoods)", style: ItemBkB14,)
            ],
          )
        ],
      ),
    );
  }

  Widget _renderGoodsList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 100;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 2;
      mainAxisExtent = 74;
    } else if(rt<1.55) {
      crossAxisCount = 2;
      mainAxisExtent = 74;
    } else if(rt<2.42) {
      crossAxisCount = 1;
      mainAxisExtent = 74;
    } else if(rt<2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 74;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _packedGoodsList.length%crossAxisCount;
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
          itemCount: _packedGoodsList.length+dumyCount,
          itemBuilder: (context, int index) {
            return AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: (index<_packedGoodsList.length)
                    ? _ItemInfo(_packedGoodsList[index]) : Container()
            );
            //return _boxItem(index, _goodsList[index]);
          }),
    );
  }

  Widget _ItemInfo(ItemPackedGoods item) {
    return GestureDetector(
        onTap: () async {
          FocusScope.of(context).unfocus();
          _clearFocus();
          setState(() {
            item.hasFocus = true;
          });
        },
        child: Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: (item.hasFocus) ? Colors.pink : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
            child: Stack(
            children: [
              Positioned(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        _itemRow(1,"바  코  드:", item.sBarcode, false),
                        _itemRow(1,"상품이름:", item.sGoodsName, false),
                        _itemRow(1,"출고수량:", item.lPackingCount.toString(), true),
                        const Spacer(),
                      ],
                    ),
                  ),
              ),

              Positioned(
                  top: 5,right: 5, left:0,
                  child: Visibility(
                      visible: item.hasFocus,
                      child:Container(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            const Spacer(),
                            // info
                            IconButton(
                                onPressed: (){
                                  showPopGoodsDetail(
                                      context: context,
                                      lGoodsId: item.lGoodsId);
                                },
                                padding: EdgeInsets.zero,
                                constraints:const BoxConstraints(),
                                icon: const Icon(Icons.info_outline,
                                    color: Colors.blue, size:18)
                            ),
                          ],
                        ),
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
            width: 55,
            child: Text(
              label,
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

  void _clearFocus() {
    for (var element in _packedGoodsList) {
      element.hasFocus = false;
    }
  }

  bool _checkValidate(String barcode) {
    // int index = items.indexWhere((element) => element.sBarcode == barcode);
    // return (index >= 0);
    return true;
  }

  Future <bool> onWillPop() async {
    return true;
  }

  Future<void> onScaned(String barcode) async {
    /*
    //barcode = "4994942201167";
    ItemPack item = await _reqGoodInfo(barcode);
    if(item.lGoodsId<1) {
      showToastMessage("거래처 상품이 아닙니다.");
      return;
    }
    
    _clearFocus();
    int index = _packItems.indexWhere((element) => element.sBarcode == barcode);
    if (index >= 0) {
      _packItems[index].hasFocus = true;
      _controller.scrollToIndex(index);
     
    } else {
      item.hasFocus = true;
      _packItems.add(item);
    }
    setState(() {});
    */
  }

  Future <void> _reqData() async {
    _totalPackedGoods = 0;
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/listPackingGoods",
        params: {
          "sBoxSeq":widget.sBoxSeq,
        },
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            var content = response['data'];
            if (content != null) {
              if (content is List) {
                _packedGoodsList = ItemPackedGoods.fromSnapshot(content);
              } else {
                _packedGoodsList = ItemPackedGoods.fromSnapshot([content]);
              }

              _packedGoodsList.forEach((element) {
                if(element.lPackingCount>0) {
                  _totalPackedGoods += element.lPackingCount;
                }
              });
            }

          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }
}
