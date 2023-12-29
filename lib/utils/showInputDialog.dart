import 'package:flutter/material.dart';

class _ContentView extends StatefulWidget {
  final String value;
  final String label;
  final Function(bool isOK, String value) onResult;

  const _ContentView({
    Key? key,
    required this.value,
    required this.label,
    required this.onResult
  }) : super(key: key);

  @override
  State<_ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<_ContentView> {
  TextEditingController v1Controller = TextEditingController();

  @override
  void initState() {
    v1Controller.text = widget.value;
    super.initState();
  }

  @override
  void dispose() {
    v1Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${widget.label}"),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: TextField(
                  controller: v1Controller,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  onChanged: (value){},
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.normal),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.fromLTRB(
                        10, 10, 10, 10),
                    isDense: true,
                    hintText: "",
                    hintStyle: TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      // borderRadius:
                      // const BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(
                          width: 1, color: Colors.amber),
                    ),
                    enabledBorder: OutlineInputBorder(
                      // borderRadius: const BorderRadius.all(
                      //     Radius.circular(10)),
                      borderSide: BorderSide(
                          width: 1, color: Colors.amber),
                    ),
                    border: OutlineInputBorder(
                      // borderRadius:
                      // BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              ),
              Divider(height: 20,),
              Row(
                children: [
                  Spacer(),
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor:Colors.grey[200]
                    ),
                    onPressed: () {
                      widget.onResult(false, v1Controller.text.trim());
                      Navigator.pop(context);
                    },
                    child: const Text('취소', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(width: 10,),
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:Colors.black
                    ),
                    onPressed: () {
                      widget.onResult(true, v1Controller.text.trim());
                      Navigator.pop(context);
                    },
                    child: const Text('확인', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }
}

void showValueInputDialog({
  required BuildContext context,
  required String label,
  required String valse,
  required Function(bool isOK, String value) onResult}) {

  showDialog (
    context: context,
    //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return _ContentView(
                label: label,
                value: valse,
                onResult: (bool isOK, String value) {
                  onResult(isOK, value);
                });
            },
          ),
        ),
      );
    },
  );
}