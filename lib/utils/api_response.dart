class ApiResponse<T> {
  final int status;
  final List<String> messageList;
  final T? data;

  const ApiResponse({
    required this.status,
    required this.messageList,
    this.data,
  });

  bool get isSuccess => status == 200 || status ==  100;
  String? get message => messageList.isEmpty ? null : messageList.join('\n');
}
