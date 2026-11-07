# 浏览器 login（Skills 路径 — 权威）

与 [zeronews-skills-setup](https://docs.zeronews.cc/raw/ai/zeronews-skills-setup.md) **包 ②**、**F-02** 一致。MCP 连接器路径用 Token / `configure_auth`，**勿混用**（见 [SKILL-ROUTER.md](./SKILL-ROUTER.md)）。

## 标准流水线（装客户端 + 映射）

```text
安装二进制 → login 授权（浏览器）→ 轮询 login:true → 启动客户端 → 确认 running/在线 → 再 expose
```

| 阶段 | Skill / 动作 |
|------|----------------|
| 安装 | `zeronews-install-client` Step 1–2 |
| 绑机 | Step 3 或 `zeronews-configure-client` |
| 启进程 | `zeronews-install-client` Step 4 或 `zeronews-manage-client-service` |
| 映射 | `zeronews-expose-service`（**仅当** `login: true` 且客户端在跑） |

**禁止** 未完成 `login: true` 就枚举端口或 `zeronews add`。

## 为什么常常「拉不起浏览器」

| 原因 | 说明 |
|------|------|
| **`NO_TTY=1`** | Agent **必须**设 `NO_TTY=1`（或非 TTY）时，CLI **只打印 verify URL 即退出**，**不会**执行 `open`/`xdg-open`（data-plane `login` 设计）。**浏览器必须由 Agent 在本机再调一次。** |
| **只跑了 `login` 没 `open`** | Skill 若只执行 `zeronews login` 就结束，用户看不到窗口。 |
| **沙箱 / 远程 Shell** | `open` / `start` 在 Agent 沙箱或远端机上执行 → 浏览器开在错误环境或失败。须 **关沙箱、用户本机**（[LOCAL-EXECUTION.md](./LOCAL-EXECUTION.md)）。 |
| **误走 MCP `login` 工具** | WorkBuddy MCP 子进程常无 GUI；Skills 规程应走 **本机 Shell**，不用 MCP 代替绑机（setup **F-15**）。 |
| **轮询拆成多回合** | `login` 一回合、`status` 每 3s 一新回合 → 体验像「卡住」；应在 **同一条 Shell** 内 `login` + while 轮询（F-18）。 |

## Agent 必做：login 后立刻打开浏览器

1. **关沙箱**，在用户本机 Shell 执行（`{WORKDIR}` 见 install / setup 标准路径表）。

```bash
export NO_TTY=1
url=$(zeronews --workdir "{WORKDIR}" login 2>&1 | grep -Eo 'https?://[^[:space:]]+' | head -1)
test -n "$url" || { echo "no verify url"; exit 1; }
```

2. **本机打开浏览器**（与 CLI 同逻辑，须在用户会话执行）：

| OS | 命令 |
|----|------|
| macOS | `open "$url"` |
| Linux | `xdg-open "$url"` 或 ` sensible-browser "$url"` |
| Windows | `start "" "$url"`（cmd）或 `Start-Process $url`（PowerShell） |

3. **若 `open` 失败**：告知用户 **在本机默认浏览器** 打开该 URL 并点确认；**不要把 URL 发到不可信频道**；可只在对话中提示「已生成确认链接，请在本机浏览器完成」而不复述完整 URL（若组织策略允许可显示一次）。

4. **同一 Shell 内轮询**（勿每 3s 新开 Agent 回合；用 `jq` 判据，禁止仅用 `grep '"login":true'`）：

```bash
i=0
while [ "$i" -lt 20 ]; do
  sleep 3
  i=$((i+1))
  out=$(zeronews --workdir "{WORKDIR}" status --json 2>&1) || true
  echo "[$i] $out"
  echo "$out" | jq -e '.login == true' >/dev/null 2>&1 && break
done
jq -e '.login == true' <<<"$out"
```

5. **`login_pending: true` 且 `login: false`** → **继续 while**，不算失败。满 20 次仍 pending → 提示用户在浏览器点确认，**用户确认后同 Shell 续轮询**（F-16）。

6. **`login: true` 后** → 执行 **start / service start**（install Step 4），再 `status --json` 确认 **running/connected**，然后才可 **expose**。

## 与 `zeronews login` 无 NO_TTY 的区别

交互式 TTY 下 CLI 会自己 `open` 并阻塞轮询。**Skills Agent 路径统一 `NO_TTY=1` + Agent `open` + Agent poll**，避免阻塞 IDE 工具超时。

## authtoken

仅当用户**已粘贴** Auth Token 或 Docker 安装时使用。`zeronews-skills-setup` **F-02** 禁止在 Skills 规程中向用户索要 Token；install 默认仍为 **浏览器 login**。
