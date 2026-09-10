# ==============================================================================
# Скрипт первоначальной настройки окружения для Frontend / React разработки
# Запускать в PowerShell от имени Администратора!
# ==============================================================================

Write-Host "=== Начало установки окружения для Frontend (React) ===" -ForegroundColor Cyan

# Проверка прав администратора
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Пожалуйста, перезапустите PowerShell от имени Администратора!"
    Exit
}

# Функция для установки через winget
function Install-App {
    param (
        [string]$Id,
        [string]$Name
    )
    Write-Host "`n[+] Установка $Name ($Id)..." -ForegroundColor Yellow
    winget install --id $Id --exact --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[✓] $Name успешно установлен." -ForegroundColor Green
    } else {
        Write-Host "[!] $Name уже установлен или возникла ошибка установки." -ForegroundColor DarkYellow
    }
}

# ------------------------------------------------------------------------------
# 1. Основные системные программы и рантаймы
# ------------------------------------------------------------------------------
Write-Host "`n--- 1. Установка основных программ ---" -ForegroundColor Cyan

# Git
Install-App -Id "Git.Git" -Name "Git"

# Node.js (LTS-версия)
Install-App -Id "OpenJS.NodeJS.LTS" -Name "Node.js LTS"

# VS Code
Install-App -Id "Microsoft.VisualStudioCode" -Name "Visual Studio Code"

# Windows Terminal (если еще не установлен)
Install-App -Id "Microsoft.WindowsTerminal" -Name "Windows Terminal"

# Google Chrome (основной браузер для отладки)
Install-App -Id "Google.Chrome" -Name "Google Chrome"

# Шрифт с лигатурами и иконками для терминала и кода (JetBrains Mono)
Install-App -Id "JetBrains.JetBrainsMono" -Name "JetBrains Mono Font"

# Postman (или можно заменить на Bruno: "Bruno.Bruno") для тестирования REST/GraphQL API
Install-App -Id "Postman.Postman" -Name "Postman"

# 7-Zip (полезный архиватор)
Install-App -Id "7zip.7zip" -Name "7-Zip"

# ------------------------------------------------------------------------------
# 2. Обновление переменных окружения текущей сессии
# ------------------------------------------------------------------------------
Write-Host "`n--- 2. Обновление путей PATH в текущей сессии ---" -ForegroundColor Cyan
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# ------------------------------------------------------------------------------
# 3. Настройка менеджеров пакетов (pnpm, yarn, corepack)
# ------------------------------------------------------------------------------
Write-Host "`n--- 3. Настройка пакетных менеджеров Node.js ---" -ForegroundColor Cyan

try {
    # Включаем Corepack (встроенный в Node.js менеджер yarn / pnpm)
    Write-Host "[+] Активация Corepack..." -ForegroundColor Yellow
    corepack enable

    # Установка pnpm глобально (наиболее быстрый и экономный менеджер пакетов для React)
    Write-Host "[+] Установка pnpm..." -ForegroundColor Yellow
    npm install -g pnpm

    # Установка serve (удобная утилита для быстрого превью продакшн билдов)
    Write-Host "[+] Установка serve..." -ForegroundColor Yellow
    npm install -g serve

    Write-Host "[✓] Пакетные менеджеры успешно настроены." -ForegroundColor Green
} catch {
    Write-Warning "Node.js еще не подтянулся в PATH текущей сессии. После перезагрузки терминала выполните: corepack enable && npm i -g pnpm"
}

# ------------------------------------------------------------------------------
# 4. Установка расширений VS Code для React / TypeScript
# ------------------------------------------------------------------------------
Write-Host "`n--- 4. Установка расширений для VS Code ---" -ForegroundColor Cyan

# Поиск исполняемого файла code
$codePath = (Get-Command code -ErrorAction SilentlyContinue).Source
if (-not $codePath) {
    # Стандартные пути установки VS Code
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
        "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd"
    )
    foreach ($p in $possiblePaths) {
        if (Test-Path $p) { $codePath = $p; break }
    }
}

if ($codePath) {
    $extensions = @(
        # Форматирование и линтинг
        "dbaeumer.vscode-eslint",            # ESLint
        "esbenp.prettier-vscode",            # Prettier (автоформатирование)
        "usernamehw.errorlens",              # Ошибки прямо в строках кода

        # React / HTML / CSS
        "dsznajder.es7-react-js-snippets",   # Сниппеты для React, Redux, TS
        "bradlc.vscode-tailwindcss",         # Автодополнение Tailwind CSS
        "formulahendry.auto-rename-tag",     # Автопереименование парных JSX/HTML тегов
        "formulahendry.auto-close-tag",      # Автозакрытие JSX тегов

        # TypeScript и удобство разработки
        "yoavbls.pretty-ts-errors",          # Читаемые ошибки TypeScript
        "christian-kohler.path-intellisense",# Автодополнение путей импорта
        "mikestead.dotenv",                  # Подсветка .env файлов

        # Git и совместная работа
        "eamodio.gitlens",                   # Интеграция с Git (история, авторы строк)

        # Тестирование API внутри редактора
        "rangav.vscode-thunder-client",      # Легковесный аналог Postman внутри VS Code

        # Оформление
        "PKief.material-icon-theme"          # Красивые иконки папок и файлов проекта
    )

    foreach ($ext in $extensions) {
        Write-Host "Установка расширения $ext..." -ForegroundColor Yellow
        & $codePath --install-extension $ext --force
    }
    Write-Host "[✓] Все расширения VS Code успешно установлены." -ForegroundColor Green
} else {
    Write-Warning "Команда 'code' пока недоступна в текущей сессии. Расширения можно установить после перезапуска."
}

# ------------------------------------------------------------------------------
# 5. Базовая настройка Git для Windows
# ------------------------------------------------------------------------------
Write-Host "`n--- 5. Базовая настройка Git ---" -ForegroundColor Cyan

# Автоматическое приведение переносов строк (важно для Windows, чтобы не конфликтовать с Linux/macOS в репозиториях)
git config --global core.autocrlf true

# Имя ветки по умолчанию - main
git config --global init.defaultBranch main

# Использование системного диспетчера учетных данных Windows (Windows Credential Manager)
git config --global credential.helper manager

Write-Host "[✓] Git настроен (autocrlf=true, defaultBranch=main, credential manager)." -ForegroundColor Green

# ------------------------------------------------------------------------------
# Завершение
# ------------------------------------------------------------------------------
Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host " Готово! Окружение для разработки на React настроено!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Рекомендуется перезагрузить компьютер или перезайти в систему," -ForegroundColor Yellow
Write-Host "чтобы все системные пути (PATH) и шрифты окончательно применились." -ForegroundColor Yellow
Write-Host "`nДля настройки имени и email в Git выполните:" -ForegroundColor Cyan
Write-Host 'git config --global user.name "Ваше Имя"'
Write-Host 'git config --global user.email "your.email@example.com"'
