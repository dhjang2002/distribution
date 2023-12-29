// ignore_for_file: file_names, use_build_context_synchronously

import 'package:distribution/common/buttonSingle.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppConfig extends StatefulWidget {
  final bool? isDeveloper;
  const AppConfig({
    Key? key,
    this.isDeveloper = false,
  }) : super(key: key);

  @override
  State<AppConfig> createState() => _AppConfigState();
}

class MenuItemPos {
  String label;
  String location;
  bool select;
  MenuItemPos({
    this.label = "",
    this.select = false,
    this.location = "0",
  });
}

class _AppConfigState extends State<AppConfig> {
  int _selIndex = 3;
  final List<MenuItemPos> _locItems = [];
  bool _useCamera = true;
  bool _useAutoLogin = true;
  bool _useTestMode = false;
  late SessionData _session;
  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _selIndex = int.parse(_session.Setting!.ActionButtonLoc!);
    _useCamera = (_session.Setting!.UseCamera == "YES");
    _useAutoLogin = (_session.Setting!.UseAutoLogin == "YES");
    _useTestMode = (_session.Setting!.UseTestMode == "YES");

    _locItems.add(MenuItemPos(label: "오른쪽 하단", location: "0"));
    _locItems.add(MenuItemPos(label: "오른쪽 상단", location: "1"));
    _locItems.add(MenuItemPos(label: "왼쪽 상단", location: "2"));
    _locItems.add(MenuItemPos(label: "왼쪽 하단", location: "3"));
    _locItems.add(MenuItemPos(label: "중앙 하단", location: "4"));

    _locItems[_selIndex].select = true;
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("환경설정"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
              visible: widget.isDeveloper!,
              child: ListTile(
                title: const Text("테스트 모드", style: ItemBkN20),
                subtitle: const Text(
                  "테스트 모드 사용",
                  style: ItemG1N12,
                ),
                trailing: Switch(
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey,
                  activeTrackColor: ColorB0,
                  activeColor: ColorB0,
                  value: _useTestMode,
                  onChanged: (value) async {
                    setState(() {
                      _useTestMode = value;
                    });
                  },
                ),
              )),
          ListTile(
            title: const Text("자동 로그인", style: ItemBkN20),
            subtitle: const Text(
              "이전 로그인 정보를 이용하여 로그인 진행",
              style: ItemG1N12,
            ),
            trailing: Switch(
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey,
              activeTrackColor: ColorB0,
              activeColor: ColorB0,
              value: _useAutoLogin,
              onChanged: (value) async {
                setState(() {
                  _useAutoLogin = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text("카메라 버튼 사용", style: ItemBkN20),
            subtitle: const Text(
              "모바일 카메라를 이용하여 바코드 인식 ",
              style: ItemG1N12,
            ),
            trailing: Switch(
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey,
              activeTrackColor: ColorB0,
              activeColor: ColorB0,
              value: _useCamera,
              onChanged: (value) async {
                setState(() {
                  _useCamera = value;
                });
              },
            ),
          ),
          Expanded(
              child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _locItems.length,
            itemBuilder: (BuildContext context, int index) {
              return _menuItem(_locItems[index]);
            },
          )),
          SizedBox(
            height: 80,
            child: Row(
              children: [
                ButtonSingle(
                    visible: true,
                    text: '적용하기',
                    enable: true,
                    onClick: () async {
                      await _applyy();
                      Navigator.pop(context, true);
                    }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _menuItem(MenuItemPos item) {
    return GestureDetector(
      onTap: () {
        if (!_useCamera) {
          return;
        }

        for (var element in _locItems) {
          element.select = false;
        }

        _selIndex = int.parse(item.location);
        setState(() {
          _locItems[_selIndex].select = true;
        });
      },
      child: Opacity(
          opacity: (_useCamera) ? 1.0 : 0.3,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            color: (item.select) ? Colors.blue : Colors.white,
            child: Text(
              item.label,
              style: ItemBkN18,
            ),
          )),
    );
  }

  Future<void> _applyy() async {
    _session.Setting!.ActionButtonLoc = _locItems[_selIndex].location;
    _session.Setting!.UseCamera = (_useCamera) ? "YES" : "NO";
    _session.Setting!.UseAutoLogin = (_useAutoLogin) ? "YES" : "NO";
    _session.Setting!.UseTestMode = (_useTestMode) ? "YES" : "NO";
    await _session.saveSetting();
  }
}
