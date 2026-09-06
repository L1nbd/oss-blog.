# 实验基线记录

## 环境信息

| 项目 | 版本/值 |
|---|---|
| 操作系统 | Windows 11 |
| Node.js | v22.23.2 |
| npm | 10.9.8 |
| Ghost CLI | 1.32.3 |
| Git | 2.55.0.windows.3 |

## Ghost 基线

| 项目 | 值 |
|---|---|
| Ghost 版本 | 5.130.6 |
| 数据库 | SQLite3 (better-sqlite3 11.7.0 驱动) |
| 运行目录 | `runtime/` |
| 内容目录 | `runtime/content/` |
| 数据库文件 | `runtime/content/data/ghost.db` |
| 监听地址 | 127.0.0.1:2368 |
| 站点 URL | http://localhost:2368/ |
| 安装日期 | 2026-09-06 |

## 上游仓库

| 项目 | 值 |
|---|---|
| 上游项目 | TryGhost/Ghost |
| 上游许可证 | MIT |
| 个人 Fork | L1nbd/Ghost (作为 upstream 参考) |
| 固定版本 | 5.130.6 |

## 管理员账号

| 项目 | 值 |
|---|---|
| 姓名 | Admin |
| 邮箱 | admin@example.com |
| 角色 | Owner (管理员) |

## 安装过程中修复的问题

1. **Ghost CLI 版本误报** — CLI 检测到不存在的 6.62.0，手动下载 5.130.6
2. **Ghost 6.x 兼容性** — 6.x 的 knex-migrator 与 better-sqlite3 冲突，降级到 5.130.6
3. **sqlite3 编译问题** — 系统无 Visual Studio，手动下载预编译二进制
4. **lodash.template 构建 bug** — 4.18.0 缺少函数定义，升级到 4.18.1
5. **express-hbs 路径比较** — Windows 相对/绝对路径不匹配，修复为 path.resolve 规范化比较

## 启动/停止命令

```bash
# 启动 Ghost
cd runtime
$env:NODE_ENV="development"
node current/index.js

# 停止 Ghost
# Ctrl+C 或停止 node 进程
```
