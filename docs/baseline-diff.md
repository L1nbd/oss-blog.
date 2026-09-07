# 上游基线与本人版本差异清单

## 基本信息

- **上游项目**：TryGhost/Ghost
- **上游参考仓库**：https://github.com/L1nbd/Ghost
- **上游版本**：Ghost 5.130.6
- **本人版本**：oss-blog v1.0-lab
- **基线建立时间**：2026-09-06
- **差异对比时间**：2026-09-07

---

## 1. 核心代码差异

### 1.1 未修改的核心代码

| 模块 | 路径 | 状态 | 说明 |
|---|---|---|---|
| Ghost 核心 | `runtime/current/core/` | ✅ 未修改 | 遵循"不修改核心"原则 |
| Ghost 版本 | `runtime/versions/5.130.6/` | ✅ 未修改 | 完整上游版本 |
| 管理端 | `runtime/current/core/frontend/` | ✅ 未修改 | Ember.js 管理端 |
| 内容服务 | `runtime/current/core/server/` | ✅ 未修改 | 业务逻辑层 |
| 数据库迁移 | `runtime/current/core/server/data/migrations/` | ✅ 未修改 | knex-migrator 迁移脚本 |

### 1.2 手动修复的依赖问题（非核心修改）

| 问题 | 文件 | 修改内容 | 原因 |
|---|---|---|---|
| express-hbs 路径问题 | `node_modules/express-hbs/lib/hbs.js` | `cacheLayout` 函数改用 `path.resolve()` 比较路径 | Windows 上相对路径与绝对路径比较失败 |
| lodash.template bug | `node_modules/lodash.template/` | 升级 4.18.0 → 4.18.1 | 4.18.0 有构建 bug（`assignWith`/`arrayEach` 未定义） |
| sqlite3 预编译二进制 | `node_modules/sqlite3/build/Release/node_sqlite3.node` | 从 GitHub releases 手动下载预编译二进制 | 系统无 Visual Studio，无法源码编译 |

> **注意**：以上修改均在 `node_modules/` 中，属于依赖修复，不影响 Ghost 核心代码。重新安装依赖后需要重新应用这些修复。

---

## 2. 配置差异

| 配置项 | 上游默认值 | 本人配置 | 说明 |
|---|---|---|---|
| 数据库 | sqlite3（默认） | sqlite3 | 保持默认 |
| 端口 | 2368（默认） | 2368 | 保持默认 |
| 邮件传输 | Direct | SMTP（127.0.0.1:2525） | 本地假 SMTP 服务器接收邮件 |
| 员工设备验证 | true（默认） | false | 禁用登录验证码，方便本地开发 |
| 更新检查 | true | false | 禁用更新检查，避免网络请求 |
| RPC Ping | true | false | 禁用 RPC Ping |

---

## 3. 主题差异

### 3.1 基础主题

- **上游主题**：Casper 5.9.0（Ghost 默认主题）
- **本人主题**：oss-blog-theme v1.0.0（基于 Casper 二次开发）

### 3.2 主题修改清单

| 文件 | 修改类型 | 修改内容 |
|---|---|---|
| `package.json` | 修改 | 主题名称、版本、作者信息更新 |
| `default.hbs` | 修改 | 自定义导航栏（关于、归档）、自定义页脚、阅读进度条 HTML/JS |
| `post-card.hbs` | 修改 | 自定义文章卡片样式、阅读更多链接、中文日期格式、作者信息 |
| `post.hbs` | 修改 | 文章详情页元数据优化、显示所有标签、引入相关文章推荐 |
| `error-404.hbs` | 修改 | 自定义 404 页面（中文提示、推荐阅读、搜索入口） |
| `assets/css/custom.css` | 新增 | 自定义样式（导航、卡片、页脚、相关推荐、进度条、响应式） |
| `partials/related-posts.hbs` | 新增 | 相关文章推荐 partial（基于标签匹配） |

### 3.3 主题新增功能

| 功能 | 实现方式 | 说明 |
|---|---|---|
| 相关文章推荐 | `{{#get}}` helper + 标签过滤 | 文章详情页底部显示 3 篇相关文章 |
| 阅读进度条 | JavaScript + CSS | 文章详情页顶部实时显示阅读进度 |
| 自定义导航 | Handlebars 模板 | 添加"关于"、"归档"导航项 |
| 中文日期格式 | Handlebars helper | 日期显示为"YYYY年MM月DD日" |

---

## 4. 数据差异

### 4.1 演示数据

| 数据类型 | 上游默认 | 本人版本 | 说明 |
|---|---|---|---|
| 文章 | 1 篇（Hello World） | 8 篇 | 覆盖技术、生活、数据库等主题 |
| 标签 | 0 个 | 3 个 | 技术、生活、数据库 |
| 会员 | 0 个 | 2 个 | 张三、李四 |
| 管理员 | 1 个（初始化创建） | 1 个 | admin@example.com |
| 评论 | 0 条 | 0 条 | 待补充 |

### 4.2 文章边界情况覆盖

| 边界情况 | 是否覆盖 | 说明 |
|---|---|---|
| 长标题 | ✅ | "开源软件二次开发实践：基于 Ghost 构建个人博客系统" |
| 无封面图 | ✅ | 所有演示文章均无封面图 |
| 代码块 | ✅ | "SQLite 数据库深入理解与应用场景分析"包含代码示例 |
| 中文搜索词 | ✅ | "数据库"、"Node.js"等中文关键词 |
| 空评论 | ✅ | 所有文章评论数为 0 |
| 多标签文章 | ⚠️ | 当前每篇文章仅关联 1 个标签 |

---

## 5. 文档差异

| 文档 | 上游是否包含 | 本人新增 | 说明 |
|---|---|---|---|
| `README.md` | ❌ | ✅ | 项目完整说明 |
| `NOTICE.md` | ❌ | ✅ | 许可证归因 |
| `docs/baseline.md` | ❌ | ✅ | 基线记录 |
| `docs/architecture.md` | ❌ | ✅ | 架构说明 |
| `docs/acceptance-criteria.md` | ❌ | ✅ | 6 条验收场景 |
| `docs/baseline-features.md` | ❌ | ✅ | 上游基线功能清单 |
| `docs/baseline-diff.md` | ❌ | ✅ | 本差异清单 |
| `docs/ISSUES.md` | ❌ | ✅ | 自主扩展功能 Issue |
| `docs/PR.md` | ❌ | ✅ | Pull Request 记录 |
| `docs/CODE_REVIEW.md` | ❌ | ✅ | Code Review 记录 |
| `tests/test-report.md` | ❌ | ✅ | 18 项测试报告 |
| `tests/gscan-output.txt` | ❌ | ✅ | gscan 主题校验输出 |
| `tests/gulp-build-output.txt` | ❌ | ✅ | gulp 构建输出 |

---

## 6. 脚本与工具差异

| 脚本 | 类型 | 说明 |
|---|---|---|
| `start.ps1` | 新增 | 一键启动 Ghost |
| `stop.ps1` | 新增 | 一键停止 Ghost |
| `backup.ps1` | 新增 | 数据库备份脚本 |
| `runtime/current/fake-smtp-server.js` | 新增 | 本地假 SMTP 服务器 |
| `runtime/current/export-content.js` | 新增 | 内容导出脚本（脱敏） |
| `runtime/current/reset-password.js` | 新增 | 管理员密码重置脚本 |
| `runtime/current/create-demo-data.js` | 新增 | 演示数据创建脚本 |
| `runtime/current/create-members.js` | 新增 | 会员创建脚本 |
| `runtime/current/activate-theme.js` | 新增 | 主题激活脚本 |
| `runtime/current/check-settings.js` | 新增 | 设置检查脚本 |
| `runtime/current/clear-login-lock.js` | 新增 | 登录锁定清除脚本 |

---

## 7. Git 历史差异

| Commit | 类型 | 说明 |
|---|---|---|
| `034c978` | chore | 初始化项目骨架和 .gitignore |
| `264767a` | docs | 添加基线记录和架构文档 |
| `651eef0` | feat | 开发自定义主题 oss-blog-theme v1.0.0 |
| `da92c22` | feat | 实现自主扩展功能并添加 Issue 文档 |
| `9f76131` | test | 添加测试报告，18 项测试全部通过 |
| `5c4056c` | docs | 添加 README 项目说明文档 |
| `ece6ef6` | docs | 添加 PR 和 Code Review 文档 |

---

## 8. 交付物差异

| 交付物 | 上游默认 | 本人版本 | 说明 |
|---|---|---|---|
| 主题源码 | Casper | oss-blog-theme | 自定义主题 |
| 主题压缩包 | ❌ | ✅ `dist/oss-blog-theme.zip` | 可安装主题包 |
| 内容导出 | ❌ | ✅ `dist/ghost-export-*.json` | 脱敏内容导出 |
| 数据库备份 | ❌ | ✅ `backups/ghost-*.db` | 数据库备份 |
| 启动脚本 | ❌ | ✅ `start.ps1` / `stop.ps1` | 一键启停 |
| 备份脚本 | ❌ | ✅ `backup.ps1` | 数据备份 |

---

## 9. 总结

### 9.1 遵循的原则

1. ✅ **不修改 Ghost 核心代码** - 所有二次开发均在主题和配置层面
2. ✅ **保持上游版本可辨识** - 明确标注基于 Ghost 5.130.6
3. ✅ **许可证合规** - MIT 许可证，NOTICE.md 完整归因
4. ✅ **数据脱敏** - 导出内容移除敏感信息
5. ✅ **可复现交付** - 完整 README、启动脚本、备份恢复说明

### 9.2 本人贡献占比

| 类别 | 上游提供 | 本人开发 | 本人贡献占比 |
|---|---|---|---|
| 核心功能 | 100% | 0% | 0% |
| 主题 | 基础 Casper | 自定义修改 + 新增功能 | ~30% |
| 文档 | 0% | 100% | 100% |
| 脚本工具 | 0% | 100% | 100% |
| 演示数据 | 0% | 100% | 100% |
| 配置优化 | 默认值 | 邮件/安全/隐私配置 | ~50% |

### 9.3 未修改的上游能力

- 认证与授权系统
- 文章编辑器与发布流程
- 会员订阅与支付（Stripe）
- 邮件通讯（Newsletter）
- 内容 API 与 Admin API
- 数据库迁移机制
- 主题引擎（Handlebars）
- 搜索索引
- 评论系统

---

**差异清单完成**，本人所有二次开发均可在源码中定位，与上游基线边界清晰。
