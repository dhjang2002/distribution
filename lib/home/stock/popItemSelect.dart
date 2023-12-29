// ignore_for_file: non_constant_identifier_names, file_names
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/info/goodsDetail.dart';
import 'package:flutter/material.dart';

const Color _colorGrayBack = Color(0xFFF4F4F4);
class SelectItem {
  String sName;
  String sBarcode;
  int? lGoodsId;
  String? tag;
  SelectItem({
    required this.sName,
    this.lGoodsId=0,
    this.tag = "",
    this.sBarcode="",
  });
}

class _ContentView extends StatefulWidget {
  final String title;
  final double viewHeight;
  final List<SelectItem> items;
  final Function(bool bDirty, int index) onClose;
  const _ContentView({
    Key? key,
    required this.title,
    required this.viewHeight,
    required this.onClose,
    this.items = const [],

  }) : super(key: key);

  @override
  State<_ContentView> createState() => __ContentViewState();
}

class __ContentViewState extends State<_ContentView> {
  int iSelect = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorGrayBack,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: _colorGrayBack,
        title: Text(widget.title),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 28,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                }),
          ),
        ],
      ),

      body: Container(
          color: Colors.white,
          child:Stack(
            children: [
              Positioned(
                top: 0, left: 0, right: 0, bottom: 0,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 58),
                  height: widget.viewHeight,
                  child: SingleChildScrollView(
                    child:ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      SelectItem item = widget.items[index];
                      return GestureDetector(
                          onTap: (){
                            setState(() {
                              iSelect = index;
                            });
                          },
                          child:Column(
                            children: [
                              Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.fromLTRB(0,3,0,0),
                                  decoration: BoxDecoration(
                                      color: (iSelect==index) ? Colors.amber[50] :Colors.white,
                                    border: Border.all(
                                      color: (iSelect==index) ? Colors.amber :Colors.white,
                                    )
                                  ),
                                  child:Stack(
                                    children: [
                                      Positioned(
                                          child: Container(
                                          padding:const EdgeInsets.fromLTRB(10,10,35,10),
                                          child:Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("${item.sBarcode} / ${item.lGoodsId}",
                                                style: ItemBkN14,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(item.sName, style: ItemBkB15,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          )
                                      )
                                      ),

                                      Positioned(
                                        top:0, right:10,
                                        child:Visibility(
                                          visible:item.lGoodsId!>0,
                                          child: IconButton(
                                              onPressed: (){
                                                showPopGoodsDetail(
                                                    context: context,
                                                    heightRate: 0.8,
                                                    lGoodsId: item.lGoodsId!);
                                              },
                                              padding: const EdgeInsets.all(5),
                                              constraints:const BoxConstraints(),
                                              icon: const Icon(Icons.info_outline,
                                                  color: Colors.black, size:22)
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                              ),
                              const Divider(height: 1),
                            ],
                      )
                      );
                    },
                  )
                  ),
                ),
              ),
              Positioned(
                  bottom: 0,left: 0, right: 0,
                  child:ButtonSingle(
                      visible: true,
                      isBottomPading: true,
                      isBottomSide: true,
                      text: "선택",
                      enable: iSelect>=0,
                      onClick: () {
                        Navigator.pop(context);
                        widget.onClose(true, iSelect);
                      }
                  ),
              ),
            ],
          )
      ),
    );
  }
}

Future <void> showItemsSelect({
  required BuildContext context,
  required List<SelectItem> items,
  String? title = "상품선택",
  required Function(bool bOk, int index) onResult}) {
  double viewHeight = MediaQuery.of(context).size.height * 0.8;
  return showModalBottomSheet(
    context: context,
    enableDrag: false,
    isScrollControlled: true,
    useRootNavigator: false,
    isDismissible: true,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => true,
        child: SizedBox(
          height: viewHeight,
          child: _ContentView(
            title: title!,
            viewHeight:viewHeight,
            items: items,
            onClose: (bDirty, items){
              onResult(bDirty, items);
            },
          ),
        ),
      );
    },
  );
}