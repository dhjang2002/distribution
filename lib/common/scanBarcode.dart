// ignore_for_file: must_be_immutable

import 'dart:io';
import 'package:distribution/common/searchForm.dart';
import 'package:distribution/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanBarcode extends StatefulWidget {
  final bool multiScan;
  Function(String barcode)? onClose;
  ScanBarcode({
    Key? key,
    required this.multiScan,
    this.onClose
  }) : super(key: key);

  @override
  State<ScanBarcode> createState() => _ScanBarcodeState();
}

class _ScanBarcodeState extends State<ScanBarcode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'BARCODE');

  QRViewController? _qrvController;
  bool _flashOn = false;

  Barcode? _barCode;
  String _keyCode = "";
  final List<String> _scanCodeList = [];

  bool bReady = false;
  @override
  void initState() {
    Future.microtask(() async {});
    super.initState();
  }

  @override
  void dispose() {
    _qrvController?.dispose();
    super.dispose();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _qrvController!.pauseCamera();
    } else if (Platform.isIOS) {
      _qrvController!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double rt = getMainAxis(context);
    double scan_width = MediaQuery.of(context).size.width*0.9;
    if(rt<1.18) {
      scan_width = MediaQuery.of(context).size.width*0.7;
    } else if(rt<1.55) {
      scan_width = MediaQuery.of(context).size.width*0.7;
    } else if(rt<2.42) {
      scan_width = MediaQuery.of(context).size.width*0.8;
    } else if(rt<2.70) {
      scan_width = MediaQuery.of(context).size.width*0.8;
    }

    return SafeArea(
        child: Scaffold(
            body: Container(
                color: Colors.grey,
                child: Column(
                  children: [
                    Container(
                        width: double.infinity,
                        height: scan_width,//MediaQuery.of(context).size.width * 0.8,
                        //margin: const EdgeInsets.all(3),
                        child: Stack(
                          children: [
                            Positioned(
                              left:0, right:0, top:0, bottom: 0,
                              child:Container(
                                  color: Colors.grey,
                                  padding: const EdgeInsets.fromLTRB(5,44,5,5),
                                  child: _buildQrView(context)
                              ),
                            ),
                            Positioned(
                                bottom: 10, left:0, right: 0,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: const [
                                      Spacer(),
                                      Text('바코드를 사각 안에 맞혀 스캔해 주세요',
                                          style: TextStyle(
                                              color: Colors.cyan,
                                              fontSize: 13)),
                                      Spacer(),
                                    ],
                                  ),
                                )
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              left: 0,
                              child: Row(
                                children: [
                                  IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        _doClose();
                                      }),
                                  const Spacer(),
                                  IconButton(
                                      icon: (_flashOn)
                                          ? const Icon(
                                        Icons.flash_on,
                                        size: 20,
                                        color: Colors.yellow,
                                      )
                                          : const Icon(
                                        Icons.flash_on,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        _doFlash();
                                      }),
                                ],
                              ),
                            ),
                          ],
                        )
                    ),
                    Container(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child:Container(
                                padding:const EdgeInsets.fromLTRB(5, 0, 2, 2),
                                child: SearchForm(
                                  readOnly: false,
                                  keyboardType:TextInputType.number,
                                  valueText: "",
                                  // suffixIcon: const Icon(
                                  //   Icons.search_outlined,
                                  //   color: Colors.grey,
                                  //   size: 28,
                                  // ),
                                  prefixIcon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                    size: 26,
                                  ),

                                  hintText: '바코드(5자 이상)',
                                  onCreated: (controller) {},
                                  onChange: (value){
                                    _keyCode = value.trim();
                                  },
                                  onSummit: (String value) {
                                    _keyCode = value.trim();
                                    FocusScope.of(context).unfocus();
                                    if(_keyCode.isNotEmpty) {
                                      _scanCodeList.add(_keyCode);
                                      _doClose();
                                    }
                                  },
                                ),
                              ),
                            ),
                            Container(
                                height: 47,
                                width: 100,
                                padding:
                                const EdgeInsets.only(right: 3),
                                child: OutlinedButton(
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    if(_keyCode.isNotEmpty) {
                                      _scanCodeList.add(_keyCode);
                                      _doClose();
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.black,
                                    side: const BorderSide(
                                        width: 1.0, color: ColorG4),
                                  ),
                                  child: const Text(
                                    "조회",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                            ),
                          ]),
                    ),
                    Expanded(
                        child: Container(
                          child: Container(

                            child: Image.asset("assets/icon/icon_bg_barcode.png",
                              width: MediaQuery.of(context).size.width*0.25,
                              fit: BoxFit.fitWidth,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        )
                    ),
                  ],
                )
            )
        )
    );
  }

  Widget _buildQrView(BuildContext context) {
    double scanArea = MediaQuery.of(context).size.width*0.5;
    return QRView(
      key: qrKey,
      onQRViewCreated: (QRViewController controller) async {
        _qrvController = controller;
        if (Platform.isAndroid) {
          await _qrvController!.resumeCamera();
          var flag = await _qrvController?.getFlashStatus();
          setState(() {
            _flashOn = (flag!);
            bReady = true;
          });
        }

        _qrvController?.scannedDataStream.listen((scanData) async {
          FlutterBeep.beep();
          _barCode = scanData;

          if (_scanCodeList.indexWhere((element) => (element == _barCode)) < 0) {
            _scanCodeList.add(_barCode!.code!);
          }

          if (!widget.multiScan) {
            await _qrvController?.pauseCamera();
            _doClose();
          } else {
            setState(() {});
            await _qrvController?.pauseCamera();
            await _qrvController?.resumeCamera();
          }
        });
      },
      overlay: QrScannerOverlayShape(
          borderColor: Colors.white,
          borderRadius: 0,
          borderLength: 20,
          borderWidth: 4.0,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  void _doClose() {
    String result = (_scanCodeList.isNotEmpty) ? _scanCodeList[0]: "";
    Navigator.pop(context, result);
    if(widget.onClose != null) {
      widget.onClose!(result);
    }
  }

  Future<void> _doFlash() async {
    await _qrvController?.toggleFlash();
    var flag = await _qrvController?.getFlashStatus();
    _flashOn = (flag!);
    setState(() {});
  }
}

Future<void> showBottomScaned({
  required BuildContext context,
  required Function(String barcode) onResult}) {
  double viewHeight = MediaQuery.of(context).size.height * 0.85;
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
          child: GestureDetector(
            onTap: (){ FocusScope.of(context).unfocus();},
            child:ScanBarcode(
              multiScan: false,
              onClose: (String barcode){
                onResult(barcode);
              },
            ),
          )
        ),
      );
    },
  );
}
