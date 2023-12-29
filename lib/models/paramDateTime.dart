// ignore_for_file: non_constant_identifier_names, file_names

import 'dart:core';
import 'package:distribution/models/dataDate.dart';
import 'package:distribution/models/dataSession.dart';
import 'package:distribution/models/dataTime.dart';

class ParamDateTime {
  String dateTitle;
  int? dateListIndex;
  List<DataDate>? dateList;

  String sessionTitle;
  int? sessionListIndex;
  List<DataSession>? sessionList;

  String timeTitle;
  int? timeListIndex;
  List<DataTime>? timeList;

  DateTime? Day;
  DateTime? PeriodBegin;
  DateTime? PeriodEnd;

  // int? TimeStart;
  // int? TimeEnd;

  ParamDateTime({

    this.dateTitle = "",
    this.dateListIndex = -1,
    this.dateList,

    this.sessionTitle = "",
    this.sessionListIndex = -1,
    this.sessionList,

    this.timeTitle = "",
    this.timeListIndex = -1,
    this.timeList,

    // this.TimeStart = 0,
    // this.TimeEnd   = 0,
    this.Day,
    this.PeriodBegin,
    this.PeriodEnd,
  });
}