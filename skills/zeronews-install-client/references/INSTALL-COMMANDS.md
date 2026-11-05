# Install Commands

Official online install commands aligned with ZeroNews docs under `install/os`.

Before any command shown with `sudo`, check whether the current session is already root. If `id -u` is `0`, run without `sudo`. See `../../zeronews-configure-client/references/PRIVILEGE-EXECUTION.md`.

> **TEST（临时）**：当前 skill 使用测试下载站，**非生产**。目录索引见 [agentv2 测试 CDN](https://agentv2.testenv.waitoin.com:8443/)。测完请改回 `https://download.zeronews.cc`。

Base download host:

```text
https://agentv2.testenv.waitoin.com:8443
```

## Linux

Supported distros include Debian, Ubuntu, RHEL, CentOS, AlmaLinux, OpenEuler, Opensuse, Manjaro, Kylin, Opencloudos, and Fedora.

Install the binary only, then bind with browser login:

```bash
curl -SLk https://agentv2.testenv.waitoin.com:8443/linux/zeronews-install.sh | sh -s install
NO_TTY=1 zeronews login
zeronews status --json
```

The official script still accepts a token (unchanged):

```bash
curl -SLk https://agentv2.testenv.waitoin.com:8443/linux/zeronews-install.sh | sh -s install {TOKEN}
```

Use `sudo` when the environment requires elevated privileges. Pair sudo with the same workdir (`/etc/zeronews`):

```bash
curl -SLk https://agentv2.testenv.waitoin.com:8443/linux/zeronews-install.sh | sudo sh -s install
sudo NO_TTY=1 zeronews login
sudo zeronews status --json
```

After install, the CLI command is `zeronews`.

Default workdir:

```text
/etc/zeronews
```

Start foreground:

```bash
zeronews start
```

Start as system service:

```bash
sudo zeronews service install
sudo zeronews service start
```

## macOS

Default workdir:

```text
/Applications/zeronews
```

### Apple Silicon (M1 / M2 / M3 / M4)

Detect with:

```bash
uname -m
```

Expected value: `arm64`

```bash
mkdir -p /Applications/zeronews
cd /Applications/zeronews
curl -o zeronews.tmp https://agentv2.testenv.waitoin.com:8443/macos/arm/zeronews
mv zeronews.tmp zeronews
chmod +x zeronews
```

### Intel (x86_64)

Expected `uname -m` value: `x86_64`

```bash
mkdir -p /Applications/zeronews
cd /Applications/zeronews
curl -o zeronews.tmp https://agentv2.testenv.waitoin.com:8443/macos/amd/zeronews
mv zeronews.tmp zeronews
chmod +x zeronews
```

Bind with browser login (preferred):

```bash
cd /Applications/zeronews
NO_TTY=1 ./zeronews login
./zeronews status --json
```

Or with an AuthToken the user already pasted:

```bash
cd /Applications/zeronews
./zeronews authtoken {TOKEN}
```

Start foreground:

```bash
cd /Applications/zeronews
./zeronews start
```

Start as system service:

```bash
cd /Applications/zeronews
sudo ./zeronews service install
sudo ./zeronews service start
```

## Windows

Requires Windows 10 or later, 64-bit.

Download URL:

```text
https://agentv2.testenv.waitoin.com:8443/windows/x64/zeronews.exe
```

Recommended install directory example:

```text
D:\zeronews
```

PowerShell download example:

```powershell
New-Item -ItemType Directory -Force -Path D:\zeronews
Invoke-WebRequest -Uri "https://agentv2.testenv.waitoin.com:8443/windows/x64/zeronews.exe" -OutFile "D:\zeronews\zeronews.exe"
Set-Location D:\zeronews
```

Bind with browser login (preferred):

```powershell
$env:NO_TTY = "1"
.\zeronews.exe login
.\zeronews.exe status --json
```

Or with an AuthToken the user already pasted:

```powershell
.\zeronews.exe authtoken {TOKEN}
```

Start foreground:

```powershell
.\zeronews.exe start
```

Start as Windows service (run shell as Administrator):

```powershell
.\zeronews.exe service install
.\zeronews.exe service start
```

If the browser or SmartScreen warns about the download, choose to keep the file and continue.

## Architecture detection cheat sheet

| Platform | Command | arm64 / Apple Silicon | x86_64 / Intel / AMD64 |
| --- | --- | --- | --- |
| Linux/macOS | `uname -m` | `arm64` | `x86_64` |
| macOS download path | — | `/macos/arm/zeronews` | `/macos/amd/zeronews` |
| Windows | assume x64 package | use `/windows/x64/zeronews.exe` | use `/windows/x64/zeronews.exe` |

Linux install script handles architecture selection internally; do not manually swap Linux binary URLs unless official docs say otherwise.
