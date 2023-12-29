// ignore_for_file: non_constant_identifier_names, file_names

import 'package:distribution/models/itemPhoto.dart';

class ItemQuestion {
  String? Key;                        // ID (서버에서 생성됨.)
  String? ContentTitle;               // 행사명칭
  String? WriterUserID;               // 작성자 ID
  String? WriterNickname;             // 작성자 닉네임
  String? WriterPhotoUrl;             // 작성자 사진
  String? IsScret;                    // 비밀문의 여부
  String? QuestionTitle;              // 문의 제목
  String? QuestionContent;            // 문의 내용
  String? QuestionKind;               // 문의 구분
  String? QuestionOption;             // 문의 옵션 (문의 구분이 "환불/취소"일때 예약번호)
  String? QuestionStamp;              // 문의 일시
  List<ItemPhoto>? QuestionPhotoList; // 문의 사진 리스트 (1~10장)
  String? AnswerContent;              // 답변 내용
  String? AnswerStamp;                // 답변 일시
  bool?   showDetail;                 // Reversed (App에서만 사용됨.)

  ItemQuestion({
    this.Key="",
    this.ContentTitle = "",
    this.WriterUserID = "",
    this.WriterNickname = "",
    this.WriterPhotoUrl = "",
    this.QuestionStamp="",
    this.QuestionContent="",
    this.QuestionTitle="",
    this.QuestionKind="",
    this.QuestionOption="",
    this.QuestionPhotoList = const <ItemPhoto>[],
    this.AnswerContent="",
    this.AnswerStamp="",
    this.IsScret = "N",
    this.showDetail = false,
  });

  static List<ItemQuestion> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemQuestion.fromJson(data);
    }).toList();
  }

  factory ItemQuestion.fromJson(Map<String, dynamic> jdata)
  {
    return ItemQuestion(
      Key: jdata['Key'],
      ContentTitle: jdata['ContentTitle'],
      WriterUserID: jdata['WriterUserID'],
      WriterNickname: jdata['WriterNickname'],
      WriterPhotoUrl: jdata['WriterPhotoUrl'],
      IsScret: jdata['IsScret'],
      QuestionTitle: jdata['QuestionTitle'],
      QuestionContent: jdata['QuestionContent'],
      QuestionKind: jdata['QuestionKind'],
      QuestionOption: jdata['QuestionOption'],
      QuestionStamp: jdata['QuestionStamp'],
      AnswerContent: jdata['AnswerContent'],
      AnswerStamp: jdata['AnswerStamp'],
      showDetail: false,
      QuestionPhotoList: ItemPhoto.fromSnapshot(jdata['QuestionPhotoList']),
    );
  }

  static Future<List<ItemQuestion>> getTestData(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    List<ItemQuestion> data = [];
    data.add(ItemQuestion(
      Key:"1",
      ContentTitle: "",
      WriterUserID: "",
      WriterNickname: "",
      WriterPhotoUrl: "",
      QuestionKind:"환불/취소",
      QuestionOption:"2106141745623",
      QuestionTitle:"문의가 있습니다.",
      QuestionStamp:"2022.06.10 13:03:27",
      QuestionContent:"2번 결제된것 같아요. 하나는 취소해 주세요.",
      QuestionPhotoList : [],
      AnswerContent:"",
      AnswerStamp:"2022.06.12 14:13:20",
      IsScret : "N",
    ));
    data.add(ItemQuestion(
      Key:"2",
      ContentTitle: "",
      WriterUserID: "",
      WriterNickname: "",
      WriterPhotoUrl: "",
      QuestionKind:"기타문의",
      QuestionOption:"",
      QuestionTitle:"문의가 있어요",
      QuestionStamp:"2022.06.12 13:03:27",
      QuestionContent:"안녕하세요. 문의드릴 것이 있습니다.",
      QuestionPhotoList : [
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post03.png"),
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post04.png"),
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post02.png")
      ],
      AnswerContent:"안녕하세요. 문의 남겨 주셔서 감사합니다.\n기획자입니다.\n문의에 대한 답변을 소근소근 두근두근 야금야금 드립니다.",
      AnswerStamp:"2022.06.12 14:13:20",
      IsScret : "N",
    ));

    data.add(ItemQuestion(
      Key:"2",
      ContentTitle: "",
      WriterUserID: "",
      WriterNickname: "",
      WriterPhotoUrl: "",
      QuestionKind:"회원관련",
      QuestionOption:"",
      QuestionTitle:"문의가 있어요",
      QuestionStamp:"2022.06.12 13:03:27",
      QuestionContent:"안녕하세요. 문의드릴 것이 있습니다.",
      QuestionPhotoList : [
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post03.png"),
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post04.png"),
        ItemPhoto(image_url:"https://momo.maxidc.net/data/file/samples/sample_post02.png")
      ],
      AnswerContent:"",
      AnswerStamp:"",
      IsScret : "N",
    ));
    return data;
  }
}