# Diary Notes（日记备忘录）

一个基于 **HarmonyOS NEXT + ArkTS** 的轻量任务备忘录示例项目，当前版本以“登录 + 日历选日 + 任务管理 + 优先级分级”为核心功能。

## 当前已实现功能

### 1) 登录页（`LoginPage.ets`）
- 账号/密码输入校验（不能为空）
- 密码明文/密文切换
- 模拟登录流程（延时后进入主页）
- “华为账号一键登录”演示入口

### 2) 主页面（`MainPage.ets`）
- 月历展示（可切换上/下月）
- 选中日期后查看该日任务
- 右下角 `+` 按钮新增任务
- 任务支持 **完成/撤销、编辑等级、删除**
- 顶部展示各等级未完成任务数量
- 按等级排序展示任务（S → A → B → C）

### 3) 任务等级与模型（`TaskModel.ets`）
- 定义任务等级：`S / A / B / C`
- 提供等级描述与颜色映射
- 提供任务排序权重
- 提供自动分级函数 `autoGrade(insertionIndex)`
  - 第1个任务：S
  - 第2个任务：A
  - 第3个任务：B
  - 第4个及以后：C

## 页面入口与路由

- 应用入口能力：`entry/src/main/ets/entryability/EntryAbility.ets`
- 首屏加载：`pages/LoginPage`
- 当前已在 `main_pages.json` 注册页面：
  - `pages/LoginPage`
  - `pages/MainPage`

> 说明：`HistoricalTaskPage.ets`、`SelectDayPage.ets` 目前为空文件，暂未接入页面流转。

## 目录结构（核心）

```text
Diary_Notes_V0.1.04/
├── AppScope/
├── entry/
│   ├── src/main/ets/
│   │   ├── entryability/EntryAbility.ets
│   │   ├── model/TaskModel.ets
│   │   └── pages/
│   │       ├── LoginPage.ets
│   │       └── MainPage.ets
│   └── src/main/resources/base/profile/main_pages.json
├── build-profile.json5
├── hvigorfile.ts
└── oh-package.json5
```

## 运行方式

1. 使用 DevEco Studio 打开 `Diary_Notes_V0.1.04` 工程目录。  
2. 配置 HarmonyOS NEXT 对应 SDK。  
3. 连接设备或启动模拟器后运行。

## 后续可扩展方向

- 接入真实账号体系（替换模拟登录）
- 增加任务持久化（数据库或首选项）
- 完善历史任务页/日期选择页
- 增加任务筛选、搜索、提醒等能力
