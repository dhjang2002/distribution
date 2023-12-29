// ignore_for_file: non_constant_identifier_names, file_names

import 'package:distribution/models/itemPhoto.dart';

class InfoChannel {
  String? ChannelID;        // 레코드 key
  String? HostName;         // 호스트 이름
  String? PhoneNumber;      // 연락처
  double? AverageRating;    // 평균평점
  int?    TotalPost;        // 후기 총 건수
  int?    TotalQuestion;    // 문의 총 건수
  double? ResponseRate;     // 문의 응답율,
  int?    ResponseInterval; // 평균 응답시간(분)
  int?    TotalPlay;        // 주최한 행사 총 건수
  int?    TotalPlace;       // 등록한 장소 총 건수
  int?    TotalEvent;       // TotalEvent = (TotalPlay + TotalPlace);
  List<ItemPhoto>? PhotoList;  // 채널 소개사진 URL

  InfoChannel({
    this.ChannelID = "",
    this.HostName = "",
    this.PhoneNumber="",
    this.AverageRating = 0.0,
    this.TotalPost = 0,
    this.TotalQuestion = 0,
    this.ResponseRate = 99.9,
    this.ResponseInterval = 30,
    this.TotalPlay = 0,
    this.TotalPlace = 0,
    this.TotalEvent = 0,
    this.PhotoList = const <ItemPhoto>[],
  });

  static List<InfoChannel> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return InfoChannel.fromJson(data);
    }).toList();
  }

  factory InfoChannel.fromJson(Map<String, dynamic> jdata)
  {
    return InfoChannel(
      ChannelID: jdata['ChannelID'],
      HostName: jdata['HostName'],
      PhoneNumber: jdata['PhoneNumber'],
    );
  }
}