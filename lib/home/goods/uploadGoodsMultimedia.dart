// ignore_for_file: file_names, invalid_use_of_visible_for_testing_member, use_build_context_synchronously
import 'dart:io';
import 'package:distribution/common/dialogbox.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/home/goods/copyGoodsMultimedia.dart';
import 'package:distribution/models/kGoodsFiles.dart';
import 'package:distribution/provider/sessionData.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:distribution/utils/mediaView.dart';
import 'package:distribution/utils/utils.dart';
import 'package:distribution/remote/remote.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';
import 'package:video_compress/video_compress.dart';

class _MenuItem {
  String label;
  bool select;
  int index;
  String type;
  String url;
  _MenuItem({
    required this.label,
    required this.index,
    required this.select,
    required this.type,
    required this.url,
  });
}

class UploadGoodsMultimedia extends StatefulWidget {
  final int lGoodsId;
  final String barcode;
  const UploadGoodsMultimedia({
    Key? key,
    required this.lGoodsId,
    required this.barcode,
  }) : super(key: key);

  @override
  State<UploadGoodsMultimedia> createState() => _UploadGoodsMultimediaState();
}

class _UploadGoodsMultimediaState extends State<UploadGoodsMultimedia> {
  bool _bDirty = false;
  int _menuIndex = 0;
  final List<_MenuItem> _menuItems = [];

  bool _bNotEmpty = false;
  GoodsFiles _photoInfo = GoodsFiles();
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    _menuItems.add(_MenuItem(
        index: 0,
        type: "m",
        select: true,
        label: "메인",
        url: _photoInfo.sMainPicture));
    _menuItems.add(_MenuItem(
        index: 1,
        type: "s1",
        select: false,
        label: "보조1",
        url: _photoInfo.sSubPic1));
    _menuItems.add(_MenuItem(
        index: 2,
        type: "s2",
        select: false,
        label: "보조2",
        url: _photoInfo.sSubPic2));
    _menuItems.add(_MenuItem(
        index: 3,
        type: "s3",
        select: false,
        label: "보조3",
        url: _photoInfo.sSubPic3));
    _menuItems.add(_MenuItem(
        index: 4,
        type: "s4",
        select: false,
        label: "보조4",
        url: _photoInfo.sSubPic4));
    _menuItems.add(_MenuItem(
        index: 5,
        type: "v",
        select: false,
        label: "동영상",
        url: _photoInfo.sVideo));
    Future.microtask(() async {
      //await DefaultCacheManager().removeFile("UploadGoodsMultimedia");
      //await DefaultCacheManager().emptyCache();
      await _reqGetFiles();
    });
    super.initState();
  }

  Future<bool> onWillPop() async {
    Navigator.pop(context, _bDirty);
    return false;
  }

  bool _bWaiting = false;
  void _showProgress(bool bShow) {
    setState(() {
      _bWaiting = bShow;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
            appBar: AppBar(
              title: const Text("상품사진"),
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28,),
                  onPressed: () {
                    //print("_bDirty====>$_bDirty");
                    Navigator.pop(context, _bDirty);
                  }),
              actions: [
                Visibility(
                  visible: _bNotEmpty,
                  child: IconButton(
                      icon: const Icon(
                        Icons.copy_outlined,
                        size: 24,
                      ),
                      onPressed: () {
                        _doPasteFiles();
                      }),
                ),
              ],
            ),
            body: _renderBody()));
  }

  Widget _renderBody() {
    final double rt = getMainAxis(context);
    double psz = MediaQuery.of(context).size.width/8;
    final picHeight = MediaQuery.of(context).size.width * 0.8;
    String fileName = getNameFromPath(_menuItems[_menuIndex].url);
    return Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // photo View
            Positioned(
              child:SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. title
                    Container(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                        child: Row(
                          children: [
                            Text(
                              _menuItems[_menuIndex].label,
                              style: ItemBkB16,
                            ),
                            const Spacer(),
                            Text(
                              fileName,
                              style: ItemBkN16,
                            ),
                          ],
                        )),
                    Container(
                      height: 40,
                      color: Colors.white,
                      child: Row(
                        children: [
                          const Spacer(),
                          Visibility(
                            visible: true,
                            child: IconButton(
                                icon: Icon(
                                  (_menuIndex != 5) ? Icons.camera : Icons.videocam,
                                  color: Colors.black,
                                  size: 22,
                                ),
                                onPressed: () {
                                  if (_menuIndex != 5) {
                                    _fromCamera(_menuItems[_menuIndex]);
                                  } else {
                                    _fromCameraVideo(
                                        _menuItems[_menuIndex]);
                                  }
                                }),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Visibility(
                            visible: true,
                            child: IconButton(
                                icon: Icon(
                                  (_menuIndex != 5) ? Icons.photo : Icons.video_library,
                                  color: Colors.black,
                                  size: 22,
                                ),
                                onPressed: () {
                                  if (_menuIndex != 5) {
                                    _fromGallery(_menuItems[_menuIndex]);
                                  } else {
                                    _fromGalleryVideo(_menuItems[_menuIndex]);
                                  }

                                }),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Visibility(
                              visible: true,
                              child: IconButton(
                                //disabledColor: Colors.grey,
                                icon: Icon(
                                  Icons.delete,
                                  color: (_menuItems[_menuIndex]
                                      .url
                                      .isNotEmpty)
                                      ? Colors.black
                                      : Colors.grey,
                                  //color: Colors.black,
                                  size: 22,
                                ),
                                onPressed: () {
                                  if (_menuItems[_menuIndex]
                                      .url
                                      .isNotEmpty) {
                                    _askDelete(_menuItems[_menuIndex]);
                                  }
                                },
                              )),
                        ],
                      ),
                    ),
                    // 2. photo view
                    SizedBox(
                      height: picHeight,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned(
                              child: Container(
                                  decoration:  BoxDecoration(
                                    //color: Colors.grey,
                                    border: Border.all(
                                      width: 1,
                                      color: const Color(0xFFC9CACF),
                                    ),
                                  ),
                                  child: _showPhoto(_menuItems[_menuIndex])
                              )
                          ),
                        ],
                      ),
                    ),
                  ],
              ))
            ),
            // select menu
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  //margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  padding: EdgeInsets.fromLTRB(psz, 0, psz, 10),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (rt<1.55) ? 6 : 3,
                        childAspectRatio: 1.1,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 1,
                      ),
                      itemCount: _menuItems.length,
                      itemBuilder: (context, int index) {
                        return _menuCard(rt, _menuItems[index]);
                      }),
                )),
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
            ),
          ],
        ));
  }

  Widget _showPhoto(_MenuItem item) {
    if (item.url.isEmpty) {
      return Center(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
          child: Image.asset(
            "assets/icon/tk_empty_photo.png",
            fit: BoxFit.fill,
            //color: Colors.grey,
          ),
      ));
    }

    if (item.type != "v") {
      return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.network(
            item.url,
            fit: BoxFit.fill,
          ));
    }

    return MediaView(
      isMovie: true,
      sourceUrl: item.url,
    );
  }

  Widget _menuCard(double rt, _MenuItem item) {
    return GestureDetector(
      onTap: () {
        for (var element in _menuItems) {
          element.select = false;
        }
        item.select = true;
        _menuIndex = item.index;
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: (item.url.isNotEmpty) ? Colors.white : Colors.grey[200],
          border: Border.all(
            color: (item.select) ? Colors.pink : Colors.grey,
          ),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.label, style: (rt<1.7) ? ItemBkN12 : ItemBkN12),
            ]),
      ),
    );
  }

  Future<void> _fromCamera(_MenuItem item) async {
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.camera);
    if (image != null) {
      File pick = File(image.path);

      // cropImage
      CroppedFile? crop = await cropImage(pick);
      if (crop != null) {
        pick = File(crop.path);
        _reqUpload(item, pick.path);
      }
    }
  }

  Future<void> _fromGallery(_MenuItem item) async {
    File? pick = await pickupImage();
    if (pick != null) {
      String ext = getExtFromPath(pick.path);
      if (ext == "png" || ext == "jpg" || ext == "jpeg") {
        CroppedFile? crop = await cropImage(pick);
        if (crop != null) {
          pick = File(crop.path);
          _reqUpload(item, pick.path);
        }
      }
    }
  }

  Future<void> _fromCameraVideo(_MenuItem item) async {
    var pickedMovie = await ImagePicker.platform.getVideo(
        source: ImageSource.camera, maxDuration: const Duration(seconds: 60));
    if (pickedMovie != null) {
      //File pick = File(pickedMovie.path);
      //Directory dir = await getTemporaryDirectory();
      _showProgress(true);
      showToastMessage("동영상 파일을 최적화 하는 중입니다.\n최대 용량은 최적화 후 99MB 입니다.\n파일 용량에 따라 몇분이 소요됩니다.", isLengthLong: true);
      MediaInfo? result = await VideoCompress.compressVideo(
        pickedMovie.path,
        deleteOrigin: false,
        quality: VideoQuality.MediumQuality,
      );

      if (result != null && result.path != null) {
        _reqUpload(item, result.path!);
      } else {
        _showProgress(false);
      }

      //_reqUpload(item, pickedMovie.path);
    }
  }

  Future <void> _fromGalleryVideo(_MenuItem item) async {
    var pickedMovie = await pickupVideo();
    if (pickedMovie != null) {
      _showProgress(true);

      showToastMessage("동영상 파일을 최적화 하는 중입니다.\n최대 용량은 최적화 후 99MB 입니다.\n파일 용량에 따라 몇분이 소요됩니다.",isLengthLong: true);
      MediaInfo? result = await VideoCompress.compressVideo(
        pickedMovie.path,
        deleteOrigin: false,
        quality: VideoQuality.MediumQuality,
      );

      if (result != null && result.path != null) {
        _reqUpload(item, result.path!);
      } else {
        _showProgress(false);
      }
    }
  }

  void _updatePhotoInfo() {
    _menuItems[0].url = _photoInfo.sMainPicture;
    _menuItems[1].url = _photoInfo.sSubPic1;
    _menuItems[2].url = _photoInfo.sSubPic2;
    _menuItems[3].url = _photoInfo.sSubPic3;
    _menuItems[4].url = _photoInfo.sSubPic4;
    _menuItems[5].url = _photoInfo.sVideo;

    _bNotEmpty = _menuItems[0].url.isNotEmpty |
        _menuItems[1].url.isNotEmpty |
        _menuItems[2].url.isNotEmpty |
        _menuItems[3].url.isNotEmpty |
        _menuItems[4].url.isNotEmpty |
        _menuItems[5].url.isNotEmpty;
  }

  void _askDelete(_MenuItem item) {
    showYesNoDialogBox(
        context: context,
        height: 240,
        title: "확인",
        message: "삭제된 데이터는 복구되지 않습니다.\n사진을 삭제하시겠습니까?",
        onResult: (bool isYes) {
          if (isYes) {
            _reqDelete(item);
          }
        });
  }

  Future<void> _reqGetFiles() async {
    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/showGoodsFiles",
        params: {"lGoodsId": widget.lGoodsId.toString()},
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            setState(() {
              _photoInfo = GoodsFiles.fromJson(response['data'][0]);
              _updatePhotoInfo();
            });
          }
        },
        onError: (String error) {});
  }

  Future<void> _reqUpload(_MenuItem item, String filePath) async {

    /*
    if (item.url.isNotEmpty) {
      await DefaultCacheManager().removeFile(item.url);
      if (kDebugMode) {
        print('Url removed:${item.url}');
      }

      String fileName = getNameFromPath(item.url);
      await DefaultCacheManager().removeFile(fileName);
      if (kDebugMode) {
        print('File removed:$fileName');
      }

      setState(() {
        item.url = "";
      });
      // Future.microtask(() async {
      // });
    }
    */

    int fileSize = await File(filePath).length();
    if(fileSize<1024) {
      showToastMessage("사용할 수 없는 파일입니다.");
      _showProgress(false);
    }

    double fileSizeMB = fileSize.toDouble()/1024/1024;
    if(fileSizeMB>99) {
      showToastMessage("최대 용량을 초과하였습니다.");
      _showProgress(false);
    }

    _showProgress(true);
    await Remote.upLoad(
        context: context,
        session: _session,
        method: "taka/uploadGoodsFile",
        filePath: filePath,
        params: {"lGoodsId": widget.lGoodsId.toString(), "type": item.type},
        onError: (String error) {
          if (kDebugMode) {
            print(error);
          }
          showToastMessage(error);
        },
        onResult: (dynamic params) {
          if (kDebugMode) {
            print(params);
          }
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            _bDirty = true;
            showToastMessage("사진/동영상을 업로드 하였습니다.");
            _reqGetFiles();
          } else {
            showToastMessage(response['message']);
          }
        },
    );
    _showProgress(false);
  }

  Future<void> _reqDelete(_MenuItem item) async {
    if (item.url.isNotEmpty) {
      await DefaultCacheManager().removeFile(item.url);

      if (kDebugMode) {
        print('File removed:${item.url}');
      }

      setState(() {
        item.url = "";
      });
    }

    await Remote.apiPost(
        context: context,
        session: _session,
        lStoreId: _session.getAccessStore(),
        method: "taka/deleteGoodsFile",
        params: {"lGoodsId": widget.lGoodsId.toString(), "type": item.type},
        onResult: (dynamic params) {
          Map<String, dynamic> response = params;
          if (response['status'] == "success") {
            _bDirty = true;
            showToastMessage("사진이 삭제되었습니다.");
            _reqGetFiles();
          }
        },
        onError: (String error) {});
  }

  Future<void> _doPasteFiles() async {
    Navigator.push(
      context,
      Transition(
          child: CopyGoodsMultimedia(
            lGoodsID: widget.lGoodsId,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }
}
