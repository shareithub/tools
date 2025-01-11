#!/bin/bash

# Fungsi untuk memeriksa dan menginstal paket di Ubuntu
install_packages_ubuntu() {
    echo "Mengupdate dan meng-upgrade sistem di Ubuntu..."
    sudo apt update && sudo apt upgrade -y

    # Memeriksa dan menginstal git, python3-pip, python3-venv
    for package in git python3-pip python3-venv; do
        if ! dpkg -l | grep -q "$package"; then
            echo "$package tidak ditemukan. Menginstal..."
            sudo apt install -y $package
        else
            echo "$package sudah terinstal. Memperbarui..."
            sudo apt install --only-upgrade -y $package
        fi
    done

    echo "Semua paket berhasil diinstal atau diperbarui di Ubuntu!"
}

# Fungsi untuk memeriksa dan menginstal paket di Termux
install_packages_termux() {
    echo "Mengupdate dan meng-upgrade sistem di Termux..."
    pkg update && pkg upgrade -y

    # Memeriksa dan menginstal git, python3-pip
    for package in git python3 python3-pip; do
        if ! pkg list-installed | grep -q "$package"; then
            echo "$package tidak ditemukan. Menginstal..."
            pkg install -y $package
        else
            echo "$package sudah terinstal. Memperbarui..."
            pkg upgrade $package -y
        fi
    done

    echo "Semua paket berhasil diinstal atau diperbarui di Termux!"
}

# Fungsi untuk meng-clone repository Git
git_clone() {
    read -p "Apakah Anda ingin meng-clone repository Git? (y/n): " clone_repo
    if [[ "$clone_repo" == "y" ]]; then
        read -p "Masukkan URL repository Git yang ingin Anda clone: " repo_url
        read -p "Masukkan direktori tujuan untuk clone (default: direktori saat ini): " destination_dir
        destination_dir=${destination_dir:-.}  # Default ke direktori saat ini

        echo "Meng-clone repository dari $repo_url ke $destination_dir..."
        git clone "$repo_url" "$destination_dir" || { echo "Gagal meng-clone repository!"; exit 1; }
        echo "Repository berhasil di-clone ke $destination_dir!"
    else
        echo "Tidak meng-clone repository."
    fi
}

# Fungsi untuk membuat virtual environment (venv)
create_venv() {
    read -p "Apakah Anda ingin membuat virtual environment (venv)? (y/n): " create_venv_choice
    if [[ "$create_venv_choice" == "y" ]]; then
        if [[ -n "$1" ]]; then
            venv_path="$1/venv"
        else
            venv_path="venv"
        fi

        echo "Membuat virtual environment di $venv_path..."
        python3 -m venv "$venv_path" || { echo "Gagal membuat virtual environment!"; exit 1; }
        echo "Virtual environment berhasil dibuat di $venv_path!"
    else
        echo "Tidak membuat virtual environment."
    fi
}

# Fungsi untuk menginstal modul-modul dari requirements.txt
install_requirements() {
    if [[ -f "$1/requirements.txt" ]]; then
        echo "Menginstal modul-modul dari $1/requirements.txt..."
        source "$2/bin/activate" && pip install -r "$1/requirements.txt" || { echo "Gagal menginstal modul-modul!"; exit 1; }
        echo "Semua modul dari requirements.txt berhasil diinstal!"
    else
        echo "Tidak ditemukan file requirements.txt di $1."
    fi
}

# Fungsi untuk menampilkan isi folder yang di-clone
display_cloned_files() {
    echo "Isi folder yang telah di-clone:"
    for file in "$1"/*; do
        echo "  $(basename "$file")"
    done
}

# Fungsi untuk menampilkan cara masuk ke folder yang di-clone dan venv
show_info() {
    echo "Untuk mengaktifkan virtual environment, jalankan perintah berikut:"
    echo "  source $1/bin/activate"

    echo "Untuk masuk ke folder hasil clone, gunakan perintah:"
    echo "  cd $2"
}

# Fungsi utama
main() {
    echo "Pilih platform instalasi:"
    echo "1. Ubuntu"
    echo "2. Termux"
    read -p "Masukkan pilihan Anda (1/2): " choice

    case "$choice" in
        1)
            install_packages_ubuntu
            ;;
        2)
            install_packages_termux
            ;;
        *)
            echo "Pilihan tidak valid. Silakan pilih 1 atau 2."
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
