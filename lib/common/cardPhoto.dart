// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CardPhoto extends StatelessWidget {
  String? photoUrl;
  BoxFit? fit;
  CardPhoto({
    Key? key,
    this.fit = BoxFit.cover,
    required this.photoUrl
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isUrl    = (photoUrl!.isNotEmpty && photoUrl!.startsWith("http"));
    bool isAssets = (photoUrl!.isNotEmpty && photoUrl!.startsWith("assets/"));
    return (isUrl)
        ? CachedNetworkImage(
            fit:BoxFit.fill,
            imageUrl: photoUrl!,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(
                    image: imageProvider, fit: fit),
              ),
            ),
            placeholder: (context, url) => const Center(
                child: SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator())),
            errorWidget: (context, url, error) => Container(color: const Color(0xFFFAFAFA)),
          )
        : (isAssets) ? (Image.asset(photoUrl!, fit: fit))
          : ((photoUrl!.isNotEmpty)
            ? Image.file(File(photoUrl!), fit: fit)
            : Container(color: const Color(0xFFFAFAFA))
    );
  }
}
