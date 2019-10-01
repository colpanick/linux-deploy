#!/bin/bash

# Get list of packages to install
cpkgs=$(cat ../common_pkgs | tr "\n" " ")
if [ -f common_pkgs ] then
    apkgs=$(cat ../common_pkgs | tr "\n" " ")
else
    apkgs=""
fi

# Install packages
pacman --noconfirm -S $cpkgs $apkgs
