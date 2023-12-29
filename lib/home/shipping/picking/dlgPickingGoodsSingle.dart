// ignore_for_file: non_constant_identifier_names, file_names

import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/inputForm.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kItemPickConfirm.dart';
import 'package:flutter/material.dart';

class _ContentView extends StatefulWidget {
  final ItemPickConfirm item;
  final bool isNew;
  final Function(bool isNew, ItemPickConfirm? item) onResult;

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

  final ItemPickConfirm _item = ItemPickConfirm();
  @override
  void initState() {
    _item.copy(widget.item);
    if(_item.fState == 0 && _item.lPickingCount==0) {
      _item.lPickingCount = _item.lGoodsCount;
    }
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

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: Colors.amber,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 4,
                        child: Row(

                          crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Spacer(),
                              const Text("요청수량:", style: ItemG1N14),
                              const SizedBox(width: 5),
                              Text("${_item.lGoodsCount}", style: ItemBkB16),
                            ]
                        )
                    ),

                    Expanded(
                        flex: 6,
                        child: Row(
                            children: [
                              const Icon(Icons.arrow_right_rounded, color: Colors.pink,),
                              const Text("출고수량:", style: ItemG1N14),
                              const SizedBox(
                                width: 5,
                              ),
                              SizedBox(
                                width: 70,
                                child: InputForm(
                                    onlyDigit: true,
                                  touchClear: false,
                                  readOnly: false,//widget.bWorkLock ,
                                  disable: false,
                                  onControl:
                                      (TextEditingController controller) {
                                        _item.controller = controller;
                                  },
                                  contentPadding: const EdgeInsets.all(3),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  valueText: _item.lPickingCount.toString(),
                                  textStyle: ItemBkB16,
                                  hintStyle: ItemG1N15,
                                  hintText: '',
                                  onChange: (String value) {
                                    String qty = value.trim();
                                    _item.lPickingCount = 0;
                                    if (qty.isNotEmpty) {
                                      _item.lPickingCount = int.parse(qty);
                                    }
                                  }
                              )
                              ),
                              const Spacer(),
                            ]
                        )
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                      width: 100,
                      child:OutlinedButton(
                        onPressed: () async {
                          widget.onResult(false, null);
                          Navigator.pop(context);
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
                          if(_item.controller!.text.isEmpty || _item.lPickingCount<0) {
                            showToastMessage("출고 수량을 확인하세요.");
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
                        child: const Text(
                          "확인",
                          style: TextStyle(
                            color: Colors.white, fontSize: 14,
                          ),
                        ),
                      )
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }
}

void DlgPickingGoodsSingle({
  required BuildContext context,
  required ItemPickConfirm item,
  required bool isNew,
  required Function(bool bDirty, ItemPickConfirm? value) onResult}) {
  showDialog(
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
              return _ContentView(
                  item: item,
                  isNew: isNew,
                  onResult: (bool bDirty, ItemPickConfirm? value) {
                    onResult(bDirty, value);
                  });
            },
          ),
        ),
      );
    },
  );
}
