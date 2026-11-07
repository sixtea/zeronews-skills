# Configure Client — 浏览器 login

本 Skill 的绑机步骤 **必须** 遵循共享规程：

**[../../_shared/references/BROWSER-LOGIN.md](../../_shared/references/BROWSER-LOGIN.md)**

要点：`NO_TTY=1 login` → **Agent 执行 `open`/`xdg-open`/`start`** → **同 Shell 轮询** `jq '.login == true'` → 再 start/服务或 handoff expose。
