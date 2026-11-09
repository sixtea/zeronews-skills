# 控制面 API vs 二进制下载 CDN

安装 Skill 涉及 **两个不同 origin**，不可混用。

| 用途 | testenv 示例 | 路径示例 |
|------|----------------|----------|
| **控制面（User Backend）** | `https://userbackendv2.testenv.waitoin.com:8443` | `GET /client/download/latest?os=&arch=&current_version=` |
| **二进制 CDN（Agent 下载站）** | `https://agentv2.testenv.waitoin.com:8443` | `/macos/arm/zeronews`、`/linux/zeronews-install.sh` |

对 `agentv2…/client/download/latest` 会 **404**（CDN 无 Gin 路由）。Agent 不得用 [INSTALL-COMMANDS.md](./INSTALL-COMMANDS.md) 的 Base download host 拼控制面 URL。

## 解析 `CP_BASE`（Step 1b 预检，按序）

1. 环境变量 **`ZERONEWS_CONTROL_PLANE_URL`**（去尾 `/`）。
2. 本机客户端内嵌地址（与 `login` / `auth` 同源）：
   ```bash
   CP_BASE=$(strings "${ZERONEWS_EXECUTABLE:-/Applications/zeronews/zeronews}" | \
     rg -o 'https://userbackend[^[:space:]]+' | head -1)
   ```
   Linux 常见 workdir：`/etc/zeronews/zeronews` 或 PATH 上的 `zeronews`。
3. **仅 testenv**：若下载域为 `agentv2.testenv.waitoin.com`，控制面为 **`userbackendv2.testenv.waitoin.com:8443`**（同端口），不要用 agentv2 当 CP。

生产环境以客户端编译内嵌的 `ControllerAddr` 或运维提供的 `ZERONEWS_CONTROL_PLANE_URL` 为准。

## 预检 curl

```bash
curl -sk "${CP_BASE}/client/download/latest?os=${OS}&arch=${ARCH}&current_version=${CURRENT_VERSION}"
```

成功：JSON `code:200`，读 `data.can_upgrade` / `must_upgrade` / `download_url`。  
失败：**禁止**把 agentv2 再试一遍当 CP；改按 [UPGRADE-ON-INSTALL.md](./UPGRADE-ON-INSTALL.md) 用 CDN 覆盖比对二进制。
