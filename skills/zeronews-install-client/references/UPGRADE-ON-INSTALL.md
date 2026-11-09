# 已安装客户端 — 自动对齐最新版（install 默认）

与 MCP `install_client`（`download_install` 默认 true）一致：**发现本机已有二进制时，不要问用户「要不要升级」**，先比对版本，非 latest 则自动执行升级链。

**Install 升级口径（固定）：** 只用 **本机 `zeronews --version`** + 控制面 **`/client/download/latest`**（按 os/arch/current_version）。**禁止**在安装任务里调用 `device download-resolve` / `device upgrade`（不读、不写入 `client_id`）。

## 何时执行

- 用户任务属于 **安装 / 装好 ZeroNews / 部署客户端**（`zeronews-install-client`）
- 探测到 **`zeronews` 已存在**（PATH 或已知 workdir）
- **未**明确说：只探测、不要下载、不要升级、仅 inspect

Docker：若容器/镜像已存在且用户要「安装」，同样 **pull 较新镜像并重建容器**（不询问是否升级），除非用户只要 inspect。

## 步骤

### 1. 读当前版本

```bash
zeronews --version
```

记录 `current_version`（去掉 `v` / `zeronews ` 前缀）；读不到版本 → 记 `version_unknown`，仍尝试官方安装脚本覆盖（不询问）。

**不要**为升级预检去解析 `status --json` 里的 `client_id`。

### 2. 预检（平台 latest，与 CP 对齐）

**先解析 `CP_BASE`**（禁止用 INSTALL-COMMANDS 下载域）：见 [CONTROL-PLANE-VS-DOWNLOAD.md](./CONTROL-PLANE-VS-DOWNLOAD.md)。

按本机平台拼查询（与 MCP `fetchOfficialDownloadLatest` 一致）：

| OS | `os` | `arch`（`uname -m`） |
|----|------|----------------------|
| macOS arm64 | `darwin` | `arm64` |
| macOS Intel | `darwin` | `amd64` |
| Linux arm64 | `linux` | `arm64` |
| Linux x86_64 | `linux` | `amd64` |

```bash
curl -sk "${CP_BASE}/client/download/latest?os=${OS}&arch=${ARCH}&current_version=${CURRENT_VERSION}"
```

解析 envelope JSON：`can_upgrade`、`must_upgrade`、`version`（目标版）、`download_url`、`checksum`。  
当 **`can_upgrade` 与 `must_upgrade` 均为 false** 且当前版非空 → 视为 **`is_latest`** → 跳到 bind/start/verify（无需下载整包）。

**HTTP 失败（含对 agentv2 误请求的 404）**：先按 CONTROL-PLANE-VS-DOWNLOAD 纠正 `CP_BASE` 并重试一次；仍失败则按 [INSTALL-COMMANDS.md](./INSTALL-COMMANDS.md) 官方 **CDN** 覆盖二进制比对（不 reset config），勿向用户确认下载域。

### 3. 非 latest — 自动升级（禁止询问用户）

**禁止** `device upgrade`。**只**换二进制 + 重启进程：

1. 预检 JSON 有 **`download_url`** → **直接下载覆盖** 当前平台二进制（macOS/Windows 替换文件；Linux 可用 install script 或 `download_url`），权限不足时用 `sudo` 仅作用于二进制路径。  
2. 无 `download_url` → 用 INSTALL-COMMANDS 中 **Base download host** 与平台路径覆盖（**直接执行**）。  
3. 客户端若在跑 → 先 **`reload`**（不提权）；仅当 reload 无效再 **`service restart`**（macOS 非 root：`sudo -n` 或 **一次** osascript）。若未 running → 按 Step 4：**已装过** 可只 osascript `service start`；否则 **一条** osascript `install && start`。  
4. 再读 `zeronews --version`；仍落后 → 再执行一次 **install script / 平台安装命令**（不 reset config）→ restart。

全程 **告知** 当前版 → 目标版与动作；**不要**问「是否升级」。

### 4. 升级后

- 继续 install skill：**本轮**若 Step 3 未执行或失败且仍 `login: false` → **`zeronews-configure-client`** 或 **续跑 install Step 3**（二选一）；**禁止** Step 3 已成功后再 configure。  
- 未 running → 按 SKILL Step 4：**root/`sudo -n` → system service**；**macOS 非 root → osascript administrator 起 system 服务，失败再前台**（见 [MACOS-AGENT-SERVICE.md](./MACOS-AGENT-SERVICE.md)）。  
- 验证：`zeronews --version` 或 `inspect-client` / `status --json`。

## 仍须用户选择的情况（非升级询问）

| 情况 | 行为 |
|------|------|
| authtoken conflict | reset / ignore（现有 Step 3b） |
| 用户明确 **reset 重装** | 二次确认后 reset |
| 用户明确 **只探测** | 不升级、不下载 |
| 控制台「设备升级」/ 远程另一台设备 | **`zeronews-upgrade-client`**（可用 `client_id`）；**不属于 install 本 skill** |

## Handoff

用户单独说「升级本机/某设备」→ **`zeronews-upgrade-client`**（可走 `download-resolve` + `device upgrade`）。  
Install 触发的自动对齐 **不得** 调用 upgrade skill 里的设备远程链，**不得**使用 `client_id`。
