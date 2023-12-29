// ignore_for_file: file_names, must_be_immutable
import 'dart:async';
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/common/scanBarcode.dart';
import 'package:distribution/home/config/appConfig.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';
import 'package:visibility_detector/visibility_detector.dart';

class TakaBarcodeBuilder extends StatefulWidget {
  final String scanKey;
  final Widget child;
  final bool  waiting;
  final bool? useCamera;
  final String? validateMessage;
  //Widget? btnIcon;
  final Color?  btnBackground;
  final double? btnOffsetRight;
  final double? btnOffsetBottom;
  final void Function(String barcode)? onScan;
  final String? onButtonText;
  final bool?   onButtonEbanle;
  final void Function()? onButton;
  final bool Function(String barcode)? validate;
  final bool allowPop;
  final WillPopCallback? onWillPop;
  const TakaBarcodeBuilder({Key? key,
    required this.scanKey,
    required this.child,
    required this.waiting,
    this.validateMessage = "사용할 수 없는 바코드입니다.",
    this.allowPop = false,
    this.onWillPop,
    this.onScan,
    this.validate,
    this.useCamera = false,
    //this.btnIcon = const Icon(Icons.camera, color: Colors.white,size: 18),
    this.btnBackground = Colors.white,
    this.btnOffsetRight = 5.0,
    this.btnOffsetBottom = 40.0,
    this.onButtonEbanle = false,
    this.onButtonText = "확인",
    this.onButton,
  }) : super(key: key);

  @override
  State<TakaBarcodeBuilder> createState() => _TakaBarcodeBuilderState();
}

class _TakaBarcodeBuilderState extends State<TakaBarcodeBuilder> {
  late bool visible;
  bool _useCamera = true;
  late SessionData _session;
  late Widget _btnIcon;
  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);

    setState(() {
      _useCamera = (_session.Setting!.UseCamera=="YES");
      _btnIcon = Image.asset("assets/icon/icon_barcode.png",
        color: Colors.black,
        width: 16,height: 16,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double _locRight = 5;
  double _locBottom = 80;
  void setActbuttonLocation(String location) {
    switch(location) {
      case "0":
        _locRight  = 0;
        _locBottom = 40;
        break;
      case "1":
        _locRight = 0;
        _locBottom = MediaQuery.of(context).size.height-240;
        break;
      case "2":
        _locRight = MediaQuery.of(context).size.width-80;
        _locBottom = MediaQuery.of(context).size.height-240;
        break;
      case "3":
        _locRight = MediaQuery.of(context).size.width-80;
        _locBottom = 40;
        break;
      case "4":
        _locRight = (MediaQuery.of(context).size.width/2)-28;
        _locBottom = 40;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _session = Provider.of<SessionData>(context, listen: true);
    setActbuttonLocation(_session.Setting!.ActionButtonLoc!);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          if(widget.onWillPop != null) {
            return widget.onWillPop!();
          }
          else {
            return onWillPop();
          }
        },
        child: ModalProgressHUD(
            inAsyncCall:widget.waiting,
          child: VisibilityDetector(
            onVisibilityChanged: (VisibilityInfo info) {
              visible = info.visibleFraction > 0;
            },
            key: Key(widget.scanKey),
            child: BarcodeKeyboardListener(
              bufferDuration: const Duration(milliseconds: 200),
              useKeyDownEvent: false,
              onBarcodeScanned: (barcode) async {
                if (!visible) {
                  return;
                }
                if(barcode.isNotEmpty) {
                  _onScaned(barcode);
                }
              },

              child: Stack(
                children: [
                  Positioned(
                      child: Container(
                          margin: (widget.onButton != null)
                            ? const EdgeInsets.only(bottom: 54): null,
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Visibility(
                                visible: false,//widget.onScan != null,
                                child: Row(
                                children: [
                                  const Spacer(),
                                  Container(
                                      margin: const EdgeInsets.fromLTRB(0,0,15,0),
                                      width: 18, height: 18,
                                      color: Colors.transparent,
                                      child:Image.asset("assets/icon/icon_barcode.png",
                                        color: Colors.black,
                                      )
                                  ),
                                ],
                              ),
                              ),

                              Expanded(child: widget.child,)
                            ],
                          )
                      )
                  ),

                  Positioned(
                      bottom: 0,left: 0,right: 0,
                      child: Visibility(
                        visible: (widget.onButton!=null),
                          child:Row(
                            children: [
                              ButtonSingle(
                                  visible: true,
                                  isBottomPading: true,
                                  isBottomSide: true,
                                  text: widget.onButtonText!,
                                  enable: widget.onButtonEbanle!,
                                  onClick: () {
                                    widget.onButton!();
                                    //_askSave();
                                  }),
                            ],
                          ),
                      )
                  ),

                  Positioned(
                      right:  _locRight,
                      bottom: _locBottom,
                      child: Visibility(
                        visible: _useCamera&&widget.useCamera!,
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: Center(
                            child: FloatingActionButton.small(
                                backgroundColor: widget.btnBackground,
                                child: GestureDetector(
                                  child: _btnIcon,
                                  onLongPress: () async {
                                    _doConfig();
                                  },
                                ),
                                onPressed: () async {
                                  showBottomScaned(
                                      context: context,
                                      onResult: (String barcode) {
                                        _onScaned(barcode);
                                      });
                                }
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onScaned(String barcode) {
    if(widget.onScan != null) {
      if (widget.validate != null) {
        if (widget.validate!(barcode)) {
          widget.onScan!(barcode);
        } else {
          showToastMessage(widget.validateMessage!);
        }
      } else {
        widget.onScan!(barcode);
      }
    }
  }

  void showMessage() async {
    showYesNoDialogBox(
        context: context,
        height: 240,
        title: "종료확인",
        message: "작업을 종료할까요?\n처리중인 데이터는 저장되지 않습니다.",
        onResult: (bool isOK) {
          if(isOK)
          {
            Navigator.pop(context);
          }
        });
  }

  Future <bool> onWillPop() async {
    if(!widget.allowPop) {
      showMessage();
    }
    return true;
  }

  /*
  Future <void> _doScan() async {
    var result = await Navigator.push(context,
      Transition(child: const ScanBarcode(multiScan: true,),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
    if(result != null && result.toString().isNotEmpty ) {
      String scanCode = result.toString().trim();
      //print("TakaBarcodeBuilder::ScanBarcode::Scaned Code:>$_scanCode<");
      _onScaned(scanCode);
    }
  }
  */
  Future<void> _doConfig() async {
    await Navigator.push(context,
      Transition(child: const AppConfig(),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }
}


