import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:primordial_spirit/config/app_config.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/services/fortune_api_service.dart';
import 'package:video_player/video_player.dart';

class MotionPreviewOverlay extends StatefulWidget {
  final String imageUrl;
  final String? visitorId;
  final String? cachedVideoUrl;
  final void Function(String videoUrl)? onVideoUrlReady;

  const MotionPreviewOverlay({
    super.key,
    required this.imageUrl,
    this.visitorId,
    this.cachedVideoUrl,
    this.onVideoUrlReady,
  });

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    String? visitorId,
    String? cachedVideoUrl,
    void Function(String videoUrl)? onVideoUrlReady,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'motion_preview',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: MotionPreviewOverlay(
            imageUrl: imageUrl,
            visitorId: visitorId,
            cachedVideoUrl: cachedVideoUrl,
            onVideoUrlReady: onVideoUrlReady,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<MotionPreviewOverlay> createState() => _MotionPreviewOverlayState();
}

class _MotionPreviewOverlayState extends State<MotionPreviewOverlay> {
  final FortuneApiService _api = FortuneApiService();
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;
  bool _videoReady = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final cached = widget.cachedVideoUrl;
    if (cached != null && cached.isNotEmpty) {
      await _initVideo(cached);
      return;
    }

    await _requestAndPoll();
  }

  Future<void> _requestAndPoll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final createResp = await _api.createMotionVideoTask(
        firstFrameImage: widget.imageUrl,
        visitorId: widget.visitorId,
      );

      if (!createResp.success) {
        throw Exception(createResp.error ?? '提交任务失败');
      }

      if (createResp.videoUrl != null && createResp.videoUrl!.isNotEmpty) {
        await _initVideo(createResp.videoUrl!);
        return;
      }

      final taskId = createResp.taskId;
      if (taskId == null || taskId.isEmpty) {
        throw Exception('任务ID为空');
      }

      await _pollStatus(taskId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '视频生成失败: $e';
      });
    }
  }

  Future<void> _pollStatus(String taskId) async {
    final completer = Completer<void>();
    final startTime = DateTime.now();

    Future<void> tick() async {
      if (!mounted) return;

      if (DateTime.now().difference(startTime) > const Duration(seconds: 90)) {
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException('等待视频生成超时'));
        }
        return;
      }

      final statusResp = await _api.getMotionVideoStatus(taskId: taskId);
      if (!statusResp.success) {
        if (!completer.isCompleted) {
          completer.completeError(Exception(statusResp.error ?? '查询失败'));
        }
        return;
      }

      final status = statusResp.status?.toLowerCase() ?? 'unknown';
      if (status == 'success' && statusResp.videoUrl != null && statusResp.videoUrl!.isNotEmpty) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        await _initVideo(statusResp.videoUrl!);
        return;
      }

      if (status == 'failed') {
        if (!completer.isCompleted) {
          completer.completeError(Exception(statusResp.error ?? '生成失败'));
        }
      }
    }

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      tick();
    });

    try {
      await tick();
      await completer.future;
    } finally {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  Future<void> _initVideo(String videoUrl) async {
    _pollTimer?.cancel();

    // 使用后端代理URL
    final proxyUrl = '${AppConfig.baseUrl}/api/v1/video/proxy?url=${Uri.encodeComponent(videoUrl)}';
    widget.onVideoUrlReady?.call(videoUrl);

    debugPrint('[MotionPreview] 使用代理URL播放视频');
    debugPrint('[MotionPreview] 原始URL: $videoUrl');
    debugPrint('[MotionPreview] 代理URL: $proxyUrl');

    setState(() {
      _isLoading = true;
      _error = null;
      _videoReady = false;
    });

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(proxyUrl));
      await controller.initialize();
      debugPrint('[MotionPreview] 视频初始化成功');

      await controller.setLooping(true);
      await controller.setVolume(0.0);
      await controller.play();
      debugPrint('[MotionPreview] 视频开始播放');

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isLoading = false;
        _videoReady = true;
        _error = null;
      });
    } catch (e) {
      debugPrint('[MotionPreview] 视频加载/播放失败: $e');
      if (!mounted) return;
      setState(() {
        _controller = null;
        _isLoading = false;
        _error = '视频加载失败: ${e.toString().replaceAll("Exception: ", "")}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          width: 340,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.voidBackground.withValues(alpha: 0.75),
                AppTheme.voidBackground.withValues(alpha: 0.55),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.fluorescentCyan.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '轻动作预览',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildPoster(widget.imageUrl),
                      AnimatedOpacity(
                        opacity: _videoReady && controller != null ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 160),
                        child: controller != null && controller.value.isInitialized
                            ? FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: controller.value.size.width,
                                  height: controller.value.size.height,
                                  child: VideoPlayer(controller),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      if (_isLoading)
                        Container(
                          color: Colors.black.withValues(alpha: 0.25),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.black.withValues(alpha: 0.45),
                          child: Center(
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final c = _controller;
                              if (c == null || !c.value.isInitialized) return;
                              if (c.value.isPlaying) {
                                await c.pause();
                              } else {
                                await c.play();
                              }
                              if (mounted) {
                                setState(() {});
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.fluorescentCyan.withValues(alpha: 0.9),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        controller != null && controller.value.isInitialized && controller.value.isPlaying
                            ? '暂停'
                            : '播放',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: _isLoading ? null : _requestAndPoll,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoster(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
      } catch (_) {
        return _fallbackPoster();
      }
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, _) => Container(
          color: Colors.black.withValues(alpha: 0.15),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, _, __) => _fallbackPoster(),
      );
    }

    return _fallbackPoster();
  }

  Widget _fallbackPoster() {
    return Container(
      color: Colors.black.withValues(alpha: 0.2),
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white54),
      ),
    );
  }
}

