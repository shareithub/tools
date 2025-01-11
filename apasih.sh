#!/bin/bash

# Warna untuk membuat tampilan lebih menarik
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'  # Reset ke warna normal

# ASCII Art
echo -e "${CYAN}
███████╗██╗  ██╗ █████╗ ██████╗ ███████╗    ██╗████████╗    ██╗  ██╗██╗   ██╗██████╗ 
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝    ██║╚══██╔══╝    ██║  ██║██║   ██║██╔══██╗
███████╗███████║███████║██████╔╝█████╗      ██║   ██║       ███████║██║   ██║██████╔╝
╚════██║██╔══██║██╔══██║██╔══██╗██╔══╝      ██║   ██║       ██╔══██║██║   ██║██╔══██╗
███████║██║  ██║██║  ██║██║  ██║███████╗    ██║   ██║       ██║  ██║╚██████╔╝██████╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝    ╚═╝   ╚═╝       ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
${NC}"

# Pesan intro
echo -e "${CYAN}
𝘋𝘰𝘯'𝘵 𝘧𝘰𝘳𝘨𝘦𝘵 𝘵𝘰 𝘫𝘰𝘪𝘯 𝘰𝘶𝘳 𝘰𝘧𝘧𝘪𝘤𝘪𝘢𝘭 𝘤𝘩𝘢𝘯𝘯𝘦𝘭:
Telegram : https://t.me/SHAREITHUB_COM
Facebook : https://www.facebook.com/shareithub
Youtube : https://www.youtube.com/@SHAREITHUB_COM
Repo Github : https://github.com/shareithub/

${NC}"

# Fungsi untuk memeriksa dan menginstal paket di Ubuntu
install_packages_ubuntu() {
    echo -e "${CYAN}Mengupdate dan meng-upgrade sistem di Ubuntu...${NC}"
    sudo apt update && sudo apt upgrade -y

    # Memeriksa dan menginstal git, python3-pip, python3-venv
    for package in git python3-pip python3-venv; do
        if ! dpkg -l | grep -q "$package"; then
            echo -e "${YELLOW}$package tidak ditemukan. Menginstal...${NC}"
            sudo apt install -y $package
        else
            echo -e "${GREEN}$package sudah terinstal. Memperbarui...${NC}"
            sudo apt install --only-upgrade -y $package
        fi
    done

    echo -e "${GREEN}Semua paket berhasil diinstal atau diperbarui di Ubuntu!${NC}"
}

# Fungsi untuk memeriksa dan menginstal paket di Termux
install_packages_termux() {
    echo -e "${CYAN}Mengupdate dan meng-upgrade sistem di Termux...${NC}"
    pkg update && pkg upgrade -y

    # Memeriksa dan menginstal git, python3-pip
    for package in git python3 python3-pip; do
        if ! pkg list-installed | grep -q "$package"; then
            echo -e "${YELLOW}$package tidak ditemukan. Menginstal...${NC}"
            pkg install -y $package
        else
            echo -e "${GREEN}$package sudah terinstal. Memperbarui...${NC}"
            pkg upgrade $package -y
        fi
    done

    echo -e "${GREEN}Semua paket berhasil diinstal atau diperbarui di Termux!${NC}"
}

# Fungsi untuk memeriksa apakah pengguna ingin melanjutkan instalasi
ask_install() {
    echo -e "${CYAN}Daftar paket yang akan diinstal:${NC}"
    
    # Tentukan daftar paket yang akan diinstal
    packages_to_install=("git" "python3-pip" "python3-venv")
    
    for package in "${packages_to_install[@]}"; do
        echo "  - $package"
    done
    
    read -p "Apakah Anda ingin melanjutkan instalasi paket? (y/n): " install_choice
    if [[ "$install_choice" != "y" ]]; then
        echo -e "${YELLOW}Instalasi dibatalkan. Melewati langkah instalasi.${NC}"
        return 1  # Mengembalikan 1 sebagai tanda bahwa instalasi dibatalkan
    fi
    return 0  # Instalasi dilanjutkan
}

# Fungsi untuk meng-clone repository Git
git_clone() {
    echo -e "${CYAN}Apakah Anda ingin meng-clone repository Git?${NC}"
    read -p "(y/n): " clone_repo
    if [[ "$clone_repo" == "y" ]]; then
        read -p "Masukkan URL repository Git yang ingin Anda clone: " repo_url
        read -p "Masukkan direktori tujuan untuk clone (default: direktori saat ini): " destination_dir
        destination_dir=${destination_dir:-.}  # Default ke direktori saat ini

        echo -e "${CYAN}Meng-clone repository dari $repo_url ke $destination_dir...${NC}"
        git clone "$repo_url" "$destination_dir" || { echo -e "${RED}Gagal meng-clone repository!${NC}"; exit 1; }
        echo -e "${GREEN}Repository berhasil di-clone ke $destination_dir!${NC}"
    else
        echo -e "${YELLOW}Tidak meng-clone repository.${NC}"
    fi
}

# Fungsi untuk membuat virtual environment (venv)
create_venv() {
    echo -e "${CYAN}Apakah Anda ingin membuat virtual environment (venv)?${NC}"
    read -p "(y/n): " create_venv_choice
    if [[ "$create_venv_choice" == "y" ]]; then
        if [[ -n "$1" ]]; then
            venv_path="$1/venv"
        else
            venv_path="venv"
        fi

        echo -e "${CYAN}Membuat virtual environment di $venv_path...${NC}"
        python3 -m venv "$venv_path" || { echo -e "${RED}Gagal membuat virtual environment!${NC}"; exit 1; }
        echo -e "${GREEN}Virtual environment berhasil dibuat di $venv_path!${NC}"
    else
        echo -e "${YELLOW}Tidak membuat virtual environment.${NC}"
    fi
}

# Fungsi untuk menginstal modul-modul dari requirements.txt
install_requirements() {
    if [[ -f "$1/requirements.txt" ]]; then
        echo -e "${CYAN}Menginstal modul-modul dari $1/requirements.txt...${NC}"
        source "$2/bin/activate" && pip install -r "$1/requirements.txt" || { echo -e "${RED}Gagal menginstal modul-modul!${NC}"; exit 1; }
        echo -e "${GREEN}Semua modul dari requirements.txt berhasil diinstal!${NC}"
    else
        echo -e "${YELLOW}Tidak ditemukan file requirements.txt di $1.${NC}"
    fi
}

# Fungsi untuk menampilkan isi folder yang di-clone
display_cloned_files() {
    echo -e "${CYAN}Isi folder yang telah di-clone:${NC}"
    for file in "$1"/*; do
        echo "  $(basename "$file")"
    done
}

# Fungsi untuk menampilkan cara masuk ke folder yang di-clone dan venv
show_info() {
    echo -e "${CYAN}Untuk mengaktifkan virtual environment, jalankan perintah berikut:${NC}"
    echo "  source $1/bin/activate"

    echo -e "${CYAN}Untuk masuk ke folder hasil clone, gunakan perintah:${NC}"
    echo "  cd $2"
}

# Fungsi utama
main() {
    echo -e "${CYAN}Pilih platform instalasi:${NC}"
    echo "1. Ubuntu"
    echo "2. Termux"
    read -p "Masukkan pilihan Anda (1/2): " choice

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
            echo -e "${RED}Pilihan tidak valid. Silakan pilih 1 atau 2.${NC}"
            exit 1
            ;;
    esac

    # Meng-clone repository
    git_clone

    # Membuat venv jika diperlukan
    if [[ -d "$destination_dir" ]]; then
        create_venv "$destination_dir"
    else
        create_venv
    fi

    # Menginstal requirements.txt jika ada
    if [[ -d "$destination_dir" && -f "$destination_dir/requirements.txt" ]]; then
        install_requirements "$destination_dir" "$venv_path"
    fi

    # Menampilkan isi folder yang di-clone
    if [[ -d "$destination_dir" ]]; then
        display_cloned_files "$destination_dir"
    fi

    # Menampilkan cara mengaktifkan venv dan masuk ke folder
    show_info "$venv_path" "$destination_dir"
}

# Menjalankan fungsi utama
main
