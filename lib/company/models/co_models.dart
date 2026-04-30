import 'package:memocrm/utils/api/api_response.dart';

// 目的:
// 会社一覧APIのレスポンスJSONを、Flutter側で扱いやすいDartの型に変換する。
//
// 概要:
// - CoData は、会社1件分のデータを表すモデル。
// - CoResponse は、API共通レスポンス形式の中にある会社一覧データを表すモデル。
// - APIの data は配列で返ってくるため、CoResponse の data は List<CoData> として扱う。

class CoData {
  final int coCd;
  final String coName;
  final String coAdress;
  final String coTantoName;
  final String coTel;

  CoData({
    required this.coCd,
    required this.coName,
    required this.coAdress,
    required this.coTantoName,
    required this.coTel,
  });

  // 会社1件分のJSONを CoData に変換する factory コンストラクタ。
  //
  // factory を使う理由:
  // - APIレスポンスの Map<String, dynamic> を受け取り、CoData の生成方法を1箇所にまとめるため。
  // - 呼び出し側が json['co_cd'] などのキー名を意識せず、CoData.fromJson(json) だけで変換できるようにするため。
  //
  // 処理内容:
  // - API側のスネークケースのキー名を、Dart側のキャメルケースのプロパティへ詰め替える。
  // - 例: co_cd -> coCd, co_name -> coName
  factory CoData.fromJson(Map<String, dynamic> json) {
    return CoData(
      // 会社コードを取得する。
      coCd: json['co_cd'],
      // 会社名を取得する。
      coName: json['co_name'],
      // 会社住所を取得する。
      coAdress: json['co_address'],
      // 会社担当者名を取得する。
      coTantoName: json['co_tanto_name'],
      // 会社担当者電話番号を取得する。
      coTel: json['co_tanto_tel'],
    );
  }
}

class CoResponse extends ApiResponse<List<CoData>> {
  const CoResponse({
    required super.status,
    required super.messageList,
    required super.data,
  });

  // 会社一覧APIのレスポンス全体を CoResponse に変換する factory コンストラクタ。
  //
  // factory を使う理由:
  // - APIレスポンス全体のJSONから、共通項目(status, messageList)と会社一覧(data)をまとめて生成するため。
  // - data が配列で返ってくるため、List<dynamic> から List<CoData> への変換処理をこのクラス内に閉じ込めるため。
  //
  // 処理内容:
  // - json['data'] から会社一覧の配列を取得する。
  // - json['message_list'] からメッセージ一覧を取得し、ApiResponse.parseMessage で共通形式に変換する。
  // - data 配列の各要素を CoData.fromJson に渡して、会社1件分ずつ CoData に変換する。
  // - 最後に toList() で Iterable<CoData> を List<CoData> に変換する。
  factory CoResponse.fromJson(
    Map<String, dynamic> json, {
    required int status,
  }) {
    // APIレスポンスの data は会社情報の配列。
    // data が存在しない可能性も考慮して、nullを許容する List<dynamic>? として取得する。
    final dataJson = json['data'] as List<dynamic>?;

    return CoResponse(
      // HTTPステータスなど、呼び出し元から渡されたステータスを設定する。
      status: status,
      // API共通の message_list を、ApiResponse 側の共通処理で変換する。
      messageList: ApiResponse.parseMessage(json['message_list']),
      // dataJson が null でなければ、配列の各要素を CoData に変換する。
      // item は dynamic 型なので、CoData.fromJson に渡す前に Map<String, dynamic> へキャストする。
      data: dataJson
          ?.map((item) => CoData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
