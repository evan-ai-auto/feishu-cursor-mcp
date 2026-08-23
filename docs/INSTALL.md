# 安装指南

## 前置条件

| 依赖 | 用途 |
|------|------|
| [Node.js](https://nodejs.org/) + `npx` | 运行 `feishu-mcp` |
| [Python 3](https://www.python.org/) | 协作者脚本 |
| [Cursor](https://cursor.com/) 桌面版 | MCP 宿主 |
| 飞书企业管理员 | 审批应用权限（一次性） |

## 第一步：Clone 安装包

```bash
git clone <your-private-git-url> ~/tools/feishu-cursor-mcp
cd ~/tools/feishu-cursor-mcp
```

建议将 kit 放在固定路径（如 `~/tools/feishu-cursor-mcp`），便于 `link-project` 引用启动器。

## 第二步：初始化本机配置

**Windows**

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install.ps1
```

**macOS / Linux**

```bash
bash scripts/install.sh
```

会在本机创建：

- Windows: `%USERPROFILE%\.feishu-mcp\config.env`
- macOS: `~/.feishu-mcp/config.env`

## 第三步：飞书开放平台（管理员一次性）

1. [创建企业自建应用](https://open.feishu.cn/app)
2. 记录 **App ID**、**App Secret**
3. **权限管理 → 批量导入** → 上传 `templates/feishu-tenant-scopes.json`
4. **创建版本并发布**，等待管理员审批
5. **分享 Wiki 协作区给应用**（见 [WIKI_WORKSPACE.md](WIKI_WORKSPACE.md)）

## 第四步：填写 config.env

编辑 `~/.feishu-mcp/config.env`，至少填写：

```env
FEISHU_APP_ID=cli_...
FEISHU_APP_SECRET=...
FEISHU_COLLABORATOR_OPEN_ID=ou_...   # 或手机号/邮箱
FEISHU_WIKI_SPACE_ID=...
FEISHU_WIKI_ROOT_NODE_TOKEN=...
```

变量说明：[CONFIG.md](CONFIG.md)

解析 OpenID：

```bash
python scripts/feishu/resolve_feishu_open_id.py
```

## 第五步：验证

```powershell
powershell -File scripts/verify.ps1
# macOS: bash scripts/verify.sh
```

期望：`tenant_access_token ok`，`smoke_test` 中 `wiki_list: ok`。

## 第六步：链接 Cursor 项目

```powershell
powershell -File scripts/link-project.ps1 -ProjectPath E:\your\project
```

重启 Cursor，在 **Settings → Tools & MCP** 确认 `feishu-mcp` 绿色已连接。

## 验收清单

- [ ] `~/.feishu-mcp/config.env` 已填写
- [ ] 飞书应用权限已审批
- [ ] Wiki 协作区已分享给应用
- [ ] `verify` 通过
- [ ] `link-project` 已执行
- [ ] Cursor MCP 已连接
- [ ] 冒烟话术测试通过（见 [QUICKSTART.md](../QUICKSTART.md)）
