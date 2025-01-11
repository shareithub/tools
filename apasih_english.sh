#!/bin/bash

# Colors to make the display more attractive
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'  # Reset to normal color

# ASCII Art
echo -e "${CYAN}
███████╗██╗  ██╗ █████╗ ██████╗ ███████╗    ██╗████████╗    ██╗  ██╗██╗   ██╗██████╗ 
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝    ██║╚══██╔══╝    ██║  ██║██║   ██║██╔══██╗
███████╗███████║███████║██████╔╝█████╗      ██║   ██║       ███████║██║   ██║██████╔╝
╚════██║██╔══██║██╔══██║██╔══██╗██╔══╝      ██║   ██║       ██╔══██║██║   ██║██╔══██╗
███████║██║  ██║██║  ██║██║  ██║███████╗    ██║   ██║       ██║  ██║╚██████╔╝██████╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝    ╚═╝   ╚═╝       ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
${NC}"

# Intro message
echo -e "${CYAN}
𝘋𝘰𝘯'𝘵 𝘧𝘰𝘳𝘨𝘦𝘵 𝘵𝘰 𝘫𝘰𝘪𝘯 𝘰𝘶𝘳 𝘰𝘧𝘧𝘪𝘤𝘪𝘢𝘭 𝘤𝘩𝘢𝘯𝘯𝘦𝘭:
Telegram : https://t.me/SHAREITHUB_COM
Facebook : https://www.facebook.com/shareithub
Youtube : https://www.youtube.com/@SHAREITHUB_COM
Github Repo : https://github.com/shareithub/

${NC}"

# Function to check and install packages on Ubuntu
install_packages_ubuntu() {
    echo -e "${CYAN}Updating and upgrading system on Ubuntu...${NC}"
    sudo apt update && sudo apt upgrade -y

    # Check and install git, python3-pip, python3-venv
    for package in git python3-pip python3-venv; do
        if ! dpkg -l | grep -q "$package"; then
            echo -e "${YELLOW}$package not found. Installing...${NC}"
            sudo apt install -y $package
        else
            echo -e "${GREEN}$package already installed. Updating...${NC}"
            sudo apt install --only-upgrade -y $package
        fi
    done

    echo -e "${GREEN}All packages successfully installed or updated on Ubuntu!${NC}"
}

# Function to check and install packages on Termux
install_packages_termux() {
    echo -e "${CYAN}Updating and upgrading system on Termux...${NC}"
    pkg update && pkg upgrade -y

    # Check and install git, python3-pip
    for package in git python3 python3-pip; do
        if ! pkg list-installed | grep -q "$package"; then
            echo -e "${YELLOW}$package not found. Installing...${NC}"
            pkg install -y $package
        else
            echo -e "${GREEN}$package already installed. Updating...${NC}"
            pkg upgrade $package -y
        fi
    done

    echo -e "${GREEN}All packages successfully installed or updated on Termux!${NC}"
}

# Function to check if the user wants to continue with the installation
ask_install() {
    echo -e "${CYAN}List of packages to be installed:${NC}"
    
    # Define the list of packages to install
    packages_to_install=("git" "python3-pip" "python3-venv")
    
    for package in "${packages_to_install[@]}"; do
        echo "  - $package"
    done
    
    read -p "Do you want to continue with the package installation? (y/n): " install_choice
    if [[ "$install_choice" != "y" ]]; then
        echo -e "${YELLOW}Installation cancelled. Skipping installation step.${NC}"
        return 1  # Return 1 to indicate installation was cancelled
    fi
    return 0  # Continue installation
}

# Function to clone a Git repository
git_clone() {
    echo -e "${CYAN}Do you want to clone a Git repository?${NC}"
    read -p "(y/n): " clone_repo
    if [[ "$clone_repo" == "y" ]]; then
        read -p "Enter the URL of the Git repository you want to clone: " repo_url
        read -p "Enter the destination directory for the clone (default: current directory): " destination_dir
        destination_dir=${destination_dir:-.}  # Default to the current directory

        echo -e "${CYAN}Cloning repository from $repo_url to $destination_dir...${NC}"
        git clone "$repo_url" "$destination_dir" || { echo -e "${RED}Failed to clone the repository!${NC}"; exit 1; }
        echo -e "${GREEN}Repository successfully cloned to $destination_dir!${NC}"
    else
        echo -e "${YELLOW}Did not clone the repository.${NC}"
    fi
}

# Function to create a virtual environment (venv)
create_venv() {
    echo -e "${CYAN}Do you want to create a virtual environment (venv)?${NC}"
    read -p "(y/n): " create_venv_choice
    if [[ "$create_venv_choice" == "y" ]]; then
        if [[ -n "$1" ]]; then
            venv_path="$1/venv"
        else
            venv_path="venv"
        fi

        echo -e "${CYAN}Creating virtual environment in $venv_path...${NC}"
        python3 -m venv "$venv_path" || { echo -e "${RED}Failed to create virtual environment!${NC}"; exit 1; }
        echo -e "${GREEN}Virtual environment successfully created in $venv_path!${NC}"
    else
        echo -e "${YELLOW}Did not create virtual environment.${NC}"
    fi
}

# Function to install modules from requirements.txt
install_requirements() {
    if [[ -f "$1/requirements.txt" ]]; then
        echo -e "${CYAN}Installing modules from $1/requirements.txt...${NC}"
        source "$2/bin/activate" && pip install -r "$1/requirements.txt" || { echo -e "${RED}Failed to install modules!${NC}"; exit 1; }
        echo -e "${GREEN}All modules from requirements.txt successfully installed!${NC}"
    else
        echo -e "${YELLOW}No requirements.txt found in $1.${NC}"
    fi
}

# Function to display the contents of the cloned folder
display_cloned_files() {
    echo -e "${CYAN}Contents of the cloned folder:${NC}"
    for file in "$1"/*; do
        echo "  $(basename "$file")"
    done
}

# Function to display how to enter the cloned folder and venv
show_info() {
    echo -e "${CYAN}To activate the virtual environment, run the following command:${NC}"
    echo "  source $1/bin/activate"

    echo -e "${CYAN}To enter the cloned folder, use the following command:${NC}"
    echo "  cd $2"
}

# Main function
main() {
    echo -e "${CYAN}Select the installation platform:${NC}"
    echo "1. Ubuntu"
    echo "2. Termux"
    read -p "Enter your choice (1/2): " choice

    case "$choice" in
        1)
            if ask_install; then
                install_packages_ubuntu
            fi
            ;;
        2)
            if ask_install; then
                install_packages_termux
            fi
            ;;
        *)
            echo -e "${RED}Invalid choice. Please select 1 or 2.${NC}"
            exit 1
            ;;
    esac

    # Clone the repository
    git_clone

    # Create venv if needed
    if [[ -d "$destination_dir" ]]; then
        create_venv "$destination_dir"
    else
        create_venv
    fi

    # Install requirements.txt if available
    if [[ -d "$destination_dir" && -f "$destination_dir/requirements.txt" ]]; then
        install_requirements "$destination_dir" "$venv_path"
    fi

    # Display contents of the cloned folder
    if [[ -d "$destination_dir" ]]; then
        display_cloned_files "$destination_dir"
    fi

    # Show how to activate the venv and enter the folder
    show_info "$venv_path" "$destination_dir"
}

# Run the main function
main
