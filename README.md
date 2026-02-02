# 鸿初元灵 - 八字数字人情感陪伴APP

## 项目简介

这是一个基于Flutter开发的移动应用,通过用户的生辰八字生成专属3D数字人形象,提供情感陪伴(80%)和人生指引(20%)服务。

## 当前进度

### ✅ 已完成
1. **项目基础结构**
   - Flutter项目初始化
   - 依赖包配置
   - 目录结构创建

2. **核心页面开发**
   - 启动页 (SplashScreen)
   - 八字输入页 (BaziInputScreen)
   - 形象生成页 (AvatarGenerationScreen)
   - 主页 (HomeScreen)
   - 聊天页 (ChatScreen)

3. **基础配置**
   - 应用配置 (AppConfig)
   - 路由系统 (AppRoutes)

### 🔄 进行中
- 八字输入界面完善
- UI优化

### 📋 待完成
1. **3D数字人渲染模块**
   - 集成flutter_cube或其他3D渲染库
   - 根据八字生成3D形象
   - 形象动画效果

2. **AI对话系统**
   - 接入AI API (如ChatGPT/Claude)
   - 实现情感陪伴对话
   - 实现人生指引建议

3. **八字知识库**
   - 天干地支计算
   - 五行分析
   - 形象特征映射

4. **数据持久化**
   - 本地存储 (Hive)
   - 用户信息管理
   - 对话历史保存

5. **功能完善**
   - 每日运势
   - 个人信息页
   - 设置页面

## 项目结构

```
lib/
├── config/              # 配置文件
│   ├── app_config.dart  # 应用配置
│   └── app_routes.dart  # 路由配置
├── screens/             # 页面
│   ├── splash_screen.dart
│   ├── bazi_input_screen.dart
│   ├── avatar_generation_screen.dart
│   ├── home_screen.dart
│   └── chat_screen.dart
├── widgets/             # 通用组件
├── models/              # 数据模型
├── services/            # 服务层
├── providers/           # 状态管理
└── utils/               # 工具类

assets/
├── images/              # 图片资源
├── 3d_models/           # 3D模型
└── animations/          # 动画资源
```

## 技术栈

- **框架**: Flutter 3.32.5
- **语言**: Dart
- **状态管理**: Provider + GetX
- **3D渲染**: flutter_cube
- **网络请求**: Dio
- **本地存储**: Hive + SharedPreferences
- **UI组件**: Material Design 3

## 运行项目

### 安装依赖
```bash
flutter pub get
```

### 运行应用
```bash
# Android设备/模拟器
flutter run

# iOS设备/模拟器
flutter run -d ios

# Windows桌面
flutter run -d windows
```

### 构建APK
```bash
flutter build apk --release
```

## 核心功能说明

### 1. 八字计算
- 根据出生年月日时计算八字
- 分析五行属性
- 生成命理特征

### 2. 3D形象生成
- 基于八字五行属性
- 动态生成数字人外观
- 支持形象交互

### 3. AI对话
- 情感陪伴(80%)：倾听、理解、共鸣
- 人生指引(20%)：建议、方向、启发
- 结合用户八字特点提供个性化回复

## 下一步计划

1. **优先级1**: 完善UI和用户体验
2. **优先级2**: 实现3D形象基础渲染
3. **优先级3**: 接入AI对话API
4. **优先级4**: 完善八字计算逻辑
5. **优先级5**: 添加数据持久化

## 开发说明

- 开发环境: Windows 11
- 终端: PowerShell
- IDE: VS Code
- 测试设备: Android (MI 9)

## 注意事项

1. AI API需要配置密钥
2. 3D模型需要准备资源文件
3. 八字计算需要准确的算法实现
4. 注意用户隐私数据保护

## 联系方式

项目开发中,如有问题请反馈。