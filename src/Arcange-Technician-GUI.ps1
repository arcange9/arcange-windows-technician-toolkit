#requires -version 5.1
[CmdletBinding()]
param()
$ErrorActionPreference='SilentlyContinue'
$Version='0.6'
$Name='Arcange Windows Technician Toolkit'
$Author='Mukamyi Izere Arcange'
$Root=Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$Engine=Join-Path $Root 'src\Arcange-Technician.ps1'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-SystemSnapshot {
  $os=Get-CimInstance Win32_OperatingSystem
  $cs=Get-CimInstance Win32_ComputerSystem
  $cpu=Get-CimInstance Win32_Processor | Select-Object -First 1
  $disks=@(Get-Disk)
  $volumes=@(Get-Volume | Where-Object Size -gt 0)
  $problem=@(Get-PnpDevice | Where-Object Status -ne 'OK')
  [pscustomobject]@{
    Manufacturer=$cs.Manufacturer
    Model=$cs.Model
    OS=$os.Caption
    Build=$os.BuildNumber
    CPU=$cpu.Name
    RAMGB=[math]::Round($cs.TotalPhysicalMemory/1GB,1)
    DiskCount=$disks.Count
    ProblemDevices=$problem.Count
    LowSpace=@($volumes | Where-Object { $_.Size -gt 0 -and ($_.SizeRemaining/$_.Size) -lt .10 }).Count
    Admin=([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  }
}
function Run-Engine([string]$Argument='') {
  if(Test-Path $Engine){
    if($Argument){ Start-Process powershell.exe -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',$Engine,$Argument -Wait }
    else { Start-Process powershell.exe -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',$Engine -Wait }
  } else { [System.Windows.Forms.MessageBox]::Show('Diagnostic engine not found.','Arcange Toolkit') }
}

$form=New-Object System.Windows.Forms.Form
$form.Text="$Name v$Version"
$form.Size=New-Object System.Drawing.Size(1050,760)
$form.StartPosition='CenterScreen'
$form.MinimumSize=New-Object System.Drawing.Size(900,660)
$form.BackColor=[System.Drawing.Color]::FromArgb(18,22,30)

$header=New-Object System.Windows.Forms.Panel
$header.Dock='Top';$header.Height=95;$header.BackColor=[System.Drawing.Color]::FromArgb(10,55,90)
$form.Controls.Add($header)
$title=New-Object System.Windows.Forms.Label
$title.Text="ARCANGE WINDOWS TECHNICIAN TOOLKIT  v$Version"
$title.ForeColor=[System.Drawing.Color]::White;$title.Font=New-Object System.Drawing.Font('Segoe UI',20,[System.Drawing.FontStyle]::Bold)
$title.Location=New-Object System.Drawing.Point(25,18);$title.AutoSize=$true;$header.Controls.Add($title)
$sub=New-Object System.Windows.Forms.Label
$sub.Text='Professional Windows diagnostics • HP • Dell • Lenovo • Acer • ASUS • MSI • Others'
$sub.ForeColor=[System.Drawing.Color]::Gainsboro;$sub.Font=New-Object System.Drawing.Font('Segoe UI',10)
$sub.Location=New-Object System.Drawing.Point(28,57);$sub.AutoSize=$true;$header.Controls.Add($sub)

$info=New-Object System.Windows.Forms.Label
$info.ForeColor=[System.Drawing.Color]::White;$info.Font=New-Object System.Drawing.Font('Segoe UI',11)
$info.Location=New-Object System.Drawing.Point(25,115);$info.Size=New-Object System.Drawing.Size(980,80)
$form.Controls.Add($info)

$actions=New-Object System.Windows.Forms.FlowLayoutPanel
$actions.Location=New-Object System.Drawing.Point(25,205);$actions.Size=New-Object System.Drawing.Size(1000,330);$actions.AutoScroll=$true
$actions.BackColor=[System.Drawing.Color]::FromArgb(24,29,39);$form.Controls.Add($actions)

function Add-Button($text,$tip,$handler){
  $b=New-Object System.Windows.Forms.Button
  $b.Text=$text;$b.Width=220;$b.Height=58;$b.Margin=New-Object System.Windows.Forms.Padding(10)
  $b.Font=New-Object System.Drawing.Font('Segoe UI',10,[System.Drawing.FontStyle]::Bold)
  $b.BackColor=[System.Drawing.Color]::FromArgb(30,90,140);$b.ForeColor=[System.Drawing.Color]::White
  $b.FlatStyle='Flat';$b.FlatAppearance.BorderSize=0
  $b.Add_Click($handler);$actions.Controls.Add($b)
}
Add-Button '🔎 Quick Scan' 'System + hardware snapshot' { $s=Get-SystemSnapshot; $info.Text="PC: $($s.Manufacturer) $($s.Model)`nOS: $($s.OS) (Build $($s.Build))`nCPU: $($s.CPU)`nRAM: $($s.RAMGB) GB   |   Problem devices: $($s.ProblemDevices)   |   Low-space volumes: $($s.LowSpace)   |   Admin: $($s.Admin)" }
Add-Button '🖥 System Info' 'Open detailed system diagnostics' { Run-Engine SystemInfo }
Add-Button '⚙ Hardware' 'CPU, RAM, GPU, USB and PnP' { Run-Engine Hardware }
Add-Button '🌐 Network Wizard' 'Guided connectivity diagnostics' { Run-Engine NetworkWizard }
Add-Button '💾 Storage' 'Disk and volume health' { Run-Engine Storage }
Add-Button '🔄 Windows Update' 'Update services and history' { Run-Engine WindowsUpdate }
Add-Button '🚗 Drivers' 'Driver and PnP diagnostics' { Run-Engine Drivers }
Add-Button '🛡 Security' 'Firewall and Defender status' { Run-Engine Security }
Add-Button '🧩 Error Analyzer' 'Analyze recent Windows errors' { Run-Engine ErrorAnalyzer }
Add-Button '📋 Generate Reports' 'TXT, JSON and HTML reports' { Run-Engine Report }
Add-Button '🔧 Repair Center' 'Open controlled repair actions' { Run-Engine Repair }
Add-Button '🧪 Hardware Tests' '20 hardware test tools' { Run-Engine HardwareSuite }
Add-Button '📡 Network Pro' '20 network diagnostics tools' { Run-Engine NetworkSuite }
Add-Button '🏥 Windows Health' '20 system health checks' { Run-Engine WindowsHealthSuite }
Add-Button '🧹 Cleanup Suite' '15 cleanup and speed tools' { Run-Engine CleanupSuite }
Add-Button '🔐 Security Suite' '10 security audit tools' { Run-Engine SecuritySuite }
Add-Button '🧰 Technician Tools' '15 workflow tools' { Run-Engine WorkflowSuite }
Add-Button '📁 Reports Folder' 'Open local reports' { $dir=Join-Path $Root 'reports';New-Item -ItemType Directory -Force -Path $dir|Out-Null;Start-Process explorer.exe $dir }

$footer=New-Object System.Windows.Forms.Label
$footer.Text='Workflow: Scan → Analyze → Explain → Recommend → Confirm → Repair → Verify → Report    |    Created by Mukamyi Izere Arcange'
$footer.ForeColor=[System.Drawing.Color]::Silver;$footer.Font=New-Object System.Drawing.Font('Segoe UI',9)
$footer.Location=New-Object System.Drawing.Point(25,670);$footer.AutoSize=$true;$form.Controls.Add($footer)

$form.Add_Shown({ $s=Get-SystemSnapshot; $info.Text="PC: $($s.Manufacturer) $($s.Model)`nOS: $($s.OS) (Build $($s.Build))`nCPU: $($s.CPU)`nRAM: $($s.RAMGB) GB   |   Problem devices: $($s.ProblemDevices)   |   Low-space volumes: $($s.LowSpace)   |   Admin: $($s.Admin)" })
[void]$form.ShowDialog()
