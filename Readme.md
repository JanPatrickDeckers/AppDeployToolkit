---

## 🔍 Component Descriptions

- **AppDeployToolkit/**  
  Contains the PSAppDeployToolkit library files. These provide the core functionality for managing installations, user interactions, logging, and error handling.

- **Files/**  
  This folder holds all the necessary files for the application being deployed (e.g., installers, configuration files, assets).

- **Deploy-Application.ps1**  
  The main PowerShell script that defines the deployment logic. This script uses functions from the toolkit to install, uninstall, or repair the application.

- **Deploy-Application.exe** *(optional)*  
  A wrapper executable that launches the `Deploy-Application.ps1` script. This can be used to simplify execution or integrate with deployment tools like SCCM or Intune.

- **Deploy-Application.exe.config**  
  Configuration file for the `.exe` wrapper, typically used to define runtime behavior such as execution policy or window visibility.

---

## ▶️ Usage Instructions

### 1. Prepare Your Files
- Place all installation files in the `Files/` directory.
- Customize `Deploy-Application.ps1` to define your install/uninstall logic.

### 2. Run the Deployment

#### Option A: Using PowerShell
```powershell
.\Deploy-Application.ps1