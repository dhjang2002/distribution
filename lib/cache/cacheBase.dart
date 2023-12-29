// ignore_for_file: file_names
import 'package:flutter/material.dart';

abstract class CacheBase with ChangeNotifier {
  var  cache = [];
  bool isFirst = true;
  bool loading = false;
  bool hasMore = true;

  CacheBase();

  void clear() {
    if(cache.isNotEmpty) {
      cache.clear();
    }
  }

}