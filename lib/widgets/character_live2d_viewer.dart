import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

/// Live2D角色查看器组件
class CharacterLive2DViewer extends StatefulWidget {
  final String modelPath;
  final double size;
  
  const CharacterLive2DViewer({
    super.key,
    this.modelPath = 'c_9999.model3.json',
    this.size = 250.0,
  });

  @override
  State<CharacterLive2DViewer> createState() => _CharacterLive2DViewerState();
}

class _CharacterLive2DViewerState extends State<CharacterLive2DViewer> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Live2D page started loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            debugPrint('Live2D page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
            // 页面加载完成后传递模型路径
            _updateModelPath();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Live2D WebView error: ${error.description}');
            debugPrint('Error type: ${error.errorType}');
            debugPrint('Failed URL: ${error.url}');
          },
        ),
      );

    // 加载本地HTML文件
    _loadLocalHtml();
  }

  Future<void> _loadLocalHtml() async {
    try {
      // 先加载HTML文件
      const htmlPath = 'assets/live2d/index.html';
      
      debugPrint('Loading Live2D HTML from: $htmlPath');
      
      // Android和iOS需要不同的加载方式
      if (Platform.isAndroid || Platform.isIOS) {
        await _controller.loadFlutterAsset(htmlPath);
      } else {
        // Web或桌面平台
        await _controller.loadRequest(
          Uri.parse('file:///android_asset/flutter_assets/$htmlPath')
        );
      }
    } catch (e) {
      debugPrint('Failed to load Live2D HTML: $e');
    }
  }

  /// 更新模型路径
  Future<void> _updateModelPath() async {
    try {
      // 等待一下确保页面完全加载
      await Future.delayed(const Duration(seconds: 1));
      
      // 构建模型的相对路径（相对于HTML文件的位置）
      final modelPath = '../images/Live2d-model-B0E5B3ACE583-112/${widget.modelPath}';
      
      debugPrint('Updating Live2D model path to: $modelPath');
      
      await _controller.runJavaScript('''
        console.log('Dart: Attempting to update model path to: $modelPath');
        if (typeof window.updateModelPath === 'function') {
          window.updateModelPath('$modelPath');
          console.log('Dart: Model path update called');
        } else {
          console.error('Dart: window.updateModelPath is not available');
          console.log('Dart: Available functions:', Object.keys(window).filter(k => typeof window[k] === 'function'));
        }
      ''');
    } catch (e) {
      debugPrint('Failed to update model path: $e');
    }
  }

  /// 播放动作
  Future<void> playMotion(String motionName) async {
    try {
      await _controller.runJavaScript('window.playMotion("$motionName")');
    } catch (e) {
      debugPrint('Failed to play motion: $e');
    }
  }

  /// 设置表情
  Future<void> setExpression(String expressionName) async {
    try {
      await _controller.runJavaScript('window.setExpression("$expressionName")');
    } catch (e) {
      debugPrint('Failed to set expression: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
      ),
      child: ClipOval(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            
            // 加载指示器
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}