import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/inputFormTouchClear.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kInfoGoods.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class EditMallId extends StatefulWidget {
  final int lGoodsId;
  final InfoGoods info;
  const EditMallId({
    Key? key,
    required this.lGoodsId,
    required this.info,
  }) : super(key: key);

  @override
  State<EditMallId> createState() => _EditMallIdState();
}

class _EditMallIdState extends State<EditMallId> {
  bool bDirty = false;
  String _mallId = "";
  late SessionData _session;
  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    setState(() {
      _mallId = widget.info.sMallGoodsId;
    });
    super.initState();
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
          title: const Text("쇼핑몰 상품코드 수정"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back, size: 28,),
              onPressed: () {
                Navigator.pop(context, bDirty);
              }),
          actions: [
            Visibility(
              visible: false,
              child: IconButton(
                  icon: const Icon(
                    Icons.photo,
                    size: 26,
                  ),
                  onPressed: () {}),
            ),
          ],
        ),
        body: ModalProgressHUD(
          inAsyncCall: _isInAsyncCall,
          child: Container(color: Colors.white, child: _renderBody()),
        ));
  }

  Widget _renderBody() {
    return Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
                child: Container(
                    padding: EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${URL_MALL}/$_mallId", style: ItemBkN18),
                          _cardMallId(),
                        ],
                      ),
                    )
                )
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                child: ButtonSingle(
                  text: '확인',
                  isBottomPading: true,
                  enable: true,
                  visible: true,
                  onClick: () async {
                    await _updateMallId();
                  },
                ),
              ),
            ),
          ],
        ));
  }

  Widget _cardMallId() {
    return Container(
        //margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.only(top:10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
                flex: 5,
                child: Text(
                  "상품코드",
                  style: ItemBkN16,
                )),
            Expanded(
                flex: 5,
                child: InputFormTouchClear(
                    readOnly: false,
                    disable: false,
                    keyboardType: TextInputType.number,
                    valueText: _mallId,
                    textStyle: ItemBkB24,
                    hintStyle: ItemG1N24,
                    hintText: '00000000',
                    onChange: (String value) {
                      _mallId = value.trim();
                    })),
          ],
        ));
  }

  Future<void> _updateMallId() async {
    // if (_mallId.isEmpty) {
    //   showToastMessage("쇼핑몰 상품코드를 입력하세요.");
    //   return;
    // }

    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/updateGoodsInfo",
        params: {
          "lGoodsId": widget.lGoodsId,
          "sMallGoodsId": _mallId,
        },
        onResult: (dynamic data) {
          _showProgress(false);

          print(data.toString());

          if (data['status'] == "success") {
            bDirty = true;
            setState(() {
              widget.info.sMallGoodsId = _mallId;
            });
            showToastMessage("처리 되었습니다.");
            Navigator.pop(context, bDirty);
          }
        },
        onError: (String error) {
          _showProgress(false);
        });
  }
}
