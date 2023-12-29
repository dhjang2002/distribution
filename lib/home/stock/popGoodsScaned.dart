// ignore_for_file: non_constant_identifier_names, file_names
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/inputForm.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/cardGoods.dart';
import 'package:distribution/models/kItemStockGoods.dart';
import 'package:distribution/models/kItemStockGoodsInfo.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Color _colorGrayBack = Color(0xFFF4F4F4);

class PopGoodsScaned extends StatefulWidget {
  final String sLot1;
  final String sLot2;
  final String sLot3;
  final bool   isScanned;
  final bool   isManager;
  final ItemStockGoodsInfo info;
  final Function(bool bDirty, String sLot3) onClose;
  const PopGoodsScaned({
    Key? key,
    required this.isScanned,
    required this.isManager,
    required this.info,
    required this.sLot1,
    required this.sLot2,
    required this.sLot3,
    required this.onClose,
  }) : super(key: key);

  @override
  State<PopGoodsScaned> createState() => _PopGoodsScanedState();
}

class _PopGoodsScanedState extends State<PopGoodsScaned> {
  TextEditingController? ctrl_sLot1;
  TextEditingController? ctrl_sLot2;
  TextEditingController? ctrl_sLot3;

  final ItemStockGoods _currGoods= ItemStockGoods();
  String _title = "";
  String _sMemo = "";
  String _description = "";
  bool _bDirty = false;
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);


    _currGoods.sLot1 = widget.sLot1;
    _currGoods.sLot2 = widget.sLot2;
    _currGoods.sLot3 = widget.sLot3;
    _currGoods.lStockInspectID = widget.info.lStockInspectID;
    _currGoods.rVirtualStock   = widget.info.rNowStock;
    _currGoods.rRealStock = 0;
    _currGoods.lGoodsId   = widget.info.lGoodsId;
    _currGoods.sGoodsName = widget.info.sName;
    _currGoods.sBarcode   = widget.info.sBarcode;
    _currGoods.hasFocus   = true;
    _currGoods.isTarget   = true;

    if(widget.isScanned) {
      _title = "스캔상품";
      if (widget.info.isStockInspect != 0) {
        //_title = "중복스캔 상품";
        _description = "주의: 진열위치 및 수량 확인 필요 !!!";
      }
    }
    else {
      _title = "실사정보";
      _description = "";
    }

    if (widget.info.isStockInspect != 0) {
        _currGoods.sLot1 = widget.info.inspectData!.sLot1;
        _currGoods.sLot2 = widget.info.inspectData!.sLot2;
        _currGoods.sLot3 = widget.info.inspectData!.sLot3;
        _currGoods.rRealStock = widget.info.inspectData!.rRealStock;
        _sMemo = widget.info.inspectData!.sMemo;
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
    final szHeight = MediaQuery.of(context).size.height * 0.90;
    return Scaffold(
      backgroundColor: _colorGrayBack,
      appBar: AppBar(
        elevation: 0.5,
        //backgroundColor: _colorGrayBack,
        title: Text(_title),
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
                }),
          ),
        ],
      ),
      body: GestureDetector(
          onTap: () async {
            FocusScope.of(context).unfocus();
          },
          child: Container(
        height: szHeight,
          color: Colors.white,
          child:SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _showGoods(),
                  const SizedBox(height: 5,),
                  _showInspect(_currGoods),
                  Visibility(
                    visible: _description.isNotEmpty,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
                          child: Text(_description, style: ItemR1B15,)
                      )
                  ),
                ],
              )
          )
      )),
    );
  }

  Widget _buildGoodInfo() {
    ItemStockGoodsInfo item = widget.info;
    return Container(
        padding: const EdgeInsets.only(top:5),
        child:CardGoods(
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 10),
          heightRate: 0.85,
          lGoodsId: item.lGoodsId,
          sGoodsName: item.sName,
          sBarcode: item.sBarcode,
        )
    );
  }

  Widget _showGoods() {
    Color? backgroundColor = Colors.white;
    return GestureDetector(
        onTap: () async {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(5, 3, 5, 0),
          //padding: const EdgeInsets.fromLTRB(10,10,10,10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              width: 2,
              color: Colors.grey,
            ),
            color: backgroundColor,
          ),
          child: _buildGoodInfo(),
        )
    );
  }

  Widget _showInspect(final ItemStockGoods item) {
    Color? backgroundColor = Colors.white;
    Color hiliteColor = Colors.black;
    if(widget.info.isStockInspect != 0) {
      hiliteColor = Colors.red;
    }
    return Container(
          margin: const EdgeInsets.fromLTRB(5,0,5,0),
          padding: const EdgeInsets.fromLTRB(10,5,10,5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              width: 2,
              color: hiliteColor,
            ),
            color: backgroundColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text("진열위치", style: ItemG1N14,),
                         const SizedBox(height: 10,),
                         Row(
                             children: [
                               //Text("${item.sLot1}-${item.sLot2}-", style: ItemBkB20),
                               SizedBox(
                                   width: 40,
                                   child: InputForm(
                                       onlyDigit: true,
                                       readOnly: !item.hasFocus,
                                       touchClear: true,
                                       disable: false,
                                       onControl: (controller) { ctrl_sLot1 = controller; },
                                       contentPadding: const EdgeInsets.all(5),
                                       textAlign: TextAlign.center,
                                       keyboardType: TextInputType.number,
                                       valueText: item.sLot1,
                                       textStyle: ItemBkB20,
                                       hintStyle: ItemG1N20,
                                       hintText: '00',
                                       onChange: (String value) {
                                         if(value.isNotEmpty) {
                                           item.sLot1 = value.trim();
                                           _bDirty = true;
                                         }
                                       }
                                   )
                               ),
                               const Text(" - "),
                               SizedBox(
                                   width: 40,
                                   child: InputForm(
                                       onlyDigit: true,
                                       readOnly: !item.hasFocus,
                                       touchClear: true,
                                       disable: false,
                                       onControl: (controller) { ctrl_sLot2 = controller; },
                                       contentPadding: const EdgeInsets.all(5),
                                       textAlign: TextAlign.center,
                                       keyboardType: TextInputType.number,
                                       valueText: item.sLot2,
                                       textStyle: ItemBkB20,
                                       hintStyle: ItemG1N20,
                                       hintText: '00',
                                       onChange: (String value) {
                                         if(value.isNotEmpty) {
                                           item.sLot2 = value.trim();
                                           _bDirty = true;
                                         }
                                       }
                                   )
                               ),
                               const Text(" - "),
                               SizedBox(
                                   width: 40,
                                   child: InputForm(
                                       onlyDigit: true,
                                       readOnly: !item.hasFocus,
                                       touchClear: true,
                                       disable: false,
                                       onControl: (controller) { ctrl_sLot3 = controller; },
                                       contentPadding: const EdgeInsets.all(5),
                                       textAlign: TextAlign.center,
                                       keyboardType: TextInputType.number,
                                       valueText: item.sLot3,
                                       textStyle: ItemBkB20,
                                       hintStyle: ItemG1N20,
                                       hintText: '00',
                                       onChange: (String value) {
                                         if(value.isNotEmpty) {
                                           item.sLot3 = value.trim();
                                           _bDirty = true;
                                         }
                                       }
                                   )
                               ),
                             ]
                         )
                       ],
                      )
                  ),

                  Expanded(
                    flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 60,
                                child: Text("현재재고:", style: ItemG1N14,),
                              ),
                              // const SizedBox(
                              //   width: 10,
                              // ),
                              const Spacer(),
                              SizedBox(
                                width: 90,
                                child: Text("${widget.info.rNowStock}",
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                      height: 1.0, color: Colors.red),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(children: [
                            const SizedBox(
                              width: 60,
                              child: Text("실사수량:", style: ItemG1N14,),
                            ),

                            const Spacer(),
                            SizedBox(
                                width: 90,
                                child: InputForm(
                                    onlyDigit: true,
                                    readOnly: !item.hasFocus,
                                    disable: false,
                                    contentPadding: const EdgeInsets.fromLTRB(5,8,5,5),
                                    textAlign: TextAlign.right,
                                    keyboardType: TextInputType.number,
                                    valueText: item.rRealStock.toString(),
                                    textStyle: ItemBkB20,
                                    hintStyle: ItemG1N18,
                                    hintText: '',
                                    onControl: (controller){ item.controller = controller; },
                                    onChange: (String sQty) {
                                      if(int.tryParse(sQty) != null) {
                                        item.rRealStock = int.parse(sQty);
                                        _bDirty = true;
                                      }
                                      // } else {
                                      //   item.controller!.text = item.rRealStock.toString();
                                      // }
                                    }
                                )
                            ),
                          ]
                          )
                        ],
                      )
                  ),
                ],
              ),

              //const SizedBox(height: 5),
              _cardEditMemo(),
              const SizedBox(height: 5,),
              Row(
                children: [
                  const Spacer(),
                  Visibility(
                      visible: true,//item.hasFocus, // item.isTarget &&
                      child: SizedBox(
                          height: 40,
                          width: 100,
                          child:OutlinedButton(
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              if(widget.isManager) {
                                await _reqSetConfirm();
                              }
                              await _reqSave(_currGoods);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.black,
                              side: const BorderSide(width: 1.0, color: ColorG4),
                            ),
                            child: const Text(
                              "저장",
                              style: TextStyle(
                                color: Colors.white, fontSize: 14,
                              ),
                            ),
                          )
                      )
                  )
                ],
              ),
            ],
          ),
        );
  }

  Widget _cardEditMemo() {
    return Container(
        padding: const EdgeInsets.only(top:10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("보조위치", style: ItemG1N14,),
            const SizedBox(height: 5),
            InputForm(
                onlyDigit: false,
                touchClear: false,
                readOnly: false,
                disable: false,
                maxLines: 3,
                minLines: 1,
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                valueText: _sMemo,
                textStyle: ItemBkB18,
                hintStyle: ItemG1N18,
                hintText: '000000, 수량',
                onChange: (String value) {
                  _sMemo = value.trim();
                  _bDirty = true;
                }
             ),
          ],
        )
    );
  }

  // 재고실사 데이터 저장
  Future <void> _reqSave(ItemStockGoods item) async {
    if(item.sLot1.length != 2 || item.sLot2.length != 2 || item.sLot3.length != 2) {
      showToastMessage("상품 진열 위치를 입력해주세요.");
      return;
    }

    if(!_bDirty) {
      widget.onClose(false, widget.sLot3);
    }

    //_showProgress(false);

    await Remote.apiPost(
      context: context,
      lStoreId: _session.getAccessStore(),
      session: _session,
      method: "taka/insertInspect",
      params: {
          "sLot1" : item.sLot1,
          "sLot2" : item.sLot2,
          "sLot3" : item.sLot3,
          "lGoodsId":item.lGoodsId,
          "lStockInspectId":item.lStockInspectID,
          "rVirtualStock":item.rVirtualStock,
          "rRealStock":item.rRealStock,
          "sMemo":_sMemo,
      },
      onError: (String error) {},
      onResult: (dynamic params) {
        Map<String, dynamic> response = params;
        if (response['status'] == "success") {
          widget.onClose(true, item.sLot3);
          Navigator.pop(context);
        }
        else {
          showToastMessage(response['message']);
        }
      },
    );
    //_showProgress(false);
  }

  Future <void> _reqSetConfirm() async {
    await Remote.apiPost(
        context: context,
        lStoreId: _session.getAccessStore(),
        session: _session,
        method: "taka/updateErrorGoods",
        params: {
          "lStockInspectDetailID":widget.info.inspectData!.lStockInspectDetailID,
        },
        onError: (String error) {},
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
          }
          else {
            showToastMessage(response['message']);
          }
        },
    );
  }

}

Future<void> showBottomScaned({
  required BuildContext context,
  required ItemStockGoodsInfo info,
  required bool isScanned,
  required bool isManager,
  required String sLot1,
  required String sLot2,
  required String sLot3,
  required Function(bool bDirty, String sLastsLot3) onResult}) {
  double viewHeight = MediaQuery.of(context).size.height * 0.85;
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
          child: PopGoodsScaned(
            isScanned: isScanned,
            isManager: isManager,
            sLot1: sLot1,
            sLot2: sLot2,
            sLot3: sLot3,
            info: info,
            onClose: (bool bDirty, String sLastsLot3){
              onResult(bDirty, sLastsLot3);
            },
          ),
        ),
      );
    },
  );
}