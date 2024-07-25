class ApiResponse {
  final int statusCode;
  final String msg;
  final Map<String, String?> data;

  ApiResponse(
      {required this.statusCode, required this.msg, required this.data});
}
