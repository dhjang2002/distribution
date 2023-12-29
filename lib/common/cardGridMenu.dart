// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:distribution/constant/constant.dart';
class CardGridMenuItem {
  final String label;
  final int    menuId;
  String? assetsPath;
  CardGridMenuItem({
    required this.label,
    required this.menuId,
    this.assetsPath = "",
  });
}

class CardGridMenu extends StatefulWidget {
  final List<CardGridMenuItem> items;
  final Function(CardGridMenuItem item) onTab;
  int?  crossAxisCount;
  bool? visible;
  double? viewHeight;
  CardGridMenu({
    Key? key,
    required this.items,
    required this.onTab,
    this.crossAxisCount = 2,
    this.visible = true,
    this.viewHeight=0,

  }) : super(key: key);

  @override
  State<CardGridMenu> createState() => _CardGridMenuState();
}

class _CardGridMenuState extends State<CardGridMenu> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool shrinkWrap = (widget.viewHeight==0);
    return Visibility(
      visible: widget.visible!,
      child: Container(
        //margin: EdgeInsets.all(5),
        child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount!,
              childAspectRatio:1.0,
              mainAxisSpacing: 1,
              crossAxisSpacing: (widget.crossAxisCount! > 2) ? 5 : 20,
            ),
            itemCount: widget.items.length,
            itemBuilder: (context, int index) {
              return menuItem(widget.items[index]);
            }),
      )
    );
  }

  Widget menuItem(CardGridMenuItem item) {
    return GestureDetector(
      onTap: (){
        widget.onTab(item);
      },
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: (item.assetsPath!.isNotEmpty)
                  ? Image.asset("assets/${item.assetsPath}", fit: BoxFit.fitHeight)
                  : Image.asset("assets/icon/coupon.png", fit: BoxFit.fitHeight),
              ),
              SizedBox(height: 5,),
              Container(
                child: Text(item.label, style: ItemBkN12),
              ),
            ]),
      ),
    );
  }
}
