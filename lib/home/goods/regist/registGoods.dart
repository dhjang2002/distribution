import 'package:distribution/common/inputForm.dart';
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class _AddItem {
  String? label;
  String? tag;
  String? value;
  String? valueType;
  _AddItem({
    this.value = "",
    this.label = "",
    this.tag="",
    this.valueType="text",
  });
}

class RegistGoods extends StatefulWidget {
  final int lGoodsID;
  final String barcode;
  final String sGoodsName;
  const RegistGoods({Key? key,
    required this.lGoodsID,
    required this.barcode,
    required this.sGoodsName
  }) : super(key: key);

  @override
  State<RegistGoods> createState() => _RegistGoodsState();
}

class _RegistGoodsState extends State<RegistGoods> {
  late SessionData _session;
  List<_AddItem> _addItems = [];

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _addItems.add(_AddItem(
      label: "상품명",
      tag:"sGoodsName",
      value: widget.sGoodsName,
      valueType: "text"
    ));
    _addItems.add(_AddItem(
        label: "바코드",
        tag:"sBarcode",
        value: widget.barcode,
        valueType: "text"
    ));
    _addItems.add(_AddItem(
        label: "상품코드",
        tag:"lGoodsID",
        value: widget.lGoodsID.toString(),
        valueType: "int"
    ));
    // Future.microtask(() {
    //   _registGoods();
    // });
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("상품등록"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back, size: 28,),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: [
            // home
            Visibility(
              visible: false,
              child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    size: 28,
                  ),
                  onPressed: () {
                    //Navigator.of(context).popUntil((route) => route.isFirst);
                  }),
            ),
          ],
        ),
        body: ModalProgressHUD(
          inAsyncCall: _isInAsyncCall,
          child: _renderBody(),
        ));
  }

  Widget _renderBody() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
        child:Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 상품정보 - 사진
                    // Container(
                    //   height: picHeight,
                    //   width: double.infinity,
                    //   color: Colors.black,
                    //   child: CardPhotoEdit(
                    //     isEdit: false,
                    //     photoUrl: _goodFiles.sMainPicture,
                    //     onTap: (String type, String url) {
                    //       //_showDetail(type, url);
                    //     },
                    //   ),
                    // ),
                    // 상품정보
                    /*
                    Container(
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              child: const Text("상품정보", style: ItemBkB16)),
                          _infoRow("상품코드:", widget.lGoodsID.toString()),
                          _infoRow("바코드:", widget.barcode),
                          _infoRow("상품명:", widget.sGoodsName),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    */
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                      padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _addRow(_addItems[0]),
                          _addRow(_addItems[1]),
                          _addRow(_addItems[2]),
                        ],
                      ),
                    ),
                    //const Spacer(),
                  ],
                ),
              ),
            )
        ),
        SizedBox(
          height: 80,
          child: Row(
            children: [
              ButtonSingle(
                  visible: true,
                  text: '상품등록',
                  enable: true,
                  onClick: () {
                    _askSave();
                  }),
            ],
          ),
        )
      ],
    ));
  }

  Widget _infoRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: Text(
                title,
                style: ItemBkN15,
              )),
          Expanded(
              flex: 7,
              child: Text(
                value,
                style: ItemBkB15,
                textAlign: TextAlign.end,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ))
        ],
      ),
    );
  }
  Widget _addRow(_AddItem item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 3,
              child: Text(
                item.label!,
                style: ItemBkN15,
              )),
          Expanded(
              flex: 7,
            child: InputForm(
                onlyDigit: false,
                readOnly: false,
                disable: false,
                keyboardType: (item.valueType == "int")
                    ? TextInputType.number : TextInputType.text,
                valueText: item.value!,
                hintText: '',
                textStyle: ItemBkB16,
                onChange: (String value) {
                  item.value = value.toString().trim();
                }),
          )
        ],
      ),
    );
  }

  void _askSave() {
    // if(_reqPrice.isEmpty || int.parse(_reqPrice)<1) {
    //   showToastMessage("상품 가격을 입력하세요.");
    //   return;
    // }
    //
    // if(_reqComment.isEmpty) {
    //   showToastMessage("사유를 입력하세요.");
    //   return;
    // }

    showYesNoDialogBox(
        context: context,
        height: 220,
        title: "확인",
        message: "신규 상품을 등록할까요?",
        onResult: (isOK){
          if(isOK) {
            _registGoods();
          }
        });
  }

  Future <void> _registGoods() async {
    showToastMessage("처리 되었습니다.");
    Navigator.pop(context, true);
    return;

    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/goodsList",
        params: {"barcode": widget.barcode},
        // method: "taka/goodsList",
        // params: {"lGoodsId": widget.lGoodsId, "lStroeId":_session.StoreId!,},
        onResult: (dynamic data) {
          _showProgress(false);
          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }
        },
        onError: (String error) {
          _showProgress(false);
        });
  }

}
