# 沙箱验证指南

在不改动现有项目（如 QuantMind）和全局 `~/.feishu-mcp/config.env` 的前提下，验证本安装包教程是否正确。

## 适用场景

- 验证 [GitHub 仓库](https://github.com/evan-ai-auto/feishu-cursor-mcp) 教程
- 本机已有其他项目的 `.env.feishu` / MCP 配置，需隔离测试
- 同事首次接入前的预演

## 目录结构

```
E:\sandbox\                          # 或 ~/sandbox
├── feishu-cursor-mcp\               # git clone 本仓库
├── feishu-mcp-private\
│   └── config.env                   # 私有配置（UTF-8，不进 Git）
└── cursor-mcp-test\                 # link-project 测试项目
```

## 一键沙箱验证（推荐）

**Windows**

```powershell
# 1. 准备沙箱（仅首次）
mkdir E:\sandbox -Force
git clone https://github.com/evan-ai-auto/feishu-cursor-mcp.git E:\sandbox\feishu-cursor-mcp

# 2. 创建私有配置（从现有 .env.feishu 复制内容，另存为 UTF-8）
notepad E:\sandbox\feishu-mcp-private\config.env

# 3. 一键验证 + link 测试项目
powershell -ExecutionPolicy Bypass -File E:\sandbox\feishu-cursor-mcp\scripts\verify-sandbox.ps1 `
  -ConfigPath E:\sandbox\feishu-mcp-private\config.env
```

**macOS / Linux**

```bash
mkdir -p ~/sandbox/feishu-mcp-private
git clone https://github.com/evan-ai-auto/feishu-cursor-mcp.git ~/sandbox/feishu-cursor-mcp
# 编辑 ~/sandbox/feishu-mcp-private/config.env（UTF-8）
bash ~/sandbox/feishu-cursor-mcp/scripts/verify-sandbox.sh \
  ~/sandbox/feishu-mcp-private/config.env
```

`verify-sandbox` 会：

1. 用 `-ConfigPath` / `FEISHU_MCP_CONFIG` 跑 `verify` + `smoke_test`
2. 执行 `link-project` 并在 `mcp.json` 写入 `env.FEISHU_MCP_CONFIG`
3. **跳过** `install.ps1`（不写全局 `~/.feishu-mcp`）

## 手动步骤（与教程对照）

| 教程步骤 | 沙箱做法 |
|----------|----------|
| clone | `E:\sandbox\feishu-cursor-mcp` |
| install | **跳过**；用手动 `config.env` |
| 填 config | `E:\sandbox\feishu-mcp-private\config.env` |
| verify | `verify.ps1 -ConfigPath <sandbox-config>` |
| link-project | `link-project.ps1 -ConfigPath <sandbox-config>` |
| Cursor | **新窗口**打开 `cursor-mcp-test` |

```powershell
powershell -File scripts/verify.ps1 -ConfigPath E:\sandbox\feishu-mcp-private\config.env

powershell -File scripts/link-project.ps1 `
  -ProjectPath E:\sandbox\cursor-mcp-test `
  -ConfigPath E:\sandbox\feishu-mcp-private\config.env
```

## Cursor UI 验证

1. **新开** Cursor 窗口（不要打开正在使用的业务项目）
2. 打开 `E:\sandbox\cursor-mcp-test`
3. Settings → Tools & MCP → `feishu-mcp` 绿色
4. 粘贴 [QUICKSTART.md](../QUICKSTART.md) 冒烟话术

## 隔离保证

| 不改动 | 说明 |
|--------|------|
| 业务项目 `.env.feishu` | 沙箱用独立 `config.env` |
| 业务项目 `.cursor/mcp.json` | 只 link 到 `cursor-mcp-test` |
| `~/.feishu-mcp/config.env` | 跳过 `install.ps1` |

## Windows 编码注意

编辑 `config.env` 时**必须保存为 UTF-8**（推荐 UTF-8 无 BOM）。

- 不要用 PowerShell `Add-Content` 追加中文，可能变成 GBK 导致 Python 读取失败
- 用 VS Code / Notepad++ 另存为 UTF-8
- `_feishu_client.py` 已兼容 `utf-8-sig` / `gbk` 回退，但仍建议统一 UTF-8

## 验收标准

- [ ] `verify.ps1 -ConfigPath ...` 输出 OK
- [ ] `smoke_test` 中 `wiki_list: ok`
- [ ] `cursor-mcp-test/.cursor/mcp.json` 含 `env.FEISHU_MCP_CONFIG`
- [ ] 新 Cursor 窗口 MCP 已连接
- [ ] 冒烟话术三项通过

## 清理

```powershell
Remove-Item -Recurse -Force E:\sandbox\cursor-mcp-test   # 可选
# 保留 feishu-mcp-private\config.env 作为本机备份
```
