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
import 'package:primordial_spirit/widgets/common/themed_background.dart';
import 'package:primordial_spirit/widgets/qi_convergence_animation.dart';
import 'package:primordial_spirit/l10n/l10n.dart';

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
  String _statusText = '';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_statusText.isEmpty) {
      _statusText = context.l10n.avatarAnalyzingBazi;
    }
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
    _taskManager ??= context.read<TaskManagerService>();

    // 保存用户八字数据（兼容旧逻辑）
    if (widget.baziData != null) {
      await modelManager.saveUserBaziData(widget.baziData!);
    }

    // 构建出生信息
    if (widget.baziData == null) {
      if (!mounted) return;
      setState(() {
        _statusText = context.l10n.avatarMissingBirthInfo;
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
      _statusText = context.l10n.avatarAnalyzingBazi;
      _detailText = context.l10n.avatarBirthInfo(
        context.l10n.birthDateFormat(date.year, date.month, date.day),
        context.l10n.birthTimeFormat(
          time.hour.toString(),
          time.minute.toString().padLeft(2, '0'),
        ),
      );
    });

    // 调用计算API
    final apiService = FortuneApiService();

    // 设置状态回调
    apiService.onStatusChanged = (status) {
      if (mounted) {
        setState(() => _detailText = status);
      }
    };

    setState(() => _detailText = context.l10n.avatarConnecting(AppConfig.baseUrl));

    final response = await apiService.calculate(birthInfo);

    if (!mounted) return;

    if (response.success && response.baziInfo != null) {
      setState(() {
        _statusText = context.l10n.avatarParsingFiveElements;
        _detailText = context.l10n.avatarBaziSummary(
          response.baziInfo!.yearPillar,
          response.baziInfo!.monthPillar,
          response.baziInfo!.dayPillar,
          response.baziInfo!.hourPillar,
        );
      });
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      // 显示五行信息
      if (response.baziInfo!.fiveElements != null) {
        final elements = response.baziInfo!.fiveElements!;
        setState(() {
          _detailText = context.l10n.avatarElementsSummary(
            elements['木'] ?? 0,
            elements['火'] ?? 0,
            elements['土'] ?? 0,
            elements['金'] ?? 0,
            elements['水'] ?? 0,
          );
        });
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
      }

      // 显示格局信息
      if (response.baziInfo!.patterns != null && response.baziInfo!.patterns!.isNotEmpty) {
        setState(() {
          _detailText = context.l10n.avatarPatternSummary(
            response.baziInfo!.patterns!.first.patternName,
          );
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
        _statusText = is2DMode
            ? context.l10n.avatarPreparing2d
            : context.l10n.avatarPreparing3d;
        _detailText = response.ziweiInfo?.mingGong.isNotEmpty == true
            ? context.l10n.avatarMingGong(response.ziweiInfo!.mingGong)
            : context.l10n.avatarDayMaster(response.baziInfo!.dayGan);
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
        _statusText = context.l10n.avatarDone;
        // 检查是否有有效的形象数据（3D或2D）
        final hasAvatar = fortuneData.avatar3dInfo?.isReady == true ||
            fortuneData.avatar3dInfo?.thumbnailUrl != null;
        _detailText = hasAvatar ? context.l10n.avatarReady : '';
      });
    } else {
      // API调用失败，显示错误信息
      setState(() {
        _statusText = context.l10n.avatarCalculationFailed;
        _detailText = response.message;
        _hasError = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      // 仍然继续到主页，但没有命盘数据
      setState(() {
        _statusText = context.l10n.avatarGenerating3d;
        _detailText = context.l10n.offlineMode;
        _hasError = false;
      });
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _statusText = context.l10n.avatarDone;
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
        _statusText = context.l10n.avatarTaskSubmitted;
        _detailText = context.l10n.avatarTaskBackground;
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
        _statusText = context.l10n.avatarConverging;
        _detailText = context.l10n.avatarConvergingDetail;
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
          _detailText = context.l10n.avatarServiceUnavailable;
        });
        return null;
      }

      final taskId = createResponse.taskId!;
      final prompt = createResponse.prompt ?? '';
      debugPrint('[3D生成] 任务已创建: $taskId');
      debugPrint('[3D生成] 提示词: $prompt');

      setState(() {
        _statusText = context.l10n.avatarConvergingSpirit;
        _detailText = context.l10n.avatarPreviewConnecting;
      });

      // 使用 SSE 流式获取进度（更优雅）
      final taskStatus = await apiService.waitForAvatar3dCompletionSSE(
        taskId,
        onProgress: (status, totalProgress, stage) {
          if (mounted) {
            setState(() {
              _statusText = _getStatusTextForStage(status, stage);
              _detailText = context.l10n.avatarTotalProgress(totalProgress);
              // 更新进度条（3D生成占后半段进度）
              _progress = 0.5 + (totalProgress / 100) * 0.5;
            });
          }
        },
        onStageChanged: (stage) {
          if (mounted) {
            setState(() {
              if (stage == 'preview') {
                _statusText = context.l10n.avatarGeneratingMesh;
                _detailText = context.l10n.avatarPreviewStage;
              } else if (stage == 'refine') {
                _statusText = context.l10n.avatarApplyingTextures;
                _detailText = context.l10n.avatarRefineStage;
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
              _statusText = context.l10n.avatarPreviewReady;
              _detailText = context.l10n.avatarRefining;
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
            _detailText = context.l10n.avatarRefineFailedUsePreview;
          });
          return previewResult;
        }

        setState(() {
          _detailText = taskStatus.error ?? context.l10n.avatarFailed;
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
          _detailText = context.l10n.avatarConnectionInterrupted;
        });
        return previewResult;
      }

      setState(() {
        _detailText = context.l10n.avatar3dError(e.toString());
      });
      return null;
    }
  }

  String _getStatusTextForStage(String status, String stage) {
    final stageText = stage == 'refine'
        ? context.l10n.avatarStageRefine
        : context.l10n.avatarStagePreview;
    switch (status) {
      case 'PENDING':
        return context.l10n.avatarStagePending(stageText);
      case 'IN_PROGRESS':
        return stage == 'refine'
            ? context.l10n.avatarApplyingTextures
            : context.l10n.avatarGeneratingMesh;
      case 'STAGE_CHANGE':
        return context.l10n.avatarPreviewToRefine;
      case 'SUCCEEDED':
        return context.l10n.avatarDone;
      case 'FAILED':
        return context.l10n.avatarStageFailed(stageText);
      case 'CANCELED':
        return context.l10n.canceled;
      default:
        return context.l10n.processing;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return context.l10n.queueing;
      case 'IN_PROGRESS':
        return context.l10n.generating;
      case 'PREVIEW_PENDING':
        return context.l10n.previewQueueing;
      case 'REFINE_PENDING':
        return context.l10n.refineQueueing;
      case 'SUCCEEDED':
        return context.l10n.avatarDone;
      case 'FAILED':
        return context.l10n.avatarFailed;
      case 'CANCELED':
        return context.l10n.canceled;
      default:
        return context.l10n.processing;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ThemedBackground(
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
                          color: _hasError ? Colors.red.shade400 : AppTheme.warmYellow,
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
                                : AppTheme.spiritGlass.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _detailText,
                            style: GoogleFonts.notoSerifSc(
                              fontSize: 12,
                              color: _hasError
                                  ? Colors.red.shade400
                                  : AppTheme.inkText.withOpacity(0.72),
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
                          color: AppTheme.spiritGlass.withOpacity(0.35),
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
                          color: AppTheme.warmYellow.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 提示文本
                      Text(
                        context.l10n.avatarHint,
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 14,
                          color: AppTheme.inkText.withOpacity(0.78),
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
