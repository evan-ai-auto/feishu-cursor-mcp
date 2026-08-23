# Wiki 协作区配置

飞书「我的文档库」**没有独立文件夹类型**，通过 **父文档 → 子文档** 形成目录树。本次实践已验证 tenant 应用可在此结构下列举、创建、编辑子文档。

## 管理员一次性操作

### 1. 创建协作根文档

在飞书客户端「我的文档库」新建文档，作为 AI 协作根目录（例如「文档助手专用」）。

### 2. 分享给自建应用

打开该文档 → **分享** → 添加你的**企业自建应用** → 权限建议 **可编辑** 或 **可管理**。

> 仅 `edit` 即可列举和创建子文档；需要管理协作者时选「可管理」。

### 3. 获取 Wiki 参数

打开根文档的 Wiki 链接，形如：

```
https://<tenant>.feishu.cn/wiki/FjyXw7T3riE9kOk8fwVctDIunAd
                              └─ FEISHU_WIKI_ROOT_NODE_TOKEN
```

在 Cursor 中让 Agent 执行 `get_feishu_document_info`（传入 Wiki URL），从返回中取：

- `space_id` → `FEISHU_WIKI_SPACE_ID`
- `node_token` → `FEISHU_WIKI_ROOT_NODE_TOKEN`

**注意**：`get_feishu_root_folder_info` 返回的 `my_library.space_id` 可能与实际文档所在 `space_id` **不一致**，务必以 `get_node` / `get_feishu_document_info` 为准。

### 4. 写入统一配置

编辑 `~/.feishu-mcp/config.env`：

```env
FEISHU_WIKI_SPACE_ID=744490269095973xxxx
FEISHU_WIKI_ROOT_NODE_TOKEN=FjyXw7T3riE9kOk8fwVctDIxxxx
FEISHU_WIKI_ROOT_TITLE=文档助手专用
```

## Agent 操作约定

| 操作 | MCP 方式 |
|------|----------|
| 列子文档 | `get_feishu_folder_files` + `wikiContext` |
| 建子文档 | `create_feishu_document` + `wikiContext` |
| 编辑正文 | 使用子节点 `obj_token`（非 node_token） |
| 授权本人 | `grant_document_collaborator.py --doc-token <obj_token>` |

## 验证

```bash
python scripts/feishu/list_wiki_children.py
python scripts/feishu/smoke_test.py
```

或在 Cursor 粘贴 [QUICKSTART.md](../QUICKSTART.md) 中的冒烟话术。

## 用户手动移动文档

将「我的文档库」中的文档拖到协作根目录下后，应用可通过 API **立即列举**子节点，无需额外分享每一篇子文档（继承父节点访问权）。

## 云盘模式（备选）

若使用云盘 folder 而非 Wiki 树：

1. 将云盘根目录或指定 folder 分享给应用（可管理）
2. 配置 `FEISHU_DEFAULT_FOLDER_TOKEN`
3. MCP 使用 `folderToken` 而非 `wikiContext`

当前推荐 **Wiki 协作区** 方案。
