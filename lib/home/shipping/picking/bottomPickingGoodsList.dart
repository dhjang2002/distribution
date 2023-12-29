// ignore_for_file: non_constant_identifier_names

import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/inputForm.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/cardGoods.dart';
import 'package:distribution/models/kItemPickConfirm.dart';
import 'package:flutter/material.dart';

class _ContentView extends StatefulWidget {
  final double menuHeight;
  final List<ItemPickConfirm> items;
  final Function(bool bOk, List<ItemPickConfirm> result) onResult;
  const _ContentView({
    Key? key,
    required this.menuHeight,
    required this.items,
    required this.onResult,
  }) : super(key: key);

  @override
  State<_ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<_ContentView> {
  List<ItemPickConfirm> list = [];
  bool _bSelectAll = true;

  @override
  void initState() {
    for (var item in widget.items) {
      // if (item.fState != STATUS_PICK_END && item.lPickingCount == 0) {
      //   item.lPickingCount = item.lGoodsCount;
      // }
      if(item.lPickingEmpId<1) {
        item.lPickingCount = item.lGoodsCount;
      }
      list.add(item);
    }

    for (var element in list) {
      element.bValid = false;
    }

    setState(() {
      _checkAll(_bSelectAll);
      _updateSumCount(false);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[300],
        child: Stack(
          children: [
            Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
                child:SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildGoodInfo(),
                      _buildHeader(),
                      _renderPickList(),
                      //const Divider(),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 10, 5, 10),
                          color: Colors.grey[300],
                          child: Row(
                            children: [
                              const Spacer(),
                              SizedBox(
                                  width: 100,
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      widget.onResult(false, []);
                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: Colors.grey[200],
                                      side: const BorderSide(
                                          width: 1.0, color: ColorG4),
                                    ),
                                    child: const Text(
                                      "취소",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )),
                              const SizedBox(
                                width: 5,
                              ),
                              SizedBox(
                                  width: 100,
                                  height: 46,
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      if (!_validate()) {
                                        setState(() {

                                        });
                                        return;
                                      }
                                      widget.onResult(true, list);
                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: Colors.black,
                                      side: const BorderSide(
                                          width: 1.0, color: ColorG4),
                                    ),
                                    child: const Text(
                                      "확인",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )),
                            ],
                          )
                      ),
                    ],
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

  int _lTotalPickingCount = 0;
  int _lTotalGoodsCount   = 0;
  void _updateSumCount(bool bRefresh) {
    _lTotalPickingCount = 0;
    _lTotalGoodsCount = 0;
    for (var element in list) {
      if (element.bSelect) {
        _lTotalPickingCount += element.lPickingCount;
        _lTotalGoodsCount   += element.lGoodsCount;
      }
    }
    if(bRefresh) {
      setState(() {

      });
    }
  }

  void _checkAll(bool bCheck) {
    for (var element in list) {
      element.bSelect = bCheck;
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      width: double.infinity,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          //borderRadius: BorderRadius.circular(10),
          // border: Border(
          //   bottom: BorderSide(
          //     width: 1,
          //     color: Colors.grey,
          //   ),
          // ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _bSelectAll = !_bSelectAll;
                _checkAll(_bSelectAll);
                setState(() {});
              },
              child: Container(
                  width: 110,
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Icon((_bSelectAll)
                            ? Icons.check_box
                            : Icons.check_box_outline_blank),
                      ),
                      const Text("전체선택"),
                    ],
                  )),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "출고수량 :  ",
                  style: ItemG1N14,
                ),
                Text("$_lTotalPickingCount",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.2,
                      color: Colors.black,
                    )),
              ],
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        ));
  }

  Widget _buildGoodInfo() {
    ItemPickConfirm item = widget.items[0];
    return Container(
      padding: const EdgeInsets.only(top:5),
        child:CardGoods(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          lGoodsId: item.lGoodsId,
          sGoodsName: item.sGoodsName,
          sBarcode: item.sBarcode,
        )
    );
  }

  Widget _renderPickList() {
    int crossAxisCount = 1;
    double mainAxisExtent = 160;
    final double rt = getMainAxis(context);
    if (rt < 1.18) {
      crossAxisCount = 2;
      mainAxisExtent = 60;
    } else if (rt < 1.55) {
      crossAxisCount = 2;
      mainAxisExtent = 60;
    } else if (rt < 2.20) {
      crossAxisCount = 1;
      mainAxisExtent = 60;
    } else if (rt < 2.70) {
      crossAxisCount = 1;
      mainAxisExtent = 60;
    }

    if(list.length<2) {
      crossAxisCount = 1;
    }

    return Container(
      color: Colors.grey[300],
      //margin: EdgeInsets.fromLTRB(0, 1, 0, 0),
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemCount: list.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, int index) {
            return _ItemInfo(list[index]);
            //return _ItemInfo(list[0]);
          }),
    );
  }

  Widget _ItemInfo(ItemPickConfirm item) {
    return Container(
      margin: EdgeInsets.only(top:1),
      //padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        //borderRadius: BorderRadius.circular(5),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
          right: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(1),
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: (item.bValid) ? Colors.pink : Colors.white,
          ),
          color: Colors.white,
          //borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // 1. check box
            GestureDetector(
              onTap: () {
                item.bSelect = !item.bSelect;
                _updateSumCount(false);
                setState(() {});
              },
              child: Container(
                width: 32,
                height: 28,
                //color: Colors.red,
                padding: const EdgeInsets.only(right: 10),
                child: Icon((item.bSelect)
                    ? Icons.check_box
                    : Icons.check_box_outline_blank),
              ),
            ),

            // 2 item
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.sStoreName, style: ItemBkB12,),
                Text(item.sShippingNo, style: ItemBkN12,),
                //const Text("요청수량/출고수량 :", style: ItemBkN12),
              ],
            ),

            const Spacer(),
            const SizedBox(width: 5),
            Text("${item.lGoodsCount}", style: ItemBkB16),
            const Spacer(),
            const SizedBox(
              width: 32,
              height: 32,
              child: Icon(
                  Icons.arrow_right_rounded,
                  color: Colors.pink, size:24
              ),
            ),
            const Spacer(),
            SizedBox(
                width: 70,
                height: 30,
                child: InputForm(
                  onlyDigit: true,
                  touchClear: true,
                  readOnly: false,
                  disable: false,
                  onControl: (controller) {
                    item.controller = controller;
                  },
                  contentPadding: const EdgeInsets.fromLTRB(5, 7, 5, 2),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  valueText: item.lPickingCount.toString(),
                  textStyle: ItemBkB16,
                  hintStyle: ItemG1N16,
                  hintText: '',
                  onChange: (String value) {
                    //String qty = value.replaceAll("[^\d]", "");
                    if (int.tryParse(value) != null) {
                      item.lPickingCount = int.parse(value);
                      _updateSumCount(true);
                    }
                    //print("qty====>$qty");
                    //item.controller!.text = qty;
                  },
                  onSubmitted: (String value) {
                    //String qty = value.replaceAll("[^\d]", "");
                    if (int.tryParse(value) != null) {
                      item.lPickingCount = int.parse(value);
                    }
                    else {
                      //item.lPickingCount = -1;
                      // item.controller!.text =
                      //     item.lPickingCount.toString();
                    }
                  },
                )
            ),
          ],
        ),
      ),
    );
  }

  bool _validate() {
    bool flag = true;
    for (var element in list) {
      element.bValid = false;
    }

    _updateSumCount(false);
    for (var element in list) {
      if(!element.bSelect) {
        continue;
      }

      print("element.lGoodsCount;${element.lGoodsCount}");
      print("element.lPickingCount;${element.lPickingCount}");

      if(element.lPickingCount>element.lGoodsCount) {
        element.bValid = true;
        showToastMessage("피킹 수량을 확인해주세요.");
        return false;
      }

      if (element.controller!.text.isEmpty || element.lPickingCount < 0) {
        element.bValid = true;
        showToastMessage("피킹 수량을 확인해주세요.");
        return false;
      }
    }

    if(_lTotalPickingCount>_lTotalGoodsCount) {
      showToastMessage("피킹 총 수량이 초과되었습니다.");
      return false;
    }

    return true;
  }
}

Future<void> PopPickingGoodsList({
  required BuildContext context,
  required List<ItemPickConfirm> items,
  required Function(bool bOK, List<ItemPickConfirm> result) onResult}) {
  final double viewHeight = MediaQuery.of(context).size.height * 0.80;
  final double menuHeight = viewHeight * .7;
  return showModalBottomSheet(
    context: context,
    enableDrag: false,
    isScrollControlled: true,
    useRootNavigator: false,
    isDismissible: false,
    builder: (context) {
      return WillPopScope(
          onWillPop: () async {
            onResult(false, []);
            return true;
          },
          child: SizedBox(
            height: viewHeight,
            child: GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  color: Colors.black,
                  child: _ContentView(
                      menuHeight: menuHeight,
                      items: items,
                      onResult: (bool bOK, List<ItemPickConfirm> result) {
                        onResult(bOK, result);
                      }),
                )),
          ));
    },
  );
}
