// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print, library_private_types_in_public_api

import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kInfoStore.dart';
import 'package:distribution/models/kEmployee.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  final String? ids;
  final String? pwd;
  const Login({
    Key? key,
    this.ids = "",
    this.pwd = "",
  }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late SessionData _session;
  TextEditingController idsController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  bool _pwShow = true;
  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);

    Future.microtask(() async {
      _session.UserIds ??= "";
      setState(() {
        idsController.text = _session.UserIds!;
        if(widget.ids!.isNotEmpty) {
          idsController.text = widget.ids!;
        }
        if(widget.pwd!.isNotEmpty) {
          pwdController.text = widget.pwd!;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    const double radious = 50.0;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: WillPopScope(
          onWillPop: () => _onBackPressed(context),
          child: GestureDetector(
            onTap: () { FocusScope.of(context).unfocus();},
            child: SafeArea(
              child:SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                        child: SizedBox(
                          height: double.infinity,
                          //alignment: Alignment.center, // This is needed
                          child: Column(
                            children: [
                              const Spacer(),
                              Image.asset(
                                "assets/icon/icon_sign_back.png",
                                fit: BoxFit.contain,
                                width: 180,
                              ),
                              const Spacer(),
                              Container(
                                color: Colors.transparent,
                                width: MediaQuery.of(context).size.width-20,
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                alignment: Alignment.topCenter,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget> [
                                    // ids
                                    //const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: TextField(
                                        controller: idsController,
                                        maxLines: 1,
                                        cursorColor: Colors.black,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                        style: ItemBkN16,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.fromLTRB(20,18,20,18),
                                          isDense: true,
                                          hintText: '사용자 계정',
                                          hintStyle: const TextStyle(color: Colors.grey),
                                          prefixIcon: Padding(
                                              padding: const EdgeInsets.all(13),
                                              child: Image.asset("assets/icon/login_id.png",
                                                color: Colors.black, width: 16, height: 16,)),
                                          focusedBorder: const OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.all(Radius.circular(radious)),
                                            borderSide: const BorderSide(width: 1, color: ColorG1),
                                          ),
                                          enabledBorder: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(radious)),
                                            borderSide: BorderSide(width: 1, color: ColorG1),
                                          ),
                                          border: const OutlineInputBorder(
                                            borderRadius:
                                            const BorderRadius.all(const Radius.circular(radious)),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // pwd
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: TextField(
                                        obscureText: _pwShow,
                                        controller: pwdController,
                                        maxLines: 1,
                                        cursorColor: Colors.black,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.go,
                                        onSubmitted: (value) {
                                          //print("search");
                                          doLogin();
                                        },
                                        style: ItemBkN16,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.fromLTRB(20,18,20,18),
                                          isDense: true,
                                          hintText: '비밀번호',
                                          hintStyle: const TextStyle(color: Colors.grey),//Colors.green),
                                          prefixIcon: Padding(
                                              padding: const EdgeInsets.all(13),
                                              child: Image.asset("assets/icon/login_pw.png",
                                                color: Colors.black, width: 16, height: 16,)),
                                          suffixIcon: IconButton(
                                            icon: Padding(
                                                padding: const EdgeInsets.all(0),
                                                child: Image.asset("assets/icon/login_pweye.png",
                                                  color: Colors.black, width: 16, height: 16,)),
                                            onPressed: () {
                                              setState(() {
                                                _pwShow = !_pwShow;
                                              });
                                            },
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.all(Radius.circular(radious)),
                                            borderSide: const BorderSide(width: 1, color: ColorG1),
                                          ),
                                          enabledBorder: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(radious)),
                                            borderSide: const BorderSide(width: 1, color: ColorG1),
                                          ),
                                          border: const OutlineInputBorder(
                                            borderRadius:
                                            const BorderRadius.all(const Radius.circular(radious)),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // 로그인 버튼
                                    const SizedBox(height: 30),
                                    GestureDetector(
                                      child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.fromLTRB(15,0,15,0),
                                        padding: const EdgeInsets.fromLTRB(0,20,0,20),
                                        decoration:  BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(radious)
                                        ),
                                        child: const Center(
                                            child:Text('로그인', style: ItemWkN16)),
                                      ),
                                      onTap: (){
                                        doLogin();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                            ],
                          )
                        )
                    ),

                    /*
                    Positioned(
                      bottom: 100,
                      child: Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width-20,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        alignment: Alignment.topCenter,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget> [
                            // ids
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: TextField(
                                controller: idsController,
                                maxLines: 1,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                style: ItemBkN16,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.fromLTRB(20,18,20,18),
                                    isDense: true,
                                    hintText: '사용자 계정',
                                    hintStyle: const TextStyle(color: Colors.grey),
                                  prefixIcon: Padding(
                                      padding: const EdgeInsets.all(13),
                                      child: Image.asset("assets/icon/login_id.png",
                                        color: Colors.black, width: 16, height: 16,)),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(radious)),
                                      borderSide: const BorderSide(width: 1, color: ColorG1),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(radious)),
                                      borderSide: BorderSide(width: 1, color: ColorG1),
                                    ),
                                    border: const OutlineInputBorder(
                                      borderRadius:
                                      const BorderRadius.all(const Radius.circular(radious)),
                                    ),
                                ),
                              ),
                            ),

                            // pwd
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: TextField(
                                obscureText: _pwShow,
                                controller: pwdController,
                                maxLines: 1,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.go,
                                onSubmitted: (value) {
                                  //print("search");
                                  doLogin();
                                },
                                style: ItemBkN16,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.fromLTRB(20,18,20,18),
                                    isDense: true,
                                    hintText: '비밀번호',
                                    hintStyle: const TextStyle(color: Colors.grey),//Colors.green),
                                  prefixIcon: Padding(
                                      padding: const EdgeInsets.all(13),
                                      child: Image.asset("assets/icon/login_pw.png",
                                        color: Colors.black, width: 16, height: 16,)),
                                  suffixIcon: IconButton(
                                    icon: Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: Image.asset("assets/icon/login_pweye.png",
                                          color: Colors.black, width: 16, height: 16,)),
                                    onPressed: () {
                                        setState(() {
                                          _pwShow = !_pwShow;
                                        });
                                    },
                                  ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(radious)),
                                      borderSide: const BorderSide(width: 1, color: ColorG1),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(radious)),
                                      borderSide: const BorderSide(width: 1, color: ColorG1),
                                    ),
                                    border: const OutlineInputBorder(
                                      borderRadius:
                                      const BorderRadius.all(const Radius.circular(radious)),
                                    ),
                                ),
                              ),
                            ),

                            // 로그인 버튼
                            const SizedBox(height: 10),
                            GestureDetector(
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.fromLTRB(15,0,15,0),
                                padding: const EdgeInsets.fromLTRB(0,20,0,20),
                                decoration:  BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(radious)
                                ),
                                child: const Center(
                                    child:Text('로그인', style: ItemWkN16)),
                              ),
                              onTap: (){
                                doLogin();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    */
                  ],
                ),
              )
            )
          )
      ),
    );
  }

  late dynamic jsonData={};

  Future <void> doLogin() async {
    FocusScope.of(context).unfocus();
    String uid = idsController.text.trim();
    String pwd = pwdController.text.trim();
    if(uid.isEmpty) {
       showToastMessage("이메일을 입력해주세요.");
       return;
    }

    if(pwd.isEmpty) {
      showToastMessage("비밀번호를 입력해주세요.");
      return;
    }

    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: "",
        method: "auth/login",
        params: {"id":uid, "password":pwd},
        //params: {"id":"k10120101", "password":"k10120101"},
        onResult: (dynamic data) {
          setState(() {
            jsonData = data;
          });

          if(data['status']=="success"){

            if (kDebugMode) {
              var logger = Logger();
              logger.d(data);
            }

            Employee person = Employee.fromJson(data['data']['employee']);
            InfoStore store = InfoStore.fromJson(data['data']['store']);
            _session.setLogin(data['data']['token'], uid, pwd, person, store);
            //print(_session.toString());
            Navigator.pop(context);
          }
          else {
            //showSnackbar(context, data['message']);
            showToastMessage(data['message']);
          }
        },
        onError: (String error){
          print(error);
        });
  }

  _onBackPressed(BuildContext context) {
    return Future(() => false);
  }
}
