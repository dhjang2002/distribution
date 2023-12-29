// ignore_for_file: file_names, non_constant_identifier_names

class ItemPhoto {
  String? content_image_oid;  // 서버에서 관리하는 고유 key (삭제, 변경시 사용됨)
  String? image_url;          // 원본 path   ex:"https://playvac/image/xxx00zz.jpg"
  //String? ThumbnailUrl;       // 썸네일 path  ex:"https://playvac/image/xxx00zz_thum.jpg"
  bool?   is_default;         // 대표 이미지 여부
  String? image_index;        // .
  ItemPhoto({
    this.content_image_oid = "",
    this.image_url = "",
    //this.ThumbnailUrl="",
    this.is_default=false,
    this.image_index="",
  });

  @override
  String toString(){
    return 'ItemPhoto {'
        'content_image_oid:$content_image_oid, '
        'is_default:$is_default, '
        'image_index:$image_index, '
        'image_url:$image_url'
        ' }';
  }

  static List<ItemPhoto> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ItemPhoto.fromJson(data);
    }).toList();
  }

  factory ItemPhoto.fromJson(Map<String, dynamic> jdata)
  {
    return ItemPhoto(
      content_image_oid: jdata['content_image_oid'],
      image_url: jdata['image_url'],
      is_default: (jdata['is_default']=='1')? true : false,
      image_index: jdata['image_index'],
    );
  }

  Map<String, dynamic> toMap() =>
  {
    'content_image_oid': content_image_oid,
    'image_url': image_url,
    'is_default': is_default,
    'image_index': image_index,
  };


}