// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter/foundation.dart';

class ItemPromotion {
  String? Key;
  String? Title;        // 광고 타이틀
  String? Period;       // 기간
  String? ClickUrl;     // 광고 클릭시 이동할 url
  String? PhotoUrl;     // 사진

  ItemPromotion({
    this.Key="",
    this.Title = "",
    this.Period = "",
    this.ClickUrl="",
    this.PhotoUrl = "",
  });

  static List<ItemPromotion> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemPromotion.fromJson(data);
    }).toList();
  }

  factory ItemPromotion.fromJson(Map<String, dynamic> jdata)
  {
    return ItemPromotion(
      Key: jdata['key'],
      Title: jdata['Title'],
      Period: jdata['Period'],
      PhotoUrl: jdata['PhotoUrl'],
      ClickUrl: jdata['ClickUrl'],
    );
  }

  @override
  String toString() {
    return 'ItemBanner{'
        'Key:$Key, '
        'Title:$Title, '
        'Period:$Period, '
        'PhotoUrl:$PhotoUrl, '
        'ClickUrl:$ClickUrl}';
  }

  static Future<List<ItemPromotion>> getMainBanner(int milliseconds) async {
    if (kDebugMode) {
      print("getMainBanner() start ............................................");
    }
    await Future.delayed(Duration(milliseconds: milliseconds));

    List<ItemPromotion> dataList = <ItemPromotion>[];
    dataList.add(ItemPromotion(
        PhotoUrl: "https://momo.maxidc.net/data/file/samples/sample_banner_box01.png",
        Title: "DLC&C\n오픈이노베이션\n스타트업 모집",
        Period: "2021.05.31 ~ 06.20"));
    dataList.add(ItemPromotion(
        PhotoUrl: "https://momo.maxidc.net/data/file/samples/sample_box01.png"));
    if (kDebugMode) {
      print("getMainBanner() end ............................................");
    }
    return dataList;
  }
  static Future<List<ItemPromotion>> getWideBanner(int milliseconds) async {
    if (kDebugMode) {
      print("getWideBanner() start ............................................");
    }

    await Future.delayed(Duration(milliseconds: milliseconds));

    List<ItemPromotion> dataList = <ItemPromotion>[];
    dataList.add(ItemPromotion(
        PhotoUrl: "https://momo.maxidc.net/data/file/samples/sample_banner_rect01.png",
        Title: "",
        Period: ""));
    dataList.add(ItemPromotion(
        PhotoUrl: "https://momo.maxidc.net/data/file/samples/sample_box01.png"));

    if (kDebugMode) {
      print("getWideBanner() end ............................................");
    }
    return dataList;
  }

}