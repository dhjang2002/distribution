
// ignore_for_file: file_names, must_be_immutable
import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kItemWarehousingDate.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  String title;
  Event(this.title);
  @override
  String toString() => title;
}

class CalendarDaySelect extends StatefulWidget {
  final String seletedDay;
  final String target;
  const CalendarDaySelect({
    Key? key,
    required this.seletedDay,
    required this.target,
  }) : super(key: key);

  @override
  State<CalendarDaySelect> createState() => _CalendarDaySelectState();
}

class _CalendarDaySelectState extends State<CalendarDaySelect> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _today = DateTime.now();
  DateTime  _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _bDirty = false;
  bool _btnEnable = false;
  String _dateText = "";
  int    _workCount = 0;

  List<ItemWarehousingDate> _dateList = [];
  List<DateTime> _haveWorkList = [];
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    if(widget.seletedDay.isNotEmpty) {
      _selectedDay = DateFormat('yyyy-MM-dd').parse(widget.seletedDay);
      _focusedDay = _selectedDay!;
    } else {
      _selectedDay = _today;
    }
    setState((){});
    Future.microtask(() {
      _reqMonthEvent(_selectedDay!);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("날짜 선택"),
        automaticallyImplyLeading: false,
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 32,
                ),
                onPressed: () async {
                  _doClose();
                }),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 80,
      child: Stack(
        children: [
          // content
          Positioned(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left:0, right: 0, top: 0),
                    child: TableCalendar(
                      locale: 'ko-KR',
                      rowHeight:55,
                      firstDay: DateTime.utc(
                          _today.year-1,
                          _today.month,
                          _today.day),
                      lastDay: _today,
                      focusedDay: _focusedDay,
                      headerVisible: true,
                      calendarFormat: _calendarFormat,
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: ItemBkB24,
                        outsideDaysVisible: false,
                        weekendTextStyle: ItemBkB24,
                        holidayTextStyle: const TextStyle().copyWith(
                            color: Colors.blue[800]),
                        selectedDecoration : const BoxDecoration(
                            color: Color(0xFF1A4C97),
                            shape: BoxShape.circle),
                        todayTextStyle: ItemBkB18,
                      ),

                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        leftChevronIcon: Icon(Icons.arrow_left),
                        rightChevronIcon:Icon(Icons.arrow_right),
                        titleTextStyle: TextStyle(fontSize: 18.0),
                      ),
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _bDirty = true;
                          _selectedDay = selectedDay;
                          _focusedDay  = focusedDay;
                          _dateText = DateFormat('yyyy-MM-dd').format(_selectedDay!);
                          _dateList.forEach((element) {
                            if(element.date == _dateText) {
                              _workCount = element.cnt;
                            }
                          });

                        });
                        _validate();
                      },
                      onPageChanged: (DateTime focusedDay) {
                        _focusedDay = focusedDay;
                        //print("onPageChanged()>>>>> ${focusedDay.toString()}");
                        _reqMonthEvent(focusedDay);
                      },

                      enabledDayPredicate: _getEnableDay,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 1,right: 1, bottom: 60,
              child: Visibility(
                visible: false,//_dateText.isNotEmpty && _workCount>0,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 2,
                      color: Colors.blue,
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text("선택일자: ", style: ItemG1N14,),
                          Text(_dateText, style: ItemBkN14,),
                          const SizedBox(width: 5,),
                          Text("( $_workCount )", style: ItemBkB14,),
                        ],
                      ),
                    ],
                  ),
                ),
              )
          ),
          // button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ButtonSingle(
                    text: '확인',
                    enable: _btnEnable,
                    visible: true,
                    isBottomPading: true,
                    isBottomSide: true,
                    onClick: () {
                      Navigator.pop(context, _dateText);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _validate() {
    setState((){
      _btnEnable = (_bDirty && _dateText.isNotEmpty);
    });
  }

  bool _getEnableDay(DateTime day) {
    if(widget.target.isNotEmpty) {
      for (var element in _haveWorkList) {
        if (day.year == element.year && day.month == element.month &&
            day.day == element.day) {
          return true;
        }
      }
      return false;
    }
    else {
      return true;
    }
  }

  void _doClose() {
    Navigator.pop(context, "");
  }

  Future<void> _reqMonthEvent(DateTime date) async {
    if(widget.target.isNotEmpty) {
      await _reqScheduleList(widget.target, date);
    }
  }

  Future <void> _reqScheduleList(String target, DateTime date) async {
    _haveWorkList = [];
    String month = DateFormat('yyyy-MM').format(date);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/schedule",
        params: {"target":target, "month": month},
        onError: (String error) {},
        onResult: (dynamic data) {
          // if (kDebugMode) {
          //   var logger = Logger();
          //   logger.d(data);
          // }
          if(data['status']=='success') {
            if (data['data'] != null) {
              _dateList = ItemWarehousingDate.fromSnapshot(data['data']);
              for (var element in _dateList) {
                _haveWorkList.add(
                    DateFormat('yyyy-MM-dd').parse(element.date));
              }
            }
          }
          else {
            showToastMessage(data['message']);
          }
        },
    );
    setState(() {});
  }

}
