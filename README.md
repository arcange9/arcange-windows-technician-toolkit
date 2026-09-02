# 🛠️ Arcange Windows Technician Toolkit

**Version 0.2** • **Windows 10 & Windows 11** • **Created by Mukamyi Izere Arcange**

A friendly, practical Windows technician toolkit for checking, diagnosing, maintaining, and troubleshooting PCs. It uses a simple Batch launcher with a PowerShell diagnostic engine so technicians, students, IT support teams, and everyday users can work through common Windows problems in a structured way.

> **Supported operating systems: Windows 10 and Windows 11 only.**

## ✨ What's new in v0.2

- Safer confirmation prompts before repair actions
- Administrator-status detection
- Improved hardware diagnostics
- USB device diagnostics
- Driver diagnostics and driver-package inventory
- Battery information and automatic battery HTML reports
- Microsoft Defender and Windows Firewall status
- HTTPS connectivity testing
- Selected automatic-service health checks
- Improved full diagnostic reports
- More detailed technician session logging
- Updated branding and user-friendly exit screen

## 🔎 Core capabilities

- 🖥️ System and Windows information
- ⚙️ CPU, RAM, BIOS/UEFI and motherboard information
- 🧩 Plug and Play problem-device detection
- 🎮 GPU/display information
- 🔌 USB device diagnostics
- 🌐 Network, gateway, internet, DNS and HTTPS diagnostics
- 💾 Storage, volumes and read-only CHKDSK checks
- 🪟 SFC, DISM and recent Windows error diagnostics
- 🚗 Driver and driver-package inspection
- 🔋 Battery diagnostics and battery reports
- 🛡️ Firewall and Microsoft Defender status
- 🔧 Controlled Windows/network repair actions
- 📋 Full technician diagnostic reports
- 📝 Session and action logging
- 📁 Local report storage
- 🙂 Simple menu designed for both beginners and technicians

## 🚀 Quick start

1. Download or clone this repository.
2. Open the project folder.
3. Run **`Arcange-Technician-Toolkit.bat`**.
4. Choose a diagnostic option.
5. Review the results.
6. Generate a full report when needed.

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

**Identify → Collect information → Diagnose → Recommend → Confirm → Repair → Verify → Report**

The toolkit is designed to encourage diagnosis before repair and to keep a record of important actions performed during a technician session.

## 🔐 Safety & limitations

This project is intended for legitimate PC maintenance, troubleshooting, education, and authorized technician work.

The toolkit performs software-level checks, but software cannot reliably detect every physical hardware fault. Problems involving a damaged motherboard, power supply, cable, connector, or certain intermittent hardware failures may require physical inspection and dedicated diagnostic equipment.

Repair options can change Windows or network configuration. The toolkit therefore uses confirmation prompts for important repair actions.

The toolkit does not automatically modify boot configuration or perform destructive disk operations.

**Always back up important data before significant repair work.**

## 🪟 Compatibility

This release supports:

- **Windows 10**
- **Windows 11**
- Windows PowerShell 5.1 or later

Individual features may depend on the Windows edition/build, permissions, hardware, drivers, and available Windows components.

## 📈 Roadmap

### v0.2 — Current release

Core diagnostics, safer repairs, driver/battery/security checks, improved reporting and technician logging.

### Future releases

- Automated problem classification
- More detailed driver analysis
- Windows Update diagnostics
- Advanced storage reliability information where supported
- More network troubleshooting tests
- Technician/customer case IDs
- HTML/JSON/PDF report export
- Better error and exit-code handling
- Hardware temperature information where reliably available
- Optional graphical interface
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
