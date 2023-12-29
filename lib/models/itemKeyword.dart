// ignore_for_file: non_constant_identifier_names, file_names

class ItemKeyword {
  /*
  	<keyword>
		<keyword>감성적인</keyword>
		<selected>0</selected>
		<order_index>0</order_index>
		<interest_keyword_oid>1000</interest_keyword_oid>
	</keyword>
   */
  String? interest_keyword_oid;
  String? keyword;
  String? selected;
  String? order_index;


  ItemKeyword({
    this.keyword,
    this.selected,
    this.order_index,
    this.interest_keyword_oid
  });

  factory ItemKeyword.fromJson(Map<String, dynamic> parsedJson)
  {
    return ItemKeyword(
      interest_keyword_oid: parsedJson['interest_keyword_oid'],
      keyword: parsedJson['keyword'],
      selected: parsedJson['selected'],
      order_index: parsedJson['order_index'],
    );
  }

  static List<ItemKeyword> fromSnapshot(List snapshot) {
    // keyword_menu = keyword_list.map((i) => ItemKeyword.fromJson(i)).toList();
    return snapshot.map((data) {
      return ItemKeyword.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'KeywordItem {'
        'keyword:$keyword, '
        'selected:$selected, '
        'order_index:$order_index, '
        'interest_keyword_oid: $interest_keyword_oid}';
  }

}