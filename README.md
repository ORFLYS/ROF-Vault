<p align="center">
  <img src="assets/icon.png" width="128" height="128" alt="ROF Vault Logo" />
</p>

<h1 align="center">ROF Vault</h1>

<p align="center">
  <b>Military-Grade Personal Digital Vault for Windows</b><br>
  <i>خزنة رقمية مشفرة وفائقة الأمان لنظام ويندوز لحماية بياناتك وملفاتك الحساسة</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?logo=windows&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/Encryption-AES--256--GCM-success?logo=lock&logoColor=white" alt="AES-256-GCM" />
  <img src="https://img.shields.io/badge/Architecture-Offline--First-blueviolet" alt="Offline-First" />
  <img src="https://img.shields.io/badge/Developer-ORFLYS-blue" alt="Developer" />
</p>

<p align="center">
  <a href="https://apps.microsoft.com/detail/9nfq9t88z30m" target="_blank">
    <img src="https://get.microsoft.com/images/en-us%20dark.svg" width="220" alt="Download from Microsoft Store" />
  </a>
</p>

---

## 📖 Overview | نبذة عن البرنامج

**ROF Vault** is an advanced, ultra-secure personal digital vault designed natively for Windows 10 and Windows 11. Built with military-grade **AES-256-GCM** encryption and an **offline-first** philosophy, ROF Vault gives you complete control over your private files, credentials, documents, and notes without third-party tracking, telemetry, or ads.

**برنامج ROF Vault** هو خزنة رقمية شخصية متطورة وفائقة الأمان مخصصة لأجهزة نظام Windows، مصممة لحماية بياناتك وملفاتك الحساسة بأعلى معايير الخصوصية والتشفير. يعتمد البرنامج على خوارزمية التشفير العسكري **AES-256-GCM** مع بنية تعمل محلياً بالكامل دون أي تعقب أو إعلانات.

---

## 📥 Download from Microsoft Store | التحميل الرسمي

The official way to download, install, and receive automatic updates for **ROF Vault** is through the **Microsoft Store**:

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

## 👨‍💻 Developer & Publisher

* **Publisher:** [ORFLYS](https://orflys.com)
* **Website:** https://orflys.com
* **Store Product:** [ROF Vault on Microsoft Store](https://apps.microsoft.com/detail/9nfq9t88z30m)

---

<p align="center">
  <sub>Copyright © 2026 <b>ORFLYS</b>. All rights reserved.</sub>
</p>
