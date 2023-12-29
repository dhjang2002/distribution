import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ItemPrice {
  String sName;
  String sPrice;
  bool isPrice;

  ItemPrice({
    this.sName = "",
    this.sPrice = "",
    this.isPrice = true,
  });
}