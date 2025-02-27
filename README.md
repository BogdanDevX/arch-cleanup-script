# Arch Linux Cleanup Script

## Overview

🚀 A lightweight Bash script for Arch Linux maintenance. Features include full system cleanup, package integrity checks, AUR updates (yay/paru), and service optimization.

## Features

✅ **Full System Cleanup** – Removes old package cache, orphaned packages, temporary files, and logs.\
✅ **Clear User Cache** – Cleans personal cache files to free up disk space.\
✅ **Repair Broken Packages** – Detects and reinstalls missing or corrupted packages.\
✅ **Delete Old Downloads** – Removes files in `~/Downloads` older than 30 days.\
✅ **Update AUR Packages** – Updates installed AUR packages using `yay` or `paru`.\
✅ **Disable Unused Services** – Detects and allows disabling unnecessary systemd services.

## Installation

Clone the repository and make the script executable:

```bash
git clone https://github.com/BogdanDevX/arch-cleanup-script.git
cd arch-cleanup-script
chmod +x arch-cleanup.sh
```

## Usage

Run the script with:

```bash
./arch-cleanup.sh
```

You'll be presented with an interactive menu:

```
Arch Linux Maintenance Menu:
1) Full Cleanup (Recommended)
----------------------------------------
2) Clear user cache
3) Repair missing or broken packages
4) Delete downloads older than 30 days
5) Update AUR Packages (yay/paru)
6) Disable Unused Services
0) Exit
```

Select an option by entering the corresponding number.

## Requirements

Ensure you have the following installed:

- `pacman` (default package manager for Arch Linux)
- `yay` or `paru` (for AUR package updates, optional)
- `pacman-contrib` (for `paccache` command, recommended)

To install missing dependencies:

```bash
sudo pacman -S pacman-contrib
```

## Notes

- Running this script **requires root privileges** for certain operations (e.g., removing system logs, updating packages).
- If `yay` or `paru` is not installed, AUR updates will be skipped.

## License

This project is licensed under the MIT License - feel free to use and modify it!

## Author

Created by **[BogdanDevX](https://github.com/BogdanDevX)**
---

🚀 **Keep your Arch Linux system clean and optimized with ease!**

