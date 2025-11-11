# 日志文件
$LogFile = "$env:USERPROFILE\Desktop\windows_runtime\git_proxy_log.txt"

function Log($msg) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value ("[$time] $msg")
}

# 示例使用
Log "脚本启动"

# PowerShell 5.1 compatible, no Chinese in source file

# Output encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Check BurntToast module
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    Log "BurntToast module not found, installing..."
    Install-Module -Name BurntToast -Force -Scope CurrentUser
}
Import-Module BurntToast

$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
$proxyEnable = "ProxyEnable"
$proxyServer = "ProxyServer"

$lastProxyEnable = $null
$lastProxyServer = $null

# Language: "en" or "zh"
$Lang = "en"

function Show-Toast {
    param(
        [string]$title,
        [string]$msg
    )
    New-BurntToastNotification -Text $title, $msg
}

function Sync-GitProxy {
    $enabled = (Get-ItemProperty -Path $regPath -Name $proxyEnable -ErrorAction SilentlyContinue).$proxyEnable
    $server  = (Get-ItemProperty -Path $regPath -Name $proxyServer -ErrorAction SilentlyContinue).$proxyServer

    if ($enabled -eq 1 -and $server) {
        if ($Lang -eq "zh") {
            $title = "System Proxy Enabled"
            $msg   = "Git global proxy set to $server"
        } else {
            $title = "System Proxy Enabled"
            $msg   = "Git global proxy set to $server"
        }
        Log ("{0}: {1}" -f $title, $server)
        git config --global http.proxy $server
        git config --global https.proxy $server
        Show-Toast -title $title -msg $msg
    } else {
        if ($Lang -eq "zh") {
            $title = "System Proxy Disabled"
            $msg   = "Git global proxy cleared"
        } else {
            $title = "System Proxy Disabled"
            $msg   = "Git global proxy cleared"
        }
        Log $title
        git config --global --unset http.proxy 2>$null
        git config --global --unset https.proxy 2>$null
        Show-Toast -title $title -msg $msg
    }
}

# Initial sync
Sync-GitProxy
$lastProxyEnable = (Get-ItemProperty -Path $regPath -Name $proxyEnable -ErrorAction SilentlyContinue).$proxyEnable
$lastProxyServer  = (Get-ItemProperty -Path $regPath -Name $proxyServer -ErrorAction SilentlyContinue).$proxyServer

Log ("[{0}] Monitoring system proxy changes (Press Ctrl+C to stop)..." -f (Get-Date -Format "HH:mm:ss"))

# Main loop
while ($true) {
    Start-Sleep -Seconds 2
    $currentEnable = (Get-ItemProperty -Path $regPath -Name $proxyEnable -ErrorAction SilentlyContinue).$proxyEnable
    $currentServer = (Get-ItemProperty -Path $regPath -Name $proxyServer -ErrorAction SilentlyContinue).$proxyServer

    if ($currentEnable -ne $lastProxyEnable -or $currentServer -ne $lastProxyServer) {
        Log ("[{0}] Proxy changed detected" -f (Get-Date -Format "HH:mm:ss"))
        Sync-GitProxy
        $lastProxyEnable = $currentEnable
        $lastProxyServer = $currentServer
    }
}
