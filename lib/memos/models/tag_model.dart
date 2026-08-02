class TagData {
  final int tagCd;
  final String tagName;

  TagData({required this.tagCd, required this.tagName});

  factory TagData.fromJson(Map<String, dynamic> json) {
    return TagData(
      tagCd: json['tag_cd'] as int,
      tagName: json['tag_name'] as String,
    );
  }
}
