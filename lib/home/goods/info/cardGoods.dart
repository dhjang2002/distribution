import 'package:flutter/material.dart';

import 'goodsDetail.dart';

class CardGoods extends StatelessWidget {
  final int lGoodsId;
  final String sGoodsName;
  final String sBarcode;
  final EdgeInsetsGeometry? padding;
  final double? heightRate;
  const CardGoods({
    Key? key,
    required this.lGoodsId,
    required this.sGoodsName,
    required this.sBarcode,
    this.padding = const EdgeInsets.fromLTRB(10, 10, 10, 10),
    this.heightRate = 0.85,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: Container(
              width: double.infinity,
              padding: padding,
              color: Colors.white,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sBarcode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          letterSpacing: -0.5,
                          height: 1.2,
                          color: Colors.black,
                        )),
                    Text(sGoodsName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.6,
                          height: 1.2,
                          color: Colors.black,
                        )),
                  ])
          ),
        ),
        Positioned(
          top:5, right:5,
            child: Visibility(
                visible: lGoodsId>0,
              child: IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.all(3),
                icon: Icon(Icons.info_outline, color: Colors.black,),
                onPressed: () {
                  showPopGoodsDetail(
                      context: context,
                      heightRate: heightRate,
                      lGoodsId: lGoodsId
                  );
                },
              ))
        ),
      ],
    );
  }
}
