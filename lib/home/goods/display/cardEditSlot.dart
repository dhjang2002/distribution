import 'package:distribution/common/inputForm.dart';
import 'package:distribution/common/inputFormTouchClear.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:flutter/material.dart';

class ItemSlot {
  String sLot;
  String sLotMemo;
  ItemSlot({
    this.sLot = "",
    this.sLotMemo = "",
  });
}

class CardEditSlot extends StatefulWidget {
  final ItemSlot sLotInfo;
  final Function(bool isSave) onSave;
  const CardEditSlot({Key? key, required this.onSave, required this.sLotInfo})
      : super(key: key);

  @override
  State<CardEditSlot> createState() => _CardEditSlotState();
}

class _CardEditSlotState extends State<CardEditSlot> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.amber,
          ),
          borderRadius: BorderRadius.circular(5),
          color: Colors.amber[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cardEditSlot(),
            cardEditMemo(),
            // 저장버튼
            Container(
                width: double.infinity,
                //height: 80,
                padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                        flex:4,
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          //padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
                          child: OutlinedButton(
                            onPressed: () async {
                              _doSave(false);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey,
                              side: const BorderSide(
                                  width: 1.0, color: ColorG4),
                            ),
                            child: const Text(
                              "취소",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )
                      )
                    ),

                    Expanded(
                        flex:6,
                        child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            //padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
                            child: OutlinedButton(
                              onPressed: () async {
                                _doSave(true);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black,
                                side: const BorderSide(
                                    width: 1.0, color: ColorG4),
                              ),
                              child: const Text(
                                "변경하기",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            )
                        )
                    ),
                  ],
                ))
          ],
        ));
  }

  Widget cardEditSlot() {
    return Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
                flex: 5,
                child: Text(
                  "진열위치",
                  style: ItemBkN16,
                )),
            Expanded(
                flex: 5,
                child: InputFormTouchClear(
                    readOnly: false,
                    disable: false,
                    keyboardType: TextInputType.number,
                    valueText: widget.sLotInfo.sLot,
                    textStyle: ItemBkB24,
                    hintStyle: ItemG1N24,
                    hintText: '000000',
                    onChange: (String value) {
                      widget.sLotInfo.sLot = value.trim();
                    })
            ),
          ],
        ));
  }

  Widget cardEditMemo() {
    return Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "메모",
              style: ItemBkN16,
            ),
            const SizedBox(height: 10),
            InputForm(
                onlyDigit: true,
                touchClear: false,
                readOnly: false,
                disable: false,
                maxLines: 5,
                minLines: 5,
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                valueText: widget.sLotInfo.sLotMemo,
                textStyle: ItemBkN16,
                hintText: '위치메모',
                onChange: (String value) {
                  widget.sLotInfo.sLotMemo = value.trim();
                }),
          ],
        ));
  }

  bool _validate() {
    return (widget.sLotInfo.sLot.length == 6 ||
        widget.sLotInfo.sLot.isEmpty);
  }

  void _doSave(bool flag) {
    if(flag) {
      if (!_validate()) {
        showToastMessage("저장위치 형식 오류입니다.");
        return;
      }
    }
    widget.onSave(flag);
  }
}
