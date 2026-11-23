# One Shot Bitcoin on Windows.
#
# The node runs in Docker Desktop, and this installer runs inside WSL (the
# Linux that Windows ships), where it is exactly the Linux installer. This
# script only checks that both are ready and starts it.
#
# In PowerShell:
#   powershell -ExecutionPolicy Bypass -File windows\install.ps1

$ErrorActionPreference = "Stop"

function Stop-With($message) {
    Write-Host ""
    Write-Host "Not ready: $message" -ForegroundColor Yellow
    exit 1
}

Write-Host "One Shot Bitcoin: checking Windows..."

# 1. WSL with a Linux distribution
if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    Stop-With "WSL is not installed. Open PowerShell as administrator, run 'wsl --install -d Ubuntu', restart, and run this again."
}
wsl.exe -e true 2>$null
if ($LASTEXITCODE -ne 0) {
    Stop-With "WSL has no Linux distribution yet. Run 'wsl --install -d Ubuntu', create your Linux user, and run this again."
}

# 2. Docker Desktop reachable from inside WSL
wsl.exe -e sh -c "docker info >/dev/null 2>&1"
if ($LASTEXITCODE -ne 0) {
    Stop-With "Docker does not answer inside WSL. Install Docker Desktop (https://docs.docker.com/desktop/setup/install/windows-install/), start it, and turn on Settings > Resources > WSL integration for your distribution."
}

# 3. git and openssl inside WSL
wsl.exe -e sh -c "command -v git >/dev/null && command -v openssl >/dev/null"
if ($LASTEXITCODE -ne 0) {
    Stop-With "git or openssl is missing inside WSL. In the Ubuntu window run: sudo apt update && sudo apt install -y git openssl"
}

# 4. Get the repository inside WSL (the Linux disk is much faster than C:) and install
Write-Host "Everything is ready. Starting the installer inside WSL..."
wsl.exe -e bash -lc 'set -e; cd ~; if [ ! -d one-shot-bitcoin ]; then git clone https://github.com/Kilombino/one-shot-bitcoin.git; fi; cd one-shot-bitcoin && ./install.sh'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Later, from PowerShell:  wsl -e bash -lc 'cd ~/one-shot-bitcoin && ./oneshot status'"
Write-Host "Keep Docker Desktop running: the node stops when it is closed."
