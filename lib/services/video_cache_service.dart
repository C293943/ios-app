// 视频缓存服务，用于下载并维护本地离线播放资源。
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoCacheService {
  static const String _videoCacheKey = 'video_cache_map';
  static const String _imageVideoCacheKey = 'image_video_cache_map';

  Future<String?> getLocalPathForUrl(String url) async {
    final cacheMap = await _loadCacheMap(_videoCacheKey);
    final localPath = cacheMap[url];
    if (localPath == null) return null;
    final file = File(localPath);
    return await file.exists() ? localPath : null;
  }

  Future<String?> getLocalPathForImage(String imageUrl) async {
    final cacheMap = await _loadCacheMap(_imageVideoCacheKey);
    final localPath = cacheMap[imageUrl];
    if (localPath == null) return null;
    final file = File(localPath);
    return await file.exists() ? localPath : null;
  }

  Future<String?> cacheVideoForImage({
    required String imageUrl,
    required String videoUrl,
  }) async {
    final localPath = await cacheVideoByUrl(videoUrl);
    if (localPath == null) return null;
    await _saveCacheValue(_imageVideoCacheKey, imageUrl, localPath);
    return localPath;
  }

  Future<String?> cacheVideoByUrl(String videoUrl) async {
    final cached = await getLocalPathForUrl(videoUrl);
    if (cached != null) return cached;

    final targetPath = await _buildTargetPath(videoUrl);
    if (targetPath == null) return null;

    try {
      final client = http.Client();
      try {
        final response = await client
            .get(Uri.parse(videoUrl))
            .timeout(const Duration(seconds: 30));

        if (response.statusCode != 200) {
          return null;
        }

        final file = File(targetPath);
        await file.writeAsBytes(response.bodyBytes, flush: true);

        await _saveCacheValue(_videoCacheKey, videoUrl, targetPath);
        return targetPath;
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('[VideoCache] 下载失败: $e');
      return null;
    }
  }

  Future<String?> _buildTargetPath(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/video_cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final fileName = 'video_${_stableHash(url)}.mp4';
      return '${cacheDir.path}/$fileName';
    } catch (e) {
      debugPrint('[VideoCache] 创建缓存目录失败: $e');
      return null;
    }
  }

  int _stableHash(String input) {
    const int fnvPrime = 16777619;
    int hash = 2166136261;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash;
  }

  Future<Map<String, String>> _loadCacheMap(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (e) {
      debugPrint('[VideoCache] 读取缓存失败: $e');
      return {};
    }
  }

  Future<void> _saveCacheValue(String key, String cacheKey, String value) async {
    final cacheMap = await _loadCacheMap(key);
    cacheMap[cacheKey] = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(cacheMap));
    } catch (e) {
      debugPrint('[VideoCache] 写入缓存失败: $e');
    }
  }
}
