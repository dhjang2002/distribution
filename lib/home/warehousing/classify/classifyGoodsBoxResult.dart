// ignore_for_file: file_names

import 'package:distribution/common/buttonSingle.dart';
import 'package:flutter/material.dart';

class ClassifyGoodsBoxResult extends StatefulWidget {
  final String targetPlace;
  final String targetInfo;
  const ClassifyGoodsBoxResult({Key? key,
    required this.targetPlace,
    required this.targetInfo}) : super(key: key);

  @override
  State<ClassifyGoodsBoxResult> createState() => _ClassifyGoodsBoxResultState();
}

class _ClassifyGoodsBoxResultState extends State<ClassifyGoodsBoxResult> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("스캔결과"),
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
                icon: const Icon(Icons.home, size: 32,),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
          ),
        ],

      ),
      body: Stack(
        children: [
          Positioned(
              child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 100),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.targetPlace,
                      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text(widget.targetInfo,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
                    maxLines: 10, overflow: TextOverflow.ellipsis,)
                ],
              ),
            ),
          )),

          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 100,
                //color: Colors.amber,
                child: Row(
                  children: [
                    ButtonSingle(visible: true, text: '확인', enable: true,
                        onClick: () {
                          Navigator.pop(context);
                        }),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
