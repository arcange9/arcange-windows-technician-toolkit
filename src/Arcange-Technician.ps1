#requires -version 5.1
[CmdletBinding()]
param([string]$Section='')
$ErrorActionPreference='SilentlyContinue'
$Version='0.6'
$Author='Mukamyi Izere Arcange'
$Name='Arcange Windows Technician Toolkit'
$Root=Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$ReportDir=Join-Path $Root 'reports'
New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
$SessionStamp=Get-Date -Format 'yyyyMMdd_HHmmss'
$CaseId='AWT-{0}' -f (Get-Date -Format 'yyyyMMdd-HHmmss')
$LogFile=Join-Path $ReportDir ("session_{0}.log" -f $SessionStamp)

function Log($m,$l='INFO'){Add-Content $LogFile ("{0} [{1}] [{2}] {3}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'),$CaseId,$l,$m)}
function Header{Clear-Host;Write-Host '';Write-Host '============================================================';Write-Host "       ARCANGE WINDOWS TECHNICIAN TOOLKIT v$Version";Write-Host '============================================================';Write-Host "Created by: $Author";Write-Host "Case ID: $CaseId";Write-Host "Manufacturer: $script:Manufacturer";Write-Host "Model: $script:Model";Write-Host 'Supported OS: Windows 10 and Windows 11';Write-Host '============================================================';Write-Host ''}
function Pause-Toolkit{Read-Host 'Press Enter to continue'|Out-Null}
function Confirm($text){$x=Read-Host "$text [Y/N]";return $x -match '^(Y|YES)$'}
function Supported{$o=Get-CimInstance Win32_OperatingSystem;return [bool]($o.Caption -match 'Windows 10|Windows 11')}
function Admin{$p=[Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent();return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)}
function Initialize-HardwareProfile{$c=Get-CimInstance Win32_ComputerSystem; if($c){$script:Manufacturer=if($c.Manufacturer){$c.Manufacturer.Trim()}else{'Unknown'};$script:Model=if($c.Model){$c.Model.Trim()}else{'Unknown'}}else{$script:Manufacturer='Unknown';$script:Model='Unknown'};if($script:Manufacturer -eq 'Microsoft Corporation' -and $script:Model -match 'Virtual|Virtual Machine'){$script:PlatformType='Virtual Machine'}else{$script:PlatformType='Physical PC'};$vp=Get-VendorProfile
  $script:Vendor=$vp.Vendor
  $script:VendorSite=$vp.Site
  $script:VendorNote=$vp.Note
  if($vp.Series){$script:Series=$vp.Series}
  Log "Detected vendor: $script:Manufacturer ($script:Vendor); model: $script:Model; platform: $script:PlatformType"}
function Get-VendorProfile{
  $m=[string]$script:Manufacturer
  $profiles=@(
    [pscustomobject]@{Match='hewlett|(^|[^a-z])hp([^\w]|$)|hp inc';Vendor='HP';Site='https://support.hp.com';Series=@('EliteBook','ProBook','ZBook','Spectre','Envy','Pavilion','Omen','OMEN','Victus','EliteDesk','ProDesk','EliteSlice');Note='HP Support Assistant, HP PC Hardware Diagnostics (F2 at boot)'}
    [pscustomobject]@{Match='dell|alienware';Vendor='Dell';Site='https://www.dell.com/support';Series=@('Latitude','Inspiron','OptiPlex','Precision','XPS','Vostro','Alienware','G15','G16','Dimension');Note='Dell SupportAssist, ePSA pre-boot diagnostics (F12)'}
    [pscustomobject]@{Match='lenovo|thinkpad|thinkcentre';Vendor='Lenovo';Site='https://support.lenovo.com';Series=@('ThinkPad','ThinkCentre','ThinkBook','IdeaPad','IdeaCentre','Yoga','Legion','LOQ','ThinkStation','Flex');Note='Lenovo Vantage, Lenovo Diagnostics (F10 on supported models)'}
    [pscustomobject]@{Match='acer|gateway|emachines|packard bell';Vendor='Acer Group';Site='https://www.acer.com/support';Series=@('Aspire','Swift','Spin','TravelMate','Predator','Nitro','Extensa','Veriton','ConceptD','Gateway','eMachines','Packard Bell');Note='Acer Care Center, Acer Quick Access'}
    [pscustomobject]@{Match='asus|asustek';Vendor='ASUS';Site='https://www.asus.com/support';Series=@('VivoBook','ZenBook','ExpertBook','ProArt','ROG','TUF','Chromebook','ProArt Studiobook','Zenbook');Note='MyASUS, ASUS Diagnostics'}
    [pscustomobject]@{Match='micro-star|msi';Vendor='MSI';Site='https://www.msi.com/support';Series=@('Katana','Raider','Titan','Stealth','Prestige','Modern','Cyborg','Vector','Crosshair','Curved');Note='MSI Center, MSI Diagnostic tools'}
    [pscustomobject]@{Match='microsoft|surface';Vendor='Microsoft Surface';Site='https://support.microsoft.com/surface';Series=@('Surface Pro','Surface Laptop','Surface Go','Surface Book','Surface Studio','Surface Duo');Note='Surface Diagnostic Toolkit, Windows Updatefirmware maintenance'}
    [pscustomobject]@{Match='samsung';Vendor='Samsung';Site='https://www.samsung.com/support';Series=@('Galaxy Book','Galaxy Book Pro','Galaxy Book Flex','Notebook','NP-');Note='Samsung Settings, Samsung Update'}
    [pscustomobject]@{Match='toshiba|dynabook';Vendor='Toshiba / Dynabook';Site='https://www.dynabook.com/support';Series=@('Satellite','Portege','Tecra','dynabook','Qosmio','KIRA');Note='Toshiba PC Health Monitor (older models)'}
    [pscustomobject]@{Match='fujitsu';Vendor='Fujitsu';Site='https://www.fujitsu.com/support';Series=@('LIFEBOOK','ESPRIMO','Stylistic','Celsius');Note='Fujitsu Diagnostic Tool, DeskUpdate'}
    [pscustomobject]@{Match='panasonic';Vendor='Panasonic';Site='https://panasonic.jp/toughbook';Series=@('Toughbook','Let','TOUGH');Note='Panasonic PC Settings, Toughbook Diagnostics'}
    [pscustomobject]@{Match='apple';Vendor='Apple (Windows on Mac)';Site='https://support.apple.com';Series=@('MacBook','iMac','Mac mini','Mac Pro','MacBook Air','MacBook Pro');Note='Boot Camp Software Update, Apple Diagnostics runs on macOS side'}
    [pscustomobject]@{Match='huawei';Vendor='HUAWEI';Site='https://consumer.huawei.com/support';Series=@('MateBook','MateBook D','MateBook X','MagicBook');Note='HUAWEI PC Manager'}
    [pscustomobject]@{Match='honor';Vendor='HONOR';Site='https://www.hihonor.com/support';Series=@('MagicBook','MagicBook Pro','Hunter');Note='HONOR PC Manager'}
    [pscustomobject]@{Match='xiaomi|redmi|timi|mitebook';Vendor='Xiaomi / Redmi';Site='https://www.mi.com/support';Series=@('Mi NoteBook','RedmiBook','MiBook','Xiaomi Book');Note='Xiaomi PC Manager (via Mi account)'}
    [pscustomobject]@{Match='lg electronics|lg(\s|$)';Vendor='LG';Site='https://www.lg.com/support';Series=@('Gram','UltraPC','Style');Note='LG Update Center, LG Smart Assistant'}
    [pscustomobject]@{Match='razer';Vendor='Razer';Site='https://support.razer.com';Series=@('Blade','Blade Stealth','Blade Pro','Book');Note='Razer Synapse, Razer Care'}
    [pscustomobject]@{Match='gigabyte';Vendor='GIGABYTE';Site='https://www.gigabyte.com/support';Series=@('AERO','AORUS','Gaming','G5','G6','G7');Note='GIGABYTE Control Center'}
    [pscustomobject]@{Match='vaio|sony';Vendor='VAIO / Sony';Site='https://support.vaio.com';Series=@('VAIO','SX','FE','FH','Pro');Note='VAIO Care, VAIO Update'}
    [pscustomobject]@{Match='medion';Vendor='Medion';Site='https://www.medion.com/support';Series=@('Akoya','Erazer','Lifetab');Note='Medion Service Center tools'}
    [pscustomobject]@{Match='clevo|tongfang|quanta|compal|pegatron|wistron| Inventec|system76|framework';Vendor='ODM / Custom-built (whitebook)';Site='https://www.google.com/search?q=PC+manufacturer+support';Series=@();Note='Generic Windows diagnostics; check seller/warranty documentation for vendor tools'}
  )
  $hit=$null
  foreach($p in $profiles){ if($m -match $p.Match){ $hit=$p; break } }
  if(-not $hit){ $hit=[pscustomobject]@{Match='';Vendor='Unknown (generic PC)';Site='https://www.google.com/search?q=PC+manufacturer+support';Series=@();Note='Generic Windows diagnostics work on every Windows 10/11 PC'} }
  $series=($hit.Series | Where-Object { $_ -and ($script:Model -match [regex]::Escape($_)) } | Select-Object -First 1)
  [pscustomobject]@{Vendor=$hit.Vendor;Site=$hit.Site;Series=$series;Note=$hit.Note}
}
function Show-VendorProfile{Header;Log "Viewed vendor profile ($($script:Vendor))";Write-Host '--- VENDOR SUPPORT PROFILE ---';Write-Host "Detected vendor : $script:Vendor";Write-Host "Manufacturer   : $script:Manufacturer";Write-Host "Model          : $script:Model";if($script:Series){Write-Host "Product series : $script:Series"};Write-Host "Support site   : $script:VendorSite";Write-Host "Vendor tools   : $script:VendorNote";Write-Host '';Write-Host 'Vendor-specific tools are OPTIONAL. All diagnostics in this';Write-Host 'toolkit use standard Windows APIs and work across vendors.';Pause-Toolkit}
function SystemInfo{Header;Log 'Viewed system information';$o=Get-CimInstance Win32_OperatingSystem;$c=Get-CimInstance Win32_ComputerSystem;$p=Get-CimInstance Win32_Processor|select -First 1;$b=Get-CimInstance Win32_BIOS|select -First 1;Write-Host "Computer : $env:COMPUTERNAME";Write-Host "User     : $env:USERNAME";Write-Host "Vendor   : $($c.Manufacturer)";Write-Host "Model    : $($c.Model)";Write-Host "Platform : $script:PlatformType";Write-Host "OS       : $($o.Caption)";Write-Host "Build    : $($o.BuildNumber)";Write-Host "CPU      : $($p.Name)";Write-Host "Cores    : $($p.NumberOfCores)";Write-Host "Threads  : $($p.NumberOfLogicalProcessors)";Write-Host ('RAM      : {0:N2} GB' -f ($c.TotalPhysicalMemory/1GB));Write-Host "BIOS     : $($b.Manufacturer) $($b.SMBIOSBIOSVersion)";Write-Host "Admin    : $(Admin)";Write-Host "Vendor   : $script:Vendor";if($script:Series){Write-Host "Series   : $script:Series"};Write-Host "Support  : $script:VendorSite";Pause-Toolkit}
function Hardware{Header;Log 'Ran hardware diagnostics';Write-Host '--- Problem Devices ---';$x=Get-PnpDevice|where Status -ne 'OK';if($x){$x|ft Status,Class,FriendlyName -AutoSize}else{Write-Host '[OK] No PnP devices currently report a problem.'};Write-Host "`n--- CPU ---";Get-CimInstance Win32_Processor|select Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed|ft -AutoSize;Write-Host "`n--- Memory ---";Get-CimInstance Win32_PhysicalMemory|select Manufacturer,PartNumber,@{N='CapacityGB';E={[math]::Round($_.Capacity/1GB,2)}},Speed|ft -AutoSize;Write-Host "`n--- GPU ---";Get-CimInstance Win32_VideoController|select Name,DriverVersion,Status|ft -AutoSize;Write-Host "`n--- USB ---";Get-PnpDevice -Class USB|select Status,FriendlyName,InstanceId|ft -AutoSize;Write-Host "`n--- Network Adapters ---";Get-NetAdapter|select Name,Status,LinkSpeed,InterfaceDescription|ft -AutoSize;Pause-Toolkit}
function Network{Header;Log 'Ran network diagnostics';Write-Host '--- Configuration ---';Get-NetIPConfiguration|select InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer|fl;Write-Host '--- Connectivity ---';foreach($t in '127.0.0.1','8.8.8.8'){if(Test-Connection $t -Count 2 -Quiet){Write-Host "[OK] $t reachable"}else{Write-Host "[FAIL] $t unreachable"}};Write-Host '--- DNS ---';try{Resolve-DnsName example.com -ErrorAction Stop|select -First 3 Name,Type,IPAddress|ft -AutoSize;Write-Host '[OK] DNS resolution works.'}catch{Write-Host '[FAIL] DNS resolution failed.'};Write-Host '--- HTTPS test ---';if(Test-NetConnection example.com -Port 443 -InformationLevel Quiet){Write-Host '[OK] HTTPS connection works.'}else{Write-Host '[FAIL] HTTPS connection failed.'};Write-Host '--- Route ---';route print;Pause-Toolkit}
function NetworkWizard{Header;Log 'Ran network troubleshooting wizard';$score=0;$checks=@();Write-Host 'NETWORK TROUBLESHOOTING WIZARD';Write-Host 'Running guided checks...`n';$adapters=Get-NetAdapter|where Status -eq 'Up';if($adapters){Write-Host '[OK] Network adapter is active.';$score++}else{Write-Host '[FAIL] No active network adapter found.';$checks+='Check Wi-Fi/Ethernet adapter and driver.'};$cfg=Get-NetIPConfiguration|where IPv4DefaultGateway;if($cfg){Write-Host '[OK] Default gateway detected.';$score++}else{Write-Host '[FAIL] No default gateway detected.';$checks+='Check DHCP/router connection.'};if(Test-Connection 8.8.8.8 -Count 2 -Quiet){Write-Host '[OK] Internet IP connectivity works.';$score++}else{Write-Host '[FAIL] Internet IP connectivity failed.';$checks+='Check router, ISP, or firewall.'};try{Resolve-DnsName example.com -ErrorAction Stop|Out-Null;Write-Host '[OK] DNS resolution works.';$score++}catch{Write-Host '[FAIL] DNS resolution failed.';$checks+='Check DNS settings or DNS server.'};if(Test-NetConnection example.com -Port 443 -InformationLevel Quiet){Write-Host '[OK] HTTPS connectivity works.';$score++}else{Write-Host '[FAIL] HTTPS connectivity failed.';$checks+='Check proxy, firewall, or HTTPS connectivity.'};Write-Host "`nScore: $score / 5";if($checks){Write-Host "`nRecommendations:";$checks|select -Unique|%{Write-Host " - $_"}}else{Write-Host '[GOOD] Basic network path looks healthy.'};Pause-Toolkit}
function WindowsHealth{Header;Log 'Ran Windows health diagnostics';Write-Host '--- SFC verification (read-only) ---';sfc /verifyonly;Write-Host '--- DISM CheckHealth ---';dism /Online /Cleanup-Image /CheckHealth;Write-Host '--- Recent System Errors ---';Get-WinEvent -FilterHashtable @{LogName='System';Level=1,2;StartTime=(Get-Date).AddDays(-3)} -MaxEvents 15|select TimeCreated,Id,ProviderName,LevelDisplayName,Message|fl;Write-Host '--- Services not running (selected automatic services) ---';Get-CimInstance Win32_Service|where {$_.StartMode -eq 'Auto' -and $_.State -ne 'Running'}|select Name,DisplayName,StartMode,State|ft -AutoSize;Pause-Toolkit}
function WindowsUpdate{Header;Log 'Ran Windows Update diagnostics';Write-Host '--- Windows Update Services ---';foreach($n in 'wuauserv','bits','cryptsvc','UsoSvc'){ $s=Get-Service $n; if($s){Write-Host ("{0}: {1} ({2})" -f $n,$s.Status,$s.StartType)}else{Write-Host "${n}: unavailable"}};Write-Host "`n--- Recent Update History ---";try{Get-HotFix|Sort-Object InstalledOn -Descending|select -First 10 HotFixID,InstalledOn,Description|ft -AutoSize}catch{Write-Host '[INFO] HotFix history unavailable.'};Write-Host "`n--- Update Cache ---";$cache=Join-Path $env:windir 'SoftwareDistribution';if(Test-Path $cache){$size=(Get-ChildItem $cache -Recurse -Force -ErrorAction SilentlyContinue|Measure-Object Length -Sum).Sum/1MB;Write-Host ('SoftwareDistribution size: {0:N1} MB' -f $size)};Write-Host "`nRecommendations:";Write-Host ' - If updates fail, record the error code before resetting services/cache.';Write-Host ' - Use Repair Center only with authorization.';Pause-Toolkit}
function Storage{Header;Log 'Ran storage diagnostics';Write-Host '--- Volumes ---';Get-Volume|select DriveLetter,FileSystem,HealthStatus,@{N='FreeGB';E={[math]::Round($_.SizeRemaining/1GB,2)}},@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}}|ft -AutoSize;Write-Host "`n--- Physical Disks ---";Get-PhysicalDisk|select FriendlyName,MediaType,HealthStatus,OperationalStatus,@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}}|ft -AutoSize;Write-Host "`n--- CHKDSK C: (read-only) ---";chkdsk C:;Pause-Toolkit}
function StorageAdvanced{Header;Log 'Ran advanced storage diagnostics';Write-Host '--- Disk Health ---';Get-Disk|select Number,FriendlyName,BusType,OperationalStatus,HealthStatus,@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}}|ft -AutoSize;Write-Host "`n--- Physical Disk Reliability (when supported) ---";try{Get-PhysicalDisk|Get-StorageReliabilityCounter|select DeviceId,Temperature,ReadErrorsTotal,WriteErrorsTotal,PowerOnHours,Wear|ft -AutoSize}catch{Write-Host '[INFO] Reliability counters are not available on this system.'};Write-Host "`n--- Volumes with low free space (<10%) ---";$low=Get-Volume|where {$_.Size -gt 0 -and ($_.SizeRemaining/$_.Size) -lt .10};if($low){$low|select DriveLetter,FileSystem,HealthStatus,@{N='FreeGB';E={[math]::Round($_.SizeRemaining/1GB,2)}},@{N='FreePercent';E={[math]::Round(($_.SizeRemaining/$_.Size)*100,1)}}|ft -AutoSize;Write-Host '[WARNING] Consider freeing space before major repairs.'}else{Write-Host '[OK] No volume is below 10% free space.'};Write-Host "`nNote: Storage health information depends on hardware and Windows support.";Pause-Toolkit}
function Drivers{Header;Log 'Ran driver diagnostics';Write-Host '--- Signed Driver Summary ---';driverquery /si;Write-Host "`n--- Problem Devices ---";Get-PnpDevice|where Status -ne 'OK'|select Status,Class,FriendlyName,InstanceId|ft -AutoSize;Write-Host "`n--- Driver Packages ---";pnputil /enum-drivers;Pause-Toolkit}
function Battery{Header;Log 'Ran battery diagnostics';$b=Get-CimInstance Win32_Battery;if($b){$b|select Name,BatteryStatus,EstimatedChargeRemaining,EstimatedRunTime|ft -AutoSize;Write-Host 'Generating Windows battery report...';$f=Join-Path $ReportDir ("battery_{0}.html" -f (Get-Date -Format 'yyyyMMdd_HHmmss'));powercfg /batteryreport /output $f|Out-Null;Write-Host "[OK] $f"}else{Write-Host '[INFO] No battery detected. This may be a desktop PC.'};Pause-Toolkit}
function Security{Header;Log 'Viewed security status';Write-Host '--- Firewall ---';Get-NetFirewallProfile|select Name,Enabled,DefaultInboundAction,DefaultOutboundAction|ft -AutoSize;Write-Host '--- Microsoft Defender ---';if(Get-Command Get-MpComputerStatus){Get-MpComputerStatus|select AMServiceEnabled,AntivirusEnabled,RealTimeProtectionEnabled,AntispywareEnabled,AntivirusSignatureVersion|ft -AutoSize}else{Write-Host '[INFO] Defender cmdlets unavailable.'};Pause-Toolkit}
function ErrorAnalyzer{Header;Log 'Ran Windows error analyzer';Write-Host 'WINDOWS ERROR ANALYZER';$events=Get-WinEvent -FilterHashtable @{LogName='System';Level=1,2;StartTime=(Get-Date).AddDays(-3)} -MaxEvents 20;if(-not $events){Write-Host '[OK] No critical/error System events found in the last 3 days.';Pause-Toolkit;return};$groups=$events|Group-Object Id|Sort-Object Count -Descending;foreach($g in $groups){$e=$g.Group|Select-Object -First 1;Write-Host "`nID $($g.Name) — $($g.Count) occurrence(s) — $($e.ProviderName)";Write-Host "Message: $($e.Message -replace '\s+',' ')";switch([int]$g.Name){41{Write-Host 'Possible cause: unexpected shutdown or power/hardware event.';Write-Host 'Recommended action: check power, thermal conditions, and recent hardware/driver changes.'}7{Write-Host 'Possible cause: storage/controller event.';Write-Host 'Recommended action: run storage diagnostics and back up important data.'}1001{Write-Host 'Possible cause: Windows Error Reporting event.';Write-Host 'Recommended action: inspect the related application/system event and recent changes.'}default{Write-Host 'Recommended action: review the event provider/message and correlate with the time of the problem.'}}};Pause-Toolkit}
function Repair{Header;Write-Host 'REPAIR CENTER - system changes require authorization.';if(-not(Admin)){Write-Host '[WARNING] Administrator privileges are recommended for repairs.'};Write-Host '1 Flush DNS';Write-Host '2 Renew DHCP';Write-Host '3 Reset Winsock';Write-Host '4 Reset TCP/IP';Write-Host '5 DISM RestoreHealth';Write-Host '6 SFC Scan';Write-Host '7 Restart Windows Explorer';Write-Host '8 Restart Windows Update services';Write-Host '9 Reset Windows Update cache';Write-Host '0 Back';$c=Read-Host 'Choose';switch($c){'1'{if(Confirm 'Flush DNS cache?'){ipconfig /flushdns;Log 'Flushed DNS'}}'2'{if(Confirm 'Release and renew DHCP?'){ipconfig /release;ipconfig /renew;Log 'Renewed DHCP'}}'3'{if(Confirm 'Reset Winsock? A restart may be required.'){netsh winsock reset;Log 'Reset Winsock'}}'4'{if(Confirm 'Reset TCP/IP? A restart may be required.'){netsh int ip reset;Log 'Reset TCP/IP'}}'5'{if(Confirm 'Run DISM RestoreHealth? This can take time.'){dism /Online /Cleanup-Image /RestoreHealth;Log 'Ran DISM RestoreHealth'}}'6'{if(Confirm 'Run SFC /scannow?'){sfc /scannow;Log 'Ran SFC scan'}}'7'{if(Confirm 'Restart Windows Explorer?'){Stop-Process -Name explorer -Force;Start-Process explorer.exe;Log 'Restarted Explorer'}}'8'{if(Confirm 'Restart Windows Update services?'){foreach($n in 'wuauserv','bits','cryptsvc','UsoSvc'){Restart-Service $n -Force};Log 'Restarted Windows Update services'}}'9'{if(-not(Admin)){Write-Host '[WARNING] Run the toolkit as Administrator for this action.'}elseif(Confirm 'Reset Windows Update cache? This renames the SoftwareDistribution folder.'){Stop-Service wuauserv,bits,cryptsvc -Force;Rename-Item (Join-Path $env:windir 'SoftwareDistribution') ("SoftwareDistribution.old_{0}" -f (Get-Date -Format 'yyyyMMddHHmmss'));Start-Service cryptsvc,bits,wuauserv;Log 'Reset Windows Update cache'}}};Pause-Toolkit}
function GetReportData{$o=Get-CimInstance Win32_OperatingSystem;$c=Get-CimInstance Win32_ComputerSystem;$p=Get-CimInstance Win32_Processor|select -First 1;[ordered]@{Toolkit=$Name;Version=$Version;CaseId=$CaseId;CreatedBy=$Author;Generated=(Get-Date);Computer=$env:COMPUTERNAME;User=$env:USERNAME;Administrator=(Admin);Manufacturer=$c.Manufacturer;Model=$c.Model;PlatformType=$script:PlatformType;Vendor=$script:Vendor;VendorSite=$script:VendorSite;OS=$o.Caption;Build=$o.BuildNumber;CPU=$p.Name;RAMGB=[math]::Round($c.TotalPhysicalMemory/1GB,2);Disks=@(Get-Disk|select Number,FriendlyName,BusType,HealthStatus,OperationalStatus,@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}});Volumes=@(Get-Volume|select DriveLetter,FileSystem,HealthStatus,@{N='FreeGB';E={[math]::Round($_.SizeRemaining/1GB,2)}},@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}});ProblemDevices=@(Get-PnpDevice|where Status -ne 'OK'|select Status,Class,FriendlyName);Network=@(Get-NetIPConfiguration|select InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer)}}
function Report{Header;$d=GetReportData;$stamp=Get-Date -Format 'yyyyMMdd_HHmmss';$txt=Join-Path $ReportDir ("diagnostic_{0}.txt" -f $stamp);$json=Join-Path $ReportDir ("diagnostic_{0}.json" -f $stamp);$html=Join-Path $ReportDir ("diagnostic_{0}.html" -f $stamp);$summary=if($d.ProblemDevices.Count -gt 0){'WARNING - problem devices detected'}else{'GOOD - no PnP problem devices detected'};@("$Name v$Version","Case ID: $CaseId","Created by: $Author","Generated: $($d.Generated)","Computer: $($d.Computer)","Vendor: $($d.Manufacturer)","Model: $($d.Model)","Platform: $($d.PlatformType)","User: $($d.User)","Administrator: $($d.Administrator)","Health summary: $summary",'','=== OS ===',(Get-CimInstance Win32_OperatingSystem|select Caption,Version,BuildNumber,OSArchitecture,LastBootUpTime|fl|Out-String),'=== COMPUTER ===',(Get-CimInstance Win32_ComputerSystem|select Manufacturer,Model,SystemType,TotalPhysicalMemory|fl|Out-String),'=== CPU ===',(Get-CimInstance Win32_Processor|select Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed|fl|Out-String),'=== DISKS ===',($d.Disks|ft -AutoSize|Out-String),'=== VOLUMES ===',($d.Volumes|ft -AutoSize|Out-String),'=== NETWORK ===',($d.Network|fl|Out-String),'=== PROBLEM DEVICES ===',($d.ProblemDevices|ft -AutoSize|Out-String))|Set-Content $txt -Encoding UTF8;$d|ConvertTo-Json -Depth 6|Set-Content $json -Encoding UTF8;$body=($d|ConvertTo-Html -Title "$Name v$Version - $CaseId" -PreContent "<h1>$Name v$Version</h1><p><b>Case ID:</b> $CaseId</p><p><b>Vendor:</b> $($d.Manufacturer)</p><p><b>Model:</b> $($d.Model)</p><p><b>Platform:</b> $($d.PlatformType)</p><p><b>Health summary:</b> $summary</p>" -PostContent '<p>Generated locally by Arcange Windows Technician Toolkit.</p>');$body|Set-Content $html -Encoding UTF8;Log "Generated reports: $txt, $json, $html";Write-Host "[OK] TXT report:  $txt";Write-Host "[OK] JSON report: $json";Write-Host "[OK] HTML report: $html";Write-Host "Health summary: $summary";Pause-Toolkit}
function Main{Initialize-HardwareProfile;if(-not(Supported)){Header;Write-Host '[UNSUPPORTED OS] Windows 10 and Windows 11 only.';Pause-Toolkit;return};if($Section){Log "Section shortcut requested: $Section";switch($Section){'SystemInfo'{SystemInfo}'Hardware'{Hardware}'Network'{Network}'NetworkWizard'{NetworkWizard}'WindowsHealth'{WindowsHealth}'WindowsUpdate'{WindowsUpdate}'Storage'{Storage}'StorageAdvanced'{StorageAdvanced}'Drivers'{Drivers}'Battery'{Battery}'Security'{Security}'ErrorAnalyzer'{ErrorAnalyzer}'Repair'{Repair}'Report'{Report}'VendorProfile'{Show-VendorProfile}'HardwareSuite'{HardwareSuite}'NetworkSuite'{NetworkSuite}'WindowsHealthSuite'{WindowsHealthSuite}'CleanupSuite'{CleanupSuite}'SecuritySuite'{SecuritySuite}'WorkflowSuite'{WorkflowSuite}default{Header;Write-Host "[INFO] Unknown section '$Section' - opening full menu.";Pause-Toolkit;}};return};Log "Toolkit started on $env:COMPUTERNAME ($script:Manufacturer $script:Model)";while($true){Header;Write-Host ' 1. System Information';Write-Host ' 2. Hardware Diagnostics';Write-Host ' 3. Network Diagnostics';Write-Host ' 4. Network Troubleshooting Wizard';Write-Host ' 5. Windows Health Diagnostics';Write-Host ' 6. Windows Update Diagnostics';Write-Host ' 7. Storage Diagnostics';Write-Host ' 8. Advanced Storage Diagnostics';Write-Host ' 9. Driver Diagnostics';Write-Host '10. Battery Diagnostics';Write-Host '11. Security Status';Write-Host '12. Windows Error Analyzer';Write-Host '13. Repair Center';Write-Host '14. Generate Full Diagnostic Reports';Write-Host '15. Open Reports Folder';Write-Host '16. Vendor Support Profile';Write-Host '17. Hardware Test Suite (20 tools)';Write-Host '18. Network Pro Suite (20 tools)';Write-Host '19. Windows Health Suite (20 tools)';Write-Host '20. Cleanup and Speed Suite (15 tools)';Write-Host '21. Security Suite (10 tools)';Write-Host '22. Technician Workflow Suite (15 tools)';Write-Host ' 0. Exit';Write-Host '';Write-Host "Administrator: $(Admin)";$c=Read-Host 'Select an option';switch($c){'1'{SystemInfo}'2'{Hardware}'3'{Network}'4'{NetworkWizard}'5'{WindowsHealth}'6'{WindowsUpdate}'7'{Storage}'8'{StorageAdvanced}'9'{Drivers}'10'{Battery}'11'{Security}'12'{ErrorAnalyzer}'13'{Repair}'14'{Report}'15'{Start-Process explorer.exe $ReportDir}'16'{Show-VendorProfile}'17'{HardwareSuite}'18'{NetworkSuite}'19'{WindowsHealthSuite}'20'{CleanupSuite}'21'{SecuritySuite}'22'{WorkflowSuite}'0'{Header;Write-Host '============================================================';Write-Host '          THANK YOU FOR USING THIS SERVICE';Write-Host '============================================================';Write-Host "$Name v$Version";Write-Host "Case ID: $CaseId";Write-Host "Vendor: $script:Manufacturer";Write-Host "Model: $script:Model";Write-Host '';Write-Host 'Thank you for using this service!';Write-Host 'Please keep your reports for future troubleshooting.';Log 'Toolkit session ended';return}default{Write-Host '[!] Invalid option.';Start-Sleep 1}}}}

# ===== v0.6 infrastructure =====
function Speak($t){ if($script:Voice){ try{ Add-Type -AssemblyName System.Speech; $s=New-Object System.Speech.Synthesis.SpeechSynthesizer; $s.Speak($t); $s.Dispose() }catch{} } }
function Require-AdminOrWarn($action){ if(-not(Admin)){ Write-Host "[WARNING] Administrator rights recommended for: $action"; return $false }; return $true }
$script:Voice=$false

function HardwareSuite{
 while($true){
  Header; Write-Host '--- HARDWARE TEST SUITE ---'; Write-Host ''
  Write-Host ' 1. CPU stress test (30s load + temperature)'
  Write-Host ' 2. RAM test (Windows Memory Diagnostic + past results)'
  Write-Host ' 3. Disk speed benchmark (read/write MB/s)'
  Write-Host ' 4. Full SMART dump with plain-English meanings'
  Write-Host ' 5. Battery wear report (design vs current capacity)'
  Write-Host ' 6. Screen dead-pixel test (full-color patterns)'
  Write-Host ' 7. Keyboard tester (visual key press)'
  Write-Host ' 8. Webcam diagnostic (device + privacy settings)'
  Write-Host ' 9. Speaker + microphone test (audio tones)'
  Write-Host '10. USB port speed detection'
  Write-Host '11. Thermal report (temperatures + thermal events)'
  Write-Host '12. GPU check (info, VRAM, driver)'
  Write-Host '13. Display resolution and refresh rate audit'
  Write-Host '14. Touchscreen check'
  Write-Host '15. Bluetooth scan and radio status'
  Write-Host '16. BIOS/UEFI version and firmware check'
  Write-Host '17. CPU temperature snapshot'
  Write-Host '18. Motherboard and chipset report'
  Write-Host '19. Power event analysis (unexpected shutdowns)'
  Write-Host '20. Printer and scanner diagnostics'
  Write-Host ' 0. Back to main menu'
  $c=Read-Host 'Choose'
  switch($c){
   '1'{Invoke-CpuStressTest}'2'{Invoke-RamTest}'3'{Invoke-DiskBenchmark}'4'{Invoke-SmartDump}'5'{Invoke-BatteryWear}'6'{Invoke-DeadPixelTest}'7'{Invoke-KeyboardTest}'8'{Invoke-WebcamTest}'9'{Invoke-AudioTest}'10'{Invoke-UsbSpeed}'11'{Invoke-ThermalReport}'12'{Invoke-GpuCheck}'13'{Invoke-DisplayAudit}'14'{Invoke-TouchscreenTest}'15'{Invoke-BluetoothTest}'16'{Invoke-BiosReport}'17'{Invoke-CpuTempSnapshot}'18'{Invoke-MotherboardReport}'19'{Invoke-PowerEventAnalysis}'20'{Invoke-PrinterScan}
   '0'{return} default{Write-Host '[!] Invalid option.'; Start-Sleep 1}
  }
 }
}

function Invoke-CpuStressTest{Header;Log 'Ran CPU stress test';Write-Host 'CPU STRESS TEST - 30 seconds of controlled load';Write-Host 'NOTE: This is a diagnostic load, not a substitute for Prime95.';$cores=[Environment]::ProcessorCount;Write-Host "Logical cores: $cores";Write-Host 'Starting load... (close other apps first)';$sw=[Diagnostics.Stopwatch]::StartNew();$jobs=@();1..$cores|ForEach-Object{$jobs+=Start-Job -ScriptBlock {$end=(Get-Date).AddSeconds(30);$x=1;while((Get-Date) -lt $end){$x=$x*3+1}}};$t0=Invoke-CpuTempSnapshot -Quiet;while($sw.Elapsed.TotalSeconds -lt 30){Start-Sleep 5;Write-Host ("  {0:N0}s elapsed" -f $sw.Elapsed.TotalSeconds)};$jobs|Stop-Job;$jobs|Remove-Job;$sw.Stop();$t1=Invoke-CpuTempSnapshot -Quiet;Write-Host 'Load finished.';Write-Host 'Temperature before/after:';Write-Host "  Before: $($t0 -join ', ')";Write-Host "  After : $($t1 -join ', ')";if((Admin)){Write-Host 'Interpretation: a jump of more than 25C under load suggests cooling problems (dust, fan, paste).'}else{Write-Host 'Run as Administrator for thermal sensor access.'};Log 'CPU stress test completed';Pause-Toolkit}

function Invoke-RamTest{Header;Log 'Ran RAM test';Write-Host 'RAM TEST - Windows Memory Diagnostic';$ram=[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1);Write-Host "Installed RAM: $ram GB";Write-Host '';Write-Host '--- Past Memory Diagnostic results ---';$ev=Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-MemoryDiagnostics-Results/Operational'} -MaxEvents 5 -ErrorAction SilentlyContinue;if($ev){foreach($e in $ev){Write-Host "$($e.TimeCreated): $($e.Message -replace '\s+',' ')"}}else{Write-Host '[INFO] No previous results - test has not run on this PC.'};Write-Host '';if(Confirm 'Launch Windows Memory Diagnostic now? (PC will RESTART to run the test)'){Log 'Scheduled Windows Memory Diagnostic';mdsched.exe}else{Write-Host 'Skipped. To run later: mdsched.exe'};Pause-Toolkit}

function Invoke-DiskBenchmark{Header;Log 'Ran disk benchmark';Write-Host 'DISK SPEED BENCHMARK';$drive='C:';$d2=Read-Host 'Drive letter to test (default C:)';if($d2 -and ($d2 -match '^[A-Za-z]:?$')){if($d2.Length -eq 1){$drive="$($d2):"}else{$drive=$d2}};if(-not(Test-Path $drive)){Write-Host "[ERROR] Drive $drive not found";Pause-Toolkit;return};$testFile=Join-Path $drive "awt_bench_$([guid]::NewGuid().ToString('N')).tmp";Write-Host "Testing $drive ...";$data=New-Object 'byte[]' (25MB);(New-Object Random).NextBytes($data);$sw=[Diagnostics.Stopwatch]::StartNew();[IO.File]::WriteAllBytes($testFile,$data);$sw.Stop();$writeMBs=[math]::Round(25/($sw.Elapsed.TotalSeconds),1);Write-Host ("  Sequential write : {0:N1} MB/s" -f $writeMBs);$sw.Reset();$sw.Start();$null=[IO.File]::ReadAllBytes($testFile);$sw.Stop();$readMBs=[math]::Round(25/($sw.Elapsed.TotalSeconds),1);Write-Host ("  Sequential read  : {0:N1} MB/s" -f $readMBs);Remove-Item $testFile -Force -ErrorAction SilentlyContinue;$grade=if($readMBs -ge 500){'Excellent (NVMe-class)'}elseif($readMBs -ge 150){'Good (SATA SSD)'}elseif($readMBs -ge 80){'Average (HDD/SATA)'}else{'Slow - HDD or problem'};Write-Host "  Verdict: $grade";Log "Disk benchmark $drive write=$writeMBs MB/s read=$readMBs MB/s";Pause-Toolkit}

function Invoke-SmartDump{Header;Log 'Ran SMART dump';Write-Host 'SMART / DISK RELIABILITY DUMP';$disks=@(Get-PhysicalDisk -ErrorAction SilentlyContinue);if(-not $disks){Write-Host '[INFO] Get-PhysicalDisk unavailable - showing basic disk info.';Get-Disk|ft Number,FriendlyName,HealthStatus -AutoSize;Pause-Toolkit;return};foreach($d in $disks){Write-Host '';Write-Host "DISK: $($d.FriendlyName) [$([math]::Round($d.Size/1GB,1)) GB]";Write-Host "  Health status   : $($d.HealthStatus)";Write-Host "  Media type      : $($d.MediaType)";$rc=$d|Get-StorageReliabilityCounter -ErrorAction SilentlyContinue;if($rc){if($rc.Temperature){$c=[math]::Round(($rc.Temperature-273.15),1);$f=[math]::Round(($rc.Temperature*9/5)-459.67,0);Write-Host "  Temperature     : $c C ($f F)";if($c -gt 55){Write-Host '  [WARNING] Disk runs HOT - check airflow/cooling.'}else{Write-Host '  [OK] Temperature in normal range.'}};if($rc.ReadErrorsTotal -ne $null){Write-Host "  Read errors     : $($rc.ReadErrorsTotal)  Write errors: $($rc.WriteErrorsTotal)";if([long]$rc.ReadErrorsTotal -gt 100 -or [long]$rc.WriteErrorsTotal -gt 100){Write-Host '  [WARNING] Many I/O errors - BACK UP DATA and run CHKDSK.'}else{Write-Host '  [OK] Error counts low.'}};if($rc.Wear -ne $null){Write-Host "  SSD wear used   : $($rc.Wear) % (100% = end of life)"};if($rc.PowerOnHours -ne $null){$y=[math]::Round($rc.PowerOnHours/8760,1);Write-Host "  Power-on hours  : $($rc.PowerOnHours) (about $y years)"}}else{Write-Host '  [INFO] Reliability counters not supported by this disk.'}};Write-Host '';Write-Host 'Remember: counters depend on hardware support.';Pause-Toolkit}

function Invoke-BatteryWear{Header;Log 'Ran battery wear report';Write-Host 'BATTERY WEAR REPORT';$b=Get-CimInstance Win32_Battery;if(-not $b){Write-Host '[INFO] No battery - likely a desktop PC.';Pause-Toolkit;return};Write-Host "Battery       : $($b.Name)";Write-Host "Current charge: $($b.EstimatedChargeRemaining) %";$report=Join-Path $ReportDir ("battery_{0}.html" -f (Get-Date -Format 'yyyyMMdd_HHmmss'));if(Require-AdminOrWarn 'battery report generation'){powercfg /batteryreport /output $report|Out-Null;if(Test-Path $report){$html=Get-Content $report -Raw;$design=[regex]::Match($html,'DESIGN CAPACITY\D*([\d,]+)');$full=[regex]::Match($html,'FULL CHARGE CAPACITY\D*([\d,]+)');if($design.Success -and $full.Success){$dc=[double]$design.Groups[1].Value -replace ',','';$fc=[double]$full.Groups[1].Value -replace ',','';$health=[math]::Round(($fc/$dc)*100,1);Write-Host '';Write-Host ("  Design capacity : {0:N0} mWh" -f $dc);Write-Host ("  Current capacity: {0:N0} mWh" -f $fc);Write-Host ("  Battery health  : {0:N1} %" -f $health);if($health -lt 50){Write-Host '  [WARNING] Battery badly worn - recommend replacement.'}elseif($health -lt 75){Write-Host '  [CAUTION] Noticeable wear - plan replacement soon.'}else{Write-Host '  [OK] Battery health good.'}};Write-Host '';Write-Host "Full report: $report"}else{Write-Host '[INFO] Could not generate report (needs admin).'}}else{Write-Host '[INFO] Run as Administrator for the full wear analysis.'};Pause-Toolkit}

function Invoke-DeadPixelTest{Header;Log 'Ran dead pixel test';Write-Host 'DEAD PIXEL TEST - full-screen colors will cycle.';Write-Host 'Press SPACE for next color, ESC to exit.';Pause-Toolkit|Out-Null;Add-Type -AssemblyName System.Windows.Forms;Add-Type -AssemblyName System.Drawing;$colors=@([Drawing.Color]::White,[Drawing.Color]::Black,[Drawing.Color]::Red,[Drawing.Color]::Green,[Drawing.Color]::Blue,[Drawing.Color]::Yellow,[Drawing.Color]::Cyan,[Drawing.Color]::Magenta);$i=0;$f=New-Object Windows.Forms.Form;$f.FormBorderStyle='None';$f.WindowState='Maximized';$f.TopMost=$true;$f.BackColor=$colors[0];$l=New-Object Windows.Forms.Label;$l.Dock='Fill';$l.ForeColor=[Drawing.Color]::Gray;$l.Text='SPACE = next color   |   ESC = exit';$l.TextAlign='MiddleCenter';$f.Controls.Add($l);$f.KeyPreview=$true;$f.Add_KeyDown({param($s,$e) if($e.KeyCode -eq 'Escape'){$f.Close()}elseif($e.KeyCode -eq 'Space'){$script:i=($script:i+1)%$colors.Count;$f.BackColor=$colors[$script:i]}});$f.Add_Click({$script:i=($script:i+1)%$colors.Count;$f.BackColor=$colors[$script:i]});[void]$f.ShowDialog();$f.Dispose();Write-Host 'Pixel test finished. Note any spots that stayed dark/lit on all colors.';Pause-Toolkit}

function Invoke-KeyboardTest{Header;Log 'Ran keyboard test';Write-Host 'KEYBOARD TEST - press keys, they will light up.';Write-Host 'ESC to exit.';Pause-Toolkit|Out-Null;Add-Type -AssemblyName System.Windows.Forms;$f=New-Object Windows.Forms.Form;$f.Text='Arcange Keyboard Test';$f.Size=New-Object Drawing.Size(700,420);$f.StartPosition='CenterScreen';$f.BackColor=[Drawing.Color]::FromArgb(18,22,30);$l=New-Object Windows.Forms.Label;$l.Dock='Fill';$l.Font=New-Object Drawing.Font('Consolas',13);$l.ForeColor=[Drawing.Color]::White;$l.Text="Press keys to test. Keys will appear here.`r`n`r`nESC = exit`r`n";$f.Controls.Add($l);$f.KeyPreview=$true;$seen=@{};$f.Add_KeyDown({param($s,$e) if($e.KeyCode -eq 'Escape'){$f.Close()}else{$k=$e.KeyCode; if($script:seen[$k]){$script:seen[$k]++}else{$script:seen[$k]=1};$l.Text="Key: $k   x$($script:seen[$k])`r`n`r`n$((($script:seen.Keys | ForEach-Object { \"$_\" }) -join '  '))`r`n`r`nESC = exit"}});[void]$f.ShowDialog();$f.Dispose();$count=($seen.Keys).Count;Write-Host "Distinct keys tested: $count";Pause-Toolkit}

function Invoke-WebcamTest{Header;Log 'Ran webcam diagnostic';Write-Host 'WEBCAM DIAGNOSTIC';$cams=@(Get-PnpDevice -Class Camera -ErrorAction SilentlyContinue);if(-not $cams){$cams=@(Get-PnpDevice -ErrorAction SilentlyContinue|Where-Object{$_.FriendlyName -match 'camera|webcam'})};if($cams){foreach($c in $cams){Write-Host "Camera device : $($c.FriendlyName)";Write-Host "  Status: $($c.Status)  Problem: $($c.ProblemDescription)"}}else{Write-Host '[INFO] No camera device detected.'};Write-Host '';Write-Host '--- Privacy settings ---';$reg='HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy';$la=Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam' -ErrorAction SilentlyContinue;if($la){Write-Host "  System webcam access: $($la.Value)";if($la.Value -eq 'Deny'){Write-Host '  [WARNING] Webcam blocked system-wide in Privacy settings.'}else{Write-Host '  [OK] System allows webcam use.'}};Write-Host '';Write-Host 'Tip: test the picture itself with the Windows Camera app.';Pause-Toolkit}

function Invoke-AudioTest{Header;Log 'Ran audio test';Write-Host 'AUDIO TEST - tones will play on the default speaker.';$dev=@(Get-PnpDevice -Class AudioEndpoint -ErrorAction SilentlyContinue|Where-Object Status -eq 'OK');if($dev){Write-Host "Active audio endpoints: $($dev.Count)"}else{Write-Host '[INFO] No active audio endpoint found - check speakers/headphones.'};Write-Host '';if(Confirm 'Play test tones now?'){Add-Type -AssemblyName System.Media;$freqs=@(440,1000,2000);foreach($f in $freqs){Write-Host "  Playing $f Hz tone...";[console]::Beep($f,500);Start-Sleep -Milliseconds 200};Write-Host '[OK] Tones played. If you heard nothing: check volume, output device.'};$mic=@(Get-PnpDevice -Class AudioEndpoint -ErrorAction SilentlyContinue|Where-Object{$_.FriendlyName -match 'Microphone|Micro'});if($mic){$m=Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone' -ErrorAction SilentlyContinue;if($m -and $m.Value -eq 'Deny'){Write-Host '[WARNING] Microphone blocked in Privacy settings.'}else{Write-Host '[OK] Microphone endpoint present and allowed.'}}else{Write-Host '[INFO] No microphone endpoint found.'};Pause-Toolkit}

function Invoke-UsbSpeed{Header;Log 'Ran USB speed detection';Write-Host 'USB PORT / DEVICE SPEED';$usbDisks=@(Get-Disk -ErrorAction SilentlyContinue|Where-Object BusType -eq 'USB');if($usbDisks){foreach($d in $usbDisks){Write-Host "USB disk: $($d.FriendlyName) [$([math]::Round($d.Size/1GB,1)) GB]"}}else{Write-Host 'No USB storage disks found.'};Write-Host '';Write-Host '--- All USB devices ---';Get-PnpDevice -Class USB -ErrorAction SilentlyContinue|select Status,FriendlyName|ft -AutoSize;Write-Host 'Note: exact negotiated speed (2.0=480 Mbps, 3.x=5-20 Gbps) requires a blue/black port and a matching cable.';Pause-Toolkit}

function Invoke-ThermalReport{Header;Log 'Ran thermal report';Write-Host 'THERMAL REPORT';Invoke-CpuTempSnapshot;Write-Host '';Write-Host '--- Thermal events (last 14 days) ---';$ev=Get-WinEvent -FilterHashtable @{LogName='System';ProviderName='Microsoft-Windows-Kernel-Power','Microsoft-Windows-Kernel-Thermal'} -MaxEvents 500 -ErrorAction SilentlyContinue|Where-Object{$_.Message -match 'thermal|temperature'};if($ev){$ev|select TimeCreated,Id,Message -First 5|fl;Write-Host "[INFO] $($ev.Count) thermal-related events found - review above."}else{Write-Host '[OK] No thermal events in the System log.'};Pause-Toolkit}

function Invoke-GpuCheck{Header;Log 'Ran GPU check';Write-Host 'GPU CHECK';$g=Get-CimInstance Win32_VideoController;foreach($v in $g){Write-Host '';Write-Host "GPU        : $($v.Name)";Write-Host "Driver     : $($v.DriverVersion) ($($v.DriverDate))";$ram=$v.AdapterRAM;if($ram){$gb=[math]::Round($ram/1GB,1);Write-Host "VRAM       : $gb GB"}else{Write-Host 'VRAM       : (not reported - common on laptops with shared memory)'};Write-Host "Resolution : $($v.CurrentHorizontalResolution)x$($v.CurrentVerticalResolution) @ $($v.CurrentRefreshRate) Hz";Write-Host "Status     : $($v.Status)"};Write-Host '';Write-Host 'Tips: screen artifacts = driver/GPU check first; game crashes = check temps + clean dust.';Pause-Toolkit}

function Invoke-DisplayAudit{Header;Log 'Ran display audit';Write-Host 'DISPLAY AUDIT';Add-Type -AssemblyName System.Windows.Forms;$screens=[Windows.Forms.Screen]::AllScreens;$i=1;foreach($s in $screens){$b=$s.Bounds;Write-Host '';Write-Host "Monitor $i : $((($s.DeviceName -replace '\\\\\.\\DISPLAY','DISPLAY')) -replace '\\','')  Primary: $($s.Primary)";Write-Host "  Resolution: $($b.Width)x$($b.Height)";$i++};Write-Host '';Write-Host '--- GPU-reported modes ---';Get-CimInstance Win32_VideoController|select Name,CurrentHorizontalResolution,CurrentVerticalResolution,CurrentRefreshRate|ft -AutoSize;Write-Host 'Note: if resolution is below native, update graphics drivers and check scaling settings.';Pause-Toolkit}

function Invoke-TouchscreenTest{Header;Log 'Ran touchscreen check';Write-Host 'TOUCHSCREEN CHECK';$t=@(Get-PnpDevice -ErrorAction SilentlyContinue|Where-Object{$_.Class -match 'HID' -and $_.FriendlyName -match 'touch'});if($t){foreach($d in $t){Write-Host "Touch device : $($d.FriendlyName)";Write-Host "  Status: $($d.Status)"}}else{Write-Host '[INFO] No touch device found - this PC may not have a touchscreen.'};Write-Host '';Write-Host 'Quick test: in Windows Search type "calibrate" and run "Calibrate the screen for pen or touch input".';Pause-Toolkit}

function Invoke-BluetoothTest{Header;Log 'Ran Bluetooth test';Write-Host 'BLUETOOTH STATUS';$bt=@(Get-PnpDevice -ErrorAction SilentlyContinue|Where-Object{$_.Class -match 'Bluetooth' -or $_.FriendlyName -match 'bluetooth'});if($bt){foreach($d in $bt){Write-Host "Radio/device: $($d.FriendlyName)  [$($d.Status)]"}}else{Write-Host '[INFO] No Bluetooth hardware found (or disabled in BIOS).'};Write-Host '';$svc=Get-Service bthserv -ErrorAction SilentlyContinue;if($svc){Write-Host "Bluetooth Support Service: $($svc.Status)"};Write-Host '';Write-Host 'Paired devices:';$paired=@(Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue|Where-Object Status -eq 'OK');if($paired){$paired|select -First 10 FriendlyName,Status|ft -AutoSize}else{Write-Host '(no paired devices connected)'};Pause-Toolkit}

function Invoke-BiosReport{Header;Log 'Ran BIOS report';Write-Host 'BIOS / UEFI REPORT';$b=Get-CimInstance Win32_BIOS;$s=$env:firmware_type;Write-Host "Vendor        : $($b.Manufacturer)";Write-Host "Version       : $($b.SMBIOSBIOSVersion)";Write-Host "Release date  : $($b.ReleaseDate)";Write-Host "Serial        : $($b.SerialNumber)";Write-Host "Firmware mode : $s";if($s -eq 'UEFI'){try{$sb=Confirm-SecureBootUEFI -ErrorAction Stop;Write-Host "Secure Boot   : $sb"}catch{Write-Host 'Secure Boot   : (unknown - run as admin)'}}else{Write-Host 'Secure Boot   : N/A (Legacy BIOS mode)';Write-Host '[WARNING] Legacy BIOS mode - modern Windows features (Secure Boot, fast boot) unavailable.'};Write-Host '';Write-Host "Vendor firmware updates: $script:VendorSite";Write-Host 'WARNING: only flash BIOS from official vendor site with AC power connected.';Pause-Toolkit}

function Invoke-CpuTempSnapshot{Header;Log 'Ran CPU temperature snapshot';Invoke-CpuTempSnapshot -Quiet;Pause-Toolkit}
function Invoke-CpuTempSnapshot([switch]$Quiet){ if(-not $Quiet){Header;Log 'CPU temp snapshot'}; $t=Get-CimInstance -Namespace 'root/wmi' -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction SilentlyContinue; if($t){ $list=@(); foreach($z in $t){ $c=[math]::Round(($z.CurrentTemperature/10)-273.15,1); $list+="$($z.InstanceName): $c C"; if(-not $Quiet){Write-Host "Thermal zone $($z.InstanceName): $c C"; if($c -gt 85){Write-Host '[DANGER] Critical temperature!'}elseif($c -gt 70){Write-Host '[WARNING] Running hot at idle - check fans/dust.'}else{Write-Host '[OK] Temperature normal.'}}}; return $list } else { if(-not $Quiet){Write-Host '[INFO] Thermal sensors not exposed (common on consumer laptops without admin rights).'}; return @('unavailable') } }

function Invoke-MotherboardReport{Header;Log 'Ran motherboard report';Write-Host 'MOTHERBOARD REPORT';$mb=Get-CimInstance Win32_BaseBoard;$bb=Get-CimInstance Win32_BIOS;$cs=Get-CimInstance Win32_ComputerSystem;Write-Host "Board        : $($mb.Manufacturer) $($mb.Product)";Write-Host "Board version: $($mb.Version)";Write-Host "Serial        : $($mb.SerialNumber)";Write-Host "System family : $($cs.SystemFamily)";Write-Host '';Write-Host '--- RAM slots in use ---';Get-CimInstance Win32_PhysicalMemory|select BankLabel,@{N='GB';E={[math]::Round($_.Capacity/1GB,0)}},Speed,Manufacturer|ft -AutoSize;Write-Host '';Write-Host '--- Chipset bridge ---';Get-CimInstance Win32_PCIIDelegate -ErrorAction SilentlyContinue|select -First 1 Name|ft -AutoSize;Get-CimInstance Win32_PnPEntity -ErrorAction SilentlyContinue|Where-Object{$_.Name -match 'Host Bridge|PCI Express Root'}|select -First 5 Name|ft -AutoSize;Pause-Toolkit}

function Invoke-PowerEventAnalysis{Header;Log 'Ran power event analysis';Write-Host 'POWER EVENT ANALYSIS (last 30 days)';$start=(Get-Date).AddDays(-30);$ev=Get-WinEvent -FilterHashtable @{LogName='System';Id=41,6008;StartTime=$start} -ErrorAction SilentlyContinue;if($ev){$c41=@($ev|Where-Object Id -eq 41).Count;$c6008=@($ev|Where-Object Id -eq 6008).Count;Write-Host "Kernel-Power 41 (unexpected loss of power): $c41 time(s)";Write-EventLogHint $ev}else{Write-Host '[OK] No unexpected shutdown events in the last 30 days.'};Write-Host '';$ok=Get-WinEvent -FilterHashtable @{LogName='System';Id=1074,6006;StartTime=$start} -MaxEvents 10 -ErrorAction SilentlyContinue;if($ok){Write-Host 'Last planned shutdowns/restarts:';$ok|select TimeCreated,@{N='Reason';E={($_.Message -replace '\s+',' ').Substring(0,[Math]::Min(100,$_.Message.Length))}}|ft -AutoSize};Pause-Toolkit}
function Write-EventLogHint($ev){Write-Host '';Write-Host 'Interpretation:';Write-Host ' - Event 41: PC lost power without clean shutdown (power cut, hard hang, dead PSU, forced off)';Write-Host ' - Event 6008: previous shutdown was unexpected (crash or power loss)';if(@($ev).Count -gt 5){Write-Host '[WARNING] Frequent unexpected shutdowns - investigate PSU, battery, overheating.'}}

function Invoke-PrinterScan{Header;Log 'Ran printer scan';Write-Host 'PRINTER AND SCANNER DIAGNOSTICS';Write-Host '--- Installed printers ---';$p=Get-Printer -ErrorAction SilentlyContinue;if($p){$p|select Name,DriverName,PortName,PrinterStatus|ft -AutoSize}else{Write-Host '[INFO] No printers installed.'};Write-Host '--- Printing services ---';foreach($n in 'Spooler','PrintNotify'){ $s=Get-Service $n -ErrorAction SilentlyContinue; if($s){Write-Host "$($s.Name): $($s.Status)"} };Write-Host '--- Scanner devices ---';$sc=@(Get-PnpDevice -ErrorAction SilentlyContinue|Where-Object{$_.Class -eq 'Image' -or $_.FriendlyName -match 'scanner|Scanner'});if($sc){$sc|select Status,FriendlyName|ft -AutoSize}else{Write-Host '[INFO] No scanner devices found.'};Write-Host '';Write-Host 'Tip: Windows Scan app (scan) and Print test page (printer Properties) verify end-to-end.';Pause-Toolkit}


function NetworkSuite{
 while($true){
  Header; Write-Host '--- NETWORK PRO SUITE ---'; Write-Host ''
  Write-Host ' 1. Internet speed test (download/latency)'
  Write-Host ' 2. Wi-Fi signal + channel congestion analysis'
  Write-Host ' 3. Local network device scanner'
  Write-Host ' 4. Port scanner'
  Write-Host ' 5. DNS benchmark (Google vs Cloudflare vs Quad9 vs ISP)'
  Write-Host ' 6. Packet loss test (60 seconds)'
  Write-Host ' 7. Public IP + ISP + geolocation'
  Write-Host ' 8. VPN detection and status'
  Write-Host ' 9. Firewall + open port audit'
  Write-Host '10. Router/gateway identification'
  Write-Host '11. Network adapter driver check'
  Write-Host '12. MAC randomization (privacy) check'
  Write-Host '13. DNS leak test'
  Write-Host '14. Hosts file integrity check'
  Write-Host '15. Proxy configuration audit'
  Write-Host '16. Ethernet vs Wi-Fi comparison'
  Write-Host '17. Saved Wi-Fi network history'
  Write-Host '18. Saved Wi-Fi password recovery (admin)'
  Write-Host '19. Latency test to popular services'
  Write-Host '20. Network settings backup + reset'
  Write-Host ' 0. Back to main menu'
  $c=Read-Host 'Choose'
  switch($c){
   '1'{Invoke-SpeedTest}'2'{Invoke-WifiAnalysis}'3'{Invoke-NetworkScanner}'4'{Invoke-PortScanner}'5'{Invoke-DnsBenchmark}'6'{Invoke-PacketLossTest}'7'{Invoke-PublicIpInfo}'8'{Invoke-VpnCheck}'9'{Invoke-FirewallAudit}'10'{Invoke-GatewayDetect}'11'{Invoke-NicDriverCheck}'12'{Invoke-MacRandomization}'13'{Invoke-DnsLeakTest}'14'{Invoke-HostsFileCheck}'15'{Invoke-ProxyAudit}'16'{Invoke-EthWifiCompare}'17'{Invoke-WifiHistory}'18'{Invoke-WifiPasswordRecovery}'19'{Invoke-LatencyTest}'20'{Invoke-NetworkBackupReset}
   '0'{return} default{Write-Host '[!] Invalid option.'; Start-Sleep 1}
  }
 }
}

function Invoke-SpeedTest{
 Header; Log 'Ran internet speed test'
 Write-Host 'INTERNET SPEED TEST'
 try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
 $old=$ProgressPreference; $ProgressPreference='SilentlyContinue'
 Write-Host 'Testing download speed (25 MB from Cloudflare)...'
 $sw=[Diagnostics.Stopwatch]::StartNew()
 $tmp=Join-Path $env:TEMP ("awt_speed_{0}.bin" -f [guid]::NewGuid().ToString('N'))
 Invoke-WebRequest -Uri 'https://speed.cloudflare.com/__down?bytes=25000000' -OutFile $tmp -TimeoutSec 60 -ErrorAction Stop | Out-Null
 $sw.Stop()
 $mbps=[math]::Round((25*8)/($sw.Elapsed.TotalSeconds),1)
 Remove-Item $tmp -Force -ErrorAction SilentlyContinue
 Write-Host ("  Download: {0:N1} Mbps" -f $mbps)
 Write-Host 'Testing latency (10 pings to 1.1.1.1)...'
 $times=@()
 1..10 | ForEach-Object {
   $t=(Test-Connection 1.1.1.1 -Count 1 -ErrorAction SilentlyContinue)
   if($t){ $times+=$t.ResponseTime }
 }
 if($times){
   $avg=[math]::Round(($times|Measure-Object -Average).Average,1)
   $j=[math]::Round((($times|Measure-Object -Maximum).Maximum-($times|Measure-Object -Minimum).Minimum),1)
   Write-Host ("  Latency : {0:N1} ms average (jitter {1:N1} ms)" -f $avg,$j)
 }
 if($mbps -ge 100){ Write-Host '  Verdict: Excellent connection' }
 elseif($mbps -ge 25){ Write-Host '  Verdict: Good - fine for streaming, calls, work' }
 elseif($mbps -ge 10){ Write-Host '  Verdict: OK - usable but slow for heavy use' }
 else{ Write-Host '  Verdict: SLOW - check Wi-Fi signal or ISP plan' }
 Log "Speed test: ${mbps} Mbps download"
 $ProgressPreference=$old
 Pause-Toolkit
}

function Invoke-WifiAnalysis{
 Header; Log 'Ran Wi-Fi analysis'
 Write-Host 'WI-FI SIGNAL AND CHANNEL ANALYSIS'
 $out = netsh wlan show networks mode=bssid 2>$null
 $script:ProgressText=$out
 $ssids=@()
 $current = @{}
 for($i=0; $i -lt $out.Count; $i++){
   $line=$out[$i]
   if($line -match '^SSID \d+ : (.*)'){ $name=$Matches[1].Trim(); if($name -eq ''){ $name='(hidden network)' } }
   if($line -match '^\s+BSSID 1\s+: (.*)'){ $bssid=$Matches[1].Trim() }
   if($line -match 'Signal\s+: (\d+)%'){ $signal=[int]$Matches[1]; $ssids += [pscustomobject]@{Name=$name; Signal=$signal; Bssid=$bssid} }
   if($line -match 'Channel\s+: (\d+)'){ if($ssids.Count -gt 0){ $ssids[-1] | Add-Member -NotePropertyName Channel -NotePropertyValue ([int]$Matches[1]) -Force } }
 }
 if($ssids.Count -eq 0){
   Write-Host '[INFO] No Wi-Fi networks visible. You may be on Ethernet, or Wi-Fi is off.'
 } else {
   Write-Host ("Networks in range: {0}" -f $ssids.Count)
   $ssids | Sort-Object Signal -Descending | Select-Object -First 15 Name,Signal,Channel | ft -AutoSize
   $ch = $ssids | Group-Object Channel | Sort-Object Count -Descending | Select-Object -First 3
   Write-Host 'Most congested channels:'
   foreach($g in $ch){ Write-Host ("  Channel {0}: {1} network(s)" -f $g.Name,$g.Count) }
   $best = $ssids | Sort-Object Signal -Descending | Select-Object -First 1
   if($best.Signal -ge 80){ Write-Host '[OK] Strong signal on your network.' }
   elseif($best.Signal -ge 60){ Write-Host '[CAUTION] Moderate signal - expect occasional drops.' }
   else{ Write-Host '[WARNING] Weak signal - move closer to router or use 5 GHz.' }
   $cong = $ssids | Where-Object { $_.Channel -ge 1 -and $_.Channel -le 11 }
   if(($ssids | Where-Object Channel -ge 12).Count -gt 0){ Write-Host 'TIP: 5 GHz networks detected (channel 12+) - less crowded band.' }
 }
 Pause-Toolkit
}

function Invoke-NetworkScanner{
 Header; Log 'Ran local network scanner'
 Write-Host 'LOCAL NETWORK SCANNER'
 $ipconf = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway }
 if(-not $ipconf){ Write-Host '[ERROR] No gateway - not on a local network.'; Pause-Toolkit; return }
 $gw = ($ipconf.IPv4DefaultGateway.NextHop)
 $myip = ($ipconf.IPv4Address.IPAddress)
 $prefix = $myip.Substring(0, $myip.LastIndexOf('.'))
 Write-Host "Your IP: $myip   Gateway: $gw"
 Write-Host "Scanning $($prefix).1 - $($prefix).254 (this takes up to a minute)..."
 $found = New-Object System.Collections.ArrayList
 1..254 | ForEach-Object {
   $target = "$prefix.$_"
   $r = Test-Connection $target -Count 1 -Quiet -ErrorAction SilentlyContinue
   if($r){ [void]$found.Add($target) }
 }
 Write-Host ("Found {0} active device(s):" -f $found.Count)
 arp -a | Select-String "dynamic" | ForEach-Object {
   $parts = ($_ -replace '\s+',' ').Trim().Split(' ')
   Write-Host ("  {0}  {1}" -f $parts[0], $parts[1])
 }
 Write-Host 'TIP: identify devices by MAC prefix (e.g. 3C:5A:B0=Huawei, 9C:8E:CD=TP-Link).'
 Pause-Toolkit
}

function Invoke-PortScanner{
 Header; Log 'Ran port scanner'
 Write-Host 'PORT SCANNER - scan your own devices only'
 $host2 = Read-Host 'Target IP or hostname (e.g. 192.168.1.1)'
 if(-not $host2){ Write-Host 'No target given.'; Pause-Toolkit; return }
 $ports = Read-Host 'Ports (default: 22,80,443,3389,445,8080)'
 if(-not $ports){ $ports='22,80,443,3389,445,8080' }
 $list = $ports.Split(',').ForEach({ $_.Trim() }) | Where-Object { $_ -match '^\d+$' }
 Write-Host "Scanning $($list.Count) ports on $host2 ..."
 $open = @()
 foreach($p in $list){
   $tcp = New-Object Net.Sockets.TcpClient
   $task = $tcp.ConnectAsync($host2, [int]$p)
   if($task.Wait(700) -and $tcp.Connected){ $open+=$p; Write-Host "  [OPEN]   port $p" }
   else{ Write-Host "  closed   port $p" }
   $tcp.Close()
 }
 if($open.Count -eq 0){ Write-Host 'All scanned ports closed.' }
 else{ Write-Host ''; Write-Host "$($open.Count) open port(s). Open ports = services running (80=web, 3389=RDP, 445=sharing)." }
 Pause-Toolkit
}

function Invoke-DnsBenchmark{
 Header; Log 'Ran DNS benchmark'
 Write-Host 'DNS BENCHMARK (5 lookups each)'
 $servers = @(
   @{Name='Current/ISP'; Dns=$null},
   @{Name='Cloudflare 1.1.1.1'; Dns='1.1.1.1'},
   @{Name='Google 8.8.8.8'; Dns='8.8.8.8'},
   @{Name='Quad9 9.9.9.9'; Dns='9.9.9.9'}
 )
 $domains = @('example.com','wikipedia.org','github.com','microsoft.com','cloudflare.com')
 $results = @()
 foreach($s in $servers){
   $times = @()
   foreach($d in $domains){
     $sw = [Diagnostics.Stopwatch]::StartNew()
     if($s.Dns){ $null = Resolve-DnsName $d -Server $s.Dns -QuickTypeTimeout 2000 -ErrorAction SilentlyContinue }
     else{ $null = Resolve-DnsName $d -ErrorAction SilentlyContinue }
     $sw.Stop()
     $times += $sw.Elapsed.TotalMilliseconds
   }
   $avg = [math]::Round(($times | Measure-Object -Average).Average,1)
   $results += [pscustomobject]@{Server=$s.Name; AvgMs=$avg}
   Write-Host ("  {0,-22} {1,8:N1} ms average" -f $s.Name, $avg)
 }
 $fastest = $results | Sort-Object AvgMs | Select-Object -First 1
 Write-Host ''
 Write-Host "Fastest: $($fastest.Server)"
 Write-Host 'TIP: set DNS in adapter settings; 1.1.1.1 is fast + privacy-friendly.'
 Pause-Toolkit
}

function Invoke-PacketLossTest{
 Header; Log 'Ran packet loss test'
 $target = Read-Host 'Target (default 8.8.8.8)'
 if(-not $target){ $target='8.8.8.8' }
 Write-Host "PINGING $target for 60 seconds (1 packet/second)..."
 $ok=0; $fail=0; $times=@()
 1..60 | ForEach-Object {
   $r = Test-Connection $target -Count 1 -ErrorAction SilentlyContinue
   if($r){ $ok++; $times += $r.ResponseTime; Write-Host -NoNewline '.' }
   else{ $fail++; Write-Host -NoNewline 'x' }
 }
 Write-Host ''
 $loss = [math]::Round(($fail/60)*100,1)
 Write-Host ("Sent 60 | OK {0} | Lost {1} | Loss {2}%" -f $ok,$fail,$loss)
 if($times){ Write-Host ("Latency: avg {0:N1} ms" -f (($times|Measure-Object -Average).Average)) }
 if($loss -eq 0){ Write-Host '[OK] Perfect - zero loss.' }
 elseif($loss -lt 2){ Write-Host '[OK] Minor loss - normal on Wi-Fi.' }
 else{ Write-Host '[WARNING] Significant loss - check cable/Wi-Fi, then report to ISP.' }
 Log "Packet loss test: $loss% loss"
 Pause-Toolkit
}

function Invoke-PublicIpInfo{
 Header; Log 'Ran public IP info'
 Write-Host 'PUBLIC IP + ISP + LOCATION'
 try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
 try {
   $info = Invoke-RestMethod -Uri 'https://ipinfo.io/json' -TimeoutSec 15
   Write-Host "IP       : $($info.ip)"
   Write-Host "City      : $($info.city)"
   Write-Host "Region   : $($info.region)"
   Write-Host "Country  : $($info.country)"
   Write-Host "ISP/Org  : $($info.org)"
   Write-Host "Timezone : $($info.timezone)"
 } catch {
   Write-Host '[INFO] Could not reach ipinfo.io - offline or blocked.'
   Write-Host 'Fallback: checking ipify...'
   try { $ip = Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 15; Write-Host "IP: $ip" } catch { Write-Host '[INFO] No internet access available.' }
 }
 Pause-Toolkit
}

function Invoke-VpnCheck{
 Header; Log 'Ran VPN check'
 Write-Host 'VPN DETECTION'
 $adapters = Get-NetAdapter -IncludeHidden -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceDescription -match 'VPN|TAP|TUN|WireGuard|OpenVPN|Cisco|Pulse|GlobalProtect|Fortinet|ZTNA' }
 if($adapters){
   Write-Host '[VPN FOUND] VPN adapters detected:'
   $adapters | select Name,InterfaceDescription,Status | ft -AutoSize
   $up = $adapters | Where-Object Status -eq 'Up'
   if($up){ Write-Host 'VPN appears CONNECTED right now.' } else { Write-Host 'VPN software present but not connected.' }
 } else { Write-Host '[OK] No VPN adapters detected.' }
 $ras = Get-Service 'RasMan' -ErrorAction SilentlyContinue
 if($ras -and $ras.Status -eq 'Running'){ Write-Host 'Note: Remote Access service is running (used by some VPN clients).' }
 Pause-Toolkit
}

function Invoke-FirewallAudit{
 Header; Log 'Ran firewall audit'
 Write-Host 'FIREWALL + OPEN PORT AUDIT'
 Write-Host '--- Firewall profiles ---'
 Get-NetFirewallProfile -ErrorAction SilentlyContinue | select Name,Enabled,DefaultInboundAction,DefaultOutboundAction | ft -AutoSize
 $off = Get-NetFirewallProfile -ErrorAction SilentlyContinue | Where-Object { -not $_.Enabled }
 if($off){ Write-Host '[WARNING] Firewall DISABLED for: '$($off.Name -join ', ')' - re-enable immediately.' } else { Write-Host '[OK] All firewall profiles enabled.' }
 Write-Host '--- Listening ports (services waiting for connections) ---'
 $lp = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalAddress -ne '::1' -and $_.LocalAddress -ne '127.0.0.1' }
 if($lp){
   $lp | select LocalAddress,LocalPort,@{N='Process';E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}} | Sort-Object LocalPort -Unique | ft -AutoSize
   $rdp = $lp | Where-Object LocalPort -eq 3389
   if($rdp){ Write-Host '[WARNING] RDP (3389) is listening - make sure it is only reachable from trusted networks.' }
   $smb = $lp | Where-Object LocalPort -eq 445
   if($smb){ Write-Host '[INFO] File sharing (445) is active.' }
 } else { Write-Host '[OK] No externally listening TCP ports.' }
 Write-Host '--- Allow rules count ---'
 $allow = @(Get-NetFirewallRule -Enabled True -Direction Inbound -Action Allow -ErrorAction SilentlyContinue)
 Write-Host "Inbound allow rules: $($allow.Count)"
 Pause-Toolkit
}

function Invoke-GatewayDetect{
 Header; Log 'Ran gateway identification'
 Write-Host 'ROUTER / GATEWAY IDENTIFICATION'
 $ipconf = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway }
 if(-not $ipconf){ Write-Host '[INFO] No gateway found.'; Pause-Toolkit; return }
 $gw = $ipconf.IPv4DefaultGateway.NextHop
 Write-Host "Gateway IP: $gw"
 $null = Test-Connection $gw -Count 2 -ErrorAction SilentlyContinue
 $mac = (arp -a | Select-String $gw)
 if($mac){ Write-Host "ARP entry: $($mac -replace '\s+',' ')" }
 $gwDesc = $ipconf.IPv4DefaultGateway.InterfaceAlias
 Write-Host "Via interface: $gwDesc"
 Write-Host ''
 Write-Host 'TIP: open the admin page by typing the gateway IP in a browser (try admin/admin).'
 Write-Host '     Common brands: 192.168.1.1 or 192.168.8.1 (Huawei), 192.168.0.1 (TP-Link/D-Link).'
 Pause-Toolkit
}

function Invoke-NicDriverCheck{
 Header; Log 'Ran NIC driver check'
 Write-Host 'NETWORK ADAPTER DRIVER CHECK'
 $nics = Get-NetAdapter -ErrorAction SilentlyContinue
 $cut = (Get-Date).AddYears(-3)
 $old = @()
 foreach($n in $nics){
   $driver = Get-NetAdapter $n.Name -ErrorAction SilentlyContinue | Select-Object DriverVersion,DriverDate
   $date = $null
   try { $date = Get-NetAdapterAdvancedProperty -Name $n.Name -ErrorAction SilentlyContinue | Out-Null; $d = Get-CimInstance Win32_PnPEntity -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $n.InterfaceDescription } | Select-Object -First 1 } catch {}
   Write-Host ("{0,-22} {1,-12} {2}" -f $n.Name, $n.Status, $n.InterfaceDescription)
   if($d -and $d.ConfigManagerErrorCode -ne 0){ Write-Host '  [WARNING] Device reports a problem code.' }
 }
 Write-Host ''
 Write-Host 'Driver version/date details:'
 Get-CimInstance Win32_PnPEntity -ErrorAction SilentlyContinue | Where-Object { $_.PNPClass -eq 'Net' } | select Name,ConfigManagerErrorCode | ft -AutoSize
 Write-Host "Vendor drivers: $script:VendorSite"
 Pause-Toolkit
}

function Invoke-MacRandomization{
 Header; Log 'Ran MAC randomization check'
 Write-Host 'MAC RANDOMIZATION (PRIVACY) CHECK'
 $val = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Security' -Name 'RandomizeHardwareIDTelemetry' -ErrorAction SilentlyContinue
 $wifiProfiles = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\WlanSvc\Interfaces\*' -ErrorAction SilentlyContinue
 $regs = @()
 $keys = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}' -ErrorAction SilentlyContinue
 $found = $false
 foreach($k in $keys){
   $p = Get-ItemProperty $k.PSPath -ErrorAction SilentlyContinue
   if($p.PSObject.Properties.Name -contains 'RandomMacHash'){ $found = $true }
 }
 Write-Host 'Windows 10 (1607+): Wi-Fi MAC randomization is set per-network:'
 Write-Host '  Settings > Network & Internet > Wi-Fi > Manage known networks > Properties > Random hardware addresses'
 Write-Host 'Windows 11: Settings > Network & Internet > Wi-Fi > Random hardware addresses: On/On per-network'
 if($found){ Write-Host '[OK] Some adapters have randomization registry data present.' } else { Write-Host '[INFO] Could not read adapter randomization state from registry (varies by driver).' }
 Write-Host 'Why it matters: fixed MAC lets networks track your device across visits.'
 Pause-Toolkit
}

function Invoke-DnsLeakTest{
 Header; Log 'Ran DNS leak test'
 Write-Host 'DNS LEAK TEST'
 try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
 Write-Host '--- DNS servers this PC uses ---'
 $dns = (Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses }) | ForEach-Object { Write-Host "  $($_.InterfaceAlias): $($_.ServerAddresses -join ', ')" }
 Write-Host ''
 try {
   $info = Invoke-RestMethod -Uri 'https://ipinfo.io/json' -TimeoutSec 15
   Write-Host "Your public IP is in: $($info.city), $($info.country) (ISP: $($info.org))"
   $isLocalDns = ($dns -match '^(192\.168|10\.|172\.(1[6-9]|2|3[01]))')
   if($isLocalDns){
     Write-Host 'Your DNS goes through your router/ISP first.'
     Write-Host 'VPN users: if the VPN is ON but DNS still resolves via ISP servers, you have a DNS LEAK.'
   }
   Write-Host ''
   Write-Host 'Full leak check: visit https://dnsleaktest.com and run the extended test.'
 } catch { Write-Host '[INFO] Online check unavailable - review the DNS servers above manually.' }
 Pause-Toolkit
}

function Invoke-HostsFileCheck{
 Header; Log 'Ran hosts file check'
 Write-Host 'HOSTS FILE INTEGRITY CHECK'
 $hosts = Join-Path $env:windir 'System32\drivers\etc\hosts'
 $entries = Get-Content $hosts -ErrorAction SilentlyContinue | Where-Object { $_ -and ($_ -notmatch '^\s*#') }
 $total = @($entries).Count
 if($total -eq 0){
   Write-Host '[OK] Hosts file is clean (no custom entries).'
 } else {
   Write-Host "Custom entries found: $total"
   $entries | ForEach-Object { Write-Host "  $_" }
   $suspicious = $entries | Where-Object { $_ -match '(facebook|google|bank|login|paypal|whatsapp|instagram|microso?ft-online|licensing)' }
   if($suspicious){
     Write-Host ''
     Write-Host '[WARNING] Suspicious entries! Redirecting popular/banking sites can mean:'
     Write-Host '  - ad-blocking (probably intentional)'
     Write-Host '  - MALWARE redirecting you to fake banking/login pages'
     if(Confirm 'Back up and clean the hosts file now?'){
       Copy-Item $hosts "$hosts.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
       $clean = Get-Content $hosts | Where-Object { $_ -match '^\s*#' -or $_ -match '^\s*$' }
       Set-Content $hosts $clean -Encoding ASCII
       Write-Host '[OK] Cleaned. Backup saved next to it. Restart browser.'
       Log 'Cleaned suspicious hosts file (backup created)'
     }
   } else { Write-Host 'Entries look like normal blocking/custom rules.' }
 }
 Pause-Toolkit
}

function Invoke-ProxyAudit{
 Header; Log 'Ran proxy audit'
 Write-Host 'PROXY CONFIGURATION AUDIT'
 $r = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue
 Write-Host "Proxy enable : $($r.ProxyEnable)"
 if($r.ProxyEnable){
   Write-Host "Proxy server  : $($r.ProxyServer)"
   Write-Host "Proxy override: $($r.ProxyOverride)"
 }
 if($r.AutoConfigURL){ Write-Host "PAC script    : $($r.AutoConfigURL)" }
 Write-Host ''
 $envProxy = "HTTP_PROXY=$env:HTTP_PROXY HTTPS_PROXY=$env:HTTPS_PROXY"
 Write-Host "Environment proxies: $envProxy"
 Write-Host ''
 Write-Host 'TIP: unexpected proxy entries are a classic malware trick to intercept browsing.'
 Write-Host '     If you did not set this proxy, disable it (Internet Options > Connections > LAN settings).'
 Pause-Toolkit
}

function Invoke-EthWifiCompare{
 Header; Log 'Ran Ethernet vs Wi-Fi comparison'
 Write-Host 'ETHERNET vs WI-FI COMPARISON'
 $adapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object Status -eq 'Up'
 $eth = $adapters | Where-Object MediaType -eq '802.3'
 $wifi = $adapters | Where-Object MediaType -eq '802.11'
 if($eth){
   Write-Host '--- Ethernet ---'
   foreach($a in $eth){ Write-Host "$($a.Name): $($a.LinkSpeed) ($($a.InterfaceDescription))" }
   Write-Host '  Ethernet = stable, lowest latency, usually fastest. Prefer for gaming/calls.'
 }
 if($wifi){
   Write-Host '--- Wi-Fi ---'
   foreach($a in $wifi){ Write-Host "$($a.Name): $($a.LinkSpeed) ($($a.InterfaceDescription))" }
   Write-Host '  Wi-Fi = convenient but adds latency/jitter. Check congestion in the Wi-Fi analyzer.'
 }
 if(-not $eth -and -not $wifi){ Write-Host '[INFO] No active Ethernet or Wi-Fi adapter found.' }
 Write-Host ''
 Write-Host 'Quick quality check: run the Internet Speed Test twice (once cabled, once on Wi-Fi) and compare.'
 Pause-Toolkit
}

function Invoke-WifiHistory{
 Header; Log 'Ran Wi-Fi history'
 Write-Host 'SAVED WI-FI NETWORKS'
 $out = netsh wlan show profiles 2>$null
 $profiles = $out | Select-String 'All User Profile\s*:\s*(.+)'
 if($profiles){
   Write-Host "Saved networks: $($profiles.Count)"
   $profiles | ForEach-Object { Write-Host "  $($_.Matches[0].Groups[1].Value)" }
   Write-Host ''
   Write-Host 'TIP: remove old networks with: netsh wlan delete profile name="NAME"'
 } else { Write-Host '[INFO] No saved Wi-Fi profiles.' }
 Pause-Toolkit
}

function Invoke-WifiPasswordRecovery{
 Header; Log 'Ran Wi-Fi password recovery'
 Write-Host 'SAVED WI-FI PASSWORD RECOVERY'
 if(-not (Admin)){ Write-Host '[WARNING] Run as Administrator for reliable key display.' }
 $out = netsh wlan show profiles 2>$null
 $profiles = $out | Select-String 'All User Profile\s*:\s*(.+)'
 if(-not $profiles){ Write-Host '[INFO] No saved Wi-Fi profiles.'; Pause-Toolkit; return }
 foreach($p in $profiles){
   $name = $p.Matches[0].Groups[1].Value
   $detail = netsh wlan show profile name="$name" key=clear 2>$null
   $key = $detail | Select-String 'Key Content\s*:\s*(.+)'
   $auth = $detail | Select-String 'Authentication\s*:\s*(.+)'
   $authType = if($auth){ $auth.Matches[0].Groups[1].Value } else { '?' }
   if($key){
     $pw = $key.Matches[0].Groups[1].Value
     Write-Host ("{0,-30} [{1,-12}]  {2}" -f $name, $authType, $pw)
   } else {
     Write-Host ("{0,-30} [{1,-12}]  (open network or key hidden)" -f $name, $authType)
   }
 }
 Write-Host ''
 Write-Host 'Only recover passwords for networks you own or have permission to use.'
 Pause-Toolkit
}

function Invoke-LatencyTest{
 Header; Log 'Ran latency test'
 Write-Host 'LATENCY TEST TO POPULAR SERVICES'
 $targets = @(
   @{Name='Cloudflare DNS'; H='1.1.1.1'},
   @{Name='Google'; H='8.8.8.8'},
   @{Name='YouTube (google)'; H='youtube.com'},
   @{Name='WhatsApp (facebook)'; H='web.whatsapp.com'},
   @{Name='Windows Update'; H='windowsupdate.microsoft.com'}
 )
 foreach($t in $targets){
   $times=@()
   1..5 | ForEach-Object {
     $r = Test-Connection $t.H -Count 1 -ErrorAction SilentlyContinue
     if($r){ $times += $r.ResponseTime }
   }
   if($times){
     $avg=[math]::Round(($times|Measure-Object -Average).Average,1)
     $grade = if($avg -lt 30){'excellent'} elseif($avg -lt 100){'good'} else{'high'}
     Write-Host ("{0,-25} {1,8:N1} ms  ({2})" -f $t.Name, $avg, $grade)
   } else { Write-Host ("{0,-25} unreachable" -f $t.Name) }
 }
 Write-Host ''
 Write-Host 'For gaming/streaming: under 100 ms is playable, under 50 ms is great.'
 Pause-Toolkit
}

function Invoke-NetworkBackupReset{
 Header; Log 'Ran network backup/reset'
 Write-Host 'NETWORK SETTINGS BACKUP + RESET'
 $backup = Join-Path $ReportDir ("network_backup_{0}.txt" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
 "--- Network backup $(Get-Date) ---" | Out-File $backup
 "=== IP configuration ===" | Out-File $backup -Append
 (Get-NetIPConfiguration | fl | Out-String) | Out-File $backup -Append
 "=== DNS servers ===" | Out-File $backup -Append
 (Get-DnsClientServerAddress | Out-String) | Out-File $backup -Append
 "=== Adapter inventory ===" | Out-File $backup -Append
 (Get-NetAdapter | ft Name,InterfaceDescription,MacAddress,Status -AutoSize | Out-String) | Out-File $backup -Append
 "=== Wi-Fi profiles ===" | Out-File $backup -Append
 (netsh wlan show profiles | Out-String) | Out-File $backup -Append
 "=== netsh dump ===" | Out-File $backup -Append
 (netsh dump | Out-String) | Out-File $backup -Append
 Write-Host "[OK] Backup saved: $backup"
 Write-Host ''
 Write-Host 'This can fix weird connectivity problems, but:'
 Write-Host ' - resets all adapters (Wi-Fi passwords survive but static IPs are lost)'
 Write-Host ' - firewall rules may need re-approval for apps'
 if(Confirm 'Run FULL network reset now? (ipconfig flush + netsh winsock/int reset + ip reset)'){
   Log 'Performed full network reset'
   ipconfig /flushdns
   netsh winsock reset
   netsh int ip reset
   Write-Host '[OK] Network stack reset. RESTART the PC for it to take effect.'
 } else { Write-Host 'Skipped. Backup remains available.' }
 Pause-Toolkit
}


function WindowsHealthSuite{
 while($true){
  Header; Write-Host '--- WINDOWS HEALTH SUITE ---'; Write-Host ''
  Write-Host ' 1. BSOD / crash dump analyzer'
  Write-Host ' 2. Boot time history (spot slowdowns)'
  Write-Host ' 3. Windows activation status'
  Write-Host ' 4. Restore point lister + creator'
  Write-Host ' 5. Outdated driver finder'
  Write-Host ' 6. Old duplicate driver package cleaner'
  Write-Host ' 7. Windows Update stuck-fixer (advanced)'
  Write-Host ' 8. Services optimizer report'
  Write-Host ' 9. System file change monitor (baseline)'
  Write-Host '10. Event log export tool'
  Write-Host '11. Corrupt user profile detector'
  Write-Host '12. Disk error pattern history'
  Write-Host '13. RAM-hungry process finder'
  Write-Host '14. Reliability summary'
  Write-Host '15. Pending reboot detector'
  Write-Host '16. Defender quick scan + threat history'
  Write-Host '17. Defender quarantine review'
  Write-Host '18. Uptime and sleep/wake analysis'
  Write-Host '19. Page file advisor'
  Write-Host '20. Time sync and clock drift check'
  Write-Host ' 0. Back to main menu'
  $c=Read-Host 'Choose'
  switch($c){
   '1'{Invoke-BsodAnalyzer}'2'{Invoke-BootHistory}'3'{Invoke-ActivationCheck}'4'{Invoke-RestorePoint}'5'{Invoke-DriverUpdateFinder}'6'{Invoke-DriverPackageCleaner}'7'{Invoke-WuStuckFixer}'8'{Invoke-ServicesOptimizer}'9'{Invoke-FileChangeMonitor}'10'{Invoke-EventExport}'11'{Invoke-CorruptProfileDetector}'12'{Invoke-DiskErrorHistory}'13'{Invoke-MemoryLeakFinder}'14'{Invoke-ReliabilitySummary}'15'{Invoke-PendingRebootCheck}'16'{Invoke-DefenderScan}'17'{Invoke-QuarantineReview}'18'{Invoke-UptimeAnalysis}'19'{Invoke-PagefileAdvisor}'20'{Invoke-TimeSyncCheck}
   '0'{return} default{Write-Host '[!] Invalid option.'; Start-Sleep 1}
  }
 }
}

function Invoke-BsodAnalyzer{
 Header; Log 'Ran BSOD analyzer'
 Write-Host 'BSOD / CRASH DUMP ANALYZER'
 Write-Host '--- Recent BugCheck events (BSODs) ---'
 $ev = Get-WinEvent -FilterHashtable @{LogName='System';Id=1001;ProviderName='Microsoft-Windows-WER-SystemErrorReporting'} -MaxEvents 10 -ErrorAction SilentlyContinue
 if($ev){
   foreach($e in $ev){
     Write-Host "$($e.TimeCreated):"
     Write-Host "  $($e.Message -replace '\s+',' ')"
   }
 } else { Write-Host '[OK] No BSOD events recorded.' }
 Write-Host ''
 Write-Host '--- Minidump files ---'
 $md = Get-ChildItem "$env:windir\Minidump" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 10
 if($md){
   foreach($f in $md){
     $kb = [math]::Round($f.Length/1KB,0)
     Write-Host "  $($f.Name)  ($($f.LastWriteTime))  ${kb} KB"
   }
   Write-Host ''
   Write-Host 'Full analysis: copy minidumps and open with WinDbg (free from Microsoft) -'
   Write-Host 'command: !analyze -v   gives the failing driver.'
 } else { Write-Host 'No minidump files found.' }
 Write-Host ''
 Write-Host '--- Unresponsive app crashes (last 7 days) ---'
 $hang = Get-WinEvent -FilterHashtable @{LogName='Application';Id=1002;StartTime=(Get-Date).AddDays(-7)} -MaxEvents 5 -ErrorAction SilentlyContinue
 if($hang){ $hang | ForEach-Object { Write-Host "  $($_.TimeCreated): $($_.Message -replace '\s+',' ')" } } else { Write-Host 'None.' }
 Log 'BSOD analysis completed'
 Pause-Toolkit
}

function Invoke-BootHistory{
 Header; Log 'Ran boot time history'
 Write-Host 'BOOT TIME HISTORY (last 20 boots)'
 $ev = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Diagnostics-Performance/Operational';Id=100} -MaxEvents 20 -ErrorAction SilentlyContinue
 if($ev){
   $rows = foreach($e in $ev){
     $x=[xml]$e.ToXml()
     $ms = [double]($x.Event.EventData.Data | Where-Object Name -eq 'BootTime').'#text'
     $p = $x.Event.EventData.Data | Where-Object Name -eq 'BootTs'
     [pscustomobject]@{When=$e.TimeCreated; Seconds=[math]::Round($ms/1000,1); Slow=($ms -gt 60000)}
   }
   $rows | ft -AutoSize
   $avg = [math]::Round((($rows.Seconds | Measure-Object -Average).Average),1)
   $worst = $rows | Sort-Object Seconds -Descending | Select-Object -First 1
   Write-Host "Average boot: $avg seconds | Slowest: $($worst.Seconds)s on $($worst.When)"
   if($avg -gt 60){ Write-Host '[WARNING] Slow boots - check startup programs in Cleanup Suite.' }
   elseif($avg -gt 30){ Write-Host '[CAUTION] Boots are getting heavy - consider startup cleanup.' }
   else{ Write-Host '[OK] Boot speed healthy.' }
 } else { Write-Host '[INFO] No boot performance events found (newer PCs may need a few boots first).' }
 Pause-Toolkit
}

function Invoke-ActivationCheck{
 Header; Log 'Ran activation check'
 Write-Host 'WINDOWS ACTIVATION STATUS'
 $act = Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND Name LIKE 'Windows%'" -ErrorAction SilentlyContinue | Select-Object -First 1
 if($act){
   Write-Host "Edition      : $($act.Name)"
   Write-Host "License state: $($act.LicenseStatus -replace '1','Licensed (activated)' -replace '0','Unlicensed' -replace '2','Out of box grace' -replace '3','Out of tolerance grace' -replace '4','Non-genuine' -replace '5','Notification (not activated)')"
   if($act.LicenseStatus -eq 1){ Write-Host '[OK] Windows is activated.' } else { Write-Host '[ACTION] Activate via Settings > System > Activation.' }
 } else { Write-Host '[INFO] Could not query licensing (try as admin). Checking slmgr...' }
 $out = cscript /nologo "$env:windir\System32\slmgr.vbs" /dli 2>$null
 if($out){ $out | Select-Object -First 8 | ForEach-Object { if($_){ Write-Host $_ } } }
 Pause-Toolkit
}

function Invoke-RestorePoint{
 Header; Log 'Ran restore point check'
 Write-Host 'SYSTEM RESTORE POINTS'
 Write-Host '--- Existing restore points ---'
 $rp = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
 if($rp){
   $rp | select SequenceNumber,Description,CreationTime | ft -AutoSize
 } else { Write-Host '[INFO] No restore points found (often disabled or cleaned).' }
 Write-Host '--- Restore is enabled on drives? ---'
 try {
   $enabled = (Get-ComputerRestorePoint -ErrorAction SilentlyContinue) ; Get-CimInstance -ClassName 'SystemRestoreConfig' -Namespace 'root\default' -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  Restore dir: $($_.RPSnapshotInterval)" }
   Enable-ComputerRestore -Drive $env:SystemDrive -ErrorAction SilentlyContinue
   Write-Host "  System Restore enabled on $env:SystemDrive"
 } catch { Write-Host '  (check System Properties > System Protection)' }
 Write-Host ''
 if(Confirm 'Create a NEW restore point now?'){
   $name = "Arcange Toolkit - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
   Checkpoint-Computer -Description $name -RestorePointType 'MODIFY_SETTINGS' -ErrorAction SilentlyContinue
   Write-Host "[OK] Restore point requested: $name"
   Log "Created restore point: $name"
   Write-Host 'Note: Windows limits creation to one per 24h by default.'
 } else { Write-Host 'Skipped.' }
 Pause-Toolkit
}

function Invoke-DriverUpdateFinder{
 Header; Log 'Ran outdated driver finder'
 Write-Host 'OUTDATED DRIVER FINDER'
 $cut = (Get-Date).AddYears(-2)
 $drivers = Get-CimInstance Win32_PnPSignedDriver -ErrorAction SilentlyContinue | Where-Object { $_.DriverDate }
 $old = $drivers | Where-Object { $_.DriverDate -lt $cut -and $_.DeviceName -notmatch 'HID|USB Root|Processor|Standard' } | Sort-Object DriverDate | Select-Object DeviceName,DriverVersion,DriverDate -Unique
 if($old){
   Write-Host "Drivers older than 2 years: $($old.Count)"
   $old | select -First 20 | ft -AutoSize
   Write-Host ''
   Write-Host 'Priority targets: GPU, Wi-Fi, chipset, audio.'
   Write-Host "Vendor driver page: $script:VendorSite"
   Write-Host 'Rule: update one driver at a time; create a restore point first (Windows Health 4).'
 } else { Write-Host '[OK] No drivers older than 2 years - nice.' }
 Pause-Toolkit
}

function Invoke-DriverPackageCleaner{
 Header; Log 'Ran driver package cleaner'
 Write-Host 'OLD DUPLICATE DRIVER PACKAGE CLEANER'
 if(-not (Require-AdminOrWarn 'driver package cleanup')){ Pause-Toolkit; return }
 $pkgs = pnputil /enum-drivers 2>$null
 Write-Host 'Driver packages installed:'
 $blocks = ($pkgs | Out-String) -split "(?=Published Name)" | Where-Object { $_ -match 'Published Name' }
 $byDriver = @{}
 foreach($b in $blocks){
   $orig = [regex]::Match($b,'Original Name:\s*(.+)').Groups[1].Value.Trim()
   $ver = [regex]::Match($b,'Driver Version:\s*(.+)').Groups[1].Value.Trim()
   $pub = [regex]::Match($b,'Published Name:\s*(.+)').Groups[1].Value.Trim()
   if($orig){ if(-not $byDriver[$orig]){ $byDriver[$orig]=@() }; $byDriver[$orig] += [pscustomobject]@{Pub=$pub;Ver=$ver} }
 }
 $dups = $byDriver.Keys | Where-Object { $byDriver[$_].Count -gt 1 }
 if($dups){
   Write-Host "Packages with multiple versions (candidates for cleanup): $($dups.Count)"
   foreach($d in $dups){
     Write-Host "$d :"
     $byDriver[$d] | ForEach-Object { Write-Host "   $($_.Pub)  version $($_.Ver)" }
   }
   Write-Host ''
   Write-Host 'Windows keeps old versions for rollback. Only remove if the device works fine.'
   $target = Read-Host 'Enter oemXX.inf to remove (or press Enter to skip)'
   if($target -match '^oem\d+\.inf$'){
     if(Confirm "Remove driver package $target?"){
       pnputil /delete-driver $target
       Log "Removed driver package $target"
     }
   } else { Write-Host 'Skipped (no valid package name given).' }
 } else { Write-Host '[OK] No duplicate driver packages found.' }
 Pause-Toolkit
}

function Invoke-WuStuckFixer{
 Header; Log 'Ran WU stuck-fixer'
 Write-Host 'WINDOWS UPDATE STUCK-FIXER (ADVANCED)'
 Write-Host '--- Current state ---'
 foreach($n in 'wuauserv','bits','cryptsvc','UsoSvc'){
   $s = Get-Service $n -ErrorAction SilentlyContinue
   if($s){ Write-Host "$($s.Name): $($s.Status) ($($s.StartType))" }
 }
 $cache = Join-Path $env:windir 'SoftwareDistribution\Download'
 $size = (Get-ChildItem $cache -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum/1MB
 Write-Host ("Update cache size: {0:N1} MB" -f $size)
 Write-Host ''
 Write-Host '--- Recent update errors ---'
 $errs = Get-WinEvent -FilterHashtable @{LogName='System';ProviderName='Microsoft-Windows-WindowsUpdateClient';Level=2;StartTime=(Get-Date).AddDays(-14)} -MaxEvents 5 -ErrorAction SilentlyContinue
 if($errs){ $errs | ForEach-Object { Write-Host "  $($_.TimeCreated): $($_.Message -replace '\s+',' ')" } } else { Write-Host 'No update errors logged in last 14 days.' }
 Write-Host ''
 Write-Host 'Advanced repair sequence:'
 Write-Host ' 1. Stop services  2. Rename SoftwareDistribution  3. Restart services  4. Re-check for updates'
 if(Confirm 'Run the advanced repair now? (requires admin; takes a minute)'){
   if(Admin){
     Stop-Service wuauserv,bits,cryptsvc,UsoSvc -Force -ErrorAction SilentlyContinue
     $sd = Join-Path $env:windir 'SoftwareDistribution'
     Rename-Item $sd ("SoftwareDistribution.old_{0}" -f (Get-Date -Format 'yyyyMMddHHmmss')) -ErrorAction SilentlyContinue
     Start-Service cryptsvc,bits,wuauserv,UsoSvc -ErrorAction SilentlyContinue
     Write-Host '[OK] Done. Open Settings > Windows Update and Check for updates.'
     Write-Host 'Update history is reset, but downloads rebuild themselves.'
     Log 'Advanced WU repair completed'
   } else { Write-Host '[DENIED] Administrator rights required.' }
 } else { Write-Host 'Skipped.' }
 Pause-Toolkit
}

function Invoke-ServicesOptimizer{
 Header; Log 'Ran services optimizer report'
 Write-Host 'SERVICES OPTIMIZER REPORT'
 Write-Host '--- Automatic services not running (possible failures or disables) ---'
 Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object { $_.StartMode -eq 'Auto' -and $_.State -ne 'Running' } | select Name,DisplayName,State,StartMode | ft -AutoSize
 Write-Host '--- Third-party services (not Microsoft/Windows) ---'
 $third = Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object { $_.PathName -and $_.PathName -notmatch 'Windows\\|Microsoft' } | select Name,State,StartMode
 $third | Sort-Object State | ft -AutoSize
 Write-Host ''
 Write-Host 'ADVISORY: commonly safe to set Manual (on home PCs):'
 Write-Host '  SysMain (Superfetch) - if you use an SSD'
 Write-Host '  Fax, RemoteRegistry, WerSvc - if not used'
 Write-Host '  Xbox services - if you never game on this PC'
 Write-Host 'NEVER disable: RpcSs, DcomLaunch, Schedule, Winmgmt, PlugPlay, EventLog.'
 Write-Host 'Change a service: services.msc > right-click > Properties > Startup type.'
 Pause-Toolkit
}

function Invoke-FileChangeMonitor{
 Header; Log 'Ran system change monitor'
 Write-Host 'SYSTEM FILE CHANGE MONITOR'
 $base = Join-Path $ReportDir 'baseline.json'
 $targets = @("$env:windir\System32\drivers\etc\hosts", "$env:windir\System32\ntoskrnl.exe")
 $apps = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object DisplayName | select -ExpandProperty DisplayName | Sort-Object -Unique
 if(Test-Path $base){
   $old = Get-Content $base -Raw | ConvertFrom-Json
   Write-Host '--- Baseline from ' $old.Created '---'
   $newApps = $apps | Where-Object { $_ -notin $old.Apps }
   $goneApps = $old.Apps | Where-Object { $_ -notin $apps }
   if($newApps){ Write-Host "NEW software installed since baseline:"; $newApps | ForEach-Object { Write-Host "  + $_" } }
   if($goneApps){ Write-Host "REMOVED since baseline:"; $goneApps | ForEach-Object { Write-Host "  - $_" } }
   if(-not $newApps -and -not $goneApps){ Write-Host '[OK] No software changes since baseline.' }
   $startups = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
   $startupCount = ($startups.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' }).Count
   Write-Host "Startup items now: $startupCount (baseline: $($old.StartupCount))"
   if(Confirm 'Refresh baseline with current state?'){
     $snap = @{Created=Get-Date -Format 'o'; Apps=$apps; StartupCount=$startupCount; Files=@{}}
     foreach($t in $targets){ if(Test-Path $t){ $h=(Get-FileHash $t -Algorithm SHA256).Hash; $snap.Files[$t]=$h } }
     $snap | ConvertTo-Json -Depth 4 | Set-Content $base -Encoding UTF8
     Write-Host '[OK] Baseline refreshed.'
   }
 } else {
   $startups = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue
   $startupCount = ($startups.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' }).Count
   $snap = @{Created=Get-Date -Format 'o'; Apps=$apps; StartupCount=$startupCount; Files=@{}}
   foreach($t in $targets){ if(Test-Path $t){ $h=(Get-FileHash $t -Algorithm SHA256).Hash; $snap.Files[$t]=$h } }
   $snap | ConvertTo-Json -Depth 4 | Set-Content $base -Encoding UTF8
   Write-Host '[OK] First baseline captured (software list, startup count, key file hashes).'
   Write-Host 'Run this again later to see exactly what changed on this PC.'
 }
 Pause-Toolkit
}

function Invoke-EventExport{
 Header; Log 'Ran event log export'
 Write-Host 'EVENT LOG EXPORT TOOL'
 Write-Host '1. System log   2. Application log   3. Security log (admin)   4. All three'
 $choice = Read-Host 'Which log(s)'
 $days = Read-Host 'How many days back (default 7)'
 if(-not $days){ $days=7 }; $days=[int]$days
 $start=(Get-Date).AddDays(-$days)
 $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
 $logs = switch($choice){ '1'{@('System')} '2'{@('Application')} '3'{@('Security')} '4'{@('System','Application','Security')} default{@('System')} }
 foreach($log in $logs){
   $file = Join-Path $ReportDir ("events_{0}_{1}.csv" -f $log.ToLower(),$stamp)
   try {
     Get-WinEvent -FilterHashtable @{LogName=$log;StartTime=$start} -ErrorAction Stop | select TimeCreated,Id,LevelDisplayName,ProviderName,Message | Export-Csv $file -NoTypeInformation -Encoding UTF8
     Write-Host "[OK] $log exported: $file"
   } catch { Write-Host "[INFO] $log export failed: $($_.Exception.Message)" }
 }
 Write-Host ''
 Write-Host 'Exports are CSV - open in Excel. Useful as EVIDENCE for client disputes.'
 Pause-Toolkit
}

function Invoke-CorruptProfileDetector{
 Header; Log 'Ran corrupt profile detector'
 Write-Host 'CORRUPT USER PROFILE DETECTOR'
 $ev = Get-WinEvent -FilterHashtable @{LogName='Application';ProviderName='Microsoft-Windows-User Profile Service';Id=1511,1515,1525} -MaxEvents 10 -ErrorAction SilentlyContinue
 if($ev){
   Write-Host '[WARNING] Profile problems logged:'
   foreach($e in $ev){ Write-Host "  $($e.TimeCreated) (Event $($e.Id)): $($e.Message -replace '\s+',' ')" }
   Write-Host ''
   Write-Host 'Event 1511 = "User profile was loaded with a TEMPORARY profile" = profile corruption.'
   Write-Host 'Fix path: create new admin account > copy files > delete broken profile.'
 } else { Write-Host '[OK] No user profile problems in the Application log.' }
 Write-Host ''
 $tempUsed = ($env:USERPROFILE -match '\.TEMP|\.bak')
 if($tempUsed){ Write-Host '[DANGER] You are CURRENTLY on a temporary profile - back up your files NOW.' } else { Write-Host '[OK] Current profile is normal.' }
 Pause-Toolkit
}

function Invoke-DiskErrorHistory{
 Header; Log 'Ran disk error history'
 Write-Host 'DISK ERROR PATTERN HISTORY (30 days)'
 $start=(Get-Date).AddDays(-30)
 $ids = @{7='disk - bad blocks';51='disk - paging error';153='disk - IO retry';55='ntfs - corruption';98='ntfs - shutdown issue'}
 $found=$false
 foreach($k in $ids.Keys){
   $ev = Get-WinEvent -FilterHashtable @{LogName='System';Id=$k;StartTime=$start} -MaxEvents 5 -ErrorAction SilentlyContinue
   $count = @(Get-WinEvent -FilterHashtable @{LogName='System';Id=$k;StartTime=$start} -ErrorAction SilentlyContinue).Count
   if($count -gt 0){
     $found=$true
     Write-Host "Event $k ($($ids[$k])): $count occurrence(s)"
     $ev | Select-Object -First 2 | ForEach-Object { Write-Host "   $($_.TimeCreated)" }
   }
 }
 if($found){
   Write-Host ''
   Write-Host '[WARNING] Disk error events found. Actions:'
   Write-Host '  1. BACK UP IMPORTANT DATA FIRST'
   Write-Host '  2. Run Storage Diagnostics (main menu 7) and Advanced Storage (8)'
   Write-Host '  3. Run chkdsk C: /f (schedules at restart)'
 } else { Write-Host '[OK] No disk error events in the last 30 days.' }
 Pause-Toolkit
}

function Invoke-MemoryLeakFinder{
 Header; Log 'Ran RAM-hungry process finder'
 Write-Host 'RAM-HUNGRY PROCESS FINDER'
 $total = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1)
 $free = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB,1)
 Write-Host "RAM total: ${total} GB | free: ${free} GB"
 Write-Host ''
 Write-Host '--- Top 10 memory consumers ---'
 Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 Name,@{N='RAM_MB';E={[math]::Round($_.WorkingSet64/1MB,0)}},Id | ft -AutoSize
 Write-Host '--- Suspicious patterns ---'
 $byName = Get-Process | Group-Object Name | Where-Object Count -gt 4 | Sort-Object Count -Descending | Select-Object -First 5
 if($byName){ $byName | ForEach-Object { Write-Host "  $($_.Name): $($_.Count) instances (many copies can mean a leak)" } }
 $upLong = Get-Process | Where-Object { $_.StartTime -and $_.StartTime -lt (Get-Date).AddHours(-24) } | Measure-Object
 Write-Host "Processes running for more than 24h: $($upLong.Count)"
 Write-Host ''
 Write-Host 'Leak signs: browser using 2+ GB, svchost always growing, app RAM rising while idle.'
 Pause-Toolkit
}

function Invoke-ReliabilitySummary{
 Header; Log 'Ran reliability summary'
 Write-Host 'RELIABILITY SUMMARY (14 days)'
 $start=(Get-Date).AddDays(-14)
 $crit = @(Get-WinEvent -FilterHashtable @{LogName='System';Level=1,2;StartTime=$start} -ErrorAction SilentlyContinue)
 $app = @(Get-WinEvent -FilterHashtable @{LogName='Application';Level=1,2;StartTime=$start} -ErrorAction SilentlyContinue)
 $crashes = @($app | Where-Object { $_.Id -eq 1000 -or $_.Id -eq 1002 })
 Write-Host "System critical/error events (14 days): $($crit.Count)"
 Write-Host "Application crashes/hangs (14 days): $($crashes.Count)"
 if($crit.Count -gt 50){ Write-Host '[WARNING] High system error count - dig with Error Analyzer (main menu 12).' }
 else{ Write-Host '[OK] System error volume looks normal.' }
 Write-Host ''
 Write-Host '--- Top system error sources ---'
 $crit | Group-Object ProviderName | Sort-Object Count -Descending | Select-Object -First 5 Count,Name | ft -AutoSize
 Write-Host '--- Top crashing apps ---'
 $crashes | ForEach-Object { ($_.Message -replace '\s+',' ') -replace ',.*','' } | Group-Object | Sort-Object Count -Descending | Select-Object -First 5 Count,Name | ft -AutoSize
 Pause-Toolkit
}

function Invoke-PendingRebootCheck{
 Header; Log 'Ran pending reboot check'
 Write-Host 'PENDING REBOOT DETECTOR'
 $reasons = @()
 $rb = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
 if($rb){ $reasons += 'Windows Update has pending operations' }
 $cbs = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
 if($cbs){ $reasons += 'Component servicing has pending changes' }
 $sf = Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations2'
 $pfro = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'PendingFileRenameOperations' -ErrorAction SilentlyContinue
 if($pfro){ $reasons += 'Files pending rename at next boot' }
 if($reasons){
   Write-Host '[REBOOT RECOMMENDED] Reasons:'
   $reasons | ForEach-Object { Write-Host "  - $_" }
 } else { Write-Host '[OK] No pending reboot detected.' }
 Pause-Toolkit
}

function Invoke-DefenderScan{
 Header; Log 'Ran Defender quick scan'
 Write-Host 'WINDOWS DEFENDER QUICK SCAN'
 if(Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue){
   $st = Get-MpComputerStatus
   Write-Host "Antivirus active      : $($st.AntivirusEnabled)"
   Write-Host "Real-time protection  : $($st.RealTimeProtectionEnabled)"
   Write-Host "Signature version     : $($st.AntivirusSignatureVersion) ($($st.AntivirusSignatureLastUpdated))"
   Write-Host ''
   if(Confirm 'Run a QUICK scan now? (few minutes)'){
     if(Admin){
       Start-MpScan -ScanType QuickScan
       Write-Host '[OK] Quick scan finished.'
       Log 'Defender quick scan completed'
     } else { Write-Host '[DENIED] Run as Administrator to start a scan.' }
   }
   Write-Host ''
   Write-Host '--- Recent threat history ---'
   $threats = Get-MpThreatDetection -ErrorAction SilentlyContinue | Sort-Object InitialDetectionTime -Descending | Select-Object -First 5
   if($threats){ $threats | select InitialDetectionTime,@{N='Threat';E={$_.ThreatID}},ActionSuccess | ft -AutoSize } else { Write-Host 'No detected threats in history.' }
 } else { Write-Host '[INFO] Defender cmdlets unavailable (third-party antivirus installed?)' }
 Pause-Toolkit
}

function Invoke-QuarantineReview{
 Header; Log 'Ran quarantine review'
 Write-Host 'DEFENDER QUARANTINE REVIEW'
 $threats = Get-MpThreat -ErrorAction SilentlyContinue
 if($threats){
   foreach($t in $threats){
     Write-Host "Threat: $($t.ThreatName)"
     Write-Host "  Severity ID: $($t.SeverityID)  Status: $($t.ThreatStatusID)"
     Write-Host "  Resources: $(@($t.Resources) -join ', ')"
   }
   Write-Host ''
   Write-Host 'Threat status 1=active, 3=removed, 4=quarantined, 6=allowed.'
   Write-Host 'Review items: quarantine means held safely; allowed items deserve attention.'
 } else { Write-Host '[OK] Defender quarantine is empty.' }
 Pause-Toolkit
}

function Invoke-UptimeAnalysis{
 Header; Log 'Ran uptime analysis'
 Write-Host 'UPTIME + SLEEP/WAKE ANALYSIS (14 days)'
 $start=(Get-Date).AddDays(-14)
 $boots = @(Get-WinEvent -FilterHashtable @{LogName='System';Id=6005;StartTime=$start} -ErrorAction SilentlyContinue)
 $shuts = @(Get-WinEvent -FilterHashtable @{LogName='System';Id=6006;StartTime=$start} -ErrorAction SilentlyContinue)
 $sleeps = @(Get-WinEvent -FilterHashtable @{LogName='System';Id=42;ProviderName='Microsoft-Windows-Kernel-Power';StartTime=$start} -ErrorAction SilentlyContinue)
 $wakes = @(Get-WinEvent -FilterHashtable @{LogName='System';Id=1;ProviderName='Microsoft-Windows-Power-Troubleshooter';StartTime=$start} -ErrorAction SilentlyContinue)
 $os = Get-CimInstance Win32_OperatingSystem
 $up = (Get-Date) - $os.LastBootUpTime
 Write-Host ("Current uptime: {0} days {1} hours" -f $up.Days, $up.Hours)
 Write-Host "Boots: $($boots.Count) | Shutdowns: $($shuts.Count) | Sleeps: $($sleeps.Count) | Wakes: $($wakes.Count)"
 if($boots.Count -gt 14){ Write-Host '[CAUTION] Very frequent reboots - stability concern.' }
 elseif($boots.Count -eq 0){ Write-Host '[CAUTION] PC not rebooted in 14 days - a restart is healthy maintenance.' }
 if($wakes.Count -gt 0){
   Write-Host ''
   Write-Host 'Last wake sources:'
   $wakes | Select-Object -First 3 | ForEach-Object { Write-Host "  $($_.TimeCreated)" }
   Write-Host 'Wake source detail is in the event message (powercfg /lastwake also helps).'
 }
 Pause-Toolkit
}

function Invoke-PagefileAdvisor{
 Header; Log 'Ran page file advisor'
 Write-Host 'PAGE FILE (VIRTUAL MEMORY) ADVISOR'
 $ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1)
 $pf = Get-CimInstance Win32_PageFileUsage -ErrorAction SilentlyContinue
 $cfg = Get-CimInstance Win32_PageFileSetting -ErrorAction SilentlyContinue
 Write-Host "Physical RAM: $ram GB"
 if($pf){
   foreach($p in $pf){
     Write-Host "Page file: $($p.Name)  Allocated: $($p.AllocatedBaseSize) MB  Current use: $($p.CurrentUsage) MB  Peak: $($p.PeakUsage) MB"
   }
 } else { Write-Host '[INFO] No page file in use (could be disabled or system-managed differently).' }
 if($cfg){ $cfg | ForEach-Object { Write-Host "Config: $($_.Name) initial $($_.InitialSize) MB max $($_.MaximumSize) MB" } } else { Write-Host 'Config: system-managed size (recommended for most users).' }
 Write-Host ''
 $peakRatio = if($pf -and $pf[0].AllocatedBaseSize){ [math]::Round(($pf[0].PeakUsage/$pf[0].AllocatedBaseSize)*100,0) } else { 0 }
 if($peakRatio -gt 75){ Write-Host "[WARNING] Peak usage hit $peakRatio% of page file - increase size or add RAM." }
 else { Write-Host '[OK] Page file usage looks healthy.' }
 Write-Host 'Advice: keep system-managed; add RAM rather than enlarging page file.'
 Pause-Toolkit
}

function Invoke-TimeSyncCheck{
 Header; Log 'Ran time sync check'
 Write-Host 'TIME SYNC AND CLOCK DRIFT CHECK'
 $svc = Get-Service W32Time -ErrorAction SilentlyContinue
 if($svc){ Write-Host "Time service (W32Time): $($svc.Status)" }
 $status = w32tm /query /status 2>$null
 if($status){ $status | ForEach-Object { if($_){ Write-Host $_ } } }
 Write-Host ''
 if(Confirm 'Force time resync now?'){
   if(Admin){ w32tm /resync; Write-Host '[OK] Resync requested.' } else { Write-Host '[DENIED] Needs admin.' }
 }
 Write-Host 'Why it matters: wrong clock breaks HTTPS, logins, Kerberos, file timestamps.'
 Pause-Toolkit
}


function CleanupSuite{
 while($true){
  Header; Write-Host '--- CLEANUP AND SPEED SUITE ---'; Write-Host ''
  Write-Host ' 1. Installed software inventory (export)'
  Write-Host ' 2. Startup programs manager'
  Write-Host ' 3. Scheduled tasks auditor'
  Write-Host ' 4. Largest 50 files finder'
  Write-Host ' 5. Disk cleanup recommendations calculator'
  Write-Host ' 6. Duplicate file detector'
  Write-Host ' 7. Browser cache size report'
  Write-Host ' 8. Bloatware uninstaller wizard'
  Write-Host ' 9. Empty folder cleaner'
  Write-Host '10. Temp files deep clean'
  Write-Host '11. Recycle bin audit and cleanup'
  Write-Host '12. Prefetch cleaner'
  Write-Host '13. WinSxS component store analyzer'
  Write-Host '14. Hibernation file advisor'
  Write-Host '15. Before/after performance tune report'
  Write-Host ' 0. Back to main menu'
  $c=Read-Host 'Choose'
  switch($c){
   '1'{Invoke-SoftwareInventory}'2'{Invoke-StartupManager}'3'{Invoke-TaskAuditor}'4'{Invoke-LargestFiles}'5'{Invoke-CleanupCalculator}'6'{Invoke-DuplicateFinder}'7'{Invoke-BrowserCacheReport}'8'{Invoke-BloatwareUninstaller}'9'{Invoke-EmptyFolderCleaner}'10'{Invoke-TempCleaner}'11'{Invoke-RecycleBinAudit}'12'{Invoke-PrefetchCleaner}'13'{Invoke-WinSxSAnalyzer}'14'{Invoke-HibernationAdvisor}'15'{Invoke-TuneReport}
   '0'{return} default{Write-Host '[!] Invalid option.'; Start-Sleep 1}
  }
 }
}

function Invoke-SoftwareInventory{
 Header; Log 'Ran software inventory'
 Write-Host 'INSTALLED SOFTWARE INVENTORY'
 $apps = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object DisplayName | select DisplayName,DisplayVersion,Publisher,InstallDate
 $apps = $apps | Sort-Object DisplayName -Unique
 Write-Host "Installed programs: $($apps.Count)"
 $file = Join-Path $ReportDir ("software_inventory_{0}.csv" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
 $apps | Export-Csv $file -NoTypeInformation -Encoding UTF8
 Write-Host "[OK] Exported: $file"
 Write-Host ''
 $apps | select -First 30 DisplayName,DisplayVersion | ft -AutoSize
 Write-Host '(first 30 shown - full list in the CSV)'
 Pause-Toolkit
}

function Invoke-StartupManager{
 Header; Log 'Ran startup manager'
 Write-Host 'STARTUP PROGRAMS MANAGER'
 Write-Host '--- Registry Run keys ---'
 $runKeys = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run','HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run')
 $items = @()
 foreach($rk in $runKeys){
   $p = Get-ItemProperty $rk -ErrorAction SilentlyContinue
   if($p){
     foreach($prop in $p.PSObject.Properties){
       if($prop.Name -notmatch '^PS' -and $prop.Value){
         $items += [pscustomobject]@{Source=$rk -replace '.*\\CurrentVersion\\',''; Name=$prop.Name; Command=$prop.Value -replace '\s+-.*$',''; Disabled=$false}
       }
     }
   }
 }
 Write-Host '--- Approved disabled startups (Task Manager disabled) ---'
 $disKey='HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run'
 $dis = Get-Item $disKey -ErrorAction SilentlyContinue
 $disabledNames=@()
 if($dis){
   $vals = Get-ItemProperty $disKey -ErrorAction SilentlyContinue
   foreach($prop in $vals.PSObject.Properties){
     if($prop.Name -notmatch '^PS'){
       $bytes = $prop.Value
       if($bytes -is [byte[]] -and $bytes.Length -gt 0 -and $bytes[0] -eq 3){ $disabledNames += $prop.Name }
     }
   }
 }
 $items | ForEach-Object { if($disabledNames -contains $_.Name){ $_.Disabled = $true } }
 $items | ft Source,Name,Disabled -AutoSize
 Write-Host ''
 Write-Host '--- Startup folders ---'
 Get-ChildItem "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup","$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  $($_.FullName)" }
 Write-Host ''
 Write-Host "Total active startup items: $(@($items | Where-Object {-not $_.Disabled}).Count)"
 Write-Host 'Advice: chat apps, updaters, and cloud sync are the usual boot slowdowns.'
 Write-Host 'To disable safely: Task Manager > Startup apps > right-click > Disable.'
 Pause-Toolkit
}

function Invoke-TaskAuditor{
 Header; Log 'Ran scheduled tasks audit'
 Write-Host 'SCHEDULED TASKS AUDITOR (non-Microsoft)'
 $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskPath -notmatch '^\\Microsoft' }
 if($tasks){
   $rows = foreach($t in $tasks){
     $act = ($t.Actions | Select-Object -First 1).Execute
     [pscustomobject]@{Name=$t.TaskName; State=$t.State; Action=$act}
   }
   $rows | Sort-Object State | ft -AutoSize
   Write-Host "Non-Microsoft tasks: $($tasks.Count)"
   $runners = $rows | Where-Object { $_.Action -match '\\Temp\\|\\AppData\\|powershell|-enc' }
   if($runners){
     Write-Host '[WARNING] Tasks running from Temp/AppData or hidden PowerShell = classic malware spot:'
     $runners | ForEach-Object { Write-Host "  $($_.Name) -> $($_.Action)" }
   } else { Write-Host '[OK] No suspicious task actions spotted.' }
 } else { Write-Host '[OK] No third-party scheduled tasks.' }
 Pause-Toolkit
}

function Invoke-LargestFiles{
 Header; Log 'Ran largest files finder'
 Write-Host 'LARGEST 50 FILES FINDER'
 $root = Read-Host 'Folder/drive to scan (default C:\)'
 if(-not $root){ $root = 'C:\' }
 if(-not (Test-Path $root)){ Write-Host '[ERROR] Path not found'; Pause-Toolkit; return }
 Write-Host "Scanning $root (this can take a while)..."
 $files = Get-ChildItem $root -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object Length -gt 100MB | Sort-Object Length -Descending | Select-Object -First 50
 if($files){
   $files | select @{N='SizeMB';E={[math]::Round($_.Length/1MB,0)}},FullName | ft -AutoSize
   $total = [math]::Round((($files | Measure-Object Length -Sum).Sum)/1GB,1)
   Write-Host "These 50 files total $total GB."
   Write-Host 'Safe to delete: old ISOs, videos, installers in Downloads. Verify before deleting!'
 } else { Write-Host 'No files over 100 MB found.' }
 Pause-Toolkit
}

function Invoke-CleanupCalculator{
 Header; Log 'Ran cleanup calculator'
 Write-Host 'DISK CLEANUP RECOMMENDATIONS CALCULATOR'
 $targets = @(
   @{Name='User temp files'; Path=$env:TEMP},
   @{Name='Windows temp'; Path="$env:windir\Temp"},
   @{Name='Windows Update cache'; Path="$env:windir\SoftwareDistribution\Download"},
   @{Name='Windows error reports'; Path="$env:ProgramData\Microsoft\Windows\WER"},
   @{Name='Delivery Optimization'; Path="$env:windir\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization"},
   @{Name='Recycle Bin'; Path='shell:RecycleBinFolder'}
 )
 $totalMB = 0
 foreach($t in $targets){
   if($t.Path -match '^shell:'){ continue }
   $size = (Get-ChildItem $t.Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
   $mb = [math]::Round($size/1MB,1)
   $totalMB += $mb
   Write-Host ("{0,-28} {1,10:N1} MB" -f $t.Name, $mb)
 }
 Write-Host ("{0,-28} {1,10:N1} MB" -f 'TOTAL recoverable (est.)', $totalMB)
 Write-Host ''
 Write-Host 'Recommended actions:'
 Write-Host ' 1. Temp clean (Cleanup 10) - safe, instant'
 Write-Host ' 2. Disk Cleanup utility: cleanmgr /sageset:1 - system files option'
 Write-Host ' 3. Storage Sense: Settings > System > Storage'
 Pause-Toolkit
}

function Invoke-DuplicateFinder{
 Header; Log 'Ran duplicate file finder'
 Write-Host 'DUPLICATE FILE FINDER'
 $root = Read-Host 'Folder to scan (e.g. C:\Users\you\Documents)'
 if(-not $root -or -not (Test-Path $root)){ Write-Host '[ERROR] Path not found'; Pause-Toolkit; return }
 $minMB = Read-Host 'Minimum file size in MB (default 10)'
 if(-not $minMB){ $minMB = 10 }
 $min = [long]$minMB * 1MB
 Write-Host 'Step 1: grouping by size...'
 $files = Get-ChildItem $root -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Length -ge $min }
 $groups = $files | Group-Object Length | Where-Object Count -gt 1
 if(-not $groups){ Write-Host '[OK] No size-matched candidates found.'; Pause-Toolkit; return }
 Write-Host "Step 2: hashing $($groups.Count) size groups..."
 $dups = @()
 foreach($g in $groups){
   $hashes = $g.Group | ForEach-Object { [pscustomobject]@{File=$_; Hash=(Get-FileHash $_.FullName -Algorithm MD5).Hash} }
   $hg = $hashes | Group-Object Hash | Where-Object Count -gt 1
   foreach($h in $hg){
     $dups += $h.Group
     Write-Host "DUPLICATE SET ($([math]::Round(($h.Group[0].File.Length)/1MB,1)) MB each):"
     $h.Group | ForEach-Object { Write-Host "   $($_.File.FullName)" }
   }
 }
 if($dups){
   $wasted = [math]::Round(($dups | Group-Object { $_.File.Length } | ForEach-Object { ($_.Count-1)*$_.Group[0].File.Length } | Measure-Object -Sum).Sum/1MB,1)
   Write-Host ''
   Write-Host "Duplicate files found: $($dups.Count) | space wasted: ~$wasted MB"
   Write-Host 'Delete manually after verifying - keep ONE copy of each set.'
 } else { Write-Host '[OK] No true duplicates found.' }
 Pause-Toolkit
}

function Invoke-BrowserCacheReport{
 Header; Log 'Ran browser cache report'
 Write-Host 'BROWSER CACHE SIZE REPORT'
 $browsers = @(
   @{Name='Google Chrome'; Path="$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"},
   @{Name='Microsoft Edge'; Path="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"},
   @{Name='Firefox'; Path="$env:LOCALAPPDATA\Mozilla\Firefox\Profiles"}
 )
 foreach($b in $browsers){
   if(Test-Path $b.Path){
     $size = (Get-ChildItem $b.Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
     Write-Host ("{0,-18} {1,10:N1} MB" -f $b.Name, ($size/1MB))
   } else { Write-Host ("{0,-18} not installed" -f $b.Name) }
 }
 Write-Host ''
 Write-Host 'Safe cleanup: Ctrl+Shift+Delete in the browser (Cached images and files).'
 Write-Host 'Do NOT delete entire profiles - that removes bookmarks and passwords.'
 Pause-Toolkit
}

function Invoke-BloatwareUninstaller{
 Header; Log 'Ran bloatware wizard'
 Write-Host 'BLOATWARE UNINSTALLER WIZARD'
 $patterns = 'Candy Crush|Bubble Witch|Spotify.Trove|xboxliveapp|Disney|TikTok|Netflix|Xbox.*Game|BingWeather|GetHelp|Getstarted|Microsoft.549981C3F5F10|Your Phone|WindowsFeedbackHub|3DPrint|Print3D|MixedReality|OneConnect|Skype App'
 $all = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -and $_.DisplayName -match $patterns }
 $known = $all | select DisplayName,UninstallString,QuietUninstallString -Unique
 if(-not $known){ Write-Host '[OK] No known bloatware found.'; Pause-Toolkit; return }
 Write-Host 'Common bloatware found on this PC:'
 $i=1
 $list = @()
 foreach($k in $known){
   if($k.DisplayName){ Write-Host " $i. $($k.DisplayName)"; $list += $k }
   $i++
 }
 Write-Host ''
 $num = Read-Host 'Enter number to uninstall (Enter to skip)'
 if($num -match '^\d+$' -and [int]$num -le $list.Count){
   $target = $list[[int]$num-1]
   if(Confirm "Uninstall $($target.DisplayName)?"){
     $cmd = if($target.QuietUninstallString){ $target.QuietUninstallString } else { $target.UninstallString }
     if(Admin){ cmd /c $cmd; Write-Host '[OK] Uninstaller launched.'; Log "Uninstalled bloatware: $($target.DisplayName)" }
     else{ Write-Host '[DENIED] Needs admin. Manually: Settings > Apps > Installed apps.' }
   }
 } else { Write-Host 'Skipped.' }
 Write-Host ''
 Write-Host 'Always review the list yourself - some preinstalled apps are wanted by the user.'
 Pause-Toolkit
}

function Invoke-EmptyFolderCleaner{
 Header; Log 'Ran empty folder cleaner'
 Write-Host 'EMPTY FOLDER CLEANER'
 $root = Read-Host 'Root folder to clean (MUST be a user folder, e.g. C:\Users\you\Documents)'
 if(-not $root -or -not (Test-Path $root)){ Write-Host '[ERROR] Path not found'; Pause-Toolkit; return }
 if($root -match 'Windows|Program Files|^C:\\$|^C:$'){ Write-Host '[DENIED] System paths are not allowed here.'; Pause-Toolkit; return }
 $empty = Get-ChildItem $root -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { -not (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1) }
 if($empty){
   Write-Host "Empty folders found: $($empty.Count)"
   $empty | Select-Object -First 30 | ForEach-Object { Write-Host "  $($_.FullName)" }
   if(Confirm "Delete all $($empty.Count) empty folders under $root ?"){
     $empty | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
     Write-Host '[OK] Deleted.'
     Log "Cleaned $($empty.Count) empty folders in $root"
   } else { Write-Host 'Skipped.' }
 } else { Write-Host '[OK] No empty folders.' }
 Pause-Toolkit
}

function Invoke-TempCleaner{
 Header; Log 'Ran temp cleaner'
 Write-Host 'TEMP FILES DEEP CLEAN'
 $paths = @($env:TEMP, "$env:windir\Temp")
 $before = 0
 foreach($p in $paths){ $before += (Get-ChildItem $p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum }
 Write-Host ("Current temp size: {0:N1} MB" -f ($before/1MB))
 if(Confirm 'Delete temp files now? (apps may be holding some files - those are skipped)'){
   $freed = 0
   foreach($p in $paths){
     $items = Get-ChildItem $p -Force -ErrorAction SilentlyContinue
     foreach($f in $items){
       if($f.LastWriteTime -lt (Get-Date).AddMinutes(-30)){
         $sz = $f.Length
         Remove-Item $f.FullName -Recurse -Force -ErrorAction SilentlyContinue
         if(-not (Test-Path $f.FullName)){ $freed += $sz }
       }
     }
   }
   Write-Host ("[OK] Cleaned. Freed approx {0:N1} MB" -f ($freed/1MB))
   Log "Temp clean freed ~$([math]::Round($freed/1MB,1)) MB"
 } else { Write-Host 'Skipped.' }
 Pause-Toolkit
}

function Invoke-RecycleBinAudit{
 Header; Log 'Ran recycle bin audit'
 Write-Host 'RECYCLE BIN AUDIT'
 try {
   $shell = New-Object -ComObject Shell.Application
   $rb = $shell.Namespace(0xA)
   $items = @($rb.Items())
   Write-Host "Items in Recycle Bin: $($items.Count)"
   if($items.Count -gt 0){
     Write-Host 'Recent deletions:'
     $items | Select-Object -First 10 | ForEach-Object { Write-Host "  $($_.Name)" }
   }
   if($items.Count -gt 0 -and (Confirm 'Empty the Recycle Bin now? (permanent deletion)')){
     Clear-RecycleBin -Force -ErrorAction SilentlyContinue
     Write-Host '[OK] Recycle Bin emptied.'
     Log 'Emptied Recycle Bin'
   }
 } catch { Write-Host '[INFO] Recycle Bin check unavailable: $($_.Exception.Message)' }
 Pause-Toolkit
}

function Invoke-PrefetchCleaner{
 Header; Log 'Ran prefetch cleaner'
 Write-Host 'PREFETCH CLEANER'
 $pf = "$env:windir\Prefetch"
 if(Require-AdminOrWarn 'prefetch cleanup'){
   $files = @(Get-ChildItem $pf -File -ErrorAction SilentlyContinue)
   $size = [math]::Round((($files | Measure-Object Length -Sum).Sum)/1MB,1)
   Write-Host "Prefetch files: $($files.Count) ($size MB)"
   Write-Host 'NOTE: Prefetch actually SPEEDS UP app launches. Windows manages it automatically.'
   Write-Host 'Cleaning is only useful for troubleshooting slow app starts.'
   if(Confirm 'Clean prefetch anyway?'){
     Remove-Item "$pf\*.pf" -Force -ErrorAction SilentlyContinue
     Write-Host '[OK] Prefetch cleaned - it rebuilds itself over the next days.'
     Log 'Cleaned prefetch'
   }
 } else { Write-Host 'Run as admin for prefetch access.' }
 Pause-Toolkit
}

function Invoke-WinSxSAnalyzer{
 Header; Log 'Ran WinSxS analyzer'
 Write-Host 'WINSXS COMPONENT STORE ANALYZER'
 if(Require-AdminOrWarn 'component store analysis'){
   Write-Host 'Running DISM analysis (1-2 minutes)...'
   $out = dism /Online /Cleanup-Image /AnalyzeComponentStore
   $out | ForEach-Object { if($_){ Write-Host $_ } }
   Write-Host ''
   Write-Host 'If "Component Store Cleanup Recommended: Yes", run:'
   Write-Host '  dism /Online /Cleanup-Image /StartComponentCleanup'
   Write-Host 'Add /ResetBase ONLY if you never uninstall updates (it removes that ability).'
 } else { Write-Host 'Run as admin to analyze the component store.' }
 Pause-Toolkit
}

function Invoke-HibernationAdvisor{
 Header; Log 'Ran hibernation advisor'
 Write-Host 'HIBERNATION FILE ADVISOR'
 $hib = "$env:SystemDrive\hiberfil.sys"
 $info = Get-Item $hib -Force -ErrorAction SilentlyContinue
 if($info){
   $gb = [math]::Round($info.Length/1GB,1)
   $ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1)
   Write-Host "hiberfil.sys size: $gb GB (RAM: $ram GB)"
   $a = powercfg /a 2>$null
   Write-Host ''
   $a | ForEach-Object { if($_){ Write-Host $_ } }
   Write-Host ''
   Write-Host 'Hibernation powers Fast Startup. Disabling it frees disk but slows boot.'
   if($gb -gt 6 -and $ram -gt 8){
     if(Confirm 'Reduce hibernation file to 50% of RAM? (keeps Fast Startup, frees disk)'){
       if(Admin){ powercfg /hibernate /type reduced; Write-Host '[OK] Reduced.' } else { Write-Host '[DENIED] Needs admin.' }
     }
   }
 } else { Write-Host '[INFO] No hibernation file (already disabled or unsupported).' }
 Pause-Toolkit
}

function Invoke-TuneReport{
 Header; Log 'Ran performance tune report'
 Write-Host 'BEFORE/AFTER PERFORMANCE TUNE REPORT'
 $hist = Join-Path $ReportDir 'tune_history.json'
 $boot = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Diagnostics-Performance/Operational';Id=100} -MaxEvents 3 -ErrorAction SilentlyContinue
 $avgBoot = $null
 if($boot){
   $secs = @()
   foreach($b in $boot){ $x=[xml]$b.ToXml(); $secs += [double]($x.Event.EventData.Data | Where-Object Name -eq 'BootTime').'#text'/1000 }
   $avgBoot = [math]::Round(($secs | Measure-Object -Average).Average,1)
 }
 $tempSize = [math]::Round(((Get-ChildItem $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum)/1MB,1)
 $startup = (Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue | Measure-Object).Count
 $ramFree = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB,1)
 $snap = @{When=(Get-Date -Format 'o'); AvgBootSec=$avgBoot; TempMB=$tempSize; StartupItems=$startup; RamFreeGB=$ramFree}
 if(Test-Path $hist){
   $all = @(Get-Content $hist -Raw | ConvertFrom-Json)
   Write-Host '--- Tune history ---'
   $all += [pscustomobject]$snap
   $rows = foreach($h in $all){ [pscustomobject]@{When=$h.When; AvgBootSec=$h.AvgBootSec; TempMB=$h.TempMB; StartupItems=$h.StartupItems; RamFreeGB=$h.RamFreeGB} }
   $rows | ft -AutoSize
   $first = $rows | Select-Object -First 1
   $last = $rows | Select-Object -Last 1
   Write-Host '--- Comparison (first vs latest) ---'
   if($first.AvgBootSec -and $last.AvgBootSec){ Write-Host "Boot: $($first.AvgBootSec)s -> $($last.AvgBootSec)s $(if($last.AvgBootSec -lt $first.AvgBootSec){'[IMPROVED]'}else{'[check]'})" }
   Write-Host "Temp: $($first.TempMB) MB -> $($last.TempMB) MB"
   Write-Host "Startup items: $($first.StartupItems) -> $($last.StartupItems)"
 } else {
   Write-Host 'First measurement captured. Run this again AFTER cleanup/repairs to compare.'
 }
 $all2 = if(Test-Path $hist){ @(Get-Content $hist -Raw | ConvertFrom-Json) + [pscustomobject]$snap } else { @([pscustomobject]$snap) }
 $all2 | ConvertTo-Json -Depth 4 | Set-Content $hist -Encoding UTF8
 Write-Host "[OK] Snapshot saved to $hist"
 Pause-Toolkit
}


function SecuritySuite{
 while($true){
  Header; Write-Host '--- SECURITY SUITE ---'; Write-Host ''
  Write-Host ' 1. Local account password age audit'
  Write-Host ' 2. Administrator account exposure check'
  Write-Host ' 3. UAC settings verification'
  Write-Host ' 4. SMBv1 and legacy protocol check'
  Write-Host ' 5. Shared folder audit'
  Write-Host ' 6. BitLocker / encryption status'
  Write-Host ' 7. RDP exposure check'
  Write-Host ' 8. Suspicious startup script detector'
  Write-Host ' 9. Installed certificates anomaly check'
  Write-Host '10. Security baseline score (0-100)'
  Write-Host ' 0. Back to main menu'
  $c=Read-Host 'Choose'
  switch($c){
   '1'{Invoke-PasswordAgeAudit}'2'{Invoke-AdminExposureCheck}'3'{Invoke-UacCheck}'4'{Invoke-LegacyProtocolCheck}'5'{Invoke-SharedFolderAudit}'6'{Invoke-BitLockerStatus}'7'{Invoke-RdpExposure}'8'{Invoke-StartupScriptDetector}'9'{Invoke-CertAnomalyCheck}'10'{Invoke-SecurityScore}
   '0'{return} default{Write-Host '[!] Invalid option.'; Start-Sleep 1}
  }
 }
}

function Invoke-PasswordAgeAudit{
 Header; Log 'Ran password age audit'
 Write-Host 'LOCAL ACCOUNT PASSWORD AGE AUDIT'
 $computer=$env:COMPUTERNAME
 $users = Get-CimInstance Win32_UserAccount -Filter "LocalAccount=True" -ErrorAction SilentlyContinue
 if(-not $users){ Write-Host '[INFO] Could not enumerate local users.'; Pause-Toolkit; return }
 foreach($u in $users){
   $adsi = [ADSI]"WinNT://$computer/$($u.Name),user"
   $age = $null
   try { $last = $adsi.PasswordAge; if($last){ $age = [math]::Round(($last/86400),0) } } catch {}
   $pwnever = $false
   try { $pwnever = $adsi.UserFlags.Value -band 0x10000 } catch {}
   Write-Host ("{0,-22} enabled={1,-6} password set {2}" -f $u.Name, $u.LocalAccount, $(if($pwnever){'NEVER (dangerous)'}elseif($age){"$age days ago"}else{'(unknown)'}))
 }
 Write-Host ''
 Write-Host 'Advice: passwords older than 180 days on shared PCs should be rotated.'
 Write-Host 'net user USERNAME newpassword (admin) or Ctrl+Alt+Del > Change a password.'
 Pause-Toolkit
}

function Invoke-AdminExposureCheck{
 Header; Log 'Ran admin exposure check'
 Write-Host 'ADMINISTRATOR ACCOUNT EXPOSURE CHECK'
 $computer=$env:COMPUTERNAME
 $users = Get-CimInstance Win32_UserAccount -Filter "LocalAccount=True" -ErrorAction SilentlyContinue
 Write-Host 'Members of local Administrators:'
 $adminList = net localgroup administrators 2>$null
 if($adminList){ $adminList | Select-Object -Skip 4 | Where-Object { $_ -and $_ -notmatch '^The command|completed successfully|^-' } | ForEach-Object { Write-Host "  $($_.Trim())" } }
 $enabled = $users | Where-Object { $_.LocalAccount }
 Write-Host ''
 Write-Host 'Enabled accounts:'
 foreach($u in $users){
   $flags = Get-CimInstance Win32_UserAccount -Filter "Name='$($u.Name)'" -ErrorAction SilentlyContinue
   Write-Host "  $($u.Name)  disabled=$($u.Disabled)"
 }
 $guest = $users | Where-Object Name -eq 'Guest'
 if($guest -and -not $guest.Disabled){ Write-Host '[WARNING] Guest account is ENABLED - disable it.' } else { Write-Host '[OK] Guest account disabled.' }
 Write-Host ''
 Write-Host 'Best practice: ONE admin account for admin work + ONE standard account for daily use.'
 Pause-Toolkit
}

function Invoke-UacCheck{
 Header; Log 'Ran UAC check'
 Write-Host 'UAC (USER ACCOUNT CONTROL) VERIFICATION'
 $k = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
 $p = Get-ItemProperty $k -ErrorAction SilentlyContinue
 Write-Host "EnableLUA (UAC master switch)   : $($p.EnableLUA)"
 Write-Host "ConsentPromptBehaviorAdmin      : $($p.ConsentPromptBehaviorAdmin)"
 Write-Host "PromptOnSecureDesktop           : $($p.PromptOnSecureDesktop)"
 $mode = switch($p.ConsentPromptBehaviorAdmin){
   0 {'No prompt (INSECURE - never recommended)'}
   2 {'Prompt for consent on secure desktop (default)'}
   5 {'Prompt for consent for non-Windows binaries (default)'}
   6 {'Prompt for credentials (secure)'}
   default {'See Microsoft docs'}
 }
 Write-Host "Interpretation: $mode"
 if($p.EnableLUA -eq 0){ Write-Host '[DANGER] UAC is DISABLED - any malware can silently get admin rights. Enable immediately!' }
 elseif($p.ConsentPromptBehaviorAdmin -eq 0){ Write-Host '[WARNING] UAC prompts suppressed - risky setting.' }
 else { Write-Host '[OK] UAC active.' }
 Pause-Toolkit
}

function Invoke-LegacyProtocolCheck{
 Header; Log 'Ran legacy protocol check'
 Write-Host 'LEGACY PROTOCOL CHECK (SMBv1 and friends)'
 $smb1 = $null
 if(Get-Command Get-SmbServerConfiguration -ErrorAction SilentlyContinue){
   $smb1 = (Get-SmbServerConfiguration -ErrorAction SilentlyContinue).EnableSMB1Protocol
 }
 if($smb1 -eq $null){
   $smb1 = (Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue).State
   $smb1 = if($smb1 -eq 'Enabled'){ $true } else { $false }
 }
 Write-Host "SMBv1 protocol: $(if($smb1){'ENABLED [DANGER]'}else{'disabled [OK]'})"
 if($smb1){ Write-Host 'SMBv1 enabled = WannaCry-class ransomware risk. Disable it:'; Write-Host '  Settings > Apps > Optional Features > Windows Features > uncheck SMB 1.0' }
 $llmnr = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\NTDS\DNSClient' -Name 'EnableMulticast' -ErrorAction SilentlyContinue
 Write-Host "LLMNR (name-resolution spoofing risk): $(if($llmnr.EnableMulticast -eq 0){'disabled [OK]'}else{'active (default - disable for hardening)'})"
 Write-Host '  Disable via Group Policy: Turn off multicast name resolution'
 $adminShares = Get-SmbShare -Special -ErrorAction SilentlyContinue | Where-Object Name -match 'ADMIN\$|C\$|IPC\$'
 Write-Host "Admin shares (C$, ADMIN$): $(if($adminShares){'present (normal on Windows, risky if exposed)'}else{'not found'})"
 Pause-Toolkit
}

function Invoke-SharedFolderAudit{
 Header; Log 'Ran shared folder audit'
 Write-Host 'SHARED FOLDER AUDIT'
 $shares = Get-SmbShare -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne 'IPC$' }
 if($shares){
   $shares | select Name,Path,Description,@{N='Unrestricted';E={ -not (($_ | Get-SmbAccess).DenyAll) }} | ft -AutoSize
   Write-Host '--- Access per share ---'
   foreach($s in $shares){
     $acc = $s | Get-SmbAccess -ErrorAction SilentlyContinue
     $everyone = $acc | Where-Object { $_.AccountName -match 'Everyone' -and $_.AccessRight -match 'Full|Change' }
     Write-Host "$($s.Name) -> $(($acc | ForEach-Object { "$($_.AccountName):$($_.AccessRight)" }) -join ', ')"
     if($everyone){ Write-Host "  [WARNING] EVERYONE has write access to $($s.Name) - review!" }
   }
   Write-Host ''
   Write-Host 'Shared folders reachable on the network = data exposure. Remove unused shares.'
   Write-Host 'Remove: Remove-SmbShare -Name NAME (admin)'
 } else { Write-Host '[OK] No shared folders - nothing exposed to the network.' }
 Pause-Toolkit
}

function Invoke-BitLockerStatus{
 Header; Log 'Ran BitLocker status'
 Write-Host 'BITLOCKER / ENCRYPTION STATUS'
 $got = $false
 if(Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue){
   $vols = Get-BitLockerVolume -ErrorAction SilentlyContinue
   foreach($v in $vols){
     $got=$true
     Write-Host "$($v.MountPoint):"
     Write-Host "  Status          : $($v.VolumeStatus)"
     Write-Host "  Encryption %    : $($v.EncryptionPercentage)"
     Write-Host "  Protection      : $($v.ProtectionStatus)"
     if($v.KeyProtector -and ($v.KeyProtector | Where-Object KeyProtectorType -eq 'RecoveryPassword')){ Write-Host '  Recovery key    : BACKED UP (RecoveryPassword protector present)' } else { Write-Host '  Recovery key    : check backup! (admin)' }
   }
 }
 if(-not $got){
   Write-Host '[INFO] BitLocker module unavailable. Trying manage-bde...'
   $out = manage-bde -status C: 2>$null
   if($out){ $out | ForEach-Object { if($_){ Write-Host $_ } } } else { Write-Host '[INFO] manage-bde unavailable - check encryption in Settings > Privacy & security > Device encryption.' }
 }
 Write-Host ''
 Write-Host 'Laptop without disk encryption = stolen data. Enable + BACK UP the recovery key to Microsoft account/USB.'
 Pause-Toolkit
}

function Invoke-RdpExposure{
 Header; Log 'Ran RDP exposure check'
 Write-Host 'RDP (REMOTE DESKTOP) EXPOSURE CHECK'
 $k = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
 $deny = (Get-ItemProperty $k -Name fDenyTSConnections -ErrorAction SilentlyContinue).fDenyTSConnections
 $rdpOn = ($deny -eq 0)
 Write-Host "RDP enabled: $(if($rdpOn){'YES'}else{'no (fDenyTSConnections=1)'})"
 if($rdpOn){
   $nla = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name UserAuthentication -ErrorAction SilentlyContinue).UserAuthentication
   Write-Host "Network Level Authentication: $(if($nla -eq 1){'ON [OK]'}else{'OFF [DANGER - enable now]'})"
   $listen = Get-NetTCPConnection -State Listen -LocalPort 3389 -ErrorAction SilentlyContinue
   Write-Host "Port 3389 listening: $(if($listen){'YES - RDP reachable on this network'}else{'no'})"
   $rules = Get-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue | Where-Object Enabled -eq True
   Write-Host "Firewall RDP rules enabled: $(if($rules){'YES'}else{'no'})"
   Write-Host ''
   Write-Host 'RDP is the #1 attack surface on office PCs. Keep NLS ON, strong passwords, and'
   Write-Host 'never expose 3389 directly to the internet (use VPN or RD Gateway).'
 } else { Write-Host '[OK] RDP is off - good default for home PCs.' }
 Pause-Toolkit
}

function Invoke-StartupScriptDetector{
 Header; Log 'Ran startup script detector'
 Write-Host 'SUSPICIOUS STARTUP SCRIPT DETECTOR'
 $suspects = @()
 $runKeys = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run')
 foreach($rk in $runKeys){
   $p = Get-ItemProperty $rk -ErrorAction SilentlyContinue
   foreach($prop in $p.PSObject.Properties){
     if($prop.Name -notmatch '^PS' -and $prop.Value -match '\.bat|\.vbs|\.js|-enc|rundll32|regsvr32|mshta|wscript|cscript'){
       if($prop.Value -match '\\Temp\\|\\AppData\\Local\\Temp'){ $sev='HIGH' } else { $sev='review' }
       $suspects += [pscustomobject]@{Source=$rk; Name=$prop.Name; Value=($prop.Value -replace '\s+',' '); Severity=$sev}
     }
   }
 }
 $folders = @("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup","$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup")
 foreach($f in $folders){
   Get-ChildItem $f -ErrorAction SilentlyContinue | Where-Object Extension -match '\.bat|\.vbs|\.js|\.ps1' | ForEach-Object {
     $suspects += [pscustomobject]@{Source='Startup folder'; Name=$_.Name; Value=$_.FullName; Severity='HIGH'}
   }
 }
 if($suspects){
   Write-Host '[REVIEW] Script-based startup entries found (scripts are a classic malware hideout):'
   $suspects | ft -AutoSize
   Write-Host 'HIGH = runs a script from a temp/user folder at every login. Investigate before deleting.'
 } else { Write-Host '[OK] No script-based startup entries - good hygiene.' }
 Pause-Toolkit
}

function Invoke-CertAnomalyCheck{
 Header; Log 'Ran certificate anomaly check'
 Write-Host 'INSTALLED CERTIFICATES ANOMALY CHECK'
 $roots = Get-ChildItem Cert:\LocalMachine\Root -ErrorAction SilentlyContinue
 $msft = $roots | Where-Object { $_.Subject -match 'Microsoft|VeriSign|DigiCert|GlobalSign|Comodo|Sectigo|Baltimore|Entrust|Thawte|GeoTrust|GoDaddy|Amazon|Google|ISRG|Let.s Encrypt|Buypass|SwissSign|QuoVadis|Certum|T-TeleSec|D-TRUST|Cybertrust|IdenTrust|Hellenic|E-Tugra|Actalis|TrustCor|SecureTrust|XRamp|GoDaddy Class 2|Starfield|Network Solutions|UserTrust' }
 $unknown = $roots | Where-Object { $_ -notin $msft }
 Write-Host "Root CAs installed: $($roots.Count)"
 Write-Host "Recognized major CAs: $(@($msft).Count)"
 Write-Host "Other/unrecognized roots: $(@($unknown).Count)"
 if($unknown){
   Write-Host ''
   Write-Host 'Unrecognized root certificates (review each - legit corporate/AV roots are common, but rogue roots enable interception):'
   $unknown | Sort-Object NotAfter -Descending | Select-Object -First 10 @{N='Issuer';E={$_.Subject}},NotAfter | ft -AutoSize
 }
 Write-Host ''
 Write-Host 'Red flags: roots issued to unknown companies, self-signed, or dated recently.'
 Write-Host 'Rogue root = attacker can fake ANY website (bank, WhatsApp web). Investigate seriously.'
 Pause-Toolkit
}

function Invoke-SecurityScore{
 Header; Log 'Ran security score'
 Write-Host 'SECURITY BASELINE SCORE'
 $score = 100
 $notes = @()
 $def = Get-MpComputerStatus -ErrorAction SilentlyContinue
 if($def){
   if(-not $def.RealTimeProtectionEnabled){ $score-=25; $notes += 'Real-time antivirus OFF (-25)' }
   if($def.AntivirusSignatureLastUpdated -and ((Get-Date)-$def.AntivirusSignatureLastUpdated).Days -gt 7){ $score-=10; $notes += 'AV signatures out of date (-10)' }
 } else { $notes += 'AV status unknown - check third-party AV (0)' }
 $fw = Get-NetFirewallProfile -ErrorAction SilentlyContinue | Where-Object { -not $_.Enabled }
 if($fw){ $score-=15; $notes += "Firewall disabled: $($fw.Name -join ',') (-15)" }
 $uac = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name EnableLUA -ErrorAction SilentlyContinue).EnableLUA
 if($uac -eq 0){ $score-=15; $notes += 'UAC disabled (-15)' }
 $smb1 = $null
 if(Get-Command Get-SmbServerConfiguration -ErrorAction SilentlyContinue){ $smb1=(Get-SmbServerConfiguration -ErrorAction SilentlyContinue).EnableSMB1Protocol }
 if($smb1){ $score-=15; $notes += 'SMBv1 enabled (-15)' }
 $guest = Get-CimInstance Win32_UserAccount -Filter "Name='Guest'" -ErrorAction SilentlyContinue
 if($guest -and -not $guest.Disabled){ $score-=10; $notes += 'Guest account enabled (-10)' }
 $k = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
 if(((Get-ItemProperty $k -Name fDenyTSConnections -ErrorAction SilentlyContinue).fDenyTSConnections) -eq 0){ $nla=(Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name UserAuthentication -ErrorAction SilentlyContinue).UserAuthentication; if($nla -ne 1){ $score-=10; $notes += 'RDP on without NLA (-10)' } }
 $pending = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
 if($pending){ $score-=5; $notes += 'Security updates pending reboot (-5)' }
 $score = [math]::Max($score,0)
 Write-Host ''
 Write-Host ('  SECURITY SCORE: {0} / 100' -f $score)
 Write-Host ''
 if($notes){ $notes | ForEach-Object { Write-Host "  - $_" } } else { Write-Host '  All baseline checks passed.' }
 if($score -ge 90){ Write-Host '  Verdict: [EXCELLENT] solid baseline.' }
 elseif($score -ge 70){ Write-Host '  Verdict: [OK] fix the flagged items for a better score.' }
 else{ Write-Host '  Verdict: [AT RISK] address the findings above now.' }
 Log "Security score: $score/100"
 Pause-Toolkit
}

function WorkflowSuite{
 while($true){
  Header; Write-Host '--- TECHNICIAN WORKFLOW SUITE ---'; Write-Host ''
  Write-Host ' 1. Client case database (add/list clients + cases)'
  Write-Host ' 2. Before/after repair comparison report'
  Write-Host ' 3. PDF report export (best effort via Word)'
  Write-Host ' 4. Email report to client (best effort via Outlook)'
  Write-Host ' 5. QR code for report summary (online)'
  Write-Host ' 6. Scheduled automatic health check'
  Write-Host ' 7. Remote-assist prep one-pager'
  Write-Host ' 8. Bootable diagnostics USB guide'
  Write-Host ' 9. Warranty status checker by serial'
  Write-Host '10. Repair price estimator'
  Write-Host '11. Technician notes for current case'
  Write-Host '12. Language settings (menu display)'
  Write-Host '13. Voice guidance on/off'
  Write-Host '14. GUI theme toggle'
  Write-Host '15. Toolkit update checker'
  Write-Host ' 0. Back to main menu'
  $c=Read-Host 'Choose'
  switch($c){
   '1'{Invoke-ClientDatabase}'2'{Invoke-BeforeAfterReport}'3'{Invoke-PdfExport}'4'{Invoke-EmailReport}'5'{Invoke-QrOnReport}'6'{Invoke-ScheduledHealthCheck}'7'{Invoke-RemoteAssistPrep}'8'{Invoke-BootableUsbGuide}'9'{Invoke-WarrantyCheck}'10'{Invoke-PriceEstimator}'11'{Invoke-CaseNotes}'12'{Invoke-LanguageSettings}'13'{Invoke-VoiceToggle}'14'{Invoke-ThemeToggle}'15'{Invoke-UpdateChecker}
   '0'{return} default{Write-Host '[!] Invalid option.'; Start-Sleep 1}
  }
 }
}

function Invoke-ClientDatabase{
 Header; Log 'Ran client database'
 Write-Host 'CLIENT CASE DATABASE'
 $db = Join-Path $ReportDir 'clients.json'
 if(-not (Test-Path $db)){ '[]' | Set-Content $db -Encoding UTF8 }
 $clients = Get-Content $db -Raw | ConvertFrom-Json
 Write-Host "1. Add client   2. List clients   3. Add case to client   4. Add note to case"
 $c = Read-Host 'Choose'
 switch($c){
  '1'{
    $name = Read-Host 'Client name'
    $phone = Read-Host 'Phone number'
    if($name){
      $case = [pscustomobject]@{Date=(Get-Date -Format 'yyyy-MM-dd'); CaseId=$CaseId; Issue=(Read-Host 'Issue description'); Notes=@()}
      $client = [pscustomobject]@{Name=$name; Phone=$phone; Added=(Get-Date -Format 'yyyy-MM-dd'); Cases=@($case)}
      $clients = @($clients) + $client
      $clients | ConvertTo-Json -Depth 5 | Set-Content $db -Encoding UTF8
      Write-Host '[OK] Client saved.'
      Log "Added client: $name"
    }
  }
  '2'{
    if($clients){ $clients | ForEach-Object { Write-Host "$($_.Name) ($($_.Phone)) - $(@($_.Cases).Count) case(s)"; @($_.Cases) | ForEach-Object { Write-Host "    $($_.Date) [$($_.CaseId)] $($_.Issue)" } } }
    else{ Write-Host 'No clients yet.' }
  }
  '3'{
    $clients | ForEach-Object { Write-Host "$($_.Name) ($($_.Phone))" }
    $nm = Read-Host 'Client name for new case'
    $cl = $clients | Where-Object Name -eq $nm
    if($cl){
      $case = [pscustomobject]@{Date=(Get-Date -Format 'yyyy-MM-dd'); CaseId=$CaseId; Issue=(Read-Host 'Issue description'); Notes=@()}
      $cl.Cases = @($cl.Cases) + $case
      $clients | ConvertTo-Json -Depth 5 | Set-Content $db -Encoding UTF8
      Write-Host "[OK] Case $CaseId added to $nm"
    } else { Write-Host 'Client not found.' }
  }
  '4'{
    $nm = Read-Host 'Client name'
    $cl = $clients | Where-Object Name -eq $nm
    if($cl -and $cl.Cases){
      $last = @($cl.Cases)[-1]
      $note = Read-Host 'Note text'
      $last.Notes += "$((Get-Date -Format 'yyyy-MM-dd')) $note"
      $clients | ConvertTo-Json -Depth 5 | Set-Content $db -Encoding UTF8
      Write-Host '[OK] Note saved.'
    } else { Write-Host 'Client/case not found.' }
  }
 }
 Pause-Toolkit
}

function Invoke-BeforeAfterReport{
 Header; Log 'Ran before/after comparison'
 Write-Host 'BEFORE/AFTER REPAIR COMPARISON'
 $jsons = @(Get-ChildItem (Join-Path $ReportDir 'diagnostic_*.json') -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 6)
 if($jsons.Count -eq 0){ Write-Host '[INFO] No diagnostic JSON reports found. Generate reports first (main menu 14).'; Pause-Toolkit; return }
 Write-Host 'Recent reports:'
 $i=1
 foreach($j in $jsons){ Write-Host " $i. $($j.Name)"; $i++ }
 $a = Read-Host 'Number of BEFORE report'
 $b = Read-Host 'Number of AFTER report'
 if($a -match '^\d+$' -and $b -match '^\d+$' -and [int]$a -le $jsons.Count -and [int]$b -le $jsons.Count){
   $before = Get-Content $jsons[[int]$a-1].FullName -Raw | ConvertFrom-Json
   $after = Get-Content $jsons[[int]$b-1].FullName -Raw | ConvertFrom-Json
   Write-Host ''
   Write-Host '--- Comparison ---'
   Write-Host "Vendor : $($before.Manufacturer) $($before.Model)"
   Write-Host "OS     : $($before.OS) -> $($after.OS)"
   $bp = @($before.ProblemDevices).Count; $ap = @($after.ProblemDevices).Count
   Write-Host "Problem devices: $bp -> $ap $(if($ap -lt $bp){'[IMPROVED]'}elseif($ap -gt $bp){'[WORSE]'}else{'[same]'})"
   Write-Host "Volumes: $(@($before.Volumes).Count) -> $(@($after.Volumes).Count)"
   Write-Host ''
   Write-Host "Case IDs: $($before.CaseId) -> $($after.CaseId)"
   Write-Host "Generated: $($before.Generated) -> $($after.Generated)"
 } else { Write-Host 'Invalid selection.' }
 Pause-Toolkit
}

function Invoke-PdfExport{
 Header; Log 'Ran PDF export'
 Write-Host 'PDF REPORT EXPORT'
 $html = Get-ChildItem (Join-Path $ReportDir 'diagnostic_*.html') -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
 if(-not $html){ Write-Host '[INFO] No HTML report found. Generate one first (main menu 14).'; Pause-Toolkit; return }
 $pdf = $html.FullName -replace '\.html$','.pdf'
 try {
   $word = New-Object -ComObject Word.Application
   $doc = $word.Documents.Open($html.FullName)
   $doc.SaveAs([ref]$pdf, [ref]17)
   $doc.Close($false)
   $word.Quit()
   Write-Host "[OK] PDF saved: $pdf"
   Log "Exported PDF: $pdf"
 } catch {
   Write-Host '[FALLBACK] Word not available. Any browser can print the HTML to PDF:'
   Write-Host '  1. Open this file in Edge/Chrome:'
   Write-Host "     $((Resolve-Path $html.FullName).Path)"
   Write-Host '  2. Ctrl+P > Destination: Save as PDF'
 }
 Pause-Toolkit
}

function Invoke-EmailReport{
 Header; Log 'Ran email report step'
 Write-Host 'EMAIL REPORT TO CLIENT'
 $latest = Get-ChildItem (Join-Path $ReportDir 'diagnostic_*.txt') -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
 if(-not $latest){ Write-Host '[INFO] No report found. Generate one first (main menu 14).'; Pause-Toolkit; return }
 $to = Read-Host 'Client email address'
 if(-not $to){ Write-Host 'No address given.'; Pause-Toolkit; return }
 $mailto = "mailto:$to?subject=Your%20PC%20Diagnostic%20Report%20$CaseId&body=Hello,%0A%0AAttached%20is%20your%20diagnostic%20report.%0A%0A$(($latest.Name -replace ' ','%20'))"
 try {
   $outlook = New-Object -ComObject Outlook.Application
   $mail = $outlook.CreateItem(0)
   $mail.To = $to
   $mail.Subject = "Your PC Diagnostic Report $CaseId"
   $mail.Body = "Hello,`n`nYour diagnostic report is attached.`n`nGenerated by Arcange Windows Technician Toolkit."
   $mail.Attachments.Add($latest.FullName) | Out-Null
   $mail.Display()
   Write-Host '[OK] Outlook draft created with the report attached. Review and press Send.'
   Log "Created email draft to $to"
 } catch {
   Start-Process $mailto
   Write-Host '[FALLBACK] Default mail app opened. Attach this file manually:'
   Write-Host "  $($latest.FullName)"
 }
 Pause-Toolkit
}

function Invoke-QrOnReport{
 Header; Log 'Ran QR code generation'
 Write-Host 'QR CODE FOR REPORT SUMMARY (requires internet)'
 try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
 $text = "Arcange Toolkit $CaseId - $script:Manufacturer $script:Model - $(Get-Date -Format 'yyyy-MM-dd') - Report in reports folder"
 $url = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=' + [uri]::EscapeDataString($text)
 $qr = Join-Path $ReportDir ("qr_{0}.png" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
 try {
   Invoke-WebRequest -Uri $url -OutFile $qr -TimeoutSec 20
   Write-Host "[OK] QR saved: $qr"
   Write-Host 'Client scans it to see the case summary text on their phone.'
   Start-Process $qr
 } catch { Write-Host '[INFO] QR service unreachable - offline PCs keep working fine without it.' }
 Pause-Toolkit
}

function Invoke-ScheduledHealthCheck{
 Header; Log 'Ran scheduled health check setup'
 Write-Host 'SCHEDULED AUTOMATIC HEALTH CHECK'
 if(Require-AdminOrWarn 'creating a scheduled task'){
   $taskName = 'ArcangeToolkitWeeklyHealth'
   $exists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
   Write-Host 'This creates a weekly task that runs the toolkit report silently'
   Write-Host 'and saves TXT/JSON/HTML reports (visible in the reports folder).'
   if($exists){
     Write-Host "[INFO] Task '$taskName' already exists."
     if(Confirm 'Remove the existing scheduled task?'){ Unregister-ScheduledTask -TaskName $taskName -Confirm:$false; Write-Host '[OK] Removed.'; Log 'Removed weekly health check task' }
   } elseif(Confirm "Create weekly health check task (Sundays 09:00)?") {
     $enginePath = (Join-Path $Root 'src\Arcange-Technician.ps1')
     $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$enginePath`" -Section Report"
     $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 9am
     $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable
     Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -RunLevel Highest -ErrorAction SilentlyContinue | Out-Null
     Write-Host '[OK] Weekly health check scheduled.'
     Log 'Created weekly health check scheduled task'
   }
 } else { Write-Host 'Run as admin to manage scheduled tasks.' }
 Pause-Toolkit
}

function Invoke-RemoteAssistPrep{
 Header; Log 'Ran remote assist prep'
 Write-Host 'REMOTE-ASSIST PREP ONE-PAGER'
 try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
 $ip = '(offline)'
 try { $ip = (Invoke-RestMethod 'https://api.ipify.org' -TimeoutSec 10) } catch {}
 $loc = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway } | ForEach-Object { $_.IPv4Address.IPAddress }
 Write-Host ''
 Write-Host '=== REMOTE SESSION PREP ==='
 Write-Host "PC name    : $env:COMPUTERNAME"
 Write-Host "Vendor     : $script:Manufacturer $script:Model"
 Write-Host "OS         : $((Get-CimInstance Win32_OperatingSystem).Caption)"
 Write-Host "Local IP   : $($loc -join ', ')"
 Write-Host "Public IP  : $ip"
 Write-Host "Admin      : $(Admin)"
 Write-Host "Case ID    : $CaseId"
 Write-Host ''
 Write-Host 'Ready to give the remote helper:'
 Write-Host ' 1. Install AnyDesk / RustDesk / use Windows Quick Assist'
 Write-Host ' 2. Tell them the 9-digit code the app shows'
 Write-Host ' 3. Stay at the PC to approve the connection'
 Write-Host ''
 Write-Host 'Security: only give control to someone you know; watch the screen during the session.'
 $file = Join-Path $ReportDir ("remote_prep_{0}.txt" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
 $this | Out-File $file
 @("PC: $env:COMPUTERNAME ($script:Manufacturer $script:Model)","Case: $CaseId","Date: $(Get-Date)") | Set-Content $file -Encoding UTF8
 Write-Host "[OK] Prep notes saved: $file"
 Pause-Toolkit
}

function Invoke-BootableUsbGuide{
 Header; Log 'Ran bootable USB guide'
 Write-Host 'BOOTABLE DIAGNOSTICS USB GUIDE'
 Write-Host ''
 Write-Host 'RECOMMENDED: Windows 11 installation media (also has repair tools)'
 Write-Host ' 1. Official tool: https://www.microsoft.com/software-download/windows11'
 Write-Host '    - "Create Windows 11 Installation Media" - run on a working PC'
 Write-Host '    - Needs an 8 GB+ USB stick - WARNING: everything on it is erased'
 Write-Host ' 2. Windows 10: https://www.microsoft.com/software-download/windows10'
 Write-Host ''
 Write-Host 'WHAT YOU CAN DO FROM BOOTABLE MEDIA:'
 Write-Host ' - Repair startup (bootrec /fixmbr, /fixboot, /rebuildbcd)'
 Write-Host ' - System Restore / System Image Recovery'
 Write-Host ' - Command prompt rescue: copy files before wiping'
 Write-Host ' - Reset this PC keeping files'
 Write-Host ''
 Write-Host 'TECHNICIAN TIP: add portable tools to the USB (memtest86+, vendor diagnostics,'
 Write-Host 'data-rescue tools). Label the stick and keep it in your toolkit bag.'
 Write-Host ''
 Write-Host 'This toolkit does NOT format USB sticks automatically - that step stays manual for safety.'
 Pause-Toolkit
}

function Invoke-WarrantyCheck{
 Header; Log 'Ran warranty check'
 Write-Host 'WARRANTY STATUS CHECKER BY SERIAL'
 $b = Get-CimInstance Win32_BIOS
 $vp = Get-VendorProfile
 Write-Host "Vendor    : $($vp.Vendor)"
 Write-Host "Model     : $script:Model"
 Write-Host "Serial    : $($b.SerialNumber)"
 Write-Host ''
 Write-Host 'Copy the serial above, then open the vendor warranty page:'
 switch -Wildcard ($vp.Vendor){
   'HP'{ Write-Host '  https://support.hp.com/us-en/checkwarranty' }
   'Dell'{ Write-Host '  https://www.dell.com/support (enter Service Tag)' }
   'Lenovo'{ Write-Host '  https://pcsupport.lenovo.com/warranty' }
   'Acer*'{ Write-Host '  https://www.acer.com/ac/en/US/content/warranty-information' }
   'ASUS'{ Write-Host '  https://www.asus.com/support/warranty-inquiry' }
   'MSI'{ Write-Host '  https://www.msi.com/support/warranty' }
   'Microsoft*'{ Write-Host '  https://support.microsoft.com/surface' }
   'Samsung'{ Write-Host '  https://www.samsung.com/us/support/warranty/' }
   'Toshiba*'{ Write-Host '  https://www.dynabook.com/support' }
   'Fujitsu'{ Write-Host '  https://www.fujitsu.com/global/support/pc/warranty/' }
   'Panasonic'{ Write-Host '  https://panasonic.jp/toughbook/support' }
   'Apple*'{ Write-Host '  https://checkcoverage.apple.com' }
   'HUAWEI'{ Write-Host '  https://consumer.huawei.com/support' }
   default { Write-Host "  General: $script:VendorSite" }
 }
 Write-Host ''
 Write-Host 'TIP: purchase-date invoices may be needed for warranty claims.'
 Pause-Toolkit
}

function Invoke-PriceEstimator{
 Header; Log 'Ran price estimator'
 Write-Host 'REPAIR PRICE ESTIMATOR (RWANDAN FRANC - RWF)'
 Write-Host 'Adjust these rates to your market.'
 $services = @(
   @{N='Dust cleaning + repaste'; Low=10000; High=25000},
   @{N='Windows reinstall (software)'; Low=15000; High=30000},
   @{N='Data backup (up to 500 GB)'; Low=10000; High=20000},
   @{N='RAM upgrade (part + work)'; Low=25000; High=60000},
   @{N='SSD upgrade 240-512 GB'; Low=60000; High=120000},
   @{N='Keyboard replacement (laptop)'; Low=30000; High=80000},
   @{N='Screen replacement (laptop)'; Low=80000; High=250000},
   @{N='Battery replacement (laptop)'; Low=30000; High=70000},
   @{N='Virus removal + tune-up'; Low=10000; High=25000},
   @{N='Full diagnostic + report'; Low=5000; High=10000}
 )
 $i=1
 foreach($s in $services){ Write-Host (" {0,2}. {1,-35} {2,8:N0} - {3,8:N0} RWF" -f $i,$s.N,$s.Low,$s.High); $i++ }
 Write-Host ''
 $pick = Read-Host 'Enter service numbers separated by commas (e.g. 1,9)'
 $totalLow=0; $totalHigh=0
 foreach($p in ($pick -split ',')){
   $n = $p.Trim()
   if($n -match '^\d+$' -and [int]$n -le $services.Count){
     $s = $services[[int]$n-1]
     $totalLow += $s.Low; $totalHigh += $s.High
     Write-Host "  + $($s.N)"
   }
 }
 if($totalLow -gt 0){
   Write-Host ''
   Write-Host ("  ESTIMATE: {0:N0} - {1:N0} RWF" -f $totalLow,$totalHigh)
   Write-Host '  (quote parts separately; confirm with client before work)'
 }
 Pause-Toolkit
}

function Invoke-CaseNotes{
 Header; Log 'Ran case notes'
 Write-Host 'TECHNICIAN NOTES FOR CURRENT CASE'
 Write-Host "Case ID: $CaseId"
 $notesFile = Join-Path $ReportDir ("case_{0}_notes.txt" -f $CaseId)
 if(Test-Path $notesFile){ Write-Host '--- Existing notes ---'; Get-Content $notesFile | ForEach-Object { Write-Host "  $_" } }
 Write-Host ''
 $note = Read-Host 'New note (Enter to finish)'
 while($note){
   Add-Content $notesFile ("{0} [{1}] {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm'),$env:USERNAME,$note)
   Write-Host '[OK] Note added.'
   $note = Read-Host 'Next note (Enter to finish)'
 }
 Write-Host "Notes file: $notesFile"
 Pause-Toolkit
}

function Invoke-LanguageSettings{
 Header; Log 'Ran language settings'
 Write-Host 'MENU LANGUAGE SETTINGS'
 Write-Host ' 1. English'
 Write-Host ' 2. Francais (main menu)'
 Write-Host ' 3. Ikinyarwanda (menyu nkuru - beta)'
 $c = Read-Host 'Choose'
 switch($c){
   '1'{ $script:MenuLang='EN'; Write-Host '[OK] Main menu will use English.' }
   '2'{ $script:MenuLang='FR'; Write-Host '[OK] Le menu principal utilisera le francais.' }
   '3'{ $script:MenuLang='RW'; Write-Host '[OK] Imenu nkuru ikoreshwa mu Kinyarwanda (beta).' }
   default{ Write-Host 'Unchanged.' }
 }
 Write-Host ''
 Write-Host 'NOTE: suite menus stay in English for now; full localization is on the roadmap.'
 Pause-Toolkit
}
$script:MenuLang='EN'

function Invoke-VoiceToggle{
 Header; Log 'Toggled voice guidance'
 $script:Voice = -not $script:Voice
 Write-Host "Voice guidance: $(if($script:Voice){'ON'}else{'OFF'})"
 if($script:Voice){ Speak 'Voice guidance is now enabled. Welcome to the Arcange Technician Toolkit.' }
 Pause-Toolkit
}

function Invoke-ThemeToggle{
 Header; Log 'Ran theme toggle info'
 Write-Host 'GUI THEME TOGGLE'
 Write-Host 'The GUI currently ships with a professional dark theme.'
 $pref = Read-Host 'Preferred theme: 1 dark / 2 light'
 $prefFile = Join-Path $ReportDir 'gui_theme.txt'
 if($pref -eq '2'){ 'light' | Set-Content $prefFile -Encoding UTF8; Write-Host '[OK] Saved preference: light - the GUI reads it on next start.' }
 else{ 'dark' | Set-Content $prefFile -Encoding UTF8; Write-Host '[OK] Saved preference: dark.' }
 Pause-Toolkit
}

function Invoke-UpdateChecker{
 Header; Log 'Ran update checker'
 Write-Host 'TOOLKIT UPDATE CHECKER (requires internet)'
 try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
 try {
   $rel = Invoke-RestMethod -Uri 'https://api.github.com/repos/arcange9/arcange-windows-technician-toolkit/releases/latest' -TimeoutSec 15
   Write-Host "Current version : v$Version"
   Write-Host "Latest published : $($rel.tag_name)"
   if($rel.tag_name -eq "v$Version"){ Write-Host '[OK] You are on the latest release.' }
   elseif($rel.tag_name){ Write-Host "[UPDATE AVAILABLE] Download: $($rel.zipball_url)"; Write-Host "Release notes: $($rel.html_url)" }
 } catch { Write-Host '[INFO] Could not check for updates (offline or blocked). Current version: v'$Version }
 Pause-Toolkit
}

Main
