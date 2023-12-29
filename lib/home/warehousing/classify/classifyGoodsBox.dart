// ignore_for_file: file_names

import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/inputFormTouchClear.dart';
import 'package:distribution/common/takaBarcodeBuilder.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kItemHBox.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassifyGoodsBox extends StatefulWidget {
  final String workDay;
  const ClassifyGoodsBox({Key? key, required this.workDay}) : super(key: key);

  @override
  State<ClassifyGoodsBox> createState() => _ClassifyGoodsBoxState();
}

class _ClassifyGoodsBoxState extends State<ClassifyGoodsBox> {
  String _barCode = "";
  String targetPlace = "";
  String targetInfo = "";

  late SessionData _session;
  List<ItemHBox> boxList = [];

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() {
      _reqHousingBoxList(widget.workDay);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("입고 분류"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          // home
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 32,
                ),
                onPressed: () {
                  //Navigator.of(context).popUntil((route) => route.isFirst);
                  _reqHousingBoxList(widget.workDay);
                }),
          ),
        ],
      ),
      body: TakaBarcodeBuilder(
        scanKey: 'taka-MoveGoodsBox-key',
        waiting: _isInAsyncCall,
        allowPop: true,
        useCamera: true,
        //validate: _checkValidate,
        onScan: (barcode) async {
          if (_checkValidate(barcode)) {
            await _reqHousingBoxCode(barcode);
          } else {
            setState(() {
              targetPlace = "";
            });
            showToastMessage("등록되지 않은 바코드입니다.");
          }
        },
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      const Spacer(),
                      const Text(
                        "입고일자: ",
                        style: ItemG1N14,
                      ),
                      Text(widget.workDay,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  )),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                        child: Center(
                          child: Container(
                        width: double.infinity,
                        height: 340,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          //color: (item.status!) ? Colors.grey[300] : Colors.white
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                    onPressed: (){
                                      setState(() {
                                        targetPlace = "";
                                      });
                                    },
                                    icon: const Icon(Icons.close, size: 32,)
                                ),
                                const Spacer(),
                              ],
                            ),

                            const SizedBox(height: 30,),
                            Text(_barCode,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)
                            ),
                            const Divider(height: 30, color: Colors.black,),
                            Text(targetPlace,
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                )
                            ),
                            const SizedBox(height: 20),
                            Text(
                              (targetInfo.isNotEmpty) ? targetInfo : "",
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.normal
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                        )
                    ),
                    Positioned(
                      child: Visibility(
                          visible: targetPlace.isEmpty,
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              height: 340,
                              padding: const EdgeInsets.all(15),
                              margin: const EdgeInsets.all(10),
                              //padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                //color: (item.status!) ? Colors.grey[300] : Colors.white
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                //crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "상품박스에 부착된 바코드를\n스캔하세요.",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(children: [
                                        SizedBox(
                                            width: 170,
                                            child: InputFormTouchClear(
                                                readOnly: false,
                                                disable: false,
                                                onControl:
                                                    (TextEditingController
                                                        controller) {},
                                                contentPadding:
                                                    const EdgeInsets.all(10),
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                valueText: _barCode,
                                                textStyle: ItemBkB24,
                                                hintStyle: ItemG1N14,
                                                hintText: '거래처코드/박스번호',
                                                onChange: (String value) {
                                                  _barCode = value.trim();
                                                })),
                                        Container(
                                            margin:
                                                const EdgeInsets.only(left: 1),
                                            height: 47,
                                            width: 80,
                                            padding:
                                                const EdgeInsets.only(right: 3),
                                            child: OutlinedButton(
                                              onPressed: () async {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                _reqHousingBoxCode(_barCode);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor: Colors.black,
                                                side: const BorderSide(
                                                    width: 1.0, color: ColorG4),
                                              ),
                                              child: const Text(
                                                "조회",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            )),
                                      ]),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
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

  bool _checkValidate(String barcode) {
    String boxCode = barcode;//int.parse(barcode).toString();
    int index = boxList.indexWhere((element) => element.sBoxNo == boxCode);
    return (index >= 0);
  }

  Future<void> _reqHousingBoxCode(String barcode) async {
    _barCode = barcode;
    targetPlace = "";
    targetInfo = "";
    if(_barCode.length<4) {
      showToastMessage("4자 이상 입력하세요.");
      return;
    }

    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/housingInfo",
        params: {"sBoxNo": barcode, "dWarehousing": widget.workDay},
        onError: (String error) {},
        onResult: (dynamic data) {
          dynamic items = data['data'];
          targetPlace = "없음";
          targetInfo = "";
          if (items != null) {
            if (items is List) {
              if (items.length > 1) {
                targetPlace = "혼재";
                for (var value in items) {
                  if (targetInfo.isNotEmpty) {
                    targetInfo += "/";
                  }
                  targetInfo = targetInfo + value['sStoreName'];
                }
              } else {
                targetPlace = items[0]['sStoreName'];
              }
            } else {
              targetPlace = items[0]['sStoreName'];
            }
            targetInfo = targetInfo.replaceAll("(주)한국다까미야", "본사");
          }
        },
    );
    _showProgress(false);
  }

  // 입고일에 등록된 박스 리스트를 가져온다
  Future<void> _reqHousingBoxList(String boxBarcode) async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/housingBoxlist",
        params: {"dWarehousing": widget.workDay},
        onError: (String error) {
          showToastMessage(error);
        },
        onResult: (dynamic data) {
          if (data['status'] == 'success') {
            if (data['data'] != null) {
              boxList = ItemHBox.fromSnapshot(data['data']);
            }
            if (boxList.isEmpty) {
              showToastMessage("데이터가 없습니다.");
              //Navigator.pop(context);
            }
          } else {
            showToastMessage(data['message']);
          }
        }
    );
    _showProgress(false);
  }
}
