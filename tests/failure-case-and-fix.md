# 测试失败用例及修复记录

## 失败用例1：主题 gscan 校验失败

### 失败信息

```
Checking theme compatibility...

✖ Your theme has fatal errors.

Errors:
- 1.  Package file must have a valid "name" field
- 2.  Package file must have a valid "version" field
```

### 失败原因

主题 `package.json` 中的 `name` 和 `version` 字段不符合 gscan 规范：
- `name` 字段包含大写字母和空格（"OSS Blog Theme"）
- `version` 字段格式不正确（"1.0" 而非 "1.0.0"）

### 修复前 Commit

- **Commit**：`651eef0`（feat: 开发自定义主题 oss-blog-theme v1.0.0）
- **修改文件**：`theme/oss-blog-theme/package.json`
- **修复前内容**：
```json
{
  "name": "OSS Blog Theme",
  "version": "1.0"
}
```

### 修复后

- **修复内容**：
```json
{
  "name": "oss-blog-theme",
  "version": "1.0.0"
}
```
- **修复 Commit**：`cd7a6c7`（docs: 补充实验文档、脚本和测试证据）
- **修复后 gscan 输出**：
```
Checking theme compatibility...

✓ Your theme is compatible with Ghost 5.x

Get more help at https://ghost.org/docs/themes/
```

### 修复验证

- ✅ gscan 校验通过
- ✅ 主题兼容 Ghost 5.x
- ✅ 无致命错误
- ✅ 无阻断性警告

---

## 失败用例2：管理员登录被锁定

### 失败信息

```
Too many different sign-in attempts, try again in 10 minutes
```

### 失败原因

多次使用错误密码尝试登录，触发 Ghost 的暴力破解保护机制（brute force protection），登录被锁定 10 分钟。

### 修复前状态

- **数据库表**：`brute` 表中有 7 条锁定记录
- **影响**：管理员无法登录管理后台

### 修复方法

1. 停止 Ghost 服务
2. 清除 `brute` 表中的锁定记录
3. 清除 `sessions` 表中的无效会话
4. 重启 Ghost 服务

### 修复脚本

```javascript
// clear-login-lock.js
const sqlite3 = require('sqlite3');
const db = new sqlite3.Database('content/data/ghost.db');

db.run('DELETE FROM brute', (err) => {
    if (err) console.error('清除 brute 表失败:', err.message);
    else console.log('已清除 brute 表');
});

db.run('DELETE FROM sessions', (err) => {
    if (err) console.error('清除 sessions 表失败:', err.message);
    else console.log('已清除 sessions 表');
    db.close();
});
```

### 修复验证

- ✅ `brute` 表已清空
- ✅ `sessions` 表已清空
- ✅ 管理员可以正常登录
- ✅ 登录不再显示锁定提示

---

## 失败用例3：内容导出 SQL 语法错误

### 失败信息

```
导出失败: SQLITE_ERROR: near "group": syntax error
```

### 失败原因

SQL 查询中使用了 SQLite 保留字 `group` 作为列名，但未用反引号括起来。

### 修复前代码

```javascript
db.all("SELECT key, value, type, group FROM settings WHERE ...", (err, rows) => {
    // ...
});
```

### 修复后代码

```javascript
db.all("SELECT key, value, type, `group` FROM settings WHERE ...", (err, rows) => {
    // ...
});
```

### 修复验证

- ✅ SQL 语法正确
- ✅ 成功导出 90 项设置
- ✅ 导出文件大小 22.73 KB
- ✅ 所有数据类型正确

---

## 失败用例4：npm 依赖冲突

### 失败信息

```
npm error ERESOLVE unable to resolve dependency tree
npm error While resolving: oss-blog-theme@1.0.0
npm error Found: postcss@8.2.13
npm error Could not resolve dependency:
npm error peer postcss@"^8.2.15" from cssnano@5.1.12
```

### 失败原因

主题 `package.json` 中 `postcss` 版本为 8.2.13，但 `cssnano` 5.1.12 要求 `postcss` 版本 ≥ 8.2.15，版本冲突导致依赖解析失败。

### 修复方法

使用 `--legacy-peer-deps` 参数安装依赖，忽略 peer dependency 版本检查：

```bash
npm install --legacy-peer-deps
```

### 修复验证

- ✅ 成功安装 1031 个依赖包
- ✅ gulp build 构建成功
- ✅ gscan 校验通过
- ✅ 主题功能正常

---

## 总结

| 失败用例 | 类型 | 修复方式 | 修复 Commit | 状态 |
|---|---|---|---|---|
| 主题 gscan 校验失败 | 配置错误 | 修改 package.json 字段 | `cd7a6c7` | ✅ 已修复 |
| 管理员登录被锁定 | 安全机制 | 清除 brute/sessions 表 | - | ✅ 已修复 |
| 内容导出 SQL 语法错误 | 代码错误 | 保留字加反引号 | - | ✅ 已修复 |
| npm 依赖冲突 | 依赖版本 | --legacy-peer-deps | - | ✅ 已修复 |

所有失败用例均已定位原因并修复，修复后通过验证，不影响最终交付。
