// ignore_for_file: unnecessary_const, non_constant_identifier_names, unnecessary_null_comparison
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:io' as io;
import 'dart:async';
import 'dart:convert';

import '../constant/constant.dart';

const bool _isDebug = true;
//const bool _isDebug = false;

//const apiUrl = "http://rc.maxidc.net:8080";
// http://211.175.164.202/api/taka/GoodsList

class Remote{
  static Future <void> upLoad({
    required BuildContext context,
    required SessionData  session,
    required String method, //"auth/thumnail"
    required Map<String,String> params,
    required String filePath,
    required Function(dynamic data) onResult,
    required Function(String error) onError
  }) async {

    params.addAll({"lEmployeeID":session.User!.lEmployeeID!});
    Uri uri = Uri.parse("$URL_API/$method");
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({ "Content-type": "multipart/form-data" });
    request.fields.addAll(params);

    // 파일 업로드
    if (filePath.isNotEmpty) {
        if (await io.File(filePath).exists()) {
          request.files.add(await http.MultipartFile.fromPath('file', filePath));
        }
    }

    if(_isDebug) {
      debugPrint(">>> apiUpLoad: $uri params=${params.toString()}");
    }

    try {
      http.StreamedResponse response = await request.send().timeout(const Duration(seconds: 120));
      if (response.statusCode == 200) {
        String data = await response.stream.bytesToString();
        dynamic jdata = jsonDecode(data);
        if (kDebugMode) {
          var logger = Logger();
          logger.d(jdata);
        }
        return onResult(jdata);
      } else {
        if (kDebugMode) {
          print("response.statusCode=${response.statusCode}");
          print("response.statusCode=${response.stream.toString()}");
        }
        return onError("업로드에 실패하였습니다.\n최대 99MB까지 업로드 가능합니다.");
      }
    } catch (e) {
      return onError("Network Error:");
    }
  }

  static Future <void> apiPost({
    required BuildContext context,
    required SessionData  session,
    required String lStoreId,
    required String method, //"auth/login"
    required Map<String,dynamic> params,
    required Function(dynamic data) onResult,
    required Function(String error) onError,
  }) async {

    if(session.User != null && session.Stroe != null) {
      params.addAll({"lEmployeeId":session.User!.lEmployeeID!, "lStoreId":lStoreId});
    }
    Uri uri = Uri.parse("$URL_API/$method");

    if (kDebugMode) {
      print(">>> apiPost: $uri params=${params.toString()}");
    }

    try {
      final response = await http.post(
          uri,
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            //"Authorization": "Bearer xxxxx"},
            "Authorization": "Bearer ${session.Token!}"},
          body: (params != null) ? json.encode(params) : "")
          .timeout(const Duration(seconds: 55),
              onTimeout: () {
                // Time has run out, do what you wanted to do.
                return http.Response('Error', 408); // Request Timeout response status code
              },
      );

      if(response != null)
      {
        //{"message":"Unauthenticated."}
        var jdata = jsonDecode(response.body.toString().trim());
        String mesg = (jdata != null && jdata['message'] != null)
            ? jdata['message'].toString().trim() : "";
        if(mesg == "Unauthenticated.") {
          //print(response.body);
          //Navigator.popUntil(context, ModalRoute.withName("/"));
          session.setLogout();
          Navigator.of(context).popUntil((route) => route.isFirst);
          //showToastMessage("비정상 접근입니다.");
          return onError(mesg);
        }

        if (response.statusCode == 200)  {
          String data = response.body;
          var jdata = jsonDecode(data);

          if(jdata != null) {
            // if (kDebugMode) {
            //   var logger = Logger();
            //   logger.d(jdata);
            // }
            return onResult(jdata);
          } else {
            String error = "Error Json jsonDecode";
            if (kDebugMode) {
              print(error);
            }
            showToastMessage(error);
            return onError(error);
          }
        }
        else {
          var jdata = jsonDecode(response.body);
          if(jdata['message'] == "Unauthenticated") {
            if (kDebugMode) {
              print(response.body);
            }
            showToastMessage(jdata['message']);
          }
          return onError("Unauthenticated");
        }
      }
      else {
        String error = "HTTP No Response";
        if (kDebugMode) {
          print(error);
        }
        showToastMessage(error);
        return onError(error);
      }

    } catch (e) {}
  }

  static Future <void> apiGet({
    required String token,
    required String method, //"auth/info"
    required Map<String,dynamic> params,
    required Function(dynamic data) onResult,
    required Function(String error) onError
  }) async {

    Uri uri = Uri.parse("$URL_API/$method");
    if (kDebugMode) {
      print(">>> apiGet: $uri params=${params.toString()}");
    }

    try {
        final response = await http.get(uri,
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            "Authorization": "Bearer$token"},
      );

      if (response.statusCode == 200) {
        String data = response.body;
        if(_isDebug) {
          debugPrint(data);
        }

        int start = data.indexOf('{', 0);
        if (start > 0) {
          data = data.substring(start);
        }

        if (kDebugMode) {
          print("<<< Rep: $data");
        }
        return onResult(jsonDecode(data));
      }

      if (kDebugMode) {
        print("<<< HTTP Error CODE:${response.statusCode}");
      }

      return onError("HTTP Error CODE:${response.statusCode}");

    } catch (e) {
      if (kDebugMode) {
        print("<<< Network Error:$e");
      }
      return onError("Network Error:$e");
    }
  }
}