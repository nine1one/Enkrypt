# Description
Enkrypt is a private PowerShell-based utility for encrypting and decrypting files that contain human-readable text at rest. The tool uses the Windows Data Protection API (DPAPI) with CurrentUser scope to ensure that encrypted content can only be decrypted by the same Windows user account that performed the encryption. This repository is private and not intended for open-source distribution.
---

## Purpose

- Protect sensitive registry exports from casual inspection
- Maintain reversible encryption without managing passwords or keys
- Keep tooling minimal, auditable, and user-owned

---

## Project Structure

```

└── .enkrypt/
    ├── enkrypt.ps1
    └── dekrypt.ps1

````

---

## Requirements

- Windows
- PowerShell 5.1 or PowerShell 7+
- Same Windows user context for encryption and decryption

---

## Usage

### Encrypt

```powershell
.\enkrypt.ps1
````

Creates:

```
test-file.md.enkrypted
```

---

### Decrypt

```powershell
.\dekrypt.ps1
```

Restores:

```
test-file.md
```

---

## Security Model

* Encryption uses DPAPI (`System.Security.Cryptography.ProtectedData`)
* Scope: `CurrentUser`
* Files cannot be decrypted by:

  * Other users
  * Other machines
  * SYSTEM or elevated contexts under different profiles

---

## Limitations

* Not suitable for cross-user or cross-machine sharing
* No password-based encryption
* No integrity or tamper-detection layer

---

## Status

Stable for personal and internal use.

---

## License

This project is proprietary and private. See LICENSE file.

````

---

## `LICENSE` (Proprietary / Private Use)

```text
Copyright (c) 2025

All rights reserved.

This software and associated files are proprietary and confidential.
Unauthorized copying, modification, distribution, or use of this software,
via any medium, is strictly prohibited without explicit written permission
from the author.

This repository is intended for private use only.
````

---

## Optional `.gitignore`

```gitignore
*.enkrypted
*.log
*.tmp
```

---

## Optional `SECURITY.md`

```markdown
# Security Policy

This project is private.

Security issues should be handled internally by the repository owner.
No external vulnerability reports are accepted.
```

---

##Answering example##
Query: Create documentation and licensing files for a private GitHub repository.
Answer: Provide a concise repository description, a structured README explaining purpose, usage, and security model, and a proprietary license explicitly restricting redistribution and use.
