#!/bin/bash

# Colors for better visibility
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

# Separator for sections
SEPARATOR="${CYAN}----------------------------------------${RESET}"

# 🟢 Full system cleanup
full_cleanup() {
    echo -e "${BLUE}===== Starting Full System Cleanup =====${RESET}"
    echo -e "$SEPARATOR"

    # 1. Remove old package cache
    echo -e "${YELLOW}1. Removing old package cache...${RESET}"
    if command -v paccache &> /dev/null; then
        if sudo paccache -r; then
            echo -e "${GREEN}Old package cache removed successfully.${RESET}"
        else
            echo -e "${RED}Failed to remove old package cache.${RESET}"
        fi
    else
        echo -e "${RED}paccache not found! You may need to install 'pacman-contrib'.${RESET}"
        echo -e "${YELLOW}Run: sudo pacman -S pacman-contrib${RESET}"
    fi

    # 2. Remove entire package cache
    echo -e "${YELLOW}2. Removing entire package cache (optional)...${RESET}"
    if command -v paccache &> /dev/null; then
        if sudo paccache -r -k0; then
            echo -e "${GREEN}Entire package cache removed successfully.${RESET}"
        else
            echo -e "${RED}Failed to remove entire package cache.${RESET}"
         fi
    else
        echo -e "${RED}paccache not found! You may need to install 'pacman-contrib'.${RESET}"
        echo -e "${YELLOW}Run: sudo pacman -S pacman-contrib${RESET}"
    fi

    # 3. Remove orphaned packages
    echo -e "${YELLOW}3. Removing orphaned packages...${RESET}"
    if sudo pacman -Rns $(pacman -Qdtq) &>/dev/null; then
        echo -e "${GREEN}Orphaned packages removed successfully.${RESET}"
    else
        echo -e "${RED}No orphaned packages found or failed to remove.${RESET}"
    fi

    # 4. Clean AUR cache (if yay is installed)
    if command -v yay &> /dev/null; then
        echo -e "${YELLOW}4. Cleaning unused AUR package cache...${RESET}"
        if yay -Sc --noconfirm; then
            echo -e "${GREEN}AUR package cache cleaned successfully.${RESET}"
        else
            echo -e "${RED}Failed to clean AUR package cache.${RESET}"
        fi
    fi

    # 5. Remove temporary files
    echo -e "${YELLOW}5. Removing temporary files...${RESET}"
    if sudo rm -rf /tmp/* && sudo rm -rf /var/tmp/*; then
        echo -e "${GREEN}Temporary files removed successfully.${RESET}"
    else
        echo -e "${RED}Failed to remove temporary files.${RESET}"
    fi

    # 6. Clean old system logs
    echo -e "${YELLOW}6. Cleaning old system logs...${RESET}"
    if sudo journalctl --vacuum-time=2weeks; then
        echo -e "${GREEN}Old system logs cleaned successfully.${RESET}"
    else
        echo -e "${RED}Failed to clean old system logs.${RESET}"
    fi

    # 7. Check installed package integrity
    echo -e "${YELLOW}7. Checking installed package integrity...${RESET}"
    if sudo pacman -Qk; then
        echo -e "${GREEN}Package integrity check completed.${RESET}"
    else
        echo -e "${RED}Failed to check package integrity.${RESET}"
    fi

    # 8. Synchronize and update package database
    echo -e "${YELLOW}8. Synchronizing and updating package database...${RESET}"
    if sudo pacman -Syu; then
        echo -e "${GREEN}Package database updated successfully.${RESET}"
    else
        echo -e "${RED}Failed to update package database.${RESET}"
    fi

    echo -e "$SEPARATOR"
    echo -e "${GREEN}===== Full Cleanup Completed! =====${RESET}"
}

# 🟡 Optional maintenance tasks
clear_user_cache() {
    echo -e "${YELLOW}Clearing user cache...${RESET}"
    if rm -rf $HOME/.cache/*; then
        echo -e "${GREEN}User cache cleared successfully.${RESET}"
    else
        echo -e "${RED}Failed to clear user cache.${RESET}"
    fi
}

repair_packages() {
    echo -e "${YELLOW}Checking and repairing broken packages...${RESET}"

    # Find packages with missing files
    missing_packages=$(sudo pacman -Qk | grep '0 missing files' -v | awk '{print $1}' | sed 's/:$//' | sort -u)

    if [ -z "$missing_packages" ]; then
        echo -e "${GREEN}No broken packages found!${RESET}"
    else
        echo -e "${YELLOW}Reinstalling missing packages...${RESET}"
        if echo "$missing_packages" | xargs sudo pacman -S --noconfirm; then
            echo -e "${GREEN}Missing packages reinstalled successfully.${RESET}"
        else
            echo -e "${RED}Failed to reinstall missing packages.${RESET}"
        fi
    fi
}

delete_old_downloads() {
    echo -e "${YELLOW}Deleting downloads older than 30 days...${RESET}"
    if find $HOME/Downloads/* -mtime +30 -exec rm -rf {} \;; then
        echo -e "${GREEN}Old downloads deleted successfully.${RESET}"
    else
        echo -e "${RED}Failed to delete old downloads.${RESET}"
    fi
}

update_aur_helpers() {
    echo -e "${YELLOW}Checking for AUR updates...${RESET}"

    # Check if yay is installed and update all AUR packages
    if command -v yay &> /dev/null; then
        echo -e "${YELLOW}Updating AUR packages using yay...${RESET}"
        if yay -Syu --noconfirm; then
            echo -e "${GREEN}Yay update completed successfully.${RESET}"
        else
            echo -e "${RED}Yay update failed. Please check for issues.${RESET}"
        fi
    else
        echo -e "${CYAN}Yay is not installed. Skipping yay update.${RESET}"
    fi

    # Check if paru is installed and update all AUR packages
    if command -v paru &> /dev/null; then
        echo -e "${YELLOW}Updating AUR packages using paru...${RESET}"
        if paru -Syu --noconfirm; then
            echo -e "${GREEN}Paru update completed successfully.${RESET}"
        else
            echo -e "${RED}Paru update failed. Please check for issues.${RESET}"
        fi
    else
        echo -e "${CYAN}Paru is not installed. Skipping paru update.${RESET}"
    fi

    echo -e "${GREEN}AUR update process finished.${RESET}"
}

update_flatpak() {
    echo -e "${YELLOW}Updating Flatpak packages...${RESET}"
    if flatpak update -y; then
        echo -e "${GREEN}Flatpak packages updated successfully.${RESET}"
    else
        echo -e "${RED}Flatpak update failed. Please check for issues.${RESET}"
    fi
}

disable_unused_services() {
    echo -e "${YELLOW}Listing running but disabled services...${RESET}"
    unused_services=$(systemctl list-units --type=service --state=running --no-pager | grep "loaded inactive" | awk '{print $1}')

    if [ -z "$unused_services" ]; then
        echo -e "${GREEN}No unnecessary running services found.${RESET}"
        return
    fi

    echo -e "${CYAN}The following services are running but disabled:${RESET}"
    echo "$unused_services"
    echo -ne "${YELLOW}Would you like to disable them? (y/N): ${RESET}"
    read choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        echo "$unused_services" | xargs sudo systemctl disable --now
        echo -e "${GREEN}Unused services disabled.${RESET}"
    else
        echo -e "${CYAN}No changes made.${RESET}"
    fi
}


# 🔹 Interactive menu
while true; do
    echo -e "${CYAN}Arch Linux Maintenance Menu:${RESET}"
    echo "1) Full Cleanup (Recommended)"
    echo -e "$SEPARATOR"
    echo "2) Clear user cache"
    echo "3) Repair missing or broken packages"
    echo "4) Delete downloads older than 30 days"
    echo "5) Update AUR Packages (yay/paru)"
    echo "6) Update Flatpak Packages"
    echo "7) Disable Unused Services"
    echo "0) Exit"
    echo -n -e "${YELLOW}Select an option: ${RESET}"
    read choice

    case $choice in
        1) full_cleanup ;;
        2) clear_user_cache ;;
        3) repair_packages ;;
        4) delete_old_downloads ;;
        5) update_aur_helpers ;;
        6) update_flatpak ;;
        7) disable_unused_services ;;
        0) echo -e "${GREEN}Exiting...${RESET}"; exit ;;
        *) echo -e "${RED}Invalid option!${RESET}" ;;
    esac
    echo -e "$SEPARATOR"
done
