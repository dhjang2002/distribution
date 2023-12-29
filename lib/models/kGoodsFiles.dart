
// ignore_for_file: file_names
import '../constant/constant.dart';

class GoodsFiles {
  String lGoodsId;
  String sMainPicture;
  String sSubPic1;
  String sSubPic2;
  String sSubPic3;
  String sSubPic4;
  String sVideo;
  String sDescimg;
  String sGoodsDetail;

  GoodsFiles({
    this.lGoodsId = "",
    this.sMainPicture = "",
    this.sSubPic1 = "",
    this.sSubPic2 = "",
    this.sSubPic3 = "",
    this.sSubPic4 = "",
    this.sVideo = "",
    this.sDescimg = "",
    this.sGoodsDetail = "",
  });

  static List<GoodsFiles> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return GoodsFiles.fromJson(data);
    }).toList();
  }

  factory GoodsFiles.fromJson(Map<String, dynamic> jdata)
  {
    return GoodsFiles(
      lGoodsId: (jdata['lGoodsId'] != null)
          ? URL_IMAGE+jdata['lGoodsId'].toString().trimLeft() : "",
      sMainPicture: (jdata['sMainPicture'] != null)
          ? URL_IMAGE+jdata['sMainPicture'] : "",
      sSubPic1: (jdata['sSubPic1'] != null)
          ? URL_IMAGE+jdata['sSubPic1'].toString().trim() : "",
      sSubPic2: (jdata['sSubPic2'] != null)
          ? URL_IMAGE+jdata['sSubPic2'].toString().trim() : "",
      sSubPic3: (jdata['sSubPic3'] != null)
          ? URL_IMAGE+jdata['sSubPic3'].toString().trim() : "",
      sSubPic4: (jdata['sSubPic4'] != null)
          ? URL_IMAGE+jdata['sSubPic4'].toString().trim() : "",
      sVideo: (jdata['sVideo'] != null)
          ? URL_IMAGE+jdata['sVideo'].toString().trim() : "",
      sDescimg: (jdata['sDescimg'] != null)
          ? URL_IMAGE+jdata['sDescimg'].toString().trim() : "",
      sGoodsDetail: (jdata['sGoodsDetail'] != null)
          ? URL_IMAGE+jdata['sGoodsDetail'].toString().trim() : "",
    );
  }
}
