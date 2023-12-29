// ignore_for_file: non_constant_identifier_names
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kItemStock.dart';
import 'package:flutter/material.dart';

class _ContentView extends StatefulWidget {
  final List<ItemStock> items;
  final Function(List<ItemStock> list) onClose;
  const _ContentView({
    Key? key,
    required this.onClose,
    required this.items,
  }) : super(key: key);

  @override
  State<_ContentView> createState() => __ContentViewState();
}

class __ContentViewState extends State<_ContentView> {
  bool _bDirty = false;
  int _selCount = 0;
  
  @override
  void initState() {
    for (var element in widget.items) {
      element.isSelect = false;
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text("지점 선택"),
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
          //margin: EdgeInsets.only(bottom: 50),
          child:Stack(
            children: [
              Positioned(
                top: 0, left: 0, right: 0, bottom: 0,
                child: Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 61),
                  width: double.infinity,
                  //height: double.infinity,
                  child: Visibility(
                      visible: true,
                      child: _bodyMenu()
                  ),
                ),
              ),

              Positioned(
                  bottom: 0,left: 0, right: 0,
                  child: Visibility(
                    visible: true,
                    child:ButtonSingle(
                        visible: true,
                        isBottomPading: true,
                        text: "확인",
                        enable: _selCount>0,
                        onClick: () {
                          List<ItemStock> items = [];
                          widget.items.forEach((element) {
                            if(element.isSelect)
                              items.add(element);
                          });
                          widget.onClose(items);
                          Navigator.pop(context);
                        }
                    ),
                  )
              ),
            ],
          )
      )
    );
  }

  Widget _bodyMenu() {
    int crossAxisCount = 1;
    double mainAxisExtent = 200;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 5;
      mainAxisExtent = 50;
    } else if(rt<1.55) {
      crossAxisCount = 5;
      mainAxisExtent = 50;
    } else if(rt<2.42) {
      crossAxisCount = 3;
      mainAxisExtent = 50;
    } else if(rt<2.70) {
      crossAxisCount = 3;
      mainAxisExtent = 50;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     width: 2,
      //     color: Colors.grey,
      //   ),
      //   borderRadius: BorderRadius.circular(8),
      //   color: Colors.white,
      // ),
      child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent:mainAxisExtent,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemCount: widget.items.length,
          itemBuilder: (context, int index) {
            return _itemMenu(widget.items[index]);
          }),
    );
  }

  Widget _itemMenu(ItemStock item) {
    return GestureDetector(
        onTap: (){
          _selCount = 0;
          item.isSelect = !item.isSelect;
          for (var element in widget.items) {
            if(element.isSelect) {
              _selCount++;
            }
          }
          setState((){});
        },
        child: Container(
            margin: EdgeInsets.all(1),
            color: Colors.transparent,
            child: Container(
              //color: Colors.pink,
              child: Row(
                children: [
                  Icon((item.isSelect)
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                    color: (item.isSelect)
                        ? Colors.blueAccent
                        : Colors.black,
                  ),
                  const SizedBox(width: 10),
                  Text(item.sStoreName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0),
                  ),
                ],
              ),
            ),
          )
    );
  }

}

Future <void> BottomStoreSelect({
  required BuildContext context,
  required List<ItemStock> items,
  required Function(List<ItemStock> list) onResult}) {
  double viewHeight = MediaQuery.of(context).size.height * 0.45;
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
            items: items,
            onClose: (List<ItemStock> list) {
              onResult(list);
            },
          ),
        ),
      );
    },
  );
}