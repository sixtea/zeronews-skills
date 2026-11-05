# 已安装客户端 — 自动对齐最新版（install 默认）

与 MCP `install_client`（`download_install` 默认 true）一致：**发现本机已有二进制时，不要问用户「要不要升级」**，先比对版本，非 latest 则自动执行升级链。

## 何时执行

- 用户任务属于 **安装 / 装好 ZeroNews / 部署客户端**（`zeronews-install-client`）
- 探测到 **`zeronews` 已存在**（PATH 或已知 workdir）
- **未**明确说：只探测、不要下载、不要升级、仅 inspect

Docker：若容器/镜像已存在且用户要「安装」，同样 **pull 较新镜像并重建容器**（不询问是否升级），除非用户只要 inspect。

## 步骤

### 1. 读当前版本

```bash
zeronews --version
zeronews --workdir {WORKDIR} status --json   # 若可能有 config
```

记录 `current_version`；读不到版本 → 报告 `version_unknown`，仍尝试官方安装脚本覆盖（不询问）。

### 2. 预检（与 CP 对齐）

**已 configure 且有 `client_id`**：

```bash
zeronews --workdir {WORKDIR} device download-resolve {CLIENT_ID} --json
```

**未 login / 无 client_id**：用 CLI/官方 latest 信息对比 `current_version`（与 MCP `fetchOfficialDownloadLatest` 意图相同；以 `--json` 或安装文档为准）。

若 **`is_latest`** → 跳到 install skill 的 bind/start/verify（无需下载整包）。

### 3. 非 latest — 自动升级（禁止询问用户）

按顺序尝试，**直到 latest 或无法继续**：

1. **本机 online + login**：  
   `zeronews --workdir {WORKDIR} device upgrade {CLIENT_ID} --json`  
   成功 → `service restart` 或 `reload`（若在跑）→ 再跑 `download-resolve` 确认 latest。

2. **remote 失败或进程未跑 / 仅有 `download_url`**：  
   用预检 JSON 中的 **`download_url`**；若无 CP URL，用 [INSTALL-COMMANDS.md](./INSTALL-COMMANDS.md) 中的 **Base download host** 与平台路径覆盖二进制（**直接执行，勿判断环境**）→ **`service restart`** 或 `start`。

3. **仍非 latest**：再执行一次 **install script / 平台安装命令**（INSTALL-COMMANDS 中的 CDN；不 reset config），然后 restart。

全程 **告知** 当前版 → 目标版与正在执行的动作；**不要**问「是否升级」。

### 4. 升级后

- 继续 install skill：未 login → configure；未 running → **已 root/管理员则 service**；**否则无法静默提权则直接前台 `start`（不问用户）**（见 SKILL Step 4）
- 验证：`inspect-client` 或 `status --json` 中的 version

## 仍须用户选择的情况（非升级询问）

| 情况 | 行为 |
|------|------|
| authtoken conflict | reset / ignore（现有 Step 3b） |
| 用户明确 **reset 重装** | 二次确认后 reset |
| 用户明确 **只探测** | 不升级、不下载 |
| 删客户端 / 删隧道 | 其他 skill |

## Handoff

细粒度 `device upgrade` 步骤见 **`zeronews-upgrade-client`**（install 触发的升级 **跳过** upgrade skill 里的用户确认步骤）。
