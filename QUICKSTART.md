# 快速开始

完整文档见 [README.md](../README.md)。

## 新电脑 5 步

```bash
git clone <private-repo> ~/tools/feishu-cursor-mcp && cd ~/tools/feishu-cursor-mcp
bash scripts/install.sh          # Windows: install.ps1
# 编辑 ~/.feishu-mcp/config.env
bash scripts/verify.sh
bash scripts/link-project.sh /path/to/your-cursor-project
# 重启 Cursor
```

## 冒烟话术（粘贴到 Cursor 对话）

```
请用 feishu-mcp：
1. 读取 ~/.feishu-mcp/config.env 中的 FEISHU_WIKI_* 作为 wikiContext
2. 列举「文档助手专用」下子节点
3. 创建标题「联调测试-可删」的子文档并写一句正文
4. 执行 grant_document_collaborator.py 给我授权
```

## 创建文档后

```bash
python scripts/feishu/grant_document_collaborator.py --doc-token <obj_token>
```

**勿在飞书正文写入 Secret、OpenID、手机号等敏感信息。**
