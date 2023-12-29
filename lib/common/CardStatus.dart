import 'package:flutter/material.dart';

class CardStatus extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? color;
  final Function? onTap;
  const CardStatus({
    Key? key,
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.fromLTRB(10,8,10,8),
    this.borderColor = Colors.black,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(onTap != null) {
          onTap!();
        }
      },
      child: Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: color!,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: borderColor!,
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
