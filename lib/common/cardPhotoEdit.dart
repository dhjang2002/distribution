// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:distribution/constant/constant.dart';
import 'package:distribution/utils/mediaView.dart';
import 'package:flutter/material.dart';

class CardPhotoEdit extends StatefulWidget {
  final String photoUrl;
  final bool isEdit;
  String? type;
  String? title;
  void Function(String type)? onCamera;
  void Function(String type)? onGallery;
  void Function()? onDelete;
  void Function(String type, String photoUrl)? onTap;
  BoxFit? fit;
  CardPhotoEdit({
    Key? key,
    required this.photoUrl,
    required this.isEdit,
    this.title = "",
    this.type = "",
    this.fit = BoxFit.fitWidth,
    this.onCamera,
    this.onGallery,
    this.onTap,
  }) : super(key: key);

  @override
  State<CardPhotoEdit> createState() => _CardPhotoEditState();
}

class _CardPhotoEditState extends State<CardPhotoEdit> {
  @override
  Widget build(BuildContext context) {
    bool isVideo = (widget.type == "v") ? true : false;
    bool isUrl = (widget.photoUrl.startsWith("http"));

    return GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!(widget.type!, widget.photoUrl);
          }
        },
        child: Container(
          //height: 300,
          color: Colors.black,
          child: Stack(
            children: [
              Positioned(
                child: Visibility(
                    visible: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: widget.title!.isNotEmpty,
                            child: Text(widget.title!, style: ItemBkN16,)),
                        Container(
                            child: (widget.photoUrl.isEmpty)
                                ? Container(color: const Color(0xFFFAFAFA))
                                : (isVideo)
                                    ? MediaView(
                                        isMovie: true,
                                        sourceUrl: widget.photoUrl)
                                    : (isUrl)
                                        ? CachedNetworkImage(
                                            fit: widget.fit,
                                            imageUrl: widget.photoUrl,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: widget.fit),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child: SizedBox(
                                                        width: 14,
                                                        height: 14,
                                                        child:
                                                            CircularProgressIndicator())),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                        color: const Color(
                                                            0xFFFAFAFA)),
                                          )
                                        : Image.file(File(widget.photoUrl),
                                            fit: widget.fit)),
                      ],
                    )),
              ),
              Positioned(
                  bottom: 10,
                  right: 10,
                  child: Visibility(
                      visible: widget.isEdit,
                      child: Container(
                        //width: 200,
                        //height: 50,
                        color: Color(0x0a000000),
                        child: Row(
                          children: [
                            Visibility(
                              visible: true,
                              child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 26,
                                  ),
                                  onPressed: () {
                                    if (widget.onDelete != null) {
                                      widget.onDelete!();
                                    }
                                  }),
                            ),
                            SizedBox(width: 20),
                            Visibility(
                              visible: true,
                              child: IconButton(
                                  icon: const Icon(
                                    Icons.camera,
                                    color: Colors.amber,
                                    size: 26,
                                  ),
                                  onPressed: () {
                                    if (widget.onCamera != null) {
                                      widget.onCamera!(widget.type!);
                                    }
                                  }),
                            ),
                            Visibility(
                              visible: true,
                              child: IconButton(
                                  icon: const Icon(
                                    Icons.photo,
                                    color: Colors.amber,
                                    size: 26,
                                  ),
                                  onPressed: () {
                                    if (widget.onGallery != null) {
                                      widget.onGallery!(widget.type!);
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ))),
            ],
          ),
        ));
  }
}
