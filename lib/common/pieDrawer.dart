// ignore_for_file: file_names

import 'package:flutter/material.dart';

class PieDrawer extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
      ..color = Colors.deepPurpleAccent // 색은 보라색
      ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
      ..strokeWidth = 4.0; // 선의 굵기는 4.0

    Paint rp = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
      ..color = Colors.grey // 색은 보라색
      ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
      ..strokeWidth = 1.0;
    //Offset p1 = Offset(0.0, 0.0); // 선을 그리기 위한 좌표값을 만듬.
    //Offset p2 = Offset(size.width, size.height);
    canvas.drawRect(Rect.fromLTRB(0,0,size.width-1, size.height-1), rp);
    canvas.drawCircle(const Offset(25.0, 25.0), 25, paint);
    //canvas.drawLine(p1, p2, paint); // 선을 그림.
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // 화면을 새로 그릴지 말지 정합니다.
    // 예전에 위젯의 좌표값과 비교해, 좌표값이 변했을 때 그린다든지 원하는 대로 조건을 줄 수 있죠.
    return false;
  }

}
