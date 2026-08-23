# 链接到任意 Cursor 项目

`link-project` 将 feishu-mcp 接入目标项目，**不**把凭证写入业务仓库。

## 命令

**Windows**

```powershell
cd ~/tools/feishu-cursor-mcp
powershell -File scripts/link-project.ps1 -ProjectPath E:\work\my-app
```

**macOS / Linux**

```bash
cd ~/tools/feishu-cursor-mcp
bash scripts/link-project.sh ~/work/my-app
```

## 脚本会做什么

| 操作 | 目标路径 |
|------|----------|
| 写入 MCP 配置 | `<project>/.cursor/mcp.json` |
| 安装 Cursor Rule | `<project>/.cursor/rules/feishu-docs.mdc` |
| 复制 Python 脚本 | `<project>/scripts/feishu/*.py` |
| 写入链接元数据 | `<project>/.feishu-mcp.json` |

MCP 启动器指向 kit 目录中的 `scripts/feishu-mcp-stdio.ps1`，并读取 `~/.feishu-mcp/config.env`。

## 多项目使用

同一台电脑只需：

1. **一次** `install` + 填写 `~/.feishu-mcp/config.env`
2. 每个 Cursor 项目执行一次 `link-project`

凭证在所有项目间共享；若不同开发者协作，各自填写自己的 `FEISHU_COLLABORATOR_OPEN_ID`。

## 更新 kit 版本

```bash
cd ~/tools/feishu-cursor-mcp
git pull
# 对每个已链接项目重新 link（刷新脚本与 rule）
powershell -File scripts/link-project.ps1 -ProjectPath E:\work\my-app
```

重启 Cursor。

## 取消链接

1. 从 `<project>/.cursor/mcp.json` 删除 `feishu-mcp` 条目
2. 可选删除 `<project>/.cursor/rules/feishu-docs.mdc`
3. 可选删除 `<project>/scripts/feishu/` 与 `.feishu-mcp.json`

`~/.feishu-mcp/config.env` 保留，不影响其他项目。

## 建议 .gitignore（业务项目）

```gitignore
.feishu-mcp.json
.env.feishu
```

（`.cursor/mcp.json` 若含本机绝对路径，团队可 gitignore 或各人生成）
