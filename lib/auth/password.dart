// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print, library_private_types_in_public_api

import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Password extends StatefulWidget {
  const Password({Key? key}) : super(key: key);

  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  late SessionData _session;
  TextEditingController idsController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController repwdController = TextEditingController();
  bool _pwShow = false;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    print(_session.toString());

    Future.microtask(() async {
      setState(() {
        idsController.text = _session.UserIds!;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    idsController.dispose();
    pwdController.dispose();
    repwdController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext ctx) {
    const double radious = 50.0;
    return Scaffold(
        backgroundColor: Colors.white,
        //extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("비밀번호 변경"),),
        body: WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: GestureDetector(
            onTap: () { FocusScope.of(context).unfocus();},
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
              children: [
                Positioned(
                  top: 50,
                  child: Container(
                    color: Colors.transparent,
                    width: MediaQuery.of(context).size.width-20,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget> [
                      // ids
                      const SizedBox(height: 30.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          controller: idsController,
                          readOnly: true,
                          maxLines: 1,
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Colors.black
                          ),
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
                            //doPassword();
                          },
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Colors.black
                          ),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.fromLTRB(20,18,20,18),
                              isDense: true,
                              hintText: '새 비밀번호',
                              hintStyle: const TextStyle(color: Colors.grey),//Colors.green),
                            prefixIcon: Padding(
                                padding: const EdgeInsets.all(13),
                                child: Image.asset("assets/icon/login_pw.png",
                                  color: Colors.black, width: 16, height: 16,)
                            ),
                            suffixIcon: IconButton(
                              icon: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Image.asset("assets/icon/login_pweye.png",
                                    color: Colors.black,
                                    width: 16, height: 16,)
                              ),
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

                      // re_pwd
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          obscureText: _pwShow,
                          controller: repwdController,
                          maxLines: 1,
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) {
                            //doPassword();
                          },
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Colors.black
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.fromLTRB(20,18,20,18),
                            isDense: true,
                            hintText: '새 비밀번호 확인',
                            hintStyle: const TextStyle(color: Colors.grey),//Colors.green),
                            prefixIcon: Padding(
                                padding: const EdgeInsets.all(13),
                                child: Image.asset("assets/icon/login_pw.png",
                                  color: Colors.black,
                                  width: 16,
                                  height: 16,)
                            ),
                            suffixIcon: IconButton(
                              icon: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Image.asset("assets/icon/login_pweye.png",
                                    color: Colors.black,
                                    width: 16, height: 16,)
                              ),
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

                      // 변경 버튼
                      const SizedBox(height: 40.0),
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
                              child:Text('비밀번호 변경',
                                  style: const TextStyle(
                                      color:Colors.white,
                                      fontSize:18.0,
                                      fontWeight: FontWeight.bold
                                  )
                              )
                          ),
                        ),
                        onTap: (){
                          _changePassword();
                        },
                      ),

                    ],
                    ),
                  ),
                ),
              ],
          ),
            ))),
        );
  }

  late dynamic jsonData={};
  Future <void> _changePassword() async {
    FocusScope.of(context).unfocus();
    // Navigator.pop(context);
    // return;

    String uid = idsController.text.trim();
    String password = pwdController.text.trim();
    String password_confirm = repwdController.text.trim();
    if(password.isEmpty || password.length<4) {
      showToastMessage("변경할 비밀번호를 입력하세요."
          "\n비밀번호는 4자 이상입니다.") ;
       return;
    }

    if(password_confirm.isEmpty) {
      showToastMessage("새 비밀번호 확인란에 비밀번호를 한번더 입력해주세요.");
      return;
    }

    if(password != password_confirm) {
      showToastMessage("변경할 비밀번호가 일치하지 않습니다."
          "\n 비밀번호를 확인해주세요.");
      return;
    }

    // { "lEmployeeId" : "123123", "password" : "123456", "password_confirm": "123456" }
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "auth/password",
        params: {"lEmployeeId":uid,
          "password":password,
          "password_confirm":password_confirm
        },
        //params: {"id":"k10120101", "password":"k10120101"},
        onResult: (dynamic data) {
          setState(() {
            jsonData = data;
          });

          //print(data);

          if(data['status']=="success"){
            showToastMessage("비밀번호가 변경되었습니다."
                "\n로그인후 사용하세요.");
            _session.setLogout();
            Navigator.pop(context);
          }
          else {
            showToastMessage(data['message']);
          }
        },
        onError: (String error){
          print(error);
        });
  }

  Future <void> doRegister() async {
      // await Navigator.push(context,
      //     Transition(child: const UserRegist(),
      //         transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
  }

  Future <void> doFindId() async {
    // await Navigator.push(context,
    //     Transition(child: UploadTest(),
    //         transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
  }

  Future <void> doFindPassword() async {
    // await Navigator.push(context,
    //     Transition(child: CalendarDemo(),
    //         transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
  }
  _onBackPressed(BuildContext context) {
    return Future(() => true);
  }
}
