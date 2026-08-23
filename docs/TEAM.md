# 团队分发指南

本团队采用 **每人独立飞书自建应用** 模式：各自申请应用、各自配置凭证、各自将 Wiki 协作区分享给**自己的**应用。

## 模式对比

| 组件 | 本团队策略（独立应用） |
|------|------------------------|
| 飞书自建应用 | **每人各自创建** |
| `FEISHU_APP_ID` / `SECRET` | 每人写入自己的 `~/.feishu-mcp/config.env` |
| Wiki 协作区分享 | **每人**将自己的「文档助手专用」分享给**自己的应用** |
| `FEISHU_COLLABORATOR_OPEN_ID` | 填本人 OpenID |
| `FEISHU_WIKI_*` | 可相同（同一协作目录结构）或各自维护 |

> 若未来改为共用应用，见 [TEAM_SHARED_APP.md](TEAM_SHARED_APP.md)（可选参考）。

## 新同事接入流程

1. 安装 Node、Python、Cursor
2. `git clone <private-repo> ~/tools/feishu-cursor-mcp`
3. 在 [飞书开放平台](https://open.feishu.cn/app) **创建自己的企业自建应用**
4. 导入 `templates/feishu-tenant-scopes.json` 并等管理员审批
5. `install` → 编辑 `~/.feishu-mcp/config.env`（填**自己的** App 凭证与 OpenID）
6. 将 Wiki 协作根文档分享给**自己的应用**（见 [WIKI_WORKSPACE.md](WIKI_WORKSPACE.md)）
7. `verify` → `link-project` 到自己的业务仓库
8. 重启 Cursor，跑冒烟话术

## 配置清单（每人独立完成）

```env
# ~/.feishu-mcp/config.env — 勿提交 Git

FEISHU_APP_ID=cli_<自己的>
FEISHU_APP_SECRET=<自己的>
FEISHU_COLLABORATOR_OPEN_ID=ou_<自己的>

# Wiki 协作区（可与团队对齐同一目录结构）
FEISHU_WIKI_SPACE_ID=...
FEISHU_WIKI_ROOT_NODE_TOKEN=...
FEISHU_WIKI_ROOT_TITLE=文档助手专用
```

Wiki 参数获取方式见 [WIKI_WORKSPACE.md](WIKI_WORKSPACE.md)。团队可共享**目录结构说明**，但**不共享** App Secret。

## 私有 Git 仓库结构建议

```
your-org/feishu-cursor-mcp   # 本安装包（私有，代码共享）
your-org/quantmind           # 业务项目 A（各自 link）
your-org/other-project       # 业务项目 B
```

安装包代码全员共享；飞书凭证**不进 Git**。

## 冒烟验收

在 Cursor 中执行：

```
请用 feishu-mcp，按 ~/.feishu-mcp/config.env 中的 FEISHU_WIKI_* 配置：
1. 列举协作根目录下子节点
2. 创建「联调测试-<你的名字>-可删」子文档
3. grant_document_collaborator.py 授权给我
```

三项成功 = 环境就绪。

## 常见问题

| 现象 | 处理 |
|------|------|
| MCP 未连接 | 重启 Cursor；检查 `link-project` |
| 根目录列举为空 | 是否将 Wiki 根文档分享给了**自己的**应用 |
| 能列举不能创建 | 应用权限升为「可管理」 |
| 文档创建了本人看不到 | 检查本人的 `FEISHU_COLLABORATOR_OPEN_ID` |

更多：[TROUBLESHOOTING.md](TROUBLESHOOTING.md)
