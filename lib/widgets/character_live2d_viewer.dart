import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Live2D角色查看器组件
class CharacterLive2DViewer extends StatefulWidget {
  final String modelPath;
  final double size;
  final bool enableDebugLog;

  const CharacterLive2DViewer({
    super.key,
    this.modelPath = '9999.model3.json',
    this.size = 250.0,
    this.enableDebugLog = false,
  });

  @override
  State<CharacterLive2DViewer> createState() => _CharacterLive2DViewerState();
}

class _CharacterLive2DViewerState extends State<CharacterLive2DViewer> {
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
        child: InAppWebView(
          initialFile: "assets/live2d/index.html",
          initialSettings: InAppWebViewSettings(
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
            transparentBackground: true,
            javaScriptEnabled: true,
            cacheEnabled: false,
          ),
          onWebViewCreated: (controller) {
            controller.addJavaScriptHandler(
              handlerName: 'onModelLoaded',
              callback: (args) {
                if (widget.enableDebugLog) {
                  debugPrint("[Live2D] Model loaded: ${args[0]}");
                }
              },
            );
          },
          onConsoleMessage: (controller, consoleMessage) {
            if (widget.enableDebugLog) {
              debugPrint("[Live2D] ${consoleMessage.message}");
            }
          },
        ),
      ),
    );
  }
}