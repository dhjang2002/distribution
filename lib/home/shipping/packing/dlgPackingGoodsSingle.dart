// ignore_for_file: non_constant_identifier_names

import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/inputForm.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kItemPack.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class _ContentView extends StatefulWidget {
  final ItemPack item;
  final bool isNew;
  final Function(bool bDirty, ItemPack? item) onResult;

  const _ContentView({
    Key? key,
    required this.item,
    required this.isNew,
    required this.onResult,
  }) : super(key: key);

  @override
  State<_ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<_ContentView> {
  final ItemPack _item = ItemPack();
  int _remainCount = 0;
  int currPackingCount = 0;
  @override
  void initState() {
    _item.copy(widget.item);
    if (kDebugMode) {
      print("_item.lTotalGoodsCount:${_item.lTotalGoodsCount}");
      print("_item.lTotalPickingCount:${_item.lTotalPickingCount}");
      print("_item.lTotalPackingCount:${_item.lTotalPackingCount}");
      print("_item.lCurrentPackingCount:${_item.lCurrentPackingCount}");
    }

    if(widget.isNew) {
      currPackingCount = _item.lTotalPackingCount;
      _remainCount = _item.lTotalPickingCount - _item.lTotalPackingCount;
    } else {
      currPackingCount = _item.lTotalPackingCount-_item.lTotalGoodsCount;
      _remainCount = _item.lTotalPickingCount - currPackingCount;
    }

    if (kDebugMode) {
      print("_remainCount:${_remainCount}");
    }

    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.maxFinite,
        child: Stack(
          children: [

            Positioned(
              child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_item.sBarcode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight:FontWeight.normal,
                        letterSpacing: -1.5,
                        height: 1.2,
                        color: Colors.black,
                      )
                  ),
                  Text(_item.sGoodsName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.5,
                        height: 1.2,
                        color: Colors.black,
                      )
                  ),
                  const Divider(height: 15),

                  Row(
                    children: [
                      const Text("* 포장 완료수량 / 피킹수량:", style: ItemBkN14),
                      const SizedBox(width: 5),
                      Text("$currPackingCount"
                          " / ${_item.lTotalPickingCount}", style: ItemBkB16),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.fromLTRB(5,10,5,10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: Colors.pink,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        const Text("잔여수량:", style: ItemG1N14),
                        const SizedBox(width: 5),
                        Text("$_remainCount", style: ItemBkB16),
                        const Icon(Icons.arrow_right_rounded, color: Colors.pink,),
                        const Text("포장수량:", style: ItemG1N14),
                        const SizedBox(width: 3,),

                        SizedBox(
                            width: 80,
                            child: InputForm(
                                onlyDigit: true,
                                touchClear: true,
                                readOnly: false,
                                disable: false,
                                onControl: (controller) {
                                  _item.controller = controller;
                                },
                                contentPadding: const EdgeInsets.fromLTRB(3,5,3,5),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                valueText: _item.lTotalGoodsCount.toString(),
                                textStyle: ItemBkB16,
                                hintStyle: ItemG1N15,
                                hintText: '',
                                onChange: (String value) {
                                  print(value);
                                  if(int.tryParse(value) != null) {
                                    _item.lTotalGoodsCount = int.parse(value);
                                  }
                                  // else {
                                  //   _item.controller!.text = "";
                                  // }
                                  //setState(() {});
                                })
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      const Spacer(),
                      SizedBox(
                          width: 100,
                          child:OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              widget.onResult(false, null);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor:Colors.grey[200],
                              side: const BorderSide(width: 1.0, color: ColorG4),
                            ),
                            child: const Text(
                              "취소",
                              style: TextStyle(
                                color: Colors.black, fontSize: 14,
                              ),
                            ),
                          )
                      ),
                      const SizedBox(width: 5,),
                      SizedBox(
                          width: 100,
                          child:OutlinedButton(
                            onPressed: () async {
                              if(!_validate(_item)) {
                                return;
                              }
                              widget.onResult(true, _item);
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.black,
                              side: const BorderSide(width: 1.0, color: ColorG4),
                            ),
                            child: Text(
                              (widget.isNew) ? "추가" : "수정",
                              style: const TextStyle(
                                color: Colors.white, fontSize: 14,
                              ),
                            ),
                          )
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),

            Positioned(
              right: 0, top:0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(10,5,10,5),
                  color: Colors.amber,
                  child: Text((widget.isNew) ? "추가" : "수정",
                    style: ItemBkB12,
                  ),
                )
            ),
          ],
        )
    );
  }

  bool _validate(ItemPack item) {
    if(item.lTotalGoodsCount<1) {
      showToastMessage("정확한 수량을 입력하세요.");
      return false;
    }

    if(_remainCount<0) {
      showToastMessage("피킹 수량을 초과합니다.");
      return false;
    }

    if(item.lTotalGoodsCount>_remainCount) {
      showToastMessage("피킹 수량을 초과합니다.");
      return false;
    }

    return true;
  }
}

void DlgPackingGoodsSingle({
  required BuildContext context,
  required ItemPack item,
  required bool isNew,
  required Function(bool bDirty, ItemPack? value) onResult}) {

  showDialog (
    context: context,
    //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 5),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return GestureDetector(
                onTap: (){
                  FocusScope.of(context).unfocus();
                },
                child: _ContentView(
                    item: item,
                    isNew: isNew,
                    onResult: (bool isAdd, ItemPack? value) {
                      onResult(isAdd, value);
                    }),
              );
            },
          ),
        ),
      );
    },
  );
}