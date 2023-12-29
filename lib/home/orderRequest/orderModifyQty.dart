// ignore_for_file: file_names, non_constant_identifier_names
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/inputForm.dart';
import 'package:distribution/common/inputFormTouchClear.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kItemRequestGoods.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class OrderModifyQty extends StatefulWidget {
  final ItemRequestGoods item;
  const OrderModifyQty({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<OrderModifyQty> createState() => _OrderModifyQtyState();
}

class _OrderModifyQtyState extends State<OrderModifyQty> {
  ItemRequestGoods _info = ItemRequestGoods();
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    setState(() {
      _info.copyFrom(widget.item);
    });
    super.initState();
  }

  @override
  void dispose() {
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
    //final szHeight = MediaQuery.of(context).size.height * 0.90;
    return Scaffold(
      appBar: AppBar(
        title: const Text("납품수량 정정"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          Visibility(
            visible: false,
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 26,
                ),
                onPressed: () {
                }
            ),
          ),
        ],
      ),
      body:ModalProgressHUD(
            inAsyncCall: _isInAsyncCall,
            child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child:Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_info.sGoodsName}",
                          style: ItemBkB16,
                        ),
                        Row(
                          children: [
                            const Text("발주수량/납품수량", style: ItemBkN18),
                            const Spacer(),
                            Text("${_info.lGoodsCount} / ", style: ItemBkN18),
                            SizedBox(
                                width: 60,
                                child: InputFormTouchClear(
                                    readOnly: false,
                                    disable: false,
                                    keyboardType: TextInputType.number,
                                    valueText: _info.lConfirmedCount.toString(),
                                    textStyle: ItemBkB18,
                                    hintStyle: ItemG1N18,
                                    hintText: '',
                                    onChange: (String value) {
                                      _info.lConfirmedCount = int.parse(value.trim());
                                    })),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                            child: InputForm(
                                onlyDigit: false,
                                readOnly: false,
                                disable: false,
                                touchClear: false,
                                keyboardType: TextInputType.text,
                                maxLines: 10,
                                minLines: 5,
                                valueText: _info.sMemo,
                                hintText: '메모를 입력하세요',
                                textAlign: TextAlign.start,
                                textStyle: ItemBkN16,
                                onChange: (String value) {
                                  _info.sMemo = value.toString().trim();
                                })),
                        //Spacer(),
                        Container(
                          child: ButtonSingle(
                              visible: true,
                              text: '확인',
                              enable: true,
                              onClick: () {
                                _askSave();
                              }),
                        )
                      ],
                    ),
                  ))
            )
      )
    );
  }

  Future <void> _askSave() async {
    // if(widget.item.lConfirmedCount != _info.lConfirmedCount || widget.item.sMemo !=_info.sMemo) {
    //   showToastMessage("변경 되었습니다.");
    //   Navigator.pop(context, _info);
    // } else {
    //   Navigator.pop(context, _info);
    // }

    _showProgress(true);
    // {"lDeliveryRequestDetailId" : "1233", "lConfirmedCount": "1", "sMemo": "메모입니다."}
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getMyStore(),
        session: _session,
        method: "taka/updateDeliveryRequest",
        params: {
          "lDeliveryRequestDetailId": _info.lDeliveryRequestDetailID,
          "lConfirmedCount": _info.lConfirmedCount,
          "sMemo": _info.sMemo
        },
        onResult: (dynamic response) {
          if (kDebugMode) {
            print(response.toString());
          }

          if (response['status'] == "success") {
            showToastMessage("변경 되었습니다.");
            Navigator.pop(context, _info);
          } else {
            showToastMessage(response['message']);
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);

  }
}
