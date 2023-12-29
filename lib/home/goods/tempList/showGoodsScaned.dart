
// ignore_for_file: non_constant_identifier_names

import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/inputForm.dart';
import 'package:distribution/common/inputFormTouchClear.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kItemStockGoods.dart';
import 'package:distribution/models/kItemStockGoodsInfo.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Color _colorGrayBack = Color(0xFFF4F4F4);

class PopGoodsScaned extends StatefulWidget {
  final String barcode;
  final Function(bool bDirty, String sLot3) onClose;
  const PopGoodsScaned({
    Key? key,
    required this.barcode,
    required this.onClose,
  }) : super(key: key);

  @override
  State<PopGoodsScaned> createState() => _PopGoodsScanedState();
}

class _PopGoodsScanedState extends State<PopGoodsScaned> {
  final ItemStockGoods _currGoods= ItemStockGoods();
  String _title = "";
  String _description = "";
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _currGoods.sLot1 = "";
    _currGoods.sLot2 = "";
    _currGoods.sLot3 = "";
    _currGoods.lStockInspectID = 0;
    _currGoods.rVirtualStock = 0;
    _currGoods.rRealStock = 0;
    _currGoods.lGoodsId   = 0;
    _currGoods.sGoodsName = "";
    _currGoods.sBarcode = widget.barcode;
    _currGoods.hasFocus = true;
    _currGoods.isTarget = true;

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
        backgroundColor: _colorGrayBack,
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
                  Visibility(
                    visible: _description.isNotEmpty,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10, 3, 10, 0),
                          child: Text(_description, style: ItemR1B15,)
                      )
                  ),
                ],
              )
          )
      )),
    );
  }
}

Future <void> showGoodsScaned({
  required BuildContext context,
  required String barcode,
  required Function(bool bDirty, String sLastsLot3) onResult}) {
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
          child: PopGoodsScaned(
            barcode: barcode,
            onClose: (bool bDirty, String sLastsLot3){
              onResult(bDirty, sLastsLot3);
            },
          ),
        ),
      );
    },
  );
}