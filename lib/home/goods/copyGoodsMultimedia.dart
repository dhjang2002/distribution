
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/cardPhotoItem.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/selectGoods.dart';
import 'package:distribution/models/kGoodsFiles.dart';
import 'package:distribution/models/kInfoGoods.dart';
import 'package:distribution/models/kItemGoodsList.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

import 'info/goodsDetail.dart';

class CopyGoodsMultimedia extends StatefulWidget {
  final int lGoodsID;
  const CopyGoodsMultimedia({
    Key? key,
    required this.lGoodsID,
  }) : super(key: key);

  @override
  State<CopyGoodsMultimedia> createState() => _CopyGoodsMultimediaState();
}

class _CopyGoodsMultimediaState extends State<CopyGoodsMultimedia> {
  InfoGoods _info = InfoGoods();
  List<CardPhotoItem> photoList = [];

  List<ItemGoodsList> goodsList = [];

  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() {
      _requestGoodsInfo();
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
          title: const Text("상품사진 복사"),
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
                    Icons.home,
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
    final double picHeight = MediaQuery.of(context).size.width * 0.8;
    final double height = MediaQuery.of(context).size.height - 160;
    return SizedBox(
        //color: Colors.amber,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned(
                child: SizedBox(
                    height: height,
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. 상품정보 - 사진
                        Container(
                          height: picHeight,
                          width: double.infinity,
                          color: Colors.black,
                          child: CardPhotos(
                            items: photoList,
                          ),
                        ),

                        Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: () async {
                                        _doSelectGoods();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.black,
                                        side: const BorderSide(
                                            width: 1.0, color: ColorG4),
                                      ),
                                      child: const Text(
                                        "상품추가",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Text(
                                      "상품선택: ",
                                      style: ItemBkN16,
                                    ),
                                    Text(
                                      "${goodsList.length}  ",
                                      style: ItemBkB16,
                                    ),
                                  ],
                                ),
                                Visibility(
                                    visible: goodsList.isEmpty,
                                    child: Container(
                                      height: 150,
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                          color: Colors.grey[50],
                                        ),
                                      child: const Text("선택한 상품이 없습니다.",style: ItemG1N16,),
                                    )
                                ),
                                Visibility(
                                    visible: goodsList.isNotEmpty,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        color: Colors.grey[10],
                                      ),
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: goodsList.length,
                                          itemBuilder: (context, index) {
                                            return _goodsItem(goodsList[index]);
                                          }),
                                    )),
                              ],
                            )),
                      ],
                    )))),
            Positioned(
                bottom: 0,
                child: SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      ButtonSingle(
                          visible: goodsList.isNotEmpty,
                          text: '등록',
                          enable: goodsList.isNotEmpty,
                          onClick: () {
                            _askCopy();
                          }),
                    ],
                  ),
                )),
          ],
        ));
  }

  Widget _goodsItem(ItemGoodsList item) {
    return GestureDetector(
      onTap: () async {
        _showDetail(item);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(10,10,0,10),
        color: Colors.transparent,
        child:Row(
          children: [
            Expanded(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Text(item.lGoodsId!.toString(), style: ItemBkN15),
                Text(item.sBarcode!, style: ItemBkN15),
                Text(item.sGoodsName!, maxLines: 3, style: ItemBkB15,),
              ],
            ),),
            IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 26,
                ),
                onPressed: () {
                  setState(() {
                    goodsList.remove(item);
                  });
                }),
          ],
        ),
      ),
    );
  }

  Future<void> _showDetail(ItemGoodsList item) async {
    Widget showTarget = GoodsDetail(
        lGoodsId: item.lGoodsId!,
        hidePickEdit:true,
    );
    var result = await Navigator.push(
        context,
        Transition(
            child: showTarget,
            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
    if (result != null && result) {
      setState(() {});
    }
  }

  Future<void> _requestGoodsInfo() async {
    _showProgress(true);
    /*
    { "lGoodsId": "147227", "lStoreId": "1" }
     */
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/goodsInfo",
        params: {"lGoodsId": widget.lGoodsID.toString()},
        onResult: (dynamic data) {
          _showProgress(false);

          // if (kDebugMode) {
          //   var logger = Logger();
          //   logger.d(data);
          // }

          if (data['data'][0] != null) {
            var content = data['data'][0];
            _info = InfoGoods.fromJson(content);
            _setPictInfoAddUrl(_info.picInfo!);
            setState(() {});
          }
        },
        onError: (String error) {
          _showProgress(false);
        });
  }

  Future <void> _doSelectGoods() async {
    var result = await Navigator.push(
        context,
        Transition(
            child: SelectGoods(isMulti:true),
            transitionEffect: TransitionEffect.RIGHT_TO_LEFT));

    if (result != null) {
      List<ItemGoodsList> items = result;
      setState(() {
        for (var item in items) {
          // 현재 상품과 동일한 상품이면 skip
          if(item.lGoodsId==widget.lGoodsID) {
            continue;
          }

          // 리스트에 등록된 상품인지 검사(중복검사)하여 미등록 상품만 필터링
          int inx = goodsList.indexWhere((element) {return (item.lGoodsId == element.lGoodsId);});
          if (inx < 0) {
            goodsList.add(item);
          }
        }
      });
    }
  }

  void _setPictInfoAddUrl(GoodsFiles picInfo) {
    photoList.clear();
    if (picInfo.sVideo.isNotEmpty) {
      photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo.sVideo}", type: "v"));
    }

    if (picInfo.sMainPicture.isNotEmpty) {
      photoList.add(
          CardPhotoItem(url: "$URL_IMAGE/${picInfo.sMainPicture}", type: "p"));
    }

    if (picInfo.sSubPic1.isNotEmpty) {
      photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo.sSubPic1}", type: "p"));
    }

    if (picInfo.sSubPic2.isNotEmpty) {
      photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo.sSubPic2}", type: "p"));
    }

    if (picInfo.sSubPic3.isNotEmpty) {
      photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo.sSubPic3}", type: "p"));
    }

    if (picInfo.sSubPic4.isNotEmpty) {
      photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo.sSubPic4}", type: "p"));
    }
  }

  void _askCopy() {
    //Navigator.push(context, Route());
    showYesNoDialogBox(
        context: context,
        height: 260,
        title: "확인",
        message: "선택한 상품의 사진을 현재 상품의 사진으로 대체합니다.\n\n작업을 진행하시겠습니까?",
        onResult: (bool isYes) {
          if (isYes) {
            _reqCopyGoodsFile();
          }
        });
  }

  Future<void> _reqCopyGoodsFile() async {
    //Navigator.pop(context);

    List<String> goodsIdList = [];
    for (var element in goodsList) {
      if(element.lGoodsId != widget.lGoodsID) {
        goodsIdList.add(element.lGoodsId.toString());
      }
    }

    if(goodsIdList.isEmpty) {
      showToastMessage("적용 대상 상품을 선택하세요.");
      return;
    }

    // {lGoodsId : "1" targets:["1","2"...]"};
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/copyGoodsFile",
        params: {"lGoodsId": widget.lGoodsID.toString(), "targets":goodsIdList},
        onResult: (dynamic data) {
          _showProgress(false);

          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

          if (data['status'] == "success") {
            showToastMessage("이미지 복사가 완료되었습니다.");
          }
          else {
            showToastMessage("이미지 복사중 오류가 발생하였습니다.");
          }
        },
        onError: (String error) {
          _showProgress(false);
          showToastMessage("이미지 복사중 오류가 발생하였습니다.");
        }
    );
    setState(() {});
  }
}
