# 发布到私有 Git 仓库（GitHub）

## 第一步：在 GitHub 创建私有仓库

1. 登录 [GitHub](https://github.com/)
2. **New repository** → 名称如 `feishu-cursor-mcp`
3. 选择 **Private**
4. **不要**勾选 "Add a README"（本地已有）
5. 创建后记下仓库 URL，形如：`https://github.com/<你的用户名>/feishu-cursor-mcp.git`

## 第二步：首次推送（在本机 feishu-cursor-mcp 目录）

```bash
git init
git add .
git commit -m "feat: initial feishu-cursor-mcp kit"
```

在 GitHub / GitLab / Gitee 创建**私有仓库**，然后：

```bash
git remote add origin <your-private-repo-url>
git branch -M main
git push -u origin main
```

## 发布前检查

- [ ] `config/config.env.example` 仅含占位符，无真实 Secret
- [ ] `.gitignore` 包含 `config.env`、`*.local.env`
- [ ] 未误提交 `~/.feishu-mcp/config.env`
- [ ] README / docs 中私有仓库 URL 已替换为实际地址

## 从 QuantMind 拆分为独立仓库（可选）

若当前在 monorepo 内，可只发布子目录：

```bash
cd feishu-cursor-mcp
git init
# ... 同上
```

或使用 `git subtree split` 保留历史（高级，按需操作）。

## 版本更新

```bash
git add .
git commit -m "docs: update wiki workspace guide"
git tag v1.0.1
git push origin main --tags
```

通知团队成员：

```bash
cd ~/tools/feishu-cursor-mcp
git pull
# 对已链接项目重新 link-project
```

## 凭证管理

| 内容 | 存放位置 | 进 Git？ |
|------|----------|----------|
| 安装包代码 | 私有 Git | 是 |
| App Secret | `~/.feishu-mcp/config.env` | **否** |
| 团队 config 模板 | 密码管理器 / 内部 Wiki | **否** |

## 后续：在另一台电脑使用

```bash
git clone <private-repo-url> ~/tools/feishu-cursor-mcp
cd ~/tools/feishu-cursor-mcp
bash scripts/install.sh   # 或 install.ps1
# 粘贴管理员提供的 config 内容到 ~/.feishu-mcp/config.env
bash scripts/verify.sh
bash scripts/link-project.sh /path/to/other-project
```

详见 [INSTALL.md](INSTALL.md)、[LINK_PROJECT.md](LINK_PROJECT.md)。
