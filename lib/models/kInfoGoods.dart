import 'package:distribution/common/cardPhotoItem.dart';
import 'package:distribution/common/dateForm.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kGoodsFiles.dart';
import 'package:distribution/models/kItemPrice.dart';
import 'package:distribution/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class InfoGoods {
  String  sName;       // 상품명
  String  sGoodsType;  // 상품타입
  String  fGoodsType;  // 상품구분
  String  sMallGoodsId; // 쇼핑몰 상품코드
  String  sState;       // 판매상태
  String  sBarcode;    // 상품 바코드
  String  sLot;        // 진열 위치
  String  sLotMemo;    // 진열 위치 메모

  String  sDisposeDate;
  String  sPromoteDate;

  int     rStoreStock; // 재고
  int     rMainStock;

  int     mBasePrice;
  int     mStorePrice;
  int     mDisposePrice;
  int     mPPrice;
  int     mNPrice;
  int     mPromotePrice;
  int     mSalesPrice;

  GoodsFiles? picInfo;
  String descriptionImageUrl;
  double descriptionImageHeight;

  InfoGoods({
    this.descriptionImageUrl = "",
    this.descriptionImageHeight = 0,
    this.sGoodsType = "",
    this.fGoodsType = "",
    this.sMallGoodsId = "",
    this.sState="",
    this.sName="",
    this.sBarcode="",
    this.sLot="",
    this.sLotMemo = "",
    this.rStoreStock=0,
    this.rMainStock=0,
    this.mBasePrice=0,
    this.mNPrice = 0,
    this.mPPrice=0,
    this.mStorePrice=0,
    this.mDisposePrice=0,
    this.mPromotePrice=0,
    this.mSalesPrice=0,
    this.sDisposeDate="",
    this.sPromoteDate="",
    this.picInfo,
  });

  @override
  String toString(){
    return 'InfoGoods {'
        'sName:$sName, '
        'sBarcode:$sBarcode, '
        'sLot:$sLot, '
        'rMainStock:$rMainStock, '
        ' }';
  }

  List<ItemPrice> getPriceInfo() {
    List<ItemPrice> items = [];
    items.add(ItemPrice(sName: "기준가격",         sPrice:numberFormat(mBasePrice)));
    items.add(ItemPrice(sName: "판매단가(P)",      sPrice:"${numberFormat(mNPrice)}원"));
    items.add(ItemPrice(sName: "세일가(S)",        sPrice:"${numberFormat(mPPrice)}원"));
    items.add(ItemPrice(sName: "매장판매단가(M)",   sPrice:"${numberFormat(mStorePrice)}원"));

    if(sDisposeDate.isNotEmpty)
    {
      items.add(ItemPrice(sName: "처분가", sPrice:"${numberFormat(mDisposePrice)}원"));
      items.add(ItemPrice(isPrice:false, sName: "처분일", sPrice: DateForm.getYMonthDay(sDisposeDate)));
    }

    if(sPromoteDate.isNotEmpty)
    {
      items.add(ItemPrice(sName: "판촉가", sPrice:"${numberFormat(mPromotePrice)}원"));
      items.add(ItemPrice(isPrice:false, sName: "적용일", sPrice: DateForm.getYMonthDay(sPromoteDate)));
    }

    return items;
  }

  void computeSalesPrice() {
    //mSalesPrice = mBasePrice;
    mSalesPrice = 999999999;
    if(mNPrice>0 && mSalesPrice>mNPrice) {
      mSalesPrice = mNPrice;
    }
    if(mPPrice>0 && mSalesPrice>mPPrice) {
      mSalesPrice = mPPrice;
    }
    if(mStorePrice>0 && mSalesPrice>mStorePrice) {
      mSalesPrice = mStorePrice;
    }
    if(mPromotePrice>0 && mSalesPrice>mPromotePrice) {
      mSalesPrice = mPromotePrice;
    }
    if(mDisposePrice>0 && mSalesPrice>mDisposePrice) {
      mSalesPrice = mDisposePrice;
    }
  }

  Future <void> setDescriptionImage(BuildContext context) async {
    //descriptionImageUrl    = "https://wms.point-i.co.kr/files/S4573236195117.jpg";
    //descriptionImageHeight = await computeImageHeight(context, descriptionImageUrl);
  }

  List<CardPhotoItem> getPictInfoAddUrl(bool bIncludeVideo) {
    List<CardPhotoItem> photoList = [];

    if (bIncludeVideo && picInfo!.sVideo.isNotEmpty) {
      photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo!.sVideo}", type: "v"));
    }

    if (picInfo!.sMainPicture.isNotEmpty) {
      photoList.add(
          CardPhotoItem(url: "$URL_IMAGE/${picInfo!.sMainPicture}", type: "p"));
    }

    if (picInfo!.sSubPic1.isNotEmpty) {
      photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo!.sSubPic1}", type: "p"));
    }

    if (picInfo!.sSubPic2.isNotEmpty) {
      photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo!.sSubPic2}", type: "p"));
    }

    if (picInfo!.sSubPic3.isNotEmpty) {
      photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo!.sSubPic3}", type: "p"));
    }

    if (picInfo!.sSubPic4.isNotEmpty) {
      photoList
          .add(CardPhotoItem(url: "$URL_IMAGE/${picInfo!.sSubPic4}", type: "p"));
    }
    return photoList;
  }

  static List<InfoGoods> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return InfoGoods.fromJson(data);
    }).toList();
  }

  factory InfoGoods.fromJson(Map<String, dynamic> jdata)
  {

    if (kDebugMode) {
      var logger = Logger();
      logger.d(jdata);
    }


    GoodsFiles picInfo = GoodsFiles();
    picInfo.sMainPicture = (jdata['sMainPicture'] != null)
        ? jdata['sMainPicture'].toString().trim() : "";
    picInfo.sSubPic1 = (jdata['sSubPic1'] != null)
        ? jdata['sSubPic1'].toString().trim() : "";
    picInfo.sSubPic2 = (jdata['sSubPic2'] != null)
        ? jdata['sSubPic2'].toString().trim() : "";
    picInfo.sSubPic3 = (jdata['sSubPic3'] != null)
        ? jdata['sSubPic3'].toString().trim() : "";
    picInfo.sSubPic4 = (jdata['sSubPic4'] != null)
        ? jdata['sSubPic4'].toString().trim() : "";
    picInfo.sVideo = (jdata['sVideo'] != null)
        ? jdata['sVideo'].toString().trim() : "";

    InfoGoods info = InfoGoods(
      sName: (jdata['sName'] != null)
          ? jdata['sName'].toString().trim() : "",
      sBarcode: (jdata['sBarcode'] != null)
          ? jdata['sBarcode'].toString().trim() : "",
      sMallGoodsId: (jdata['sMallGoodsID'] != null)
            ? jdata['sMallGoodsID'].toString().trim() : "",
      sGoodsType: (jdata['SGoodsType'] != null)
          ? jdata['SGoodsType'].toString().trim() : "",

      sState: (jdata['sState'] != null)
          ? jdata['sState'] : "",

      sLot: (jdata['sLot'] != null)
          ? jdata['sLot'].toString().trim():"",

      sLotMemo: (jdata['sLotMemo'] != null)
          ? jdata['sLotMemo'].toString().trim() : "",

      mBasePrice:(jdata['mBasePrice'] != null)
          ? int.parse(jdata['mBasePrice'].toString().trimLeft()) : 0,

      mNPrice:(jdata['mNPrice'] != null)
          ? double.parse(jdata['mNPrice'].toString().trimLeft()).toInt() : 0,

      mPPrice:(jdata['mPPrice'] != null)
          ? double.parse(jdata['mPPrice'].toString().trimLeft()).toInt() : 0,

      mStorePrice:(jdata['mStorePrice'] != null)
          ? double.parse(jdata['mStorePrice'].toString().trimLeft()).toInt() : 0,

      mDisposePrice:(jdata['mDisposePrice'] != null)
          ? double.parse(jdata['mDisposePrice'].toString().trimLeft()).toInt() : 0,

      mPromotePrice:(jdata['mPromotePrice'] != null)
          ? double.parse(jdata['mPromotePrice'].toString().trimLeft()).toInt() : 0,

      rStoreStock:(jdata['rStoreStock'] != null)
          ? double.parse(jdata['rStoreStock'].toString().trimLeft()).toInt() : 0,

      rMainStock:(jdata['rMainStock'] != null)
          ? double.parse(jdata['rMainStock'].toString().trimLeft()).toInt() : 0,

      sDisposeDate: (jdata['sDisposeDate'] != null)
          ? jdata['sDisposeDate'].toString().trim(): "",

      sPromoteDate: (jdata['sPromoteDate'] != null)
          ? jdata['sPromoteDate'].toString().trim(): "",
      picInfo:picInfo,
    );

    info.computeSalesPrice();
    return info;
  }
}
