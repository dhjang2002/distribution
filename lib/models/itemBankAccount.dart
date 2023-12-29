class ItemBankAccount {
  String? BankName;     // 은행명
  String? AccountNum;   // 계좌번호
  String? OwnerName;    // 예금주

  ItemBankAccount({
    this.BankName="은행선택",
    this.AccountNum="",
    this.OwnerName=""
  });

  static List<ItemBankAccount> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemBankAccount.fromJson(data);
    }).toList();
  }

  factory ItemBankAccount.fromJson(Map<String, dynamic> jdata)
  {
    return ItemBankAccount(
      BankName: jdata['BankName'],
      AccountNum: jdata['AccountNum'],
      OwnerName: jdata['OwnerName'],
    );
  }

  static Future<ItemBankAccount> getTestAccount(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));

    return ItemBankAccount(
      BankName: "기업은행",
      AccountNum: "3144489607",
      OwnerName: "홍길동",
    );
  }
}
