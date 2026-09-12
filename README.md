# 🛠️ Arcange Windows Technician Toolkit

**Version 0.6** • **Windows 10 & Windows 11** • **Multi-vendor PC support** • **Created by Mukamyi Izere Arcange**

A friendly, practical Windows technician toolkit for checking, diagnosing, maintaining, troubleshooting, and safely repairing PCs. It uses a simple Batch launcher with a PowerShell diagnostic engine so technicians, students, IT support teams, and everyday users can work through common Windows problems in a structured way.

> **Supported operating systems: Windows 10 and Windows 11.**

## ✨ What's new in v0.6 — the 100-feature release

v0.6 adds **100 new features** organized into six themed suites (menu 17–22), on top of everything from v0.5:

**Hardware Test Suite (menu 17)** — CPU stress test with thermal watch, RAM test launcher, disk speed benchmark, SMART dump with plain-English meanings, battery wear analysis, dead-pixel test, keyboard tester, webcam and audio diagnostics, USB speed detection, thermal report, GPU check, display audit, touchscreen check, Bluetooth scan, BIOS/UEFI report, CPU temperature, motherboard report, power event analysis, printer diagnostics.

**Network Pro Suite (menu 18)** — internet speed test, Wi-Fi channel congestion analysis, local network scanner, port scanner, DNS benchmark, packet loss test, public IP/ISP info, VPN detection, firewall audit, gateway identification, NIC driver check, MAC randomization check, DNS leak test, hosts file integrity, proxy audit, Ethernet vs Wi-Fi comparison, saved Wi-Fi history, Wi-Fi password recovery (admin), latency test, network backup + reset.

**Windows Health Suite (menu 19)** — BSOD analyzer, boot time history, activation check, restore points, outdated driver finder, driver package cleaner, Windows Update stuck-fixer, services optimizer, system file change monitor, event log export, corrupt profile detector, disk error history, RAM-hungry process finder, reliability summary, pending reboot detector, Defender scan + quarantine review, uptime analysis, page file advisor, time sync check.

**Cleanup and Speed Suite (menu 20)** — software inventory export, startup manager, scheduled tasks auditor, largest files finder, cleanup calculator, duplicate file detector, browser cache report, bloatware uninstaller, empty folder cleaner, temp cleaner, recycle bin audit, prefetch cleaner, WinSxS analyzer, hibernation advisor, before/after tune report.

**Security Suite (menu 21)** — password age audit, admin exposure check, UAC verification, SMBv1/legacy protocol check, shared folder audit, BitLocker status, RDP exposure check, suspicious startup script detector, certificate anomaly check, and a 0–100 security baseline score.

**Technician Workflow Suite (menu 22)** — client case database, before/after repair comparison, PDF export, email report to client, QR code for report summary, scheduled weekly health checks, remote-assist prep page, bootable USB guide, warranty checker by serial, repair price estimator (RWF), case notes, language settings (English/Français/Kinyarwanda menu beta), voice guidance, GUI theme preference, and a toolkit update checker.

Some features need internet (speed test, public IP, QR, update check) or Administrator rights (Wi-Fi passwords, Defender scans, scheduled tasks); the toolkit degrades gracefully when they are unavailable.


## 🖥️ Multi-vendor compatibility

The toolkit is designed to work across common Windows PC manufacturers instead of being locked to one brand.

Recognized vendors and product families include:

- HP / EliteBook / ProBook / ZBook / Spectre / Envy / Pavilion / Omen / Victus
- Dell / Latitude / Inspiron / OptiPlex / Precision / XPS / Vostro / Alienware
- Lenovo / ThinkPad / ThinkCentre / ThinkBook / IdeaPad / IdeaCentre / Yoga / Legion / LOQ
- Acer Group (Acer, Gateway, eMachines, Packard Bell) / Aspire / Swift / Spin / TravelMate / Predator / Nitro
- ASUS / VivoBook / ZenBook / ExpertBook / ProArt / ROG / TUF
- MSI / Katana / Raider / Titan / Stealth / Prestige / Modern / Cyborg
- Microsoft Surface / Surface Pro / Surface Laptop / Surface Go / Surface Book
- Samsung / Galaxy Book
- Toshiba / Dynabook / Satellite / Portege / Tecra
- Fujitsu / LIFEBOOK / ESPRIMO / Stylistic / Celsius
- Panasonic / Toughbook
- Apple (Windows on Mac via Boot Camp) / MacBook / iMac / Mac mini
- HUAWEI / MateBook
- HONOR / MagicBook
- Xiaomi / Redmi / Mi NoteBook / RedmiBook
- LG / Gram / UltraPC
- Razer / Blade
- GIGABYTE / AERO / AORUS
- VAIO / Sony / VAIO SX
- Medion / Akoya / Erazer
- ODM and custom-built PCs (Clevo, TongFang, Quanta, Compal, PCSpecialist, System76, and others)
- Other Windows 10 and Windows 11 compatible PCs

The toolkit automatically detects the **manufacturer, model, platform type, vendor brand, and product series** through standard Windows system information, and shows a **Vendor Support Profile** with the official support site and recommended vendor tools (menu option 16). Diagnostics primarily use Windows/CIM/WMI, Plug and Play, networking, storage, security, and system-management interfaces rather than manufacturer-specific utilities.

This means the same toolkit can be used on an HP today and a Dell, Lenovo, Acer, ASUS, MSI, Surface, or custom PC tomorrow.

> **Important:** “Multi-vendor” does not mean every feature is guaranteed on every machine. Some hardware information depends on the Windows version, drivers, firmware, permissions, and hardware capabilities. Vendor-specific BIOS or hardware tools may still be required for certain advanced cases.

## 🔎 Core capabilities

- 🖥️ Automatic manufacturer and model detection
- ⚙️ CPU, RAM, BIOS/UEFI and motherboard information
- 🧩 Plug and Play problem-device detection
- 🎮 GPU/display information
- 🔌 USB device diagnostics
- 🌐 Network, gateway, internet, DNS and HTTPS diagnostics
- 🧭 Guided network troubleshooting wizard
- 💾 Storage, volumes and read-only CHKDSK checks
- 📊 Advanced storage health/reliability information where supported
- 🪟 SFC, DISM and recent Windows error diagnostics
- 🔄 Windows Update service and history diagnostics
- 🚗 Driver and driver-package inspection
- 🔋 Battery diagnostics and battery reports
- 🛡️ Firewall and Microsoft Defender status
- 🔍 Windows Error Analyzer
- 🔧 Controlled Windows/network repair actions
- 📋 TXT, JSON and HTML technician reports
- 🆔 Session Case IDs
- 📝 Session and action logging
- 📁 Local report storage
- 🙂 Simple menu designed for both beginners and technicians

## 🚀 Quick start

1. Download or clone this repository.
2. Open the project folder.
3. Run **`Arcange-Technician-Toolkit.bat`**.
4. Choose a diagnostic option.
5. Review the results and recommendations.
6. Use Repair Center only when appropriate and authorized.
7. Generate a full report when needed.

Administrator permission is recommended for repair operations. Only perform repairs when you have appropriate authorization.

## 📂 Project structure

```text
arcange-windows-technician-toolkit/
├── Arcange-Technician-Toolkit.bat
├── src/
│   └── Arcange-Technician.ps1
├── reports/
│   └── .gitkeep
├── .gitignore
├── LICENSE
└── README.md
```

## 🧑‍🔧 Technician workflow

**Scan → Analyze → Explain → Recommend → Confirm → Repair → Verify → Report**

Each session receives a Case ID such as `AWT-20260906-120000`. The toolkit records important actions in the session log and can generate TXT, JSON, and HTML reports for later review.

## 📊 Reporting

Version 0.3 can generate three local report formats:

- **TXT** — easy to read and share
- **JSON** — useful for future automation and integrations
- **HTML** — readable technician report with a health summary

Reports include detected manufacturer/model information and are saved in the local `reports/` folder. They are not uploaded automatically.

## 🔐 Safety & limitations

This project is intended for legitimate PC maintenance, troubleshooting, education, and authorized technician work.

The toolkit performs software-level checks, but software cannot reliably detect every physical hardware fault. Problems involving a damaged motherboard, power supply, cable, connector, or certain intermittent hardware failures may require physical inspection and dedicated diagnostic equipment.

Repair options can change Windows or network configuration. The toolkit therefore uses confirmation prompts for important repair actions and checks administrator status.

The Windows Update cache reset renames the existing `SoftwareDistribution` folder rather than deleting it directly, but it should still only be performed when appropriate and with authorization.

The toolkit does not automatically modify boot configuration or perform destructive disk operations.

**Always back up important data before significant repair work.**

## 🪟 Compatibility

This release supports:

- **Windows 10**
- **Windows 11**
- Windows PowerShell 5.1 or later
- Major PC manufacturers and compatible custom-built systems

Individual features may depend on the Windows edition/build, permissions, hardware, drivers, firmware, and available Windows components. Advanced storage reliability counters are only shown when the system exposes them.

## 📈 Roadmap

### v0.6 — Current release

The 100-feature release: six themed suites (Hardware Test, Network Pro, Windows Health, Cleanup and Speed, Security, Technician Workflow) on top of worldwide vendor support profiles, GUI section shortcuts, offline GUI, and local TXT/JSON/HTML reporting.

### Future releases

- More automated problem classification
- More detailed driver analysis
- Better error-code and exit-code handling
- Hardware temperature information where reliably available
- Optional PDF export
- Automated test suite and GitHub Actions validation
- Deeper vendor-aware modules for special hardware features (BIOS/firmware tool integration)
- Authorized remote-support capabilities

## 📜 License

Released under the **MIT License**. See [LICENSE](LICENSE).

## 👨‍💻 About

**Arcange Windows Technician Toolkit** is a practical Computer Systems and Architecture project created by **Mukamyi Izere Arcange**.

The project was created with a simple idea: Windows troubleshooting should be **organized, understandable, safe, and friendly**. It brings commonly useful Windows diagnostic and maintenance tools into one place so that learners and technicians can follow a consistent troubleshooting workflow instead of remembering many separate commands.

This project is also intended as a learning and development platform. As it grows, the goal is to improve compatibility, diagnostics, reporting, usability, and technician workflow while keeping the tool approachable for normal PC users.

If you discover a bug, have a useful feature idea, or find a way to make the toolkit safer and easier to use, please open a GitHub issue or contribute to the project.

### ❤️ Thanks for using this service

**Thank you for using Arcange Windows Technician Toolkit!**

Created to make Windows PC troubleshooting simpler, friendlier, and more practical for everyone.

— **Mukamyi Izere Arcange**
