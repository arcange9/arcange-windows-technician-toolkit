# 🛠️ Arcange Windows Technician Toolkit

**Version 0.4** • **Windows 10 & Windows 11** • **Multi-vendor PC support** • **Created by Mukamyi Izere Arcange**

A friendly, practical Windows technician toolkit for checking, diagnosing, maintaining, troubleshooting, and safely repairing PCs. It uses a simple Batch launcher with a PowerShell diagnostic engine so technicians, students, IT support teams, and everyday users can work through common Windows problems in a structured way.

> **Supported operating systems: Windows 10 and Windows 11.**

## ✨ What's new in v0.3

- Windows Update diagnostics and service checks
- Guided network troubleshooting wizard with a basic health score
- Advanced storage diagnostics and reliability counters where supported
- Low-free-space detection
- Windows Error Analyzer with common-event explanations and recommendations
- Technician Case IDs for each session
- TXT, JSON, and HTML diagnostic report export
- Health summary in full reports
- Windows Update service restart and cache-reset repair options
- Automatic PC manufacturer and model detection
- Vendor-independent diagnostics using standard Windows APIs and tools
- Expanded technician workflow: **Scan → Analyze → Explain → Recommend → Confirm → Repair → Verify → Report**
- Continued confirmation prompts and administrator checks for impactful repairs

## 🖥️ Multi-vendor compatibility

The toolkit is designed to work across common Windows PC manufacturers instead of being locked to one brand.

Examples include:

- HP / EliteBook / ProBook / Pavilion
- Dell / Latitude / Inspiron / Precision
- Lenovo / ThinkPad / IdeaPad / Yoga
- Acer / Aspire / TravelMate
- ASUS / VivoBook / ZenBook / TUF
- MSI
- Microsoft Surface
- Custom-built desktop PCs
- Other Windows 10 and Windows 11 compatible PCs

The toolkit automatically detects the **manufacturer, model, and platform type** through standard Windows system information. Diagnostics primarily use Windows/CIM/WMI, Plug and Play, networking, storage, security, and system-management interfaces rather than manufacturer-specific utilities.

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

### v0.4 — Current release

Professional offline GUI, 50+ technician actions, multi-vendor diagnostics, Windows Update checks, guided network troubleshooting, advanced storage checks, error analysis, Case IDs, automatic hardware vendor detection, and local reporting.

### Future releases

- More automated problem classification
- More detailed driver analysis
- Better error-code and exit-code handling
- Hardware temperature information where reliably available
- Optional PDF export
- Automated test suite and GitHub Actions validation
- Optional vendor-aware modules for special hardware features
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
