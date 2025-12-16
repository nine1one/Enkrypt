# Enkrypt

**Enkrypt** is a lightweight, PowerShell-based utility designed for secure, user-bound file encryption on Windows. By leveraging the **Windows Data Protection API (DPAPI)**, it ensures that your sensitive files can only be decrypted by *you*—the user who encrypted them—on the same machine.

> **Status**: Open Source
> **Version**: 1.0.0

---

## 🚀 Features

-   **Seamless Integration**: Uses native Windows APIs (DPAPI) via PowerShell.
-   **Zero Key Management**: No passwords to remember or keys to manage; your Windows identity is the key.
-   **In-Place Operation**: Automatically replaces the source file with its encrypted counterpart (and vice-versa) to prevent data leaks.
-   **Minimal Footprint**: Pure PowerShell implementation with no external dependencies.

## 🛠 Usage

### Prerequisites
-   **OS**: Windows 10/11 or Server.
-   **Shell**: PowerShell 5.1 or PowerShell Core 7+.

### Quick Start

The toolkit consists of two primary scripts:

#### 1. Encrypt a File
Secure a clear-text file. This will generate an `.enkrypted` file and safely remove the original.

```powershell
.\enkrypt.ps1 -Path ".\secret-data.txt"
```

**Result**: `secret-data.txt` is removed, and `secret-data.txt.enkrypted` is created.

#### 2. Decrypt a File
Restore an encrypted file to its original state.

```powershell
.\dekrypt.ps1 -Path ".\secret-data.txt.enkrypted"
```

**Result**: `secret-data.txt.enkrypted` is removed, and `secret-data.txt` is restored.

---

## 🔒 Security Model

Enkrypt utilizes `System.Security.Cryptography.ProtectedData` with the **CurrentUser** scope.

| Allowed                   | Blocked                                       |
| :------------------------ | :-------------------------------------------- |
| ✅ You (Same User Profile) | ❌ Other Users on the same PC                  |
| ✅ Same Machine            | ❌ Other Machines (even with same credentials) |
|                           | ❌ SYSTEM account or Admins                    |

**⚠️ Critical Warning**: Because the encryption key is tied to your Windows User Profile:
1.  **Do not** lose access to your Windows account. Resetting your password via administrative force (outside of normal change flows) may result in permanent data loss.
2.  **Do not** transfer `.enkrypted` files to other machines; they cannot be decrypted there.

## 📂 Project Structure

```text
.
├── enkrypt.ps1         # Encryption logic
├── dekrypt.ps1         # Decryption logic
├── readme.md           # This documentation
└── LICENSE             # MIT License
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
