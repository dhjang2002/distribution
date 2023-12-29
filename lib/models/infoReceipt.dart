// ignore_for_file: non_constant_identifier_names, file_names

class InfoReceipt {
  final String? Key;                      // ID
  final String? ApprovalNumber;           // 승인번호
  final String? CardType;                 // 카드종류
  final String? CardNumber;               // 카드번호
  final String? Installment;              // 할부/일시불
  final String? TransactionDate;          // 거래일시
  final String? CancellationDate;         // 취소일시
  final String? OrderProduct;             // 주문상품
  final String? OrderNumber;              // 주문번호
  final String? SellerTradeName;          // 판매자 상호
  final String? SellerRepresentative;     // 판매자 대표
  final String? SellerRegistrationNumber; // 판매자 사업자등록번호
  final String? SellerPhoneNumber;        // 판매자 전화번호
  final String? SellerAddress;            // 판매자 주소
  final int?    Price;                    // 거래금액
  final int?    VAT;                      // 부가세
  final int?    Total;                    // 합계

  InfoReceipt({
    this.Key="",
    this.ApprovalNumber = "",
    this.CardType = "",
    this.CardNumber = "",
    this.Installment="",
    this.TransactionDate="",
    this.CancellationDate = "",
    this.OrderProduct = "",
    this.OrderNumber = "",
    this.SellerTradeName = "",
    this.SellerRepresentative = "",
    this.SellerRegistrationNumber = "",
    this.SellerPhoneNumber = "",
    this.SellerAddress = "",
    this.Price = 0,
    this.VAT = 0,
    this.Total = 0,
  });

  static List<InfoReceipt> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return InfoReceipt.fromJson(data);
    }).toList();
  }

  factory InfoReceipt.fromJson(Map<String, dynamic> jdata)
  {
    return InfoReceipt(
      ApprovalNumber: jdata['ApprovalNumber'],
      CardType: jdata['CardType'],
      CardNumber: jdata['CardNumber'],
    );
  }

  static InfoReceipt getTestData() {
    return InfoReceipt(
      Key:"",
      ApprovalNumber : "12345678",
      CardType : "삼성카드",
      CardNumber : "1234-1234-4314",
      Installment:"일시불",
      TransactionDate:"2022.06.15.15:24:33",
      CancellationDate : "",
      OrderProduct : "2021 핸드페어(윈터)",
      OrderNumber : "12345678",
      SellerTradeName : "(주)필리스",
      SellerRepresentative : "홍길동",
      SellerRegistrationNumber : "314-24-43321",
      SellerPhoneNumber : "042-863-0988",
      SellerAddress : "대전시 유성구 대덕대로 124",
      Price : 50000,
      VAT : 5000,
      Total : 55000,
    );
  }
}