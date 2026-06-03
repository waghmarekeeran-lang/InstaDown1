import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class FileDownloadService {
  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 10),
  ));
  CancelToken? _token;

  Future<String> downloadVideo({
    required String url,
    required String filename,
    required void Function(int received, int total) onProgress,
  }) async {
    _token = CancelToken();
    final dir  = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$filename';
    try {
      await _dio.download(
        url, path,
        cancelToken: _token,
        onReceiveProgress: onProgress,
        options: Options(headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36',
        }),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) throw Exception('Download cancelled');
      rethrow;
    }
    return path;
  }

  void cancel() => _token?.cancel();

  String buildFilename(String title, String platform, String ext) {
    final p = platform.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    final len = title.length.clamp(0, 28);
    final t = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, len);
    return '${p}_${t}_${DateTime.now().millisecondsSinceEpoch}.$ext';
  }
}
