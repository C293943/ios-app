import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primordial_spirit/config/app_config.dart';
import 'package:primordial_spirit/config/app_routes.dart';
import 'package:primordial_spirit/config/app_theme.dart';
import 'package:primordial_spirit/models/fortune_models.dart';
import 'package:primordial_spirit/services/model_manager_service.dart';
import 'package:primordial_spirit/services/fortune_api_service.dart';
import 'package:primordial_spirit/services/task_manager_service.dart';
import 'package:primordial_spirit/widgets/common/mystic_background.dart';
import 'package:primordial_spirit/widgets/qi_convergence_animation.dart';

/// 3D形象生成页面（加载过渡页）
class AvatarGenerationScreen extends StatefulWidget {
  final Map<String, dynamic>? baziData;

  const AvatarGenerationScreen({super.key, this.baziData});

  @override
  State<AvatarGenerationScreen> createState() => _AvatarGenerationScreenState();
}

class _AvatarGenerationScreenState extends State<AvatarGenerationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _statusText = '正在分析八字...';
  String _detailText = '';
  double _progress = 0.0;
  bool _hasError = false;
  TaskManagerService? _taskManager;
  StreamSubscription<TaskManagerService>? _taskManagerSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _progress = _animation.value;
        });
      });

    _startGeneration();
  }

  @override
  void dispose() {
    _taskManagerSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startGeneration() async {
    _controller.forward();

    final modelManager = context.read<ModelManagerService>();
    final taskManager = _taskManager ??= context.read<TaskManagerService>();

    // 保存用户八字数据（兼容旧逻辑）
    if (widget.baziData != null) {
      await modelManager.saveUserBaziData(widget.baziData!);
    }

    // 构建出生信息
    if (widget.baziData == null) {
      if (!mounted) return;
      setState(() {
        _statusText = '缺少生辰信息';
        _hasError = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    final date = widget.baziData!['date'] as DateTime;
    final time = widget.baziData!['time'];
    final city = widget.baziData!['city'] as String? ?? '北京';
    final birthInfo = BirthInfo(
      year: date.year,
      month: date.month,
      day: date.day,
      hour: time.hour as int,
      minute: time.minute as int,
      gender: widget.baziData!['gender'] as String,
      city: city,
    );

    // 显示请求信息
    setState(() {
      _statusText = '正在分析八字...';
      _detailText = '出生: ${date.year}年${date.month}月${date.day}日 ${time.hour}:${time.minute}';
    });

    // 调用计算API
    final apiService = FortuneApiService();

    // 设置状态回调
    apiService.onStatusChanged = (status) {
      if (mounted) {
        setState(() => _detailText = status);
      }
    };

    setState(() => _detailText = '正在连接 ${AppConfig.baseUrl}...');

    final response = await apiService.calculate(birthInfo);

    if (!mounted) return;

    if (response.success && response.baziInfo != null) {
      setState(() {
        _statusText = '正在解析五行属性...';
        _detailText = '八字: ${response.baziInfo!.yearPillar} ${response.baziInfo!.monthPillar} ${response.baziInfo!.dayPillar} ${response.baziInfo!.hourPillar}';
      });
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      // 显示五行信息
      if (response.baziInfo!.fiveElements != null) {
        final elements = response.baziInfo!.fiveElements!;
        setState(() {
          _detailText = '五行: 木${elements['木'] ?? 0} 火${elements['火'] ?? 0} 土${elements['土'] ?? 0} 金${elements['金'] ?? 0} 水${elements['水'] ?? 0}';
        });
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
      }

      // 显示格局信息
      if (response.baziInfo!.patterns != null && response.baziInfo!.patterns!.isNotEmpty) {
        setState(() {
          _detailText = '格局: ${response.baziInfo!.patterns!.first.patternName}';
        });
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
      }

      // 保存完整命盘数据（ziwei_info 可能为空，创建一个默认的）
      final ziweiInfo = response.ziweiInfo ?? ZiweiInfo(mingGong: '');
      var fortuneData = FortuneData(
        birthInfo: birthInfo,
        baziInfo: response.baziInfo!,
        ziweiInfo: ziweiInfo,
        calculatedAt: DateTime.now(),
      );

      // 根据当前显示模式决定生成方式
      final currentMode = modelManager.displayMode;
      final is2DMode = currentMode == DisplayMode.mode2D || currentMode == DisplayMode.live2D;

      setState(() {
        _statusText = is2DMode ? '正在准备2D形象...' : '正在准备3D元神形象...';
        _detailText = response.ziweiInfo?.mingGong.isNotEmpty == true
            ? '命宫: ${response.ziweiInfo!.mingGong}'
            : '日主: ${response.baziInfo!.dayGan}';
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // 根据模式调用不同的生成API
      if (is2DMode) {
        // 2D模式：后台提交图片生成任务（不等待）
        // ✅ 关键：不使用await，立即继续执行，让用户马上进入主页
        _submit2DImageTaskInBackground(
          baziInfo: response.baziInfo!,
          gender: birthInfo.gender,
          visitorId: modelManager.visitorId ?? 'default',
          fortuneData: fortuneData,
          modelManager: modelManager,
        );
      } else {
        // 3D模式：调用3D生成API
        final avatar3dInfo = await _generate3dAvatar(
          baziInfo: response.baziInfo!,
          gender: birthInfo.gender,
        );

        // 更新命盘数据，添加3D信息
        if (avatar3dInfo != null) {
          fortuneData = fortuneData.copyWith(avatar3dInfo: avatar3dInfo);
        }
      }

      // 保存命盘数据
      await modelManager.saveFortuneData(fortuneData);

      if (!mounted) return;
      setState(() {
        _statusText = '生成完成!';
        // 检查是否有有效的形象数据（3D或2D）
        final hasAvatar = fortuneData.avatar3dInfo?.isReady == true ||
            fortuneData.avatar3dInfo?.thumbnailUrl != null;
        _detailText = hasAvatar ? '元神形象已就绪' : '';
      });
    } else {
      // API调用失败，显示错误信息
      setState(() {
        _statusText = '命盘计算失败';
        _detailText = response.message;
        _hasError = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      // 仍然继续到主页，但没有命盘数据
      setState(() {
        _statusText = '正在生成3D形象...';
        _detailText = '(离线模式)';
        _hasError = false;
      });
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _statusText = '生成完成!';
        _detailText = '';
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // 导航到主页（替换整个导航栈）
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  /// 后台提交2D图片生成任务（不阻塞UI）
  ///
  /// 使用默认的egg图片prompt,在后台生成
  /// 用户可以立即继续使用应用,不用等待
  /// 任务完成后会自动更新fortuneData
  void _submit2DImageTaskInBackground({
    required BaziInfo baziInfo,
    required String gender,
    required String visitorId,
    required FortuneData fortuneData,
    required ModelManagerService modelManager,
  }) {
    final taskManager = context.read<TaskManagerService>();

    // 构建默认的egg图片prompt
    final prompt = _buildImagePrompt(baziInfo, gender);

    debugPrint('[后台生图] 提交任务, prompt: $prompt');

    // ✅ 关键：不等待任务完成，立即继续执行
    // TaskManagerService会在后台处理，完成后通过notifyListeners通知
    taskManager.submitImageGenerationTask(
      prompt: prompt,
      visitorId: visitorId,
      metadata: {
        'bazi_info': baziInfo.toJson(),
        'gender': gender,
        'prompt': prompt,
      },
    ).then((task) {
      // ✅ 异步回调：任务完成后更新fortuneData
      if (task != null && task.isCompletedSuccessfully && task.resultUrl != null) {
        debugPrint('[后台生图] 任务完成,更新fortuneData: ${task.resultUrl}');

        final updatedFortuneData = fortuneData.copyWith(
          avatar3dInfo: Avatar3dInfo(
            taskId: task.taskId,
            status: 'SUCCEEDED',
            thumbnailUrl: task.resultUrl,
            glbUrl: task.resultUrl,
            prompt: prompt,
            createdAt: DateTime.now(),
            isRefined: true,
          ),
        );

        modelManager.saveFortuneData(updatedFortuneData).then((_) {
          debugPrint('[后台生图] fortuneData已更新');
        });
      }
    });

    // 显示提示信息
    if (mounted) {
      setState(() {
        _statusText = '生成任务已提交';
        _detailText = '形象正在后台绘制中...';
      });
    }

    debugPrint('[后台生图] 任务已提交,用户可继续使用应用');
  }

  /// 构建图片生成提示词
  String _buildImagePrompt(BaziInfo baziInfo, String gender) {
    // 基础提示词
    final basePrompt = 'Full body shot, frontal view, ethereal Xianxia immortal style';

    // 根据日主（天干）添加特征
    final dayMaster = baziInfo.dayGan;
    String characterFeature = '';
    switch (dayMaster) {
      case '甲':
      case '乙':
        characterFeature = 'wood element spirit, gentle and elegant, green and cyan robes';
        break;
      case '丙':
      case '丁':
        characterFeature = 'fire element spirit, passionate and bright, red and orange robes';
        break;
      case '戊':
      case '己':
        characterFeature = 'earth element spirit, stable and reliable, yellow and brown robes';
        break;
      case '庚':
      case '辛':
        characterFeature = 'metal element spirit, sharp and decisive, white and golden robes';
        break;
      case '壬':
      case '癸':
        characterFeature = 'water element spirit, wise and fluid, blue and black robes';
        break;
      default:
        characterFeature = 'mystical immortal spirit';
    }

    // 根据性别添加特征
    final genderFeature = gender == '男' ? 'male cultivator' : 'female cultivator';

    // 组合完整提示词
    return '$basePrompt, $genderFeature, $characterFeature, '
        'floating in clouds, celestial atmosphere, Chinese traditional painting style, '
        'highly detailed, digital art, 8k resolution';
  }

  /// 生成3D元神形象（通过后端API）
  /// 使用 SSE 流式获取进度，支持两阶段流程：预览 -> 精细化
  /// 预览完成后先展示预览模型，精细化完成后更新为精细化模型
  Future<Avatar3dInfo?> _generate3dAvatar({
    required BaziInfo baziInfo,
    required String gender,
  }) async {
    Avatar3dInfo? previewResult;  // 保存预览结果

    try {
      setState(() {
        _statusText = '正在凝聚元神...';
        _detailText = '根据八字生成专属形象';
      });

      final apiService = FortuneApiService();

      // 通过后端创建3D任务（自动执行两阶段流程）
      final createResponse = await apiService.createAvatar3dTask(
        dayMaster: baziInfo.dayGan,
        gender: gender,
        fiveElements: baziInfo.fiveElements,
        fiveElementsStrength: baziInfo.fiveElementsStrength,
        autoRefine: true,  // 自动执行精细化
        enablePbr: true,   // 生成PBR贴图
      );

      if (!createResponse.success || createResponse.taskId == null) {
        debugPrint('[3D生成] 创建任务失败: ${createResponse.error}');
        setState(() {
          _detailText = '3D生成服务暂时不可用';
        });
        return null;
      }

      final taskId = createResponse.taskId!;
      final prompt = createResponse.prompt ?? '';
      debugPrint('[3D生成] 任务已创建: $taskId');
      debugPrint('[3D生成] 提示词: $prompt');

      setState(() {
        _statusText = '元神正在凝聚...';
        _detailText = '预览阶段：连接中...';
      });

      // 使用 SSE 流式获取进度（更优雅）
      final taskStatus = await apiService.waitForAvatar3dCompletionSSE(
        taskId,
        onProgress: (status, totalProgress, stage) {
          if (mounted) {
            setState(() {
              _statusText = _getStatusTextForStage(status, stage);
              _detailText = '总进度: $totalProgress%';
              // 更新进度条（3D生成占后半段进度）
              _progress = 0.5 + (totalProgress / 100) * 0.5;
            });
          }
        },
        onStageChanged: (stage) {
          if (mounted) {
            setState(() {
              if (stage == 'preview') {
                _statusText = '正在生成3D网格...';
                _detailText = '预览阶段';
              } else if (stage == 'refine') {
                _statusText = '正在添加贴图...';
                _detailText = '精细化阶段（预览模型已就绪）';
              }
            });
          }
        },
        onPreviewComplete: (event) {
          // 预览完成，保存预览结果
          debugPrint('[3D生成] 预览完成! GLB: ${event.modelUrls?['glb']}');
          previewResult = Avatar3dInfo(
            taskId: taskId,
            status: 'PREVIEW_SUCCEEDED',
            glbUrl: event.modelUrls?['glb'],
            fbxUrl: event.modelUrls?['fbx'],
            objUrl: event.modelUrls?['obj'],
            usdzUrl: event.modelUrls?['usdz'],
            thumbnailUrl: event.thumbnailUrl,
            videoUrl: event.videoUrl,
            prompt: prompt,
            createdAt: DateTime.now(),
            isRefined: false,  // 预览模型，未精细化
          );

          if (mounted) {
            setState(() {
              _statusText = '预览模型已就绪';
              _detailText = '正在进行精细化处理...';
            });
          }
        },
      );

      if (taskStatus.isSucceeded) {
        debugPrint('[3D生成] 生成成功!');
        debugPrint('[3D生成] GLB URL: ${taskStatus.modelUrls?['glb']}');
        debugPrint('[3D生成] 缩略图: ${taskStatus.thumbnailUrl}');
        debugPrint('[3D生成] 是否精细化模型: ${taskStatus.isRefinedModel}');

        return Avatar3dInfo(
          taskId: taskId,
          status: taskStatus.status,
          glbUrl: taskStatus.modelUrls?['glb'],
          fbxUrl: taskStatus.modelUrls?['fbx'],
          objUrl: taskStatus.modelUrls?['obj'],
          usdzUrl: taskStatus.modelUrls?['usdz'],
          thumbnailUrl: taskStatus.thumbnailUrl,
          videoUrl: taskStatus.videoUrl,
          prompt: prompt,
          createdAt: DateTime.now(),
          isRefined: taskStatus.isRefinedModel,
        );
      } else {
        debugPrint('[3D生成] 生成失败: ${taskStatus.error}');

        // 如果精细化失败但有预览结果，返回预览结果
        if (previewResult != null) {
          debugPrint('[3D生成] 返回预览结果作为备用');
          setState(() {
            _detailText = '精细化失败，使用预览模型';
          });
          return previewResult;
        }

        setState(() {
          _detailText = taskStatus.error ?? '生成失败';
        });
        return Avatar3dInfo(
          taskId: taskId,
          status: taskStatus.status,
          prompt: prompt,
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('[3D生成] 异常: $e');

      // 异常时如果有预览结果，返回预览结果
      if (previewResult != null) {
        debugPrint('[3D生成] 异常，返回预览结果');
        setState(() {
          _detailText = '连接中断，使用预览模型';
        });
        return previewResult;
      }

      setState(() {
        _detailText = '3D生成出错: $e';
      });
      return null;
    }
  }

  String _getStatusTextForStage(String status, String stage) {
    final stageText = stage == 'refine' ? '精细化' : '预览';
    switch (status) {
      case 'PENDING':
        return '$stageText排队中...';
      case 'IN_PROGRESS':
        return stage == 'refine' ? '正在添加贴图...' : '正在生成3D网格...';
      case 'STAGE_CHANGE':
        return '预览完成，开始精细化...';
      case 'SUCCEEDED':
        return '生成完成!';
      case 'FAILED':
        return '$stageText失败';
      case 'CANCELED':
        return '已取消';
      default:
        return '处理中...';
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return '排队中...';
      case 'IN_PROGRESS':
        return '正在生成...';
      case 'PREVIEW_PENDING':
        return '预览排队中...';
      case 'REFINE_PENDING':
        return '精细化排队中...';
      case 'SUCCEEDED':
        return '生成完成!';
      case 'FAILED':
        return '生成失败';
      case 'CANCELED':
        return '已取消';
      default:
        return '处理中...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MysticBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),

                      // 状态文本
                      Text(
                        _statusText,
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _hasError ? Colors.red.shade400 : AppTheme.deepVoidBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // 详细信息
                      if (_detailText.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _hasError
                                ? Colors.red.withValues(alpha: 0.1)
                                : AppTheme.deepVoidBlue.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _detailText,
                            style: GoogleFonts.notoSerifSc(
                              fontSize: 12,
                              color: _hasError
                                  ? Colors.red.shade400
                                  : AppTheme.deepVoidBlue.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 20),

                      // 进度条
                      Container(
                        width: double.infinity,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.deepVoidBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.jadeGreen,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.jadeGreen.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 进度百分比
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 16,
                          color: AppTheme.deepVoidBlue.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 提示文本
                      Text(
                        '基于您的八字信息\n正在凝聚专属元神...',
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 14,
                          color: AppTheme.deepVoidBlue.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 五行汇聚动画层
          Positioned.fill(
            child: QiConvergenceAnimation(
              isTriggered: true,
              onComplete: () {
                // 动画完成后不做任何操作，让页面继续正常流程
              },
            ),
          ),
        ],
      ),
    );
  }
}