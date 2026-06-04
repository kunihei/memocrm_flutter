import 'package:memocrm/utils/api/api_response.dart';
import 'package:memocrm/memos/models/tag_model.dart';

class MemoData {
  final int coCd;
  final int memoCd;
  final String tantoName;
  final String title;
  final String content;
  final String time;
  final List<TagData> tags;

  MemoData({
    required this.coCd,
    required this.memoCd,
    required this.tantoName,
    required this.title,
    required this.content,
    required this.time,
    required this.tags,
  });

  factory MemoData.fromJson(Map<String, dynamic> json) {
    return MemoData(
      coCd: json['co_cd'] as int,
      memoCd: json['memo_cd'] as int,
      tantoName: json['co_tanto_name'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      time: json['memo_time'] as String,
      tags: (json['tags'] as List<dynamic>)
          .map((tag) => TagData.fromJson(tag as Map<String, dynamic>))
          .toList(),
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
