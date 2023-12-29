// ignore_for_file: non_constant_identifier_names, file_names

import 'package:distribution/models/itemPhoto.dart';

class InfoPost {
  String? Key;                  // 후기 ID (레코드 수정/삭제 시 사용) : 서버에서 생성
  String? ContentID;            // 행사 ID(Key)
  String? ContentTitle;         // 행사 명칭
  String? ContentOption;        // 행사 옵션정보
  String? ContentPhotoUrl;      // 행사 대표사진
  String? ContentReservationNo; // 행사 예약번호
  String? WriterNickname;       // 후기 작성자 닉네임
  String? WriterPhotoUrl;       // 후기 작성자 사진
  String? Kind;                 // 후기 종류: "한줄후기","포토후기"
  String? Status;               // 후기 처리상태: "승인대기","승인반려","적립완료"
  double? Rating;               // 후기 평점 (1 ~ 5 )
  String? WriteStamp;           // 후기 작성일시 (yyyy.MM.dd hh:MM:ss) 서버에서 저장시 생성.
  String? Content;              // 후기 내용 (한줄: 5자 이상, 포토:20자 이상)
  List<ItemPhoto>? PhotoList;   // 후기 사진 리스트 (1~10장)

  InfoPost({
    this.Key = "",
    this.Kind = "",
    this.Status="",
    this.WriterNickname  = "",
    this.WriterPhotoUrl = "",
    this.Rating = 0,
    this.WriteStamp="",
    this.Content="",
    this.ContentID="",
    this.ContentTitle = "",
    this.ContentOption="",
    this.ContentPhotoUrl = "",
    this.ContentReservationNo = "",
    this.PhotoList = const <ItemPhoto>[],
  });

  static List<InfoPost> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return InfoPost.fromJson(data);
    }).toList();
  }

  factory InfoPost.fromJson(Map<String, dynamic> jdata)
  {
    return InfoPost(
      ContentTitle: jdata['ContentTitle'],
      Content: jdata['Content'],
      WriteStamp: jdata['WriteStamp'],
    );
  }

  static Future<List<InfoPost>> getPostMe(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    List<InfoPost> data = [];
    data.add(InfoPost(
      Key:"1",
      Kind:"한줄후기",
      Status:"적립완료",
      WriteStamp:"2021.07.20 10:09",
      Rating:4,
      Content:"이번 행사가 너무 재미있고 매해 하는 행사라 내년에도 참석 예정 입니다.",
      PhotoList : [],

      ContentID:"123456",
      ContentTitle : "2021 핸드메이드페어(윈터)",
      ContentOption:"옵션:1 타입:A타입 실속형",
      ContentPhotoUrl:"https://momo.maxidc.net/data/file/samples/sample_box01.png",
      ContentReservationNo:"2106151745623",
    ));

    data.add(InfoPost(
      Key:"2",
      Kind:"포토후기",
      Status:"승인대기",
      Rating:3,
      WriteStamp:"2021.07.20 10:08",
      Content:"되도록 앞자리에 앉아야 잘 보여요.",
      PhotoList: [
      ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post03.png"),
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post04.png"),
            ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post02.png")
      ],
      ContentID:"123456",
      ContentTitle : "대전 e스포츠 경기장",
      ContentOption:"옵션:1 타입:A타입 실속형",
      ContentPhotoUrl:"https://momo.maxidc.net/data/file/samples/sample_box02.png",
      ContentReservationNo:"2106151745623",
    ));

    data.add(InfoPost(
      Key:"3",
      Kind:"포토후기",
      Status:"승인반려",
      Rating:5,
      WriteStamp:"2021.07.20 10:08",
      Content:"2번 옵션 골랐습니다.""\n교통편도 편리하고 아이들이랑 너무 재미있게 다녀 왔네요~~",
      PhotoList: [
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post01.png"),
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post02.png"),
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post03.png")],
      ContentID:"123456",
      ContentTitle : "2021 시흥 갯골축제",
      ContentOption:"옵션:1 타입:A타입 실속형",
      ContentPhotoUrl:"https://momo.maxidc.net/data/file/samples/sample_box04.png",
      ContentReservationNo:"2106151745623",
    ));

    data.add(InfoPost(
      Key:"4",
      Kind:"포토후기",
      Status:"적립완료",
      Rating:3,
      WriteStamp:"2021.07.20 10:08",
      Content:"되도록 앞자리에 앉아야 잘 보여요.",
      PhotoList: [
      ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post03.png"),
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post04.png"),
    ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post02.png")
      ],
      ContentID:"123456",
      ContentTitle : "대전 e스포츠 경기장",
      ContentOption:"옵션:1 타입:A타입 실속형",
      ContentPhotoUrl:"https://momo.maxidc.net/data/file/samples/sample_box02.png",
      ContentReservationNo:"2106151745623",
    ));
    return data;
  }
}

