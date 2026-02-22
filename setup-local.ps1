
# AdventureLog Local Setup Script (Windows, no Docker)
# Run from the AdventureLog directory: .\setup-local.ps1

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  AdventureLog Local Dev Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ── 1. Install pnpm ──────────────────────────────────────────────
Write-Host "[1/7] Installing pnpm..." -ForegroundColor Yellow
npm install -g pnpm
Write-Host "pnpm installed." -ForegroundColor Green

# ── 2. Create PostgreSQL DB & user ───────────────────────────────
Write-Host "`n[2/7] Creating PostgreSQL database & user..." -ForegroundColor Yellow
$pgBin = "C:\Program Files\PostgreSQL\17\bin"
if (-not (Test-Path "$pgBin\psql.exe")) {
    $pgBin = "C:\Program Files\PostgreSQL\13\bin"
}
$env:PATH += ";$pgBin"
$env:PGPASSWORD = "postgres"   # default superuser password — change if yours differs

# Create user & DB (ignore errors if they already exist)
psql -U postgres -c "CREATE USER adventure WITH PASSWORD 'adventure123';" 2>$null
psql -U postgres -c "CREATE DATABASE adventurelog OWNER adventure;" 2>$null
psql -U postgres -d adventurelog -c "CREATE EXTENSION IF NOT EXISTS postgis;" 2>$null
psql -U postgres -d adventurelog -c "GRANT ALL PRIVILEGES ON DATABASE adventurelog TO adventure;" 2>$null
Write-Host "Database ready." -ForegroundColor Green

# ── 3. Python virtual environment ────────────────────────────────
Write-Host "`n[3/7] Setting up Python virtual environment..." -ForegroundColor Yellow
Set-Location "$root\backend\server"
if (-not (Test-Path "venv")) {
    python -m venv venv
}
& ".\venv\Scripts\Activate.ps1"
Write-Host "venv activated." -ForegroundColor Green

# ── 4. Install Python dependencies ───────────────────────────────
Write-Host "`n[4/7] Installing Python packages..." -ForegroundColor Yellow
pip install --upgrade pip
pip install -r requirements.txt
Write-Host "Python packages installed." -ForegroundColor Green

# ── 5. Django setup ──────────────────────────────────────────────
Write-Host "`n[5/7] Running Django migrations..." -ForegroundColor Yellow
python manage.py migrate
python manage.py collectstatic --noinput
Write-Host "Django ready." -ForegroundColor Green

# ── 6. Frontend dependencies ─────────────────────────────────────
Write-Host "`n[6/7] Installing frontend packages..." -ForegroundColor Yellow
Set-Location "$root\frontend"
pnpm install
Write-Host "Frontend packages installed." -ForegroundColor Green

# ── 7. Done ──────────────────────────────────────────────────────
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host @"

To start the app run in TWO separate terminals:

  Terminal 1 — Backend:
    cd backend\server
    .\venv\Scripts\Activate.ps1
    python manage.py runserver

  Terminal 2 — Frontend:
    cd frontend
    pnpm dev

Then open: http://localhost:5173

"@ -ForegroundColor Cyan
