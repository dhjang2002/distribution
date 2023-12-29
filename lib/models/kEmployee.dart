// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

class Employee {
  String? lEmployeeID;
  String? sEmployeeNo;
  String? sName;
  String? sAddr;
  String? sMobile;
  String? sEmail;
  String? sGender;
  String? sPicturePath;
  String? sPushToken;

  Employee({
    this.lEmployeeID = "",
    this.sEmployeeNo="",
    this.sName="",
    this.sAddr="",
    this.sMobile="",
    this.sEmail="",
    this.sGender="",
    this.sPicturePath="",
    this.sPushToken="",
  });

  factory Employee.fromJson(Map<String, dynamic> person)
  {
    return Employee(
      sEmployeeNo:(person['sEmployeeNo']!=null) ? person['sEmployeeNo'].toString().trim() : "",
      lEmployeeID:(person['lEmployeeID']!=null) ? person['lEmployeeID'].toString().trim() : "",
      sName: (person['sName']!=null) ? person['sName'].toString().trim() : "",
      sAddr: (person['sAddr']!=null) ? person['sAddr'].toString().trim() : "",
      sMobile: (person['sMobile']!=null) ? person['sMobile'].toString().trim() : "",
      sEmail: (person['sEmail']!=null) ? person['sEmail'].toString().trim() : "",
      sGender: (person['sGender']!=null) ? person['sGender'].toString().trim() : "",
      sPicturePath:(person['sPicturePath']!=null) ? person['sPicturePath'].toString().trim() : "",
      sPushToken:(person['sPushToken']!=null) ? person['sPushToken'].toString().trim() : "",
    );
  }

  @override
  String toString(){
    return 'Employee {'
        'lEmployeeID:$lEmployeeID, '
        'sEmployeeNo:$sEmployeeNo, '
        'sName:$sName, '
        'sAddr:$sAddr, '
        'sMobile:$sMobile, '
        'sEmail:$sEmail, '
        'sGender:$sGender, '
        'sPushToken:$sPushToken, '
        'sPicturePath:$sPicturePath }';
  }
}
