import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/video_info.dart';

class DownloaderService {
  static const _host =
      'all-social-media-video-downloader.p.rapidapi.com';

  Future<VideoInfo> getVideoInfo(String postUrl) async {
    final apiKey = dotenv.env['RAPIDAPI_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw ApiException('RAPIDAPI_KEY missing in .env', code: 0);
    }

    final uri = Uri.https(_host, '/v2/', {'url': postUrl.trim()});
    http.Response res;
    try {
      res = await http
          .get(uri, headers: {
            'X-RapidAPI-Key':  apiKey,
            'X-RapidAPI-Host': _host,
          })
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw ApiException('Network error: $e', code: -1);
    }

    switch (res.statusCode) {
      case 200:
        try {
          return VideoInfo.fromJson(
              jsonDecode(res.body) as Map<String, dynamic>);
        } catch (_) {
          throw ApiException('Could not parse API response.', code: -2);
        }
      case 400:
        throw ApiException('Invalid URL — use a direct post/reel link.', code: 400);
      case 401:
        throw ApiException('Invalid RapidAPI key. Check .env file.', code: 401);
      case 403:
        throw ApiException('Not subscribed to this API on RapidAPI.', code: 403);
      case 429:
        throw ApiException('Monthly limit reached. Upgrade RapidAPI plan.', code: 429);
      default:
        throw ApiException('API error (${res.statusCode})', code: res.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int code;
  const ApiException(this.message, {required this.code});
  @override
  String toString() => message;
}
