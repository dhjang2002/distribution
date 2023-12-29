import 'package:distribution/constant/constant.dart';
import 'package:distribution/models/kItemNotify.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class ShowNotify extends StatefulWidget {
  const ShowNotify({Key? key}) : super(key: key);

  @override
  State<ShowNotify> createState() => _ShowNotifyState();
}

class _ShowNotifyState extends State<ShowNotify> {
  List<ItemNotify> _itemList = [];

  late SessionData _session;
  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    Future.microtask(() {
      _reqList();
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
          title: const Text("공지사항"),
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
                    size: 26,
                  ),
                  onPressed: () {
                    _reqList();
                  }),
            ),
          ],
        ),
        body: ModalProgressHUD(
          inAsyncCall: _isInAsyncCall,
          child: Container(color: Colors.white, child: _renderBody()),
        ));
  }

  Widget _renderBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Row(
            children: [
              const Spacer(),
              const Text("공지글 갯수 :  ", style: ItemBkN14,),
              Text("${_itemList.length}", style: ItemBkB16,),
            ],
          ),
        ),
        const Divider(height: 5,),
        Expanded(
            child: ListView.builder(
                itemCount: _itemList.length,
                itemBuilder: (context, index) {
                  return _itemNotice(_itemList[index]);
                }
            )
        ),
      ],
    );
  }

  Future<void> _reqList() async {
    _showProgress(true);
    // { "sTopic" : "HD" 혹은 "lEmployeeId": "123" }
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/appListNotice",
        params: {"sTopic": _session.FireBaseTopic, "lPageNo": "1",  "lRowNo" : "15"},
        onResult: (dynamic data) async {
          _showProgress(false);
          if (data['data'] != null) {
            var content = data['data'];
            _itemList = ItemNotify.fromSnapshot(content);
            if(_itemList.isNotEmpty) {
              _itemList[0].showMore = true;
              String noticeId = _itemList[0].lNoticeID.toString();
              if(noticeId != _session.NoticeId) {
                await _session.setNoticeId(noticeId);
                _session.doNotify();
              }
            }
          }
        },
        onError: (String error) {}
    );
    _showProgress(false);
  }

  Widget _itemNotice(ItemNotify item) {
    final span=TextSpan(text:item.tContent);
    final tp =TextPainter(text:span,maxLines: 3,textDirection: TextDirection.ltr);
    tp.layout(maxWidth: MediaQuery.of(context).size.width); // equals the parent screen width
    //print("tp.didExceedMaxLines=${tp.didExceedMaxLines}");
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.dtRegDate, style: ItemBkN12,),
              const Spacer(),
              Visibility(
                  visible: tp.didExceedMaxLines,//!item.showMore,
                  child: TextButton(
                      onPressed: (){
                        setState(() {
                          item.showMore = !item.showMore;
                        });
                      },
                      child: Icon((item.showMore)
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_outlined)
                  )
              ),
            ],
          ),
          const SizedBox(height: 5,),
          Text(item.sTitle, style: ItemBkB18, maxLines: 3,
            textAlign:TextAlign.justify,
            overflow: TextOverflow.ellipsis,),
          Padding(
            padding: const EdgeInsets.fromLTRB(0,5,0,0),
            child: Text(item.tContent,
                style: ItemBkN14,
                maxLines: (item.showMore) ? 44 : 3,
                textAlign:TextAlign.justify,
                overflow: TextOverflow.ellipsis),
          ),
          const Divider(),
        ],
      ),
    );
  }

}
