import 'package:memocrm/utils/api/api_response.dart';

class MemoData {
  final int memoCd;
  final String tantoName;
  final String memoTitle;
  final String memoContent;
  final Map<String, String> tags;

  MemoData({
    required this.memoCd,
    required this.tantoName,
    required this.memoTitle,
    required this.memoContent,
    required this.tags,
  });
}