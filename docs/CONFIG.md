# 配置说明

统一配置文件路径（优先级从高到低）：

1. 环境变量 `FEISHU_MCP_CONFIG` 指向的任意路径
2. `~/.feishu-mcp/config.env`（推荐）
3. 项目根目录 `.env.feishu`（旧版兼容）

模板：`config/config.env.example`

## 凭证（必填）

| 变量 | 说明 |
|------|------|
| `FEISHU_APP_ID` | 飞书自建应用 App ID |
| `FEISHU_APP_SECRET` | 飞书自建应用 App Secret |

## MCP 行为

| 变量 | 默认 | 说明 |
|------|------|------|
| `FEISHU_AUTH_TYPE` | `tenant` | `tenant`=应用身份；`user`=OAuth |
| `FEISHU_ENABLED_MODULES` | `document` | MCP 启用模块 |
| `FEISHU_SCOPE_VALIDATION` | `false` | 首次联调可 `false` |
| `FEISHU_USER_KEY` | `local-dev` | stdio 用户标识 |

## 协作者自动授权

| 变量 | 说明 |
|------|------|
| `FEISHU_AUTO_GRANT_COLLABORATOR` | `true` 时 Agent 创建文档后应执行 grant 脚本 |
| `FEISHU_COLLABORATOR_OPEN_ID` | 本人 OpenID（推荐） |
| `FEISHU_COLLABORATOR_MOBILE` | 手机号（脚本解析 OpenID） |
| `FEISHU_COLLABORATOR_EMAIL` | 邮箱 |
| `FEISHU_COLLABORATOR_PERM` | `view` / `edit` / `full_access` |

## Wiki 协作区（推荐填写）

飞书「我的文档库」用**父子文档**形成目录树。以下三项让 Agent 无需每次询问即可定位协作根目录：

| 变量 | 说明 | 获取方式 |
|------|------|----------|
| `FEISHU_WIKI_SPACE_ID` | Wiki 空间 ID | 打开协作根文档 → `get_feishu_document_info` 返回的 `space_id` |
| `FEISHU_WIKI_ROOT_NODE_TOKEN` | 根父节点 token | Wiki URL 中 `/wiki/` 后的字符串 |
| `FEISHU_WIKI_ROOT_TITLE` | 根节点标题（备注用） | 如 `文档助手专用` |

MCP 使用示例：

```json
{
  "wikiContext": {
    "spaceId": "<FEISHU_WIKI_SPACE_ID>",
    "parentNodeToken": "<FEISHU_WIKI_ROOT_NODE_TOKEN>"
  }
}
```

## 云盘模式（可选）

| 变量 | 说明 |
|------|------|
| `FEISHU_DEFAULT_FOLDER_TOKEN` | 云盘 folder token；Wiki 模式通常留空 |

## 安全

- **切勿**将 `config.env` 提交到 Git
- 团队共享凭证时通过加密渠道传递，或每人只改 `FEISHU_COLLABORATOR_*`

## 示例（占位符，请替换）

```env
FEISHU_APP_ID=cli_xxxxxxxxxxxxxxxx
FEISHU_APP_SECRET=<your-secret>
FEISHU_AUTH_TYPE=tenant
FEISHU_COLLABORATOR_OPEN_ID=ou_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
FEISHU_WIKI_SPACE_ID=7444902690959736833
FEISHU_WIKI_ROOT_NODE_TOKEN=FjyXw7T3riE9kOk8fwVctDIunAd
FEISHU_WIKI_ROOT_TITLE=文档助手专用
```
