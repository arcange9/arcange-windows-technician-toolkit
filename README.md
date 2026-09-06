# 🛠️ Arcange Windows Technician Toolkit

**Version 0.3** • **Windows 10 & Windows 11** • **Created by Mukamyi Izere Arcange**

A friendly, practical Windows technician toolkit for checking, diagnosing, maintaining, troubleshooting, and safely repairing PCs. It uses a simple Batch launcher with a PowerShell diagnostic engine so technicians, students, IT support teams, and everyday users can work through common Windows problems in a structured way.

> **Supported operating systems: Windows 10 and Windows 11 only.**

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
- Expanded technician workflow: **Scan → Analyze → Explain → Recommend → Confirm → Repair → Verify → Report**
- Continued confirmation prompts and administrator checks for impactful repairs

## 🔎 Core capabilities

- 🖥️ System and Windows information
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

Reports are saved in the local `reports/` folder and are not uploaded automatically.

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

Individual features may depend on the Windows edition/build, permissions, hardware, drivers, and available Windows components. Advanced storage reliability counters are only shown when the system exposes them.

## 📈 Roadmap

### v0.3 — Current release

Professional diagnostics, Windows Update checks, guided network troubleshooting, advanced storage checks, error analysis, Case IDs, and TXT/JSON/HTML reporting.

### Future releases

- More automated problem classification
- More detailed driver analysis
- Better error-code and exit-code handling
- Hardware temperature information where reliably available
- Optional graphical interface
- Optional PDF export
- Automated test suite and GitHub Actions validation
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
