
// ignore_for_file: file_names
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/tempList/detailList.dart';
import 'package:distribution/home/goods/tempList/dlgEditGoodsCategory.dart';
import 'package:distribution/models/kItemTempMaster.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class MasterList extends StatefulWidget {
  const MasterList({Key? key}) : super(key: key);

  @override
  State<MasterList> createState() => _MasterListState();
}

class _MasterListState extends State<MasterList> {

  bool _bEditMode = false;
  List<ItemTempMaster> _itemList = [];
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() {
      _reqListTempCategory();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isInAsyncCall = false;
  void _showProgress(bool bShow) {
    setState(() {
      _isInAsyncCall = bShow;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("임시저장"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: Icon((!_bEditMode)
                    ? Icons.lock_clock_outlined
                    : Icons.lock_open_outlined,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _bEditMode = !_bEditMode;
                  });
                }),
          ),

          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 26,
                ),
                onPressed: () {
                  _reqListTempCategory();
                }),
          ),
        ],
      ),
      body: _renderBody(),
      floatingActionButton: Visibility(
        visible: _bEditMode,
        child: FloatingActionButton.small(
          onPressed: (){
            _addCategory();
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.add, color: Colors.black,),
        ),
      ),
    );
  }

  Widget _renderBody() {
    return Column(
      children: [
        _renderTitle(),
        Expanded(
            child: ModalProgressHUD(
                inAsyncCall: _isInAsyncCall,
                child: ListView.builder(
              itemCount: _itemList.length+1,
                itemBuilder: (context, index){
                if(index<_itemList.length) {
                  return _itemInfo(index, _itemList[index]);
                }
                else {
                  return Container(height: 48,);
                }
            })
            )
        ),
      ],
    );
  }

  Widget _renderTitle() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          const Spacer(),
          const Text("카운트: ", style:ItemBkN16),
          Text("${_itemList.length}", style: ItemBkB16,),
        ],
      ),
    );
  }

  Widget _itemInfo(int index, ItemTempMaster item) {
    String display = "미정의";
    if(item.sMemo.isNotEmpty) {
      display = item.sMemo;
    }

    return GestureDetector(
      onTap: () {
        if(!_bEditMode) {
          _showDetail(item);
        }
      },
      child:Container(
        color: Colors.transparent,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      flex: 8,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("[${item.lOrder}] ", style: ItemBkB16),
                                  Expanded(
                                      child: Text(display,
                                    style: (item.sMemo.isNotEmpty) ? ItemBkN16 : ItemG1N16,
                                      )
                                  )
                                ],
                              )
                            ],
                          ),
                      )
                  ),
                  Expanded(
                      flex: 2,
                      child:
                          Row(
                            children: [
                              const Spacer(),
                              Visibility(
                                  visible: _bEditMode,
                                  child:IconButton(
                                    icon: const Icon(Icons.edit, size: 20,),
                                    onPressed: () {
                                      DlgEditGoodsCategory(
                                        context: context,
                                        label: "카테고리 변경",
                                        value: item.sMemo,
                                        onResult: (bool isOK, String value) {
                                          if(isOK) {
                                            item.sMemo = value;
                                            _updateMemo(item);
                                          }
                                        },
                                      );
                                    },
                                  )
                              ),
                              Visibility(
                                  visible: !_bEditMode,
                                  child:IconButton(
                                    icon: const Icon(Icons.navigate_next_outlined, size: 28,),
                                    onPressed: () {
                                      _showDetail(item);
                                    },
                                  )
                              )
                            ],
                          )

                  )
                ],
              ),
              const Divider(height: 1,),
            ],
          ),
    )
    );
  }
  
  Future <void> _reqListTempCategory() async {
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/listTempGoodsMaster",
        params: {},
        onResult: (dynamic data) {
          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

          if (data['data'][0] != null) {
            var content = data['data'];
            if(content != null) {
              _itemList = ItemTempMaster.fromSnapshot(content);
            }
            setState(() {
            });
          }
        },
        onError: (String error) {}
    );
  }

  Future<void> _updateMemo(ItemTempMaster item) async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/updateGoodsTempMasterName",
        params: {
          "lMasterId": item.lMasterID,
          "sMemo":item.sMemo
        },
        onResult: (dynamic data) {
          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

          if (data['status']== "success") {
              _reqListTempCategory();
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

  Future<void> _showDetail(ItemTempMaster item) async {
    await Navigator.push(
      context,
      Transition(
          child: TempDetailList(
              master:item,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }

  void _addCategory() {
    String sMemo = "";
    DlgEditGoodsCategory(
      context: context,
      label: "카테고리 추가",
      value: sMemo,
      onResult: (bool isOK, String value) {
        if(isOK) {
          sMemo = value.trim();
          _reqAddCategory(sMemo);
          // setState(() {
          //
          // });
        }
      },
    );
  }

  Future<void> _reqAddCategory(String sMemo) async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getMyStore(),
        method: "taka/insertTempGoodsMaster",
        params: {
          "sMemo":sMemo
        },
        onResult: (dynamic data) {
          if (kDebugMode) {
            var logger = Logger();
            logger.d(data);
          }

          if (data['status']== "success") {
            _reqListTempCategory();
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }
}
