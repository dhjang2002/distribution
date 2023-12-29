import 'package:distribution/common/cardGridMenu.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/shipping/output/listShippingBox.dart';
import 'package:distribution/home/shipping/packing/workPackMain.dart';
import 'package:distribution/home/shipping/picking/workPickMain.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class ShippingMain extends StatefulWidget {
  const ShippingMain({Key? key}) : super(key: key);

  @override
  State<ShippingMain> createState() => _ShippingMainState();
}

class _ShippingMainState extends State<ShippingMain> {
  List<CardGridMenuItem> menuItems = [];


  //final bool _bAvailScan = true;
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _buildMenuItems();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _buildMenuItems() {
    menuItems = [];
    if(_session.isSigned()) {
      menuItems.add(CardGridMenuItem(
          label: '상품픽업', menuId:3001, assetsPath: "icon/main_check.png"));
      menuItems.add(CardGridMenuItem(
          label: '상품포장', menuId:3002, assetsPath: "icon/main_boxes.png"));
      menuItems.add(CardGridMenuItem(
          label: '출하내역', menuId:3003, assetsPath: "icon/main_file.png"));
    }
  }

  void _onAction(CardGridMenuItem item) {
    switch(item.menuId) {
      case 3001: // 상품출고
        Navigator.push(context,
          Transition(child: const WorkPickMain(),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;

      case 3002: // 상품포장
        Navigator.push(context,
          Transition(child: const PackMaster(),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;

      case 3003: // 상품포장
        Navigator.push(context,
          Transition(child: ListShippingBox(),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("상품출고"),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 28,),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
      body:_renderBody()
    );
  }

  Widget _renderBody() {
    double psz = MediaQuery.of(context).size.width/6;
    double bottomPading = getMainBottomPading(context, 1);
    double mainPictHeight = MediaQuery.of(context).size.height*0.35;
    return Stack(
      children: [
        Positioned(
            top:0, left:0, right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.fromLTRB(5, 25, 5, 15),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _session.Stroe!.sName,
                        style: ItemBkB20,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        "상품출고 업무를 처리합니다.",
                        style: ItemBkN16,
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: mainPictHeight,
                  width: double.infinity,
                  child: Image.asset("assets/intro/menu_distribute.png",
                    fit: BoxFit.cover,),
                ),
              ],
            )
        ),
        Positioned(
            bottom: 0, left: 0, right: 0,
            child: Visibility(
                visible: true,
                child:Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(bottom: bottomPading),
                    color: Colors.white,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(psz, 0, psz, 0),
                        child: CardGridMenu(
                          crossAxisCount: 3,
                          items: menuItems,
                          onTab: (CardGridMenuItem item) {
                            _onAction(item);
                          },
                        ),
                      ),
                    ))
            )
        ),
        Positioned(
            bottom: 0, left: 0, right: 0,
            child: Visibility(
                visible: false,
                child:Container(
                    height: 240,
                    width: double.infinity,
                    color: Colors.grey[50],
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: const Text("출고 데이터가 없습니다.", style: ItemBkN20,),
                      ),
                    ))
            )
        ),
      ],
    );
  }

}
