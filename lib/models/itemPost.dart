// ignore_for_file: non_constant_identifier_names, file_names

import 'package:distribution/models/itemPhoto.dart';

class ItemPost {
  final String? Key;
  final String? ContentID;            // 행사ID (콘텐츠 ID)
  final String? ContentTitle;         // 행사명칭
  final String? ContentOption;        // 행사 옵션정보
  final String? WriterNickname;       // 작성자 닉네임
  final String? WriterPhotoUrl;       // 작성자 사진
  final double? Rating;               // 평점
  final String? WriteStamp;           // 작성일시
  final String? Content;              // 후기내용
  final List<ItemPhoto>? PhotoList;   // 후기사진 리스트

  ItemPost({
    this.Key = "",
    this.ContentID="",
    this.WriterNickname = "",
    this.WriterPhotoUrl = "",
    this.ContentTitle = "",
    this.Rating=0.0,
    this.WriteStamp="",
    this.ContentOption="",
    this.Content="",
    this.PhotoList = const <ItemPhoto>[],
  });

  static List<ItemPost> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemPost.fromJson(data);
    }).toList();
  }

  factory ItemPost.fromJson(Map<String, dynamic> jdata)
  {
    return ItemPost(
      ContentTitle: jdata['ContentTitle'],
      Content: jdata['Content'],
      WriteStamp: jdata['WriteStamp'],
    );
  }

  static Future<List<String>> getPhotoData(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    List<ItemPhoto> data = [];
    data.add(ItemPhoto(image_url: "https://momo.maxidc.net/data/file/samples/sample_post04.png", content_image_oid: "1234", image_index: "",));
    data.add(ItemPhoto(image_url: "https://momo.maxidc.net/data/file/samples/sample_post02.png", content_image_oid: "1234", image_index: "",));
    data.add(ItemPhoto(image_url: "https://momo.maxidc.net/data/file/samples/sample_post01.png", content_image_oid: "1234", image_index: "",));
    return data.map((e) => e.image_url!).toList();
  }

  static Future<List<ItemPost>> getTestData(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    List<ItemPost> data = [];
    data.add(ItemPost(
        WriterPhotoUrl: "https://momo.maxidc.net/data/file/samples/user01.jpg",
        WriterNickname: "카드값줘체리",
        WriteStamp: "2021.0720 10:08",
        Rating: 1.0,
        ContentOption: "옵션:00, 타입:A타입, 옵션 설명란",
        Content: "이번 행사가 너무 재미있고 매해 하는 행사라 내년에도",
        PhotoList: [
          ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post03.png"),
          ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post04.png"),
          ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post02.png")
        ]));
    data.add(ItemPost(
        WriterPhotoUrl: "",
        WriterNickname: "옥수수콧수염차",
        WriteStamp: "2021.0720 10:08",
        Rating: 5.0,
        ContentOption: "옵션:00, 타입:A타입, 옵션 설명란",
        Content: "되도록 앞자리에 있어야 잘 보여요!",
        PhotoList: [
          ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post05.png")
        ]));
    data.add(ItemPost(
        WriterPhotoUrl: "https://momo.maxidc.net/data/file/samples/user03.jpg",
        WriterNickname: "아뇨똥인데요",
        WriteStamp: "2021.0720 10:08",
        Rating: 3.5,
        ContentOption: "옵션:00, 타입:A타입, 옵션 설명란",
        Content: "2번 옵션 골랐습니다." "\n교통편도 편리하고 아이들이랑 너무 재미있게 다녀왔네요~",
        PhotoList: [
          ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post01.png"),
          ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post02.png"),
          ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post03.png")
        ]));
    return data;
  }

}