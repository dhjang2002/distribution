// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:distribution/constant/constant.dart';
import 'package:flutter/material.dart';
class ButtonSingle extends StatefulWidget {
  final String text;
  final Function() onClick;
  final bool?  visible;
  final bool?  enable;
  final Color? enableTextColor;
  final Color? disableTextColor;
  final Color? enableColor;
  final Color? disableColor;
  final bool? isBottomPading;
  final int? milliseconds;
  final bool? isBottomSide;
  const ButtonSingle({
    Key? key,
    required this.text,
    required this.onClick,
    this.isBottomPading = true,
    this.visible = true,
    this.enable = true,
    this.enableColor      = (modeIsDeveloper) ? const Color(0xFFFF0000): const Color(0xFF133D86),
    this.disableColor     = const Color(0xFFDDDDDD),
    this.enableTextColor  = Colors.white,
    this.disableTextColor = Colors.grey,
    this.milliseconds = 150,
    this.isBottomSide = false,
  }) : super(key: key);

  @override
  State<ButtonSingle> createState() => _ButtonSingleState();
}

class _ButtonSingleState extends State<ButtonSingle> {
  bool _isAutoLock = false;

  @override
  void initState() {
    _isAutoLock = false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible!,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Material(
          child: InkWell(
            child: Container(
              width: double.infinity,
              padding: (widget.isBottomPading!)
                  ? const EdgeInsets.fromLTRB(0,15,0,25)
                  : const EdgeInsets.fromLTRB(0,15,0,15),
              child: Center(
                  child:Text(widget.text,
                      style: TextStyle(
                          color:(widget.enable! && !_isAutoLock)
                              ? widget.enableTextColor: widget.disableTextColor,
                          fontSize:15.0,
                          fontWeight: FontWeight.normal,
                          height: 1.0)
                  )
              ),
              decoration:  BoxDecoration(
                  color: (widget.enable! && !_isAutoLock)
                      ? widget.enableColor : widget.disableColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                    bottomLeft: Radius.circular(widget.isBottomSide! ? 0 : 5),
                    bottomRight: Radius.circular(widget.isBottomSide! ? 0 : 5),
                  )
              ),
            ),
            onTap:() {
              if(widget.enable! && !_isAutoLock) {
                if(!_isAutoLock) {
                  setState(() {
                    _isAutoLock = true;
                  });
                  Future.delayed(Duration(milliseconds: widget.milliseconds!), () {
                    setState(() {
                      _isAutoLock = false;
                    });
                  });
                }
                widget.onClick();
              }
            },
          ),
        ),
      ),
    );
  }
}




