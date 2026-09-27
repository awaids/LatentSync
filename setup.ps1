$ErrorActionPreference = "Stop"

Write-Host "Setting up LatentSync..." -ForegroundColor Cyan

# --------------------------------------------------
# Resolve project directory
# --------------------------------------------------

$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectDir

Write-Host "Project directory: $ProjectDir"

# --------------------------------------------------
# 1. Check uv
# --------------------------------------------------

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "uv is not installed." -ForegroundColor Yellow
    Write-Host "Install it first with:"
    Write-Host 'powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"'
    exit 1
}

# --------------------------------------------------
# 2. Install Python 3.10.13
# --------------------------------------------------

Write-Host ""
Write-Host "Installing Python 3.10.13..." -ForegroundColor Cyan

uv python install 3.10.13

# --------------------------------------------------
# 3. Create virtual environment
# --------------------------------------------------

Write-Host ""
Write-Host "Creating virtual environment..." -ForegroundColor Cyan

uv venv --python 3.10.13

# --------------------------------------------------
# 4. Install Python dependencies
# --------------------------------------------------

Write-Host ""
Write-Host "Installing Python dependencies..." -ForegroundColor Cyan

if (Test-Path "pyproject.toml") {
    uv sync
}
elseif (Test-Path "requirements.txt") {
    uv pip install -r requirements.txt
}
else {
    throw "Neither pyproject.toml nor requirements.txt was found."
}

# --------------------------------------------------
# 5. Install FFmpeg
# --------------------------------------------------

Write-Host ""
Write-Host "Checking FFmpeg..." -ForegroundColor Cyan

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {

    Write-Host "FFmpeg not found. Installing with winget..." -ForegroundColor Yellow

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget is not available. Please install FFmpeg manually."
    }

    winget install --id Gyan.FFmpeg -e --accept-package-agreements --accept-source-agreements

    Write-Host ""
    Write-Host "FFmpeg was installed." -ForegroundColor Green
    Write-Host "You may need to restart PowerShell before ffmpeg is available in PATH." -ForegroundColor Yellow
}
else {
    Write-Host "FFmpeg already installed." -ForegroundColor Green
}

# --------------------------------------------------
# 6. Create checkpoints directory
# --------------------------------------------------

$CheckpointDir = Join-Path $ProjectDir "checkpoints"

if (-not (Test-Path $CheckpointDir)) {
    New-Item -ItemType Directory -Path $CheckpointDir | Out-Null
}

# --------------------------------------------------
# 7. Download Hugging Face checkpoints
# --------------------------------------------------

Write-Host ""
Write-Host "Downloading Whisper checkpoint..." -ForegroundColor Cyan

uv run huggingface-cli download `
    ByteDance/LatentSync-1.6 `
    whisper/tiny.pt `
    --local-dir $CheckpointDir

Write-Host ""
Write-Host "Downloading LatentSync UNet checkpoint..." -ForegroundColor Cyan

uv run huggingface-cli download `
    ByteDance/LatentSync-1.6 `
    latentsync_unet.pt `
    --local-dir $CheckpointDir

# --------------------------------------------------
# 8. Verify CUDA
# --------------------------------------------------

Write-Host ""
Write-Host "Checking PyTorch CUDA support..." -ForegroundColor Cyan

uv run python -c "import torch; print('PyTorch:', torch.__version__); print('CUDA available:', torch.cuda.is_available()); print('CUDA version:', torch.version.cuda); print('GPU:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'None')"

# --------------------------------------------------
# Done
# --------------------------------------------------

Write-Host ""
Write-Host "LatentSync setup complete." -ForegroundColor Green
Write-Host ""