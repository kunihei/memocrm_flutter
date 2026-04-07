// 共通のベースAPIのレスポンスの型
// statusとmessageListは必須
class ApiResponse<T> {
  final int status;
  final List<String> messageList;
  // 実データ、APIごとに型が変わるためジェネリクスで柔軟に対応
  final T? data;

  const ApiResponse({
    required this.status,
    required this.messageList,
    this.data,
  });

  // 成功かどうかを判定するプロパティ
  // 一部APIで100が成功コードして返すため、100/200を成功扱いにする
  bool get isSuccess => status == 200 || status ==  100;
  // メッセージを改行で結合して取得するプロパティ
  String? get message => messageList.isEmpty ? null : messageList.join('\n');

  /// messageListの共通パースロジック、配列でない場合はから配列を返す
  /// 条件に合致した配列はその中でも文字列のみを抽出してList型で返す
  static List<String> parseMessage(dynamic rawMessage) {
    // 配列がList型をチェック、その要素の中身の型まではチェックしない
    if (rawMessage is List) {
      return rawMessage.whereType<String>().toList();
    }
    // 配列がMap型をチェック、その要素の中身の型まではチェックしない
    if (rawMessage is Map) {
      return rawMessage.values.whereType<String>().toList();
    }
    // 配列でない場合、空の配列を返す
    return [];
  }
}
