import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:distribution/constant/constant.dart';

class _DialogContent extends StatelessWidget {
  final String message;
  final bool shrinkWrap;
  final bool? isCenter;
  const _DialogContent({
    Key? key,
    required this.message,
    required this.shrinkWrap,
    this.isCenter = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const TextStyle bodyStyle = TextStyle(fontSize: 16,
        fontWeight: FontWeight.normal,
        letterSpacing: -0.5,
        height: 1.2,
        color: Colors.black);
    List items = message.split("\n");
    return Container(
      padding: const EdgeInsets.only(left:10, right: 10),
      alignment: (isCenter! )? Alignment.center : Alignment.centerLeft,
      child: ListView.builder(
          shrinkWrap: shrinkWrap,
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            if(isCenter!) {
              return Center(
                  child: Text(items[index],
                      maxLines: 20,
                      overflow: TextOverflow.ellipsis,
                      style: bodyStyle)
              );
            }
            return Text(items[index],
                maxLines: 20,
                overflow: TextOverflow.ellipsis,
                style: bodyStyle);
        }
      ),
    );
  }
}

void showOkDialogBox({
  required BuildContext context,
  required String title,
  required String message,
  String? btnText = "확인",
  double? height = 250,
  bool?   alignHorCenter = true,
  EdgeInsets? margin = const EdgeInsets.all(10),
  Function(bool isOK)? onResult,})
{
  showDialog(
    context: context,
    barrierDismissible: true, //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            insetPadding: margin!,
            contentPadding: const EdgeInsets.all(0),
            content: SizedBox(
              width: MediaQuery.of(context).size.width*0.9,//double.minPositive,
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 15,15,10),
                    child: Center(
                      child: Text(
                        title, maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ItemBkN18
                      ),
                    ),
                  ),
                  const Divider(thickness: 1),

                  // body
                  Expanded(
                      child: _DialogContent(
                      shrinkWrap:true,
                      isCenter: alignHorCenter,
                      message: message
                      )
                  ),

                  const SizedBox(height: 10),

                  // button
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            color:Colors.black,
                            child: Center(
                              child: Center(
                                child: Text(btnText!,
                                  style: const TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14)
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            if(onResult != null) {
                              onResult(true);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
      );
    },
  );
}

Future <void> showYesNoDialogBox({
  required BuildContext context,
  required String title,
  required String message,
  String? btnYes = "예",
  String? btnNo  = "아니오",
  double? height = 240,
  bool?   reverse = false,
  bool?   alignHorCenter = true,
  EdgeInsets? margin = const EdgeInsets.all(10),
  required Function(bool isOK) onResult}) async {
  showDialog(
    context: context,
    barrierDismissible: false, //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () async => true,//false,
          child: AlertDialog(
            insetPadding: margin!,
            contentPadding: const EdgeInsets.all(0),
            content: SizedBox(
              width: MediaQuery.of(context).size.width*0.85,//double.minPositive,
              height: height,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title
                    Container(
                      padding: const EdgeInsets.all(15),
                      child: Center(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ItemBkN20
                        ),
                      ),
                    ),
                    const Divider(thickness: 1),

                    // body
                    Expanded(
                        child: _DialogContent(
                            shrinkWrap:true,
                            isCenter: alignHorCenter,
                            message: message
                        )
                    ),
                    const SizedBox(height: 10),

                    // Yes/No Button
                    SizedBox(
                      height: 56,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.only(top:15, bottom: 15),
                                color:(reverse!) ? Colors.black: const Color(0xFFEEEEF0),
                                child: Center(
                                    child:Text(btnYes!,
                                        style: TextStyle(
                                            color: (reverse)
                                                ? Colors.grey : const Color(0xFFB1B2B9),
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14
                                        )
                                    )
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                onResult(true);
                              },
                            ),
                          ),

                          Expanded(
                            flex: 5,
                            child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.only(top:15, bottom: 15),
                                color:(!reverse) ? Colors.black: const Color(0xFFEEEEF0),
                                child: Center(
                                    child: Text(btnNo!,
                                        style: TextStyle(
                                            color: (reverse)
                                                ? Colors.grey : const Color(0xFFB1B2B9),
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14
                                        )
                                    )
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                onResult(false);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
      );
    },
  );
}

void showToastDialog({
  required BuildContext context,
  required String message,
  Function()? onResult,
  EdgeInsetsGeometry? padding = const EdgeInsets.only(left:10, right:10),
  double? topGap = -5,
  Color?  barrierColor = const Color(0x00000000),
  Color?  background = const Color(0xFFFFFFFF),
  bool?   barrierDismissible = false,
  bool?   onWillPop = false,}) {
  double topOffset = MediaQuery.of(context).padding.top+topGap!;
  showDialog(
      context: context,
      barrierDismissible: barrierDismissible!,
      barrierColor: barrierColor,
      builder: (BuildContext context){
        return  WillPopScope(
            onWillPop: () async => onWillPop!,
            child: Stack(
              clipBehavior: Clip.none, alignment: Alignment.topCenter,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width*0.95,
                    height: 48,
                    margin: EdgeInsets.only(top: topOffset),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: background,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    padding: padding!,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(message, overflow: TextOverflow.ellipsis, maxLines: 1,
                          style: ItemB1N16,
                        ),
                        const Spacer(),
                        GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            child: const Icon(Icons.clear, size: 22, color: Colors.black,),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            onResult!();
                          },
                        ),
                      ],
                    )
                )
              ],
            )
        );
      }
  );
}

void showSnackbar(BuildContext context, String message) {
  var snack = SnackBar(
    content: Text(message, style: const TextStyle(fontSize: 16),),
    duration: const Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snack);
}

void showToastMessage(String message, {
  bool isLengthLong = false,
  bool prevCancel=false})
{
  if(prevCancel) {
    Fluttertoast.cancel();
  }

  Fluttertoast.showToast(
      msg: message,
      toastLength: (isLengthLong) ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}