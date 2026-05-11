# Noteworthy（词弦）

> 一个双模块轻学习工具，将碎片时间转化为主动学习——随机遇见单词，随机聆听和弦，每次打开都是 30 秒即可完成的一次微练习。

**Noteworthy** 是一个刻意的双关：**note** 既指值得记录的词汇条目，也指值得聆听的音符；后缀 **-worthy** 暗示每一次遇见——无论单词还是和弦——都值得你驻足。

---

## 截图

> 截图请放在 `docs/screenshots/` 目录下，按以下命名即可被 README 引用。

| 页面 | 文件名 | 说明 |
|------|--------|------|
| 主页 | `home.png` | 按时段问候 + 每日一词卡片 |
| 单词学习 | `word-card.png` | 随机单词卡片：释义、例句、词根、搭配 |
| 学习计划 | `plan-list.png` | 计划列表页，显示已创建/导入的计划 |
| 弹奏模式 | `free-play.png` | 钢琴键盘 + 标记/播放功能 |
| 和弦辨识 | `chord-practice.png` | 听和弦 → 从 12 种类型中选择 |
| 音程练习 | `interval.png` | 听参考音 → 辨第二个音 |
| 和弦进行 | `progression.png` | 听根音 → 和弦序列 → 揭晓答案 |
| 设置 | `settings.png` | 主题色、字体大小、全局快捷键 |

补充后将下面的 `<!--  -->` 注释替换为实际图片即可：

```markdown
![主页](docs/screenshots/home.png)
![单词学习](docs/screenshots/word-card.png)
...
```

---

## 设计理念

| 原则 | 说明 |
|------|------|
| **轻量** | 无课程体系，无进度压力。打开即用，用完即走。 |
| **随机** | 每次遇见的内容不可预测，用好奇心驱动持续使用。 |
| **碎片** | 30 秒即可完成一次练习，适配任何时间间隙。 |
| **主动** | 随机只是入口，辨认和思考才是核心——用户始终在主动参与。 |
| **统一** | 一词一弦，形式不同但交互节奏和学习底层逻辑一致。 |

两个模块看似一文一武（视觉 vs 听觉），共享同一套模式：

> **偶然输入 → 主动辨认**

---

## 模块详解

### 词（Word）—— 随机闪卡式词汇积累

每次打开随机展示一张单词卡片，从多个维度帮助理解和记忆。

**卡片内容：**
- **释义** — 中英双语释义
- **音标** — 国际音标注音
- **词性** — 名词/动词/形容词等标注
- **例句** — 真实语境中的中英对照例句
- **词根分析** — 词源拆解，展示每个组成部分的含义和来源
- **搭配** — 常见词组与固定搭配，以标签形式展示

**学习计划：**
- 创建自定义学习计划，组织自己的词表
- 支持导入/导出词表
- 激活计划后，随机展示限定在该计划范围内
- 未激活计划时默认从全词库随机抽取

**收藏：**
- 一键收藏单词（星标）
- 收藏持久化存储，跨会话保留

**每日一词：**
- 主页根据日期展示"每日一词"，每天固定不变
- 显示单词、音标、释义、例句、搭配

### 弦（Chord）—— MIDI 合成的和弦练耳

软件通过 MIDI 合成实时生成音频，无需预录音频文件。四个子模块覆盖不同训练目标：

**弹奏模式（Free Play）：**
- 完整钢琴键盘（C2–C6，49 键）
- 点击琴键即时发声
- **标记模式**：在键盘上标记多个音符，一键同时播放构成和弦
- 适合自由探索和声效果

**和弦辨识（Practice）：**
- 随机生成和弦，覆盖 **12 种和弦类型**：大三、小三、减三、增三、挂二、挂四、属七、大七、小七、减七、半减七、增大七
- 点击播放聆听和弦 → 从 12 个选项中选出正确类型
- 答后反馈：显示正确/错误、根音名称、和弦色彩描述
- 钢琴键盘高亮显示当前和弦的组成音

**音程练习（Interval）：**
- 聆听参考音 → 再听第二个音 → 判断两音之间的音程关系
- 训练对音程距离的听觉敏感度
- 钢琴键盘可视化两个音的位置

**和弦进行（Progression Reveal）：**
- 先听根音 → 再听完整和弦序列
- 自己推测进行的级数和色彩 → 点击揭晓答案
- 训练对和弦进行方向的感知

### 全局快捷键

Windows 平台支持录制全局快捷键（如 `Ctrl+Shift+N`），在任何应用前台都可一键呼出 Noteworthy 窗口，实现真正的"随手一练"。

---

## 个性化设置

| 设置项 | 说明 |
|--------|------|
| **主题颜色** | 8 种主题色可选，即时预览 |
| **字体大小** | 4 档可调（小/默认/中/大），适配不同屏幕和视力需求 |
| **全局快捷键** | 录制/清除全局快捷键，支持 Ctrl/Alt/Shift/Win 组合 |
| **暗色模式** | 跟随系统或手动切换亮暗主题 |

所有设置即时生效并持久化保存。

---

## 技术栈

| 层 | 技术选择 |
|----|----------|
| **框架** | Flutter（Dart），单代码库覆盖 Windows / Android / Web |
| **状态管理** | Provider — 轻量，不引入额外范式 |
| **MIDI 合成** | 纯 Dart 层构建 MIDI 消息；Windows 通过 win32 FFI 调用系统 MIDI 合成器；Android 通过 MethodChannel；Web 为静默桩 |
| **UI** | Material 3 卡片式设计；Playfair Display（标题）+ Noto Sans（正文） |
| **窗口** | Windows 自定义标题栏（隐藏原生标题栏，自绘窗口控制按钮） |
| **快捷键** | hotkey_manager 插件注册系统级热键 |
| **存储** | 本地 JSON 文件（词库、计划、收藏、设置） |

---

## 项目结构

```
lib/
├── main.dart                    # 入口，初始化所有服务与 Provider
├── app.dart                     # MaterialApp + 导航框架 + 侧边栏
├── core/
│   ├── constants.dart           # 版本号、MIDI 常量、音名表
│   ├── theme/
│   │   ├── app_theme.dart       # 主题构建（颜色、字体、字号）
│   │   └── theme_provider.dart  # 主题/字体/颜色状态
│   ├── services/
│   │   └── shortcut_service.dart # 全局快捷键服务
│   └── widgets/                 # 通用组件
│       ├── sidebar.dart         # 侧边导航栏
│       ├── entry_card.dart      # 入口卡片（Hub 页使用）
│       ├── noteful_card.dart    # 统一卡片容器
│       ├── action_button.dart   # 操作按钮
│       ├── play_button.dart     # 播放按钮
│       ├── feedback_area.dart   # 正确/错误反馈区
│       ├── back_header.dart     # 返回头部栏
│       ├── piano_keyboard.dart  # 钢琴键盘组件
│       └── window_controls.dart # Windows 自定义窗口按钮
├── modules/
│   ├── home/views/              # 主页视图
│   ├── word/
│   │   ├── models/              # WordEntry, StudyPlan, 例句/词根/搭配
│   │   ├── providers/           # WordProvider, PlanProvider, FavoritesProvider
│   │   ├── services/            # WordService, PlanStorage
│   │   └── views/               # 单词卡片、计划列表、计划详情
│   ├── chord/
│   │   ├── models/              # ChordDefinition, ChordInstance
│   │   ├── providers/           # ChordProvider, IntervalPracticeProvider, ProgressionRevealProvider
│   │   ├── services/            # ChordGenerator
│   │   └── views/               # 弹奏、辨识、音程、和弦进行
│   ├── midi/
│   │   ├── models/              # MidiMessage
│   │   ├── platform/            # Windows/Android/Noop MIDI 播放器实现
│   │   └── services/            # MidiScheduler, MidiPlayer 接口
│   └── settings/views/          # 设置页
└── assets/
    ├── data/words.json          # 内置词库
    └── icon/                    # 应用图标
```

---

## 开发指南

### 环境要求

- Flutter SDK ^3.11.5
- Android SDK（Android 构建）
- Visual Studio 2022 含桌面 C++（Windows 构建）
- Windows 开发者模式（Windows 原生插件编译需要）

### 运行

```bash
# 安装依赖
flutter pub get

# Web（两个模块均可交互，MIDI 无声音）
flutter run -d chrome

# Windows（完整 MIDI 合成支持）
flutter run -d windows

# Android（完整 MIDI 合成支持）
flutter run -d <android-device-id>
```

### 静态分析

```bash
flutter analyze
```

---

## 版本

当前版本：**v0.6.0**
