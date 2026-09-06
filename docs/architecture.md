# 项目架构说明

## 总体架构

```
访客/会员浏览器
      │
      ▼
┌─────────────────────────────────────────┐
│           自定义 Ghost 主题              │
│  (content/themes/oss-blog-theme/)       │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│         Ghost 前端服务 (core/frontend)   │
│  路由解析 / 模板渲染 / Content API 调用   │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│         Ghost 内容服务 (core/server)     │
│  文章/标签/会员/评论/搜索 业务逻辑        │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│            SQLite 数据库                 │
│  (content/data/ghost.db)                │
│  文章/标签/会员/评论/设置                │
└─────────────────────────────────────────┘

管理员浏览器
      │
      ▼
┌─────────────────────────────────────────┐
│        Ghost Admin 管理端                │
│  (/ghost/) - 文章编辑/会员管理/设置      │
└─────────────────────────────────────────┘
```

## 请求流程

**前台文章访问流程：**
1. 浏览器请求 `http://localhost:2368/` 或文章 URL
2. Ghost 前端服务（core/frontend）解析路由
3. 调用内容服务（core/server）获取文章数据
4. 内容服务查询 SQLite 数据库
5. 数据返回前端服务，使用主题模板渲染
6. 返回 HTML 给浏览器

**管理端操作流程：**
1. 管理员访问 `/ghost/`
2. Admin 客户端（Ember.js 应用）加载
3. 通过 Admin API 与后端交互
4. 后端内容服务处理业务逻辑
5. 数据持久化到 SQLite 数据库

## 关键目录说明

| 目录 | 路径 | 说明 | 是否可修改 |
|---|---|---|---|
| 项目根目录 | `oss-blog/` | 实验项目根目录 | ✅ 可修改 |
| 文档目录 | `docs/` | 实验文档（基线、架构等） | ✅ 可修改 |
| 主题目录 | `theme/` | 自定义主题源码 | ✅ 可修改 |
| 测试目录 | `tests/` | 测试用例和测试记录 | ✅ 可修改 |
| Ghost 运行目录 | `runtime/` | Ghost 运行时目录 | ⚠️ 部分可修改 |
| Ghost 内容目录 | `runtime/content/` | 用户内容（主题/数据/图片） | ⚠️ 部分可修改 |
| 主题安装目录 | `runtime/content/themes/` | 已安装的主题 | ✅ 可修改（自定义主题） |
| 数据库目录 | `runtime/content/data/` | SQLite 数据库文件 | ❌ 禁止提交到 Git |
| 日志目录 | `runtime/content/logs/` | 运行日志 | ❌ 禁止提交到 Git |
| Ghost 核心代码 | `runtime/current/core/` | Ghost 核心源码 | ❌ 禁止修改 |
| Ghost 版本目录 | `runtime/versions/` | Ghost 各版本源码 | ❌ 禁止修改 |
| Ghost 配置文件 | `runtime/config.development.json` | 开发环境配置 | ⚠️ 可修改（不提交密钥） |

## 允许修改 vs 禁止修改

### ✅ 允许修改的目录
- `docs/` — 实验文档
- `theme/` — 自定义主题源码
- `tests/` — 测试用例
- `runtime/content/themes/oss-blog-theme/` — 自定义主题安装目录
- 项目根目录的配置文件（.gitignore、README.md 等）

### ❌ 禁止修改的目录
- `runtime/current/core/` — Ghost 核心代码（通过主题和 Content API 扩展）
- `runtime/versions/` — Ghost 版本源码
- `runtime/content/data/` — 数据库文件（通过导出/恢复备份）
- `runtime/content/logs/` — 日志文件
- `runtime/content/images/` — 用户上传图片

## 二次开发边界

本实验遵循"不修改 Ghost 核心"的原则，二次开发通过以下边界进行：

1. **主题层**：在 `theme/oss-blog-theme/` 中开发自定义主题，修改模板、样式和前端交互
2. **Content API 层**：通过 Ghost Content API 获取数据，在主题中进行展示和交互
3. **伴随服务层**：如有需要，可在独立目录中开发伴随服务，通过 API 与 Ghost 交互
4. **配置层**：通过 `config.development.json` 配置 Ghost 行为

这种边界设计的优势：
- 便于 Ghost 版本升级，核心代码不受影响
- 二次开发内容可辨识，便于代码审查
- 符合开源项目的最佳实践
