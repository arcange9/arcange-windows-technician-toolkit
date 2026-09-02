# 🛠️ Arcange Windows Technician Toolkit

**Version 0.1** • **Windows 10 & Windows 11** • **Created by Mukamyi Izere Arcange**

A friendly, practical Windows technician toolkit for checking, diagnosing, maintaining, and troubleshooting PCs. It combines a simple Batch launcher with a PowerShell diagnostic engine so technicians and learners can work through common Windows problems in a structured way.

> **Supported operating systems: Windows 10 and Windows 11 only.**

## ✨ What it can do

- 🖥️ System and Windows information
- ⚙️ CPU, RAM, BIOS/UEFI and motherboard information
- 🧩 Plug and Play problem-device detection
- 🎮 GPU/display information
- 🌐 Network, gateway, internet and DNS diagnostics
- 💾 Storage, volumes and read-only CHKDSK checks
- 🪟 SFC, DISM and recent Windows error diagnostics
- 🔧 Controlled network and Windows repair actions
- 📋 Full technician diagnostic reports
- 📝 Session and action logging
- 📁 Local report storage
- 🙂 Simple menu designed to be easy for beginners and technicians

## 🚀 Quick start

1. Download or clone this repository.
2. Open the project folder.
3. Run **`Arcange-Technician-Toolkit.bat`**.
4. Choose a diagnostic option.
5. Review the results.
6. Generate a full report when needed.

Administrator permission may be required for some repair operations. Only perform repairs when you have appropriate authorization.

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

## 🔐 Safety & limitations

This project is intended for legitimate PC maintenance, troubleshooting, education, and authorized technician work.

The toolkit performs many software-level checks, but no software utility can reliably detect every physical hardware fault. Problems involving components such as a damaged motherboard, power supply, cable, connector, or certain intermittent hardware failures may require physical inspection and dedicated diagnostic equipment.

The toolkit does not automatically modify boot configuration or perform destructive disk operations. Read-only diagnostics are preferred before repair actions.

**Always back up important data before significant repair work.**

## 🧑‍🔧 Technician workflow

The project follows a simple troubleshooting mindset:

**Identify → Collect information → Diagnose → Recommend → Confirm → Repair → Verify → Report**

This helps prevent unnecessary repairs and makes troubleshooting easier to document.

## 🪟 Compatibility

This release is intended for:

- Windows 10
- Windows 11
- Windows PowerShell 5.1 or later

Individual features may depend on the Windows edition/build, permissions, hardware, drivers, and available Windows components.

## 📈 Roadmap

**v0.1 — Initial release**

- Core diagnostics
- Network troubleshooting
- Storage checks
- Windows health checks
- Basic repair center
- Reports and logging

Future releases may add:

- Automated problem classification
- More detailed driver diagnostics
- Windows Update diagnostics
- Battery health analysis
- Expanded hardware information
- HTML/JSON/PDF reports
- Technician/customer case IDs
- Improved error handling and compatibility detection
- Optional graphical interface
- More advanced remote-support capabilities for authorized environments

## 📜 License

Released under the **MIT License**. See [LICENSE](LICENSE).

## 👨‍💻 About

**Arcange Windows Technician Toolkit** is a practical Computer Systems and Architecture project created by **Mukamyi Izere Arcange**.

The goal is to make Windows troubleshooting more organized, understandable, and accessible to students, independent technicians, IT support teams, and everyday PC users. The project is designed to grow over time through testing, feedback, improvements, and new technician-focused features.

If you find a problem or have an idea that could make the toolkit safer, easier, or more useful, please consider opening a GitHub issue or contributing to the project.

### ❤️ Thanks for using this service

**Thank you for using Arcange Windows Technician Toolkit!**

Created with the goal of making Windows PC troubleshooting simpler, friendlier, and more practical for everyone.

— **Mukamyi Izere Arcange**
