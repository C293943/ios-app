import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 图片工具类
class ImageUtils {
  /// 判断图片URL是否为Base64编码
  static bool isBase64Image(String? imageUrl) {
    return imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('data:image');
  }

  /// 从Base64 URL解码图片数据
  static Uint8List? decodeBase64Image(String base64Url) {
    try {
      final base64String = base64Url.split(',').last;
      final imageBytes = base64Decode(base64String);
      return imageBytes;
    } catch (e) {
      debugPrint('[ImageUtils] Base64解码失败: $e');
      return null;
    }
  }

  /// 构建图片Widget,自动判断是网络图片还是Base64图片
  static Widget buildImage(
    String? imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    bool useCachedNetworkImage = true,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return placeholder ?? const SizedBox.shrink();
    }

    // Base64编码的图片
    if (isBase64Image(imageUrl)) {
      final imageBytes = decodeBase64Image(imageUrl);
      if (imageBytes != null) {
        return Image.memory(
          imageBytes,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('[ImageUtils] Base64图片显示失败: $error');
            return errorWidget ?? const Icon(Icons.error);
          },
        );
      } else {
        return errorWidget ?? const Icon(Icons.error);
      }
    }

    // 网络图片
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      if (useCachedNetworkImage) {
        // 使用cached_network_image包
        try {
          final cachedNetworkImage = CachedNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: fit,
            placeholder: (context, url) =>
                placeholder ?? const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) {
              debugPrint('[ImageUtils] 网络图片加载失败: $error');
              return errorWidget ?? const Icon(Icons.error);
            },
          );
          return cachedNetworkImage;
        } catch (e) {
          // 如果cached_network_image不可用,回退到普通Image.network
          debugPrint('[ImageUtils] CachedNetworkImage不可用,使用Image.network: $e');
          return Image.network(
            imageUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('[ImageUtils] 网络图片加载失败: $error');
              return errorWidget ?? const Icon(Icons.error);
            },
          );
        }
      } else {
        return Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ??
                const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('[ImageUtils] 网络图片加载失败: $error');
            return errorWidget ?? const Icon(Icons.error);
          },
        );
      }
    }

    // 本地资源图片
    return Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
      debugPrint('[ImageUtils] 本地资源加载失败: $error');
      return errorWidget ?? const Icon(Icons.error);
    },
    );
  }

  /// 从API响应中获取图片URL
  /// 优先使用Base64图片(背景已移除),回退到原始URL
  static String? getImageUrlFromResponse(Map<String, dynamic> data) {
    // 检查是否有背景移除的图片
    if (data['background_removed'] == true && data['result_url'] != null) {
      return data['result_url'] as String?;
    }

    // 回退到普通URL
    return data['result_url'] as String? ?? data['result_url_original'] as String?;
  }

  /// 检查图片是否已移除背景
  static bool isBackgroundRemoved(Map<String, dynamic> data) {
    return data['background_removed'] == true;
  }
}
