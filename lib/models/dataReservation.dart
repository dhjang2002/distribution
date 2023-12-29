// ignore_for_file: non_constant_identifier_names

import 'package:distribution/models/dataDate.dart';
import 'package:distribution/models/dataDiscount.dart';
import 'package:distribution/models/dataEquipment.dart';
import 'package:distribution/models/dataSession.dart';
import 'package:distribution/models/dataZone.dart';
import 'package:distribution/models/paramDateTime.dart';

class DataReservation {
  List<DataDate>?       dateList;           // 예약 가능일
  List<DataDiscount>?   disCountList;       // 할인정보
  List<DataEquipment>?  basicEquipmentList;      // 부대장비
  List<DataEquipment>?  optionEquipmentList;      // 부대장비
  List<DataSession>?    sessionList;        // 세션정보
  List<DataZone>?       zoneList;           // 구역정보

  int? Price;
  int? PersonCount;
  ParamDateTime? dateSet;
  String? dateSetInfo;

  String? Type;
  List<String>? TypeList;

  String? Option;
  List<String>? OptionList;

  String? Info;
  List<String>? InfoList;

  DataReservation({
    this.dateList,
    this.disCountList,
    this.basicEquipmentList  = const [],
    this.optionEquipmentList = const [],
    this.sessionList,
    this.zoneList,

    this.Price = 5000,
    this.PersonCount = 1,
    this.dateSet,
    this.dateSetInfo="",
    this.Type="",
    this.TypeList   = const <String>[],
    this.Option="",
    this.OptionList = const <String>[],
    this.Info="",
    this.InfoList   = const <String>[],
  });
}