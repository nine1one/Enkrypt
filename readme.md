# Enkrypt V2

**Enkrypt** is a production-grade, PowerShell-based utility for secure file encryption on Windows. It implements an **Envelope Encryption** model, protecting your data with **AES-256-GCM** while securing the encryption keys using the **Windows Data Protection API (DPAPI)**.

> **Status**: Production Ready (V2)
> **Version**: 2.0.0
> **Cryptography**: AES-256-GCM + DPAPI
> **Format**: JSON Header + Binary Ciphertext

---

## 🚀 Key Features

*   **Production-Grade Cryptography**: Uses **AES-GCM** (Galois/Counter Mode) for authenticated encryption, ensuring both confidentiality and integrity.
*   **Envelope Encryption**: Data is encrypted with a unique random key; that key is separately protected by your Windows identity.
*   **Tamper Evidence**: GCM ensures that any modification to the encrypted file is detected, preventing decryption of corrupted or malicious data.
*   **Metadata Header**: Files include a generic JSON header (version, algorithm info, IV, etc.) for future-proofing and auditability.
*   **In-Place Operation**: Automatically replaces the source file with its encrypted counterpart (`.enkrypted`) to prevent data leaks.

---

## 🛠 Usage

### Prerequisites

*   **OS**: Windows 10/11 or Server.
*   **Environment**: PowerShell 7+ recommended (or .NET Framework 4.7+ environment).

### Commands

#### 1. Encrypt a File
Secure a file. Generates a random AES key, encrypts the data, wraps the key, and saves the result `[filename].enkrypted`.

```powershell
.\enkrypt.ps1 -Path ".\secret-data.txt"
```

#### 2. Decrypt a File
Restore an encrypted file. Validates integrity (AuthTag) before releasing data.

```powershell
.\dekrypt.ps1 -Path ".\secret-data.txt.enkrypted"
```

---

## 🔒 Security Model

**Enkrypt V2** uses a hybrid approach:

1.  **Data Layer**: `AES-256-GCM`
    *   Protecting the actual file content.
    *   Unique 96-bit Nonce (IV) per file.
    *   128-bit Authentication Tag.
2.  **Key Layer**: `DPAPI` (CurrentUser)
    *   Protecting the AES key.
    *   The AES key is wrapped and stored in the file header.

### Recovery
*   Files can **only** be decrypted by the **user** who encrypted them, on the **machine** where they were encrypted.
*   If you lose your Windows profile, you lose the data (standard DPAPI behavior).

---

## 📂 Project Structure

```text
.
├── Enkrypt.psm1        # Core Crypto Module (New-EnkryptKey, Protect-File, etc.)
├── enkrypt.ps1         # CLI Wrapper for Encryption
├── dekrypt.ps1         # CLI Wrapper for Decryption
└── system-upgrade.md   # Design & Upgrade Notes
```
