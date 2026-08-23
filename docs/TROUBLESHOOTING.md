# 故障排查

| 现象 | 可能原因 | 处理 |
|------|----------|------|
| MCP 工具列表为空 | Cursor 未重启 / Node 未安装 | 重启 Cursor；`node -v`、`npx -v` |
| Missing FEISHU_APP_ID | 未创建 config | 运行 `install`，编辑 `~/.feishu-mcp/config.env` |
| tenant token failed | App ID/Secret 错误 | 核对飞书控制台凭证 |
| 99991672 权限错误 | 应用权限未审批 | 重新导入 `feishu-tenant-scopes.json` 并发布 |
| Wiki 列举为空 | 未分享给应用 / space_id 错误 | 见 [WIKI_WORKSPACE.md](WIKI_WORKSPACE.md) |
| 搜索不到协作根目录 | 用了错误的 space_id | 用 `get_feishu_document_info` 获取真实 `space_id` |
| 能读不能建子文档 | 应用仅 edit | 分享权限升为「可管理」 |
| grant 失败 | 未配置协作者 | 设置 `FEISHU_COLLABORATOR_OPEN_ID` |
| `UnicodeDecodeError` 读 config | Windows GBK 编码 | 用 UTF-8 重写 config.env，见 [CONFIG.md](CONFIG.md) |
| 沙箱验证不想动现有项目 | — | 用 [VERIFY_SANDBOX.md](VERIFY_SANDBOX.md) + `verify-sandbox.ps1` |
| mcp.json 路径错误 | 换了 kit 安装位置 | 重新 `link-project` |

## 诊断命令

```bash
# 配置与 token
bash scripts/verify.sh

# Wiki 列举
python scripts/feishu/list_wiki_children.py

# 综合冒烟
python scripts/feishu/smoke_test.py
```

## 日志

Cursor：**Settings → Tools & MCP** 查看 `feishu-mcp` 连接状态与错误输出。

## 联系支持

收集以下信息（**勿含 Secret**）：

- `verify` / `smoke_test` 输出
- `FEISHU_WIKI_SPACE_ID`（可提供）
- 飞书开放平台错误 `log_id`（若有）
