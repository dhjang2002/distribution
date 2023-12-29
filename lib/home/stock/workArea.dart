import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/stock/workTana.dart';
import 'package:distribution/models/kItemStockTana.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class WorkArea extends StatefulWidget {
  final String workDay;
  const WorkArea({
    Key? key,
    required this.workDay,
  }) : super(key: key);

  @override
  State<WorkArea> createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  late SessionData _session;
  List<ItemStockTana> _tanaList = [];
  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() {
      _reqTanaList();
    });
    super.initState();
  }

  bool _bWaiting = false;
  void _showProgress(bool bShow) {
    setState(() {
      _bWaiting = bShow;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("타나 분할표"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28,),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 32,
                ),
                onPressed: () {
                  _reqTanaList();
                }),
          ),
          // home
          Visibility(
            visible: false,
            child: IconButton(
                icon: const Icon(
                  Icons.home,
                  size: 32,
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
            child: Row(
              children: [
                const Text("작업자: ", style: ItemBkN16),
                Text(_session.User!.sName!, style: ItemBkB16),
                const Spacer(),
                const Text("타나 갯수: ", style: ItemBkN16),
                Text("${_tanaList.length} ", style: ItemBkB16),
              ],
            ),
          ),
          Row(
            children: [
              Spacer(),
              _showColorInfo(),
            ],
          ),

          const Divider(
            height: 10,
            color: Colors.black,
          ),
          Expanded(
              child: Stack(
                children: [
                  Positioned(child: _renderTanaList()),
                  Positioned(
                      child: Visibility(
                          visible: _bWaiting,
                          child:Container(
                            color: const Color(0x1f000000),
                            child:const Center(
                                child: CircularProgressIndicator()
                            ),
                          )
                      )
                  )
                ],
              )
          )
        ],
      ),
    );
  }

  Widget _showColorInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: [
          const Text("진행: ", style: ItemBkN12,),
          Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
                color: STD_DIFF
            ),
          ),
          
          const SizedBox(width: 5,),
          const Text("대기: ", style: ItemBkN12,),
          Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
                color: STD_READY
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderTanaList() {
    int crossAxisCount = 3;
    final double rt = getMainAxis(context);
    if(rt<1.18) {
      crossAxisCount = 5;
    } else if(rt<1.55) {
      crossAxisCount = 5;
    } else if(rt<2.42) {
      crossAxisCount = 3;
    } else if(rt<2.70) {
      crossAxisCount = 2;
    }

    int dumyCount = 0;
    dumyCount = crossAxisCount;
    int diff = _tanaList.length%crossAxisCount;
    if(diff>0) {
      dumyCount = crossAxisCount + crossAxisCount - diff;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: GridView.builder(
          shrinkWrap: false,
          //physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.0,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemCount: _tanaList.length+dumyCount,
          itemBuilder: (context, int index) {
            return (index<_tanaList.length)
                ? _boxItem(index, _tanaList[index]) : Container();
          }),
    );
  }

  Widget _boxItem(int index, ItemStockTana item) {
    return GestureDetector(
      onTap: () {
        _doProcessTana(index, item);
      },
      child: Container(
        //margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: (item.detailCount>0) ? Colors.grey : Colors.black,
          ),
          borderRadius: BorderRadius.circular(3),
          color:
              (item.detailCount>0) ? STD_DIFF : STD_READY
        ),
        child: Row(
          children: [
            const Spacer(),
            Text(item.sLot1, style: ItemBkB15),
            Text(" (${item.detailCount})", style: ItemBkN14),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // 작업자에게 할당된 타나 정보를 가져온다.
  Future <void> _reqTanaList() async {
    _showProgress(true);
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/listInspectLots1",
        params: {},
        onResult: (dynamic data) {
          // if (kDebugMode) {
          //   var logger = Logger();
          //   logger.d(data);
          // }

          if (data['data'] != null) {
            if (data['data'] is List) {
              _tanaList = ItemStockTana.fromSnapshot(data['data']);
            } else {
              _tanaList = ItemStockTana.fromSnapshot([data['data']]);
            }
          }
          if (_tanaList.isEmpty) {
            showToastMessage("데이터가 없습니다.");
          }
        },
        onError: (String error) {}
     );
    _showProgress(false);
  }

  Future<void> _doProcessTana(int index, ItemStockTana item) async {
    //var result =
    await Navigator.push(
      context,
      Transition(
          child: WorkTana(sLot1: item.sLot1),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    _reqTanaList();
  }
}
