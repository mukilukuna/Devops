#!/bin/bash

# Functie om het pakket te downloaden en te installeren
install_pkg() {
    local pkg_url="$1"
    local pkg_name="$2"
    local temp_dir="/tmp/pkg_install"

    # Maak een tijdelijke directory aan
    mkdir -p "$temp_dir"
    cd "$temp_dir" || { echo "Kan niet naar $temp_dir navigeren"; exit 1; }

    # Download het pakket
    echo "Downloaden van $pkg_name van $pkg_url..."
    curl -L -o "$pkg_name" "$pkg_url"
    if [ $? -ne 0 ]; then
        echo "Fout bij het downloaden van $pkg_name"
        exit 1
    fi

    # Installeer het pakket
    echo "Installeren van $pkg_name..."
    sudo installer -pkg "$pkg_name" -target /
    if [ $? -ne 0 ]; then
        echo "Fout bij het installeren van $pkg_name"
        exit 1
    fi

    # Verwijder de tijdelijke directory
    cd /
    rm -rf "$temp_dir"

    echo "$pkg_name is succesvol geïnstalleerd."
}

# Variabelen voor het pakket
PKG_URL="https://voorbeeld.com/pad/naar/pakket.pkg"  # Vervang dit door de daadwerkelijke URL
PKG_NAME="pakket.pkg"  # Vervang dit door de daadwerkelijke bestandsnaam

# Voer de installatiefunctie uit
install_pkg "$PKG_URL" "$PKG_NAME"
