// ignore_for_file: must_be_immutable

import 'package:distribution/constant/constant.dart';
import 'package:flutter/material.dart';

class SearchForm extends StatefulWidget {
  Function(String value)? onChange;
  final Function(String value) onSummit;
  final Function(TextEditingController controller) onCreated;
  final String? hintText;
  final String? valueText;
  final Color? background;
  final String? title;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final bool? readOnly;
  final bool? suffixAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  SearchForm({
    Key? key,
    required this.onSummit,
    this.onChange,
    required this.onCreated,
    this.hintText = "",
    this.valueText = "",
    this.suffixAction,
    this.title = "",
    this.background = Colors.white,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction = TextInputAction.search,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,

  }) : super(key: key);

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  TextEditingController tController = TextEditingController();

  @override
  void initState() {
    tController.text = widget.valueText!;
    widget.onCreated(tController);
    super.initState();
  }

  @override
  void dispose() {
    tController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
          controller: tController,
          readOnly: widget.readOnly!,
          obscureText: widget.obscureText!,
          maxLines: 1,
          cursorColor: Colors.black,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: (widget.readOnly!) ? const Color(0xFFFEFEFE) : Colors.white,
            contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            isDense: true,
            hintText: widget.hintText,
            hintStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xffc0c0c0),
                fontWeight: FontWeight.normal),

            prefixIcon:(widget.prefixIcon != null)
                ? IconButton(
                onPressed: () {
                  tController.text = "";
                },
                icon: widget.prefixIcon!)
                : null,
            suffixIcon:(widget.suffixIcon != null)
                ? IconButton(
                    onPressed: () => widget.onSummit(tController.text),
                    icon: widget.suffixIcon!)
                : null,
            //suffixIconColor: Colors.black,
            disabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              borderSide: BorderSide(width: 1, color: ColorG6),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              borderSide: BorderSide(width: 1, color: Colors.pinkAccent),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              borderSide: BorderSide(width: 1, color: Colors.black),
            ),
          ),
          onChanged: (String value) {
            if(widget.onChange != null) {
              widget.onChange!(value);
            }
            //print("onChanged()=>$value");
          },
          onSubmitted: (String value) {
            //print("onSubmitted()=>$value");
            widget.onSummit(value);
          }
      ),
    );
  }
}
