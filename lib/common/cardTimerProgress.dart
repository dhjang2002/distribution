import 'dart:async';

import 'package:flutter/material.dart';

class AutoRefreshController extends ChangeNotifier {
  int counter = 0;
  int? periodic = 5;
  Function()? onTimer;
  Function(double prog)? onProgress;
  Timer? timer;
  AutoRefreshController() {
    periodic = 5;
  }

  void resume() {
    startTimer();
    notifyListeners();
  }

  void start(int periodic, final Function()? callBack, Function(double prog)? onProgress) {
    this.periodic   = periodic;
    this.onTimer     = callBack;
    this.onProgress = onProgress;
    resume();
    //notifyListeners();
  }

  void pause() {
    if(timer != null) {
      timer!.cancel();
      timer = null;
    }
    notifyListeners();
  }

  void startTimer() {
    if(timer != null) {
      timer!.cancel();
    }

    counter = 0;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      counter++;
      if(counter>periodic!) {
        counter = 0;
        if(onTimer != null) {
          onTimer!();
        }
      } else {
        if(onProgress != null) {
          onProgress!(counter / periodic! * 100);
        }
      }
    });
  }
}

class AutoRefreshProgress extends StatefulWidget {
  final bool visiable;
  final Function() onTimer;
  final AutoRefreshController controller;
  AutoRefreshProgress({
      Key? key,
      required this.controller,
      required this.onTimer,
      required this.visiable,
  }) : super(key: key);

  @override
  State<AutoRefreshProgress> createState() => _AutoRefreshProgressState();
}

class _AutoRefreshProgressState extends State<AutoRefreshProgress> {

  late AutoRefreshController controller;
  double _progressValue = 0;
  @override
  void initState() {
    controller = widget.controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      minHeight: 1,
      backgroundColor: Colors.white,
      color: Colors.black,
      value: _progressValue,
    );
  }
}
