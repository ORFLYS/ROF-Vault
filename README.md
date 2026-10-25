<p align="center">
  <img src="assets/icon.png" width="128" height="128" alt="ROF Vault Logo" />
</p>

<h1 align="center">ROF Vault</h1>

<p align="center">
  <b>Military-Grade Personal Digital Vault for Windows</b><br>
  <i>خزنة رقمية مفتوحة المصدر مشفرة وفائقة الأمان لنظام ويندوز لحماية بياناتك وملفاتك الحساسة</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?logo=windows&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/Flutter-3.41%2B-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Encryption-AES--256--GCM-success?logo=lock&logoColor=white" alt="AES-256-GCM" />
  <img src="https://img.shields.io/badge/Architecture-Offline--First-blueviolet" alt="Offline-First" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT" /></a>
  <img src="https://img.shields.io/badge/Developer-ORFLYS-blue" alt="Developer" />
</p>

<p align="center">
  <a href="https://apps.microsoft.com/detail/9nfq9t88z30m" target="_blank">
    <img src="https://get.microsoft.com/images/en-us%20dark.svg" width="220" alt="Download from Microsoft Store" />
  </a>
</p>

---

## 📖 Overview | نبذة عن البرنامج

**ROF Vault** is an open-source, ultra-secure personal digital vault designed natively for Windows 10 and Windows 11. Built with military-grade **AES-256-GCM** encryption and an **offline-first** philosophy, ROF Vault gives you complete control over your private files, credentials, documents, and notes without third-party tracking, telemetry, or ads.

**برنامج ROF Vault** هو خزنة رقمية شخصية مفتوحة المصدر متطورة وفائقة الأمان مخصصة لأجهزة نظام Windows، مصممة لحماية بياناتك وملفاتك الحساسة بأعلى معايير الخصوصية والتشفير. يعتمد البرنامج على خوارزمية التشفير العسكري **AES-256-GCM** مع بنية تعمل محلياً بالكامل دون أي تعقب أو إعلانات.

---

## 📥 Download from Microsoft Store | التحميل الرسمي

The official and recommended way to install and receive automatic updates for **ROF Vault** is through the **Microsoft Store**:

<p align="center">
  <a href="https://apps.microsoft.com/detail/9nfq9t88z30m" target="_blank">
    <img src="https://get.microsoft.com/images/en-us%20dark.svg" width="240" alt="Get it from Microsoft Store" />
  </a>
</p>

* ✅ **Automatic Updates:** Always run the latest release with zero manual hassle.
* ✅ **Microsoft Verified:** Scanned, certified, and digitally signed for Windows.
* ✅ **100% Free & Private:** No ads, no hidden subscriptions, and zero tracking.

---

## 📸 Screenshots | لقطات الشاشة الرسمية

<div align="center">
  <table>
    <tr>
      <td width="50%">
        <b>🔐 Sign In & Authentication</b><br>
        <img src="screenshots/01_signin.png" alt="Sign In Screen" width="100%" />
      </td>
      <td width="50%">
        <b>🗂️ Vault Dashboard (Light Mode)</b><br>
        <img src="screenshots/02_dashboard_light.png" alt="Dashboard Light Mode" width="100%" />
      </td>
    </tr>
    <tr>
      <td width="50%">
        <b>☁️ Encrypted Cloud Backup (Google Drive)</b><br>
        <img src="screenshots/03_cloud_backup.png" alt="Encrypted Cloud Backup" width="100%" />
      </td>
      <td width="50%">
        <b>⚙️ Settings & Security Controls</b><br>
        <img src="screenshots/04_settings.png" alt="Settings & Security" width="100%" />
      </td>
    </tr>
    <tr>
      <td colspan="2" align="center">
        <b>🌙 Vault Dashboard (Dark Mode)</b><br>
        <img src="screenshots/05_dashboard_dark.png" alt="Dashboard Dark Mode" width="70%" />
      </td>
    </tr>
  </table>
</div>

---

## ✨ Key Features | المميزات الرئيسية

* 🛡️ **Military-Grade Encryption:** Local AES-256-GCM cryptographic protection ensures data is encrypted before reaching disk or cloud.
* 📦 **6-in-1 Comprehensive Vault:**
  * **🖼️ Media Gallery:** Secure viewing and storage of private photos and videos.
  * **📄 Documents Locker:** Confidential PDF and file storage.
  * **🔑 Passwords & Accounts:** Organized credentials manager with quick-copy buttons.
  * **📝 Encrypted Notes:** Secure notepad for private ideas, recovery seeds, and memos.
  * **💳 Payment Cards:** Encrypted storage for debit/credit card details.
  * **🪪 Identity Records:** Safe storage for national IDs, passports, and licenses.
* ☁️ **Encrypted Google Drive Backup:** Seamless, zero-knowledge cloud backup and restore. Files are fully encrypted before leaving your machine.
* ⏱️ **Intelligent Auto-Lock:** Configurable inactivity timers to automatically lock your vault.
* 🌐 **Offline-First Privacy:** Zero ads, zero background telemetry, and zero tracking. Your data stays with you.
* 🖥️ **Windows Desktop Native UI:** Optimized with mouse controls, right-click context menus, physical keyboard support, and Light/Dark theme switching.

---

## 🔒 Security Architecture | معمارية الأمان

```
[ User Input / Files ]
         │
         ▼
[ PBKDF2 Key Derivation + Master Key / PIN ]
         │
         ▼
[ AES-256-GCM Authenticated Encryption ]
         │
    ┌────┴───────────────────────────┐
    ▼                                ▼
[ Local Encrypted Storage ]   [ Encrypted Cloud Sync (Google Drive) ]
(Zero Plaintext on Disk)       (Zero-Knowledge to Provider)
```

1. **Client-Side Encryption:** All encryption/decryption keys are derived on the client machine using cryptographically secure algorithms.
2. **Encrypted at Rest:** Data on disk remains completely unreadable without the user's master credentials.
3. **Safe Cloud Sync:** Google Drive backup sends ciphertext only; Google never receives decryption keys or plaintext content.

---

## 💻 System Requirements | متطلبات التشغيل

* **Operating System:** Windows 10 (64-bit) / Windows 11 (64-bit)
* **Processor:** 1.5 GHz or faster (x64)
* **Memory:** 2 GB RAM (4 GB recommended)
* **Storage:** 200 MB free disk space

---

## 🛠️ Building From Source | بناء المشروع من المصدر

### Prerequisites
* [Flutter SDK](https://flutter.dev) (v3.24+ recommended)
* [Visual Studio](https://visualstudio.microsoft.com/) with "Desktop development with C++" workload installed
* Git

### Steps
```bash
# 1. Clone repository
git clone https://github.com/ORFLYS/ROF-Vault.git
cd ROF-Vault

# 2. Fetch dependencies
flutter pub get

# 3. Run in debug mode on Windows
flutter run -d windows

# 4. Build release executable
flutter build windows --release

# 5. Build MSIX Store Package (optional)
dart run msix:create
```

---

## 📄 License | الترخيص

This project is open-source and licensed under the **[MIT License](LICENSE)**.
You are free to use, modify, and distribute this software in accordance with the terms of the MIT License.

هذا المشروع مفتوح المصدر ومرخص بموجب **[رخصة MIT](LICENSE)**.
يحق لك وللجميع استخدام هذا البرنامج، وتعديله، وإعادة توزيعه بحرية تامة وفق شروط رخصة MIT.

---

## 👨‍💻 Developer & Publisher

* **Publisher:** [ORFLYS](https://orflys.com)
* **Website:** https://orflys.com
* **Store Product:** [ROF Vault on Microsoft Store](https://apps.microsoft.com/detail/9nfq9t88z30m)

---

<p align="center">
  <sub>Developed with ❤️ by <b>ORFLYS</b>. Licensed under the <a href="LICENSE">MIT License</a>.</sub>
</p>
