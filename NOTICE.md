# NOTICE - 开源许可证归因

本项目基于多个开源项目进行二次开发，以下列出所有使用的开源资源及其许可证信息。

---

## 1. 主项目：Ghost

- **项目名称**：Ghost
- **仓库地址**：https://github.com/TryGhost/Ghost
- **上游参考仓库**：https://github.com/L1nbd/Ghost （TryGhost/Ghost 的 fork）
- **使用版本**：5.130.6
- **许可证**：MIT License
- **使用范围**：作为博客系统基线运行，未修改核心代码
- **许可证文本**：

```
MIT License

Copyright (c) 2013-2024 Ghost Foundation

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 2. 主题：Casper（自定义主题基础）

- **项目名称**：Casper
- **仓库地址**：https://github.com/TryGhost/Casper
- **原始版本**：5.9.0
- **自定义版本**：oss-blog-theme v1.0.0
- **许可证**：MIT License
- **使用范围**：作为自定义主题的基础，修改了导航、文章卡片、详情页、404页面等
- **修改内容**：
  - default.hbs：自定义导航栏、页脚、阅读进度条
  - post-card.hbs：自定义文章卡片样式、阅读更多链接
  - post.hbs：文章详情页元数据优化、相关文章推荐
  - error-404.hbs：自定义404页面
  - custom.css：自定义样式
  - related-posts.hbs：新增相关文章推荐 partial
  - package.json：主题名称、版本、作者信息更新

---

## 3. 第三方依赖

### 3.1 运行时依赖（Ghost 核心）

Ghost 5.130.6 包含以下主要运行时依赖（完整列表见 Ghost 仓库 package.json）：

| 依赖 | 版本 | 许可证 | 用途 |
|---|---|---|---|
| express | 4.x | MIT | Web 框架 |
| knex | 2.x | MIT | SQL 查询构建器 |
| sqlite3 | 5.1.7 | BSD-3-Clause | SQLite 数据库驱动 |
| bcryptjs | 2.x | MIT | 密码哈希 |
| jsonwebtoken | 9.x | MIT | JWT 认证 |
| lodash | 4.x | MIT | 工具函数 |
| moment | 2.x | MIT | 日期处理 |
| validator | 13.x | MIT | 数据验证 |

### 3.2 主题开发依赖

自定义主题 oss-blog-theme 包含以下开发依赖：

| 依赖 | 版本 | 许可证 | 用途 |
|---|---|---|---|
| gulp | 4.0.2 | MIT | 构建工具 |
| gscan | 4.48.0 | MIT | 主题兼容性检查 |
| postcss | 8.2.13 | MIT | CSS 处理 |
| autoprefixer | 10.4.7 | MIT | CSS 前缀自动添加 |
| cssnano | 5.1.12 | MIT | CSS 压缩 |
| gulp-uglify | 3.0.2 | MIT | JS 压缩 |
| gulp-concat | 2.6.1 | MIT | 文件合并 |
| gulp-zip | 5.1.0 | MIT | 主题打包 |

### 3.3 前端库（主题内置）

| 库 | 版本 | 许可证 | 用途 |
|---|---|---|---|
| jQuery | 3.5.1 | MIT | DOM 操作、AJAX |
| PhotoSwipe | 4.x | MIT | 图片查看器 |
| imagesLoaded | 4.x | MIT | 图片加载检测 |
| FitVids | 1.x | WTFPL | 响应式视频 |
| Infinite Scroll | 3.x | GPL-3.0 | 无限滚动 |

---

## 4. 字体与图标

- **字体**：使用系统默认字体栈（-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, sans-serif），无外部字体依赖
- **图标**：使用 Ghost 主题内置 SVG 图标（partials/icons/），来自 Casper 主题

---

## 5. 图片资源

- **主题截图**：assets/screenshot-desktop.jpg、assets/screenshot-mobile.jpg（来自 Casper 主题，MIT 许可证）
- **默认图片**：assets/images/（来自 Casper 主题，MIT 许可证）
- **文章封面图**：演示文章未使用封面图，无外部图片依赖

---

## 6. 本人原创内容

以下内容为本项目作者（OSS Blog Developer）原创，采用 MIT 许可证：

- 自定义主题修改部分（default.hbs、post-card.hbs、post.hbs、error-404.hbs 的修改）
- 新增文件（related-posts.hbs、custom.css）
- 项目文档（README.md、docs/、tests/）
- 演示数据（8篇文章、3标签、2会员）
- 启动/停止脚本
- 配置文件修改

---

## 7. 许可证选择

本项目整体采用 **MIT License**，与上游 Ghost 项目保持兼容。

---

## 8. 致谢

感谢以下开源项目和社区：
- [Ghost Foundation](https://ghost.org/) - 提供优秀的开源博客平台
- [Casper 主题](https://github.com/TryGhost/Casper) - 提供主题基础
- [Node.js 社区](https://nodejs.org/) - 提供运行时环境
- 所有开源贡献者

---

**最后更新**：2026-09-07
**维护者**：OSS Blog Developer
