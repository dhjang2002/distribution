// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:distribution/cache/cacheBase.dart';
import 'package:distribution/models/requestParam.dart';

class CacheContent extends CacheBase{
  CacheContent() : super();

  Future <void> requestFrom({
    required BuildContext context,
    required bool first,
    required RequestParam param,
    }) async {

    isFirst = first;
    if(isFirst) {
      param.PageNo = 1;
    }
    else
    {
      param.PageNo = param.PageNo!+1;
    }
    if (kDebugMode) {
      print( "requestFrom: param -> ${param.toString()}");
    }

    if(!isFirst && cache.length>25) {
      hasMore = false;
      notifyListeners();
      return;
    }

    loading = true;
    notifyListeners();

    var items = [];//await geItems(context, param);

    if(isFirst && cache.isNotEmpty) {
      hasMore = true;
      cache.clear();
    }

    if(items.isNotEmpty) {
      cache = [
        ...cache,
        ...items,
      ];
      if(items.length<param.RowsPerPage!) {
        hasMore = false;
      }
    }
    else {
      hasMore = false;
    }

    loading = false;
    notifyListeners();
  }

  /*
  Future<List<ItemContent>> geItems(BuildContext context, RequestParam param) async {
    MsgGetUserDataXml msgGetUserDataXml = MsgGetUserDataXml();
    msgGetUserDataXml.setKeyEncN(param.session.PublicKeyEncN!);
    msgGetUserDataXml.setParam(
        AuthKey:    param.session.AuthKey!,
        SessionID:  param.session.User.SessionID!,
        UserOid:    param.session.User.UserOid!,
        DeviceId:   param.session.DeviceId!,
        mode: "SEARCH_CONTENT",
        reqData: param.toRequest()
    );

    List<ItemContent> items = [];
    await msgGetUserDataXml.request(
        ctx: context,
        onResult: (bool status, dynamic jsonData) async {
          //msgGetUserDataXml.traceMessage(context);
          if (status) {
            var resultSet = jsonData['soap:Envelope']['soap:Body']
            ['GetUserDataXmlResponse']['GetUserDataXmlResult']
            ['resultset'];

            print(resultSet.toString());
            String result = resultSet['result'];
            if(result=="+OK" && resultSet['content_list']['content'] != null) {
              var content = resultSet['content_list']['content'];
              if(content==null)
                return items;

              if(content is List) {
                items = ItemContent.fromSnapshot(content);
              }
              else {
                items = ItemContent.fromSnapshot([content]);
              }
            }
          }
        }
    );
    return items;
  }
  */
}