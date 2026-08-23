# feishu-cursor-mcp

在 Cursor 中通过 [Feishu-MCP](https://github.com/cso1z/Feishu-MCP) 操作飞书文档（创建、编辑、Wiki 目录树），支持 **tenant 应用身份** + **自动协作者授权**。

本仓库为**独立安装包**，在任意电脑上 clone 后链接到任意 Cursor 项目。

## 特点

- **配置统一**：凭证与 Wiki 默认值集中在 `~/.feishu-mcp/config.env`（每台机器一份）
- **项目解耦**：`link-project` 将 MCP 接入任意项目，无需复制凭证进业务仓库
- **Wiki 目录树**：支持飞书「我的文档库」父子文档结构
- **协作者脚本**：应用创建文档后自动给本人 `full_access`

## 快速开始

```powershell
# 1. clone 本仓库
git clone https://github.com/evan-ai-auto/feishu-cursor-mcp.git ~/tools/feishu-cursor-mcp
cd ~/tools/feishu-cursor-mcp

# 2. 初始化本机配置（仅首次）
powershell -ExecutionPolicy Bypass -File scripts/install.ps1
# macOS: bash scripts/install.sh

# 3. 编辑 ~/.feishu-mcp/config.env（见 docs/CONFIG.md）

# 4. 验证
powershell -File scripts/verify.ps1

# 5. 链接到你的 Cursor 项目
powershell -File scripts/link-project.ps1 -ProjectPath E:\path\to\your-project

# 6. 重启 Cursor → Settings → Tools & MCP → 确认 feishu-mcp 已连接
```

详细步骤：[docs/INSTALL.md](docs/INSTALL.md)  
链接其他项目：[docs/LINK_PROJECT.md](docs/LINK_PROJECT.md)  
团队分发：[docs/TEAM.md](docs/TEAM.md)

## 目录结构

```
feishu-cursor-mcp/
├── README.md
├── QUICKSTART.md
├── config/
│   └── config.env.example      # 配置模板（提交 Git）
├── docs/                       # 使用文档
├── scripts/
│   ├── install.ps1 / .sh       # 创建 ~/.feishu-mcp/config.env
│   ├── link-project.ps1 / .sh  # 接入任意 Cursor 项目
│   ├── verify.ps1 / .sh        # 验证 token + smoke test
│   ├── feishu-mcp-stdio.ps1    # MCP 启动器（读统一配置）
│   └── feishu/                 # 协作者 / 工具脚本
└── templates/
    ├── feishu-tenant-scopes.json
    └── cursor-rule-feishu-docs.mdc
```

## 配置位置（重要）

| 文件 | 位置 | 是否提交 Git |
|------|------|-------------|
| 统一配置 | `~/.feishu-mcp/config.env` | 否 |
| 项目 MCP | `<project>/.cursor/mcp.json` | 可选（link 生成） |
| 项目脚本副本 | `<project>/scripts/feishu/*.py` | 可提交 |
| 链接元数据 | `<project>/.feishu-mcp.json` | 建议 gitignore |

## 常用命令

```bash
# 列举 Wiki 根目录下子文档
python scripts/feishu/list_wiki_children.py

# 创建文档后授权
python scripts/feishu/grant_document_collaborator.py --doc-token <obj_token>

# 解析 OpenID
python scripts/feishu/resolve_feishu_open_id.py

# 冒烟测试
python scripts/feishu/smoke_test.py
```

## 参考

- [飞书开放平台](https://open.feishu.cn/document)
- [Feishu-MCP](https://github.com/cso1z/Feishu-MCP)
- [Feishu-MCP 配置说明](https://github.com/cso1z/Feishu-MCP/blob/main/FEISHU_CONFIG.md)
