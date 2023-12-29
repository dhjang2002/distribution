// ignore_for_file: non_constant_identifier_names, file_names

class ItemNotice {
  String? Category; // 알림 구뷴
  String? Stamp;    // 알림일시
  String? Title;    // 타이틀
  String? Content;  // 내용

  ItemNotice({
    this.Category = "",
    this.Stamp = "",
    this.Title = "",
    this.Content = "",
  });

  static List<ItemNotice> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemNotice.fromJson(data);
    }).toList();
  }

  factory ItemNotice.fromJson(Map<String, dynamic> jdata)
  {
    return ItemNotice(
      Category: jdata['Category'],
      Stamp: jdata['Stamp'],
      Title: jdata['Title'],
    );
  }

  static Future <List<ItemNotice>> getNoticeData(int milliseconds) async {
    List<ItemNotice> dataList = [];
    await Future.delayed(Duration(milliseconds: milliseconds));
    dataList.add(ItemNotice(
      Category: "0",
      Stamp: "2021.08.21 09:45:44",
      Title: "포토 후기가 등록되었습니다.",
      Content: "포토 후기를 작성해 주셔서 감사합니다." "\n후기 승인이 완료되면 적립금이 지급됩니다."
          "\nAnd they ask you questions about your lifestyle and your family history, your medication history, your surgical history, your allergy history ... did I forget any history",
    ));
    dataList.add(ItemNotice(
      Category: "1",
      Stamp: "2022.06.09 09:45:00",
      Title: "포토 후기가 등록되었습니다.",
      Content: "에스케이이엔에스(SK E&S)가 주요 사업자로 참여하고 있는 호주 바로사-칼디따 해상 가스전(이하 바로사 가스전) 개발 사업을 둘러싸고, 호주 현지에서 환경단체와 원주민들이 법원에 공사 중지 처분을 요구하는 소송을 제기했다. 앞서 한국 법원은 지난달 호주 원주민들이 낸 공사 가처분 신청을 기각한 바 있다.\n9일 국내 환경단체 기후솔루션에 따르면, 바로사 가스전 사업장 인근 티위(Tiwi) 제도의 므누피(Munupi) 지역 원주민들은 “바로사 가스전 사업의 시추 허가에 절차상의 문제가 있다” 지난 7일 호주 법원에 공사 중지 가처분 신청을 냈다. 바로사 가스전 사업 예정지는 므누피 원주민들이 거주하는 지역에서 북동쪽으로 40㎞ 떨어져 있다.",
    ));
    dataList.add(ItemNotice(
      Category: "2",
      Stamp: "2022.06.08 09:45:00",
      Title: "포토 후기가 등록되었습니다.",
      Content: "[서울=뉴시스] 차미례 기자 = 세계적인 식량가격 폭등 등 식량위기에 공동대처하기 위한 지중해 연안국가들의 장관회의가 8일(현지시간) 유엔식량농업기구(FAO)가 있는 로마에서 최초로 열렸다."
          "\n\n이탈리아 정부과 주최한 이 회의에 참석한 이집트, 프랑스, 그리스 , 스페인을 포함한 24개국 대표들은 앞으로 기초식량 생산품의 가격 인상과 싸우기 위한 협정을 체결했다.\n이 날 회의는 이탈리아의 마리나 세레니 외교부 차관의 주재로 직접 대면회의와 화상회의를 겸해서 진행되었다. 세레니는 로마의 유엔식량기구를 포함한 국제기구들과 협력해서 식량위기에 처한 특정 지역에 개입하는 데 집중하기로 했다고 밝혔다.최근 세계 식량가격은 러시아와 우크라이나의 전쟁, 공급망 붕괴, 코로나19 대유행의 후유증 등이 복합된 원인으로 인해 몇 달 동안이나 계속해서 급상승했다.\n\n빵바구니 물가의 척도인 세계식량가격지수( World Food Price Index)는 지난 3개월 동안 3번이나 최고점을 경신했고 3월 중에는 계속해서 고공행진을 했다.이 가격지수는 1990년 이래 상승세를 계속해왔다.\n\nFAO의 취동위 사무총장은 8일 열린 장관회의에서 연설하면서 우크라이나 사태로 인해 전세계의 식량수급 시스템을 정비할 필요가 있음이 입증되었다고 말했다. 우리는 전세계의 식량 무역을 개방하고 농산물과 식품 수출에 대한 제한이나 과세를 없애도록 해야한다고 그는 강조했다.",
    ));

    return dataList;
  }
}