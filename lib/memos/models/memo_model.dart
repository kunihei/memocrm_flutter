import 'package:memocrm/utils/api/api_response.dart';

class MemoData {
  final int memoCd;
  // final String tantoName;
  final String memoTitle;
  final String memoContent;
  // final Map<String, String> tags;

  MemoData({
    required this.memoCd,
    // required this.tantoName,
    required this.memoTitle,
    required this.memoContent,
    // required this.tags,
  });

  factory MemoData.fromJson(Map<String, dynamic> json) {
    return MemoData(
      memoCd: json['memo_cd'] as int,
      // tantoName: json['tanto_name'] as String,
      memoTitle: json['title'] as String,
      memoContent: json['content'] as String,
      // tags: Map<String, String>.from(json['tags'] as Map),
    );
  }
}

class MemoResponse extends ApiResponse<List<MemoData>> {
  const MemoResponse({
    required super.status,
    required super.messageList,
    required super.data,
  });

  factory MemoResponse.fromJson(
    Map<String, dynamic> json, {
    required int status,
  }) {
    final dataList = json['data'] as List<dynamic>?;

    return MemoResponse(
      status: status,
      messageList: ApiResponse.parseMessage(json['message_list']),
      data: dataList
          ?.map((item) => MemoData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
